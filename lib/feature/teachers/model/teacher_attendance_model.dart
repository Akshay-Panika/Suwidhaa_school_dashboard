import 'teacher_model.dart';

class TeacherAttendanceModel {
  final int? id;
  final String date;
  final String dayName;
  final String month;
  final int year;
  final String? checkInTime;
  final String? checkOutTime;
  final String status;
  final double workingHours;
  final String remarks;
  final bool isVirtual;

  TeacherAttendanceModel({
    this.id,
    required this.date,
    required this.dayName,
    required this.month,
    required this.year,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.workingHours,
    required this.remarks,
    required this.isVirtual,
  });

  factory TeacherAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceModel(
      id: json['id'],
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
      month: json['month'] ?? '',
      year: json['year'] ?? 0,
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      status: json['status'] ?? 'absent',
      workingHours: (json['working_hours'] ?? 0.0).toDouble(),
      remarks: json['remarks'] ?? '',
      isVirtual: json['is_virtual'] ?? false,
    );
  }
}

class TeacherAttendanceHistoryResponse {
  final bool success;
  final int teacherId;
  final String teacherIdCard;
  final String teacherName;
  final int totalRecords;
  final int realRecords;
  final Map<String, Map<String, List<TeacherAttendanceModel>>> history;
  final List<String> availableStatuses;

  TeacherAttendanceHistoryResponse({
    required this.success,
    required this.teacherId,
    required this.teacherIdCard,
    required this.teacherName,
    required this.totalRecords,
    required this.realRecords,
    required this.history,
    required this.availableStatuses,
  });

  factory TeacherAttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    final historyMap = <String, Map<String, List<TeacherAttendanceModel>>>{};
    final statusesSet = <String>{};

    if (json['history'] != null) {
      final rawHistory = json['history'] as Map<String, dynamic>;
      rawHistory.forEach((year, monthsObj) {
        final monthsMap = <String, List<TeacherAttendanceModel>>{};
        (monthsObj as Map<String, dynamic>).forEach((month, daysList) {
          final list = (daysList as List).map((e) {
            final model = TeacherAttendanceModel.fromJson(e);
            if (model.status.isNotEmpty) statusesSet.add(model.status);
            return model;
          }).toList();
          monthsMap[month] = list;
        });
        historyMap[year] = monthsMap;
      });
    }

    return TeacherAttendanceHistoryResponse(
      success: json['success'] ?? false,
      teacherId: json['teacher_id'] ?? 0,
      teacherIdCard: json['teacher_id_card'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      totalRecords: json['total_records'] ?? 0,
      realRecords: json['real_records'] ?? 0,
      history: historyMap,
      availableStatuses: statusesSet.toList(),
    );
  }

  DateTime? get latestYearMonth {
    if (history.isEmpty) return null;
    final years = history.keys.map(int.parse).toList()..sort();
    final latestYear = years.last.toString();

    const monthsOrder = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final months = history[latestYear]!.keys.toList();
    months.sort((a, b) => monthsOrder.indexOf(b).compareTo(monthsOrder.indexOf(a)));
    final latestMonth = months.first;

    final monthIndex = monthsOrder.indexOf(latestMonth) + 1;
    return DateTime(int.parse(latestYear), monthIndex, 1);
  }
}

class AttendanceStatus {
  final String todayIs;
  final String date;

  AttendanceStatus({
    required this.todayIs,
    required this.date,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceStatus(
      todayIs: json['today_is'] ?? 'absent',
      date: json['date'] ?? '',
    );
  }
}

class TeacherListModel {
  final AttendanceStatus attendanceStatus;
  final TeacherModel teacher;

  TeacherListModel({
    required this.attendanceStatus,
    required this.teacher,
  });

  factory TeacherListModel.fromJson(Map<String, dynamic> json) {
    return TeacherListModel(
      attendanceStatus: AttendanceStatus.fromJson(json['attendance_status'] ?? {}),
      teacher: TeacherModel.fromJson(json['teacher'] ?? {}),
    );
  }
}