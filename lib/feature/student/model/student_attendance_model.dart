// lib/feature/student_attendance/model/student_attendance_model.dart

class StudentAttendanceModel {
  final int? id;
  final String date;
  final String dayName;
  final String month;
  final int year;
  final String attendanceStatus;
  final String remarks;
  final String? createdAt;
  final String? updatedAt;

  StudentAttendanceModel({
    this.id,
    required this.date,
    required this.dayName,
    required this.month,
    required this.year,
    required this.attendanceStatus,
    required this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentAttendanceModel.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceModel(
      id: json['id'] as int?,
      date: json['date']?.toString() ?? '',
      dayName: json['day_name']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      attendanceStatus: json['attendance_status']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'day_name': dayName,
    'month': month,
    'year': year,
    'attendance_status': attendanceStatus,
    'remarks': remarks,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  StudentAttendanceModel copyWith({
    int? id,
    String? date,
    String? dayName,
    String? month,
    int? year,
    String? attendanceStatus,
    String? remarks,
    String? createdAt,
    String? updatedAt,
  }) {
    return StudentAttendanceModel(
      id: id ?? this.id,
      date: date ?? this.date,
      dayName: dayName ?? this.dayName,
      month: month ?? this.month,
      year: year ?? this.year,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() =>
      'StudentAttendanceModel(id: $id, date: $date, status: $attendanceStatus)';
}

class StudentAttendanceHistoryResponse {
  final bool status;
  final Map<String, dynamic>? student;
  final int totalRecords;
  final Map<String, Map<String, List<StudentAttendanceModel>>> history;

  StudentAttendanceHistoryResponse({
    required this.status,
    this.student,
    required this.totalRecords,
    required this.history,
  });

  factory StudentAttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'] as Map<String, dynamic>? ?? {};
    final parsedHistory = <String, Map<String, List<StudentAttendanceModel>>>{};

    rawHistory.forEach((year, months) {
      final monthMap = <String, List<StudentAttendanceModel>>{};
      if (months is Map<String, dynamic>) {
        months.forEach((month, list) {
          if (list is List) {
            monthMap[month] = list
                .whereType<Map<String, dynamic>>()
                .map((e) => StudentAttendanceModel.fromJson(e))
                .toList();
          }
        });
      }
      parsedHistory[year] = monthMap;
    });

    return StudentAttendanceHistoryResponse(
      status: json['status'] as bool? ?? false,
      student: json['student'] is Map<String, dynamic>
          ? json['student'] as Map<String, dynamic>
          : null,
      totalRecords: (json['total_records'] as num?)?.toInt() ?? 0,
      history: parsedHistory,
    );
  }

  List<StudentAttendanceModel> get allRecords {
    final list = <StudentAttendanceModel>[];
    history.forEach((year, months) {
      months.forEach((month, days) {
        list.addAll(days);
      });
    });
    return list;
  }

  /// Distinct attendance statuses observed in backend history.
  /// Used to build the UI filter chips — no hardcoded values.
  List<String> get availableStatuses {
    final set = <String>{};
    for (final rec in allRecords) {
      if (rec.attendanceStatus.isNotEmpty) {
        set.add(rec.attendanceStatus);
      }
    }
    return set.toList();
  }

  /// Distinct years in history (as ints), sorted ascending.
  List<int> get availableYears {
    final set = <int>{};
    for (final y in history.keys) {
      final parsed = int.tryParse(y);
      if (parsed != null) set.add(parsed);
    }
    final list = set.toList()..sort();
    return list;
  }

  /// Distinct month names for a given year, in backend order.
  List<String> monthsForYear(int year) {
    return history[year.toString()]?.keys.toList() ?? [];
  }

  /// Latest (year, month) in history. Used to auto-select the calendar month.
  ({int year, int month})? get latestYearMonth {
    int? latestYear;
    int? latestMonth;
    history.forEach((yearStr, months) {
      final y = int.tryParse(yearStr);
      if (y == null) return;
      months.forEach((monthName, _) {
        final m = _monthNumFromName(monthName);
        if (m == null) return;
        if (latestYear == null ||
            y > latestYear! ||
            (y == latestYear! && m > latestMonth!)) {
          latestYear = y;
          latestMonth = m;
        }
      });
    });
    if (latestYear == null || latestMonth == null) return null;
    return (year: latestYear!, month: latestMonth!);
  }

  static int? _monthNumFromName(String name) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    final idx = months.indexOf(name);
    return idx >= 0 ? idx + 1 : null;
  }

  @override
  String toString() =>
      'StudentAttendanceHistoryResponse(total: $totalRecords, years: ${history.keys.toList()})';
}