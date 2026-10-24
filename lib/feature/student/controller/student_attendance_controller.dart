// lib/feature/student_attendance/controller/student_attendance_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../model/student_attendance_model.dart';
import '../repository/student_attendance_repository.dart';

class StudentAttendanceController extends GetxController {
  final StudentAttendanceRepository _repo = StudentAttendanceRepository();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  final Rx<DateTime> currentMonth = DateTime.now().obs;
  final RxList<StudentAttendanceModel> records = <StudentAttendanceModel>[].obs;
  final RxMap<String, StudentAttendanceModel> recordsByDate =
      <String, StudentAttendanceModel>{}.obs;
  final RxList<String> availableStatuses = <String>[].obs;
  final RxMap<int, String> studentStatusMap = <int, String>{}.obs;

  // Today's attendance — single-slot (used by the open right panel)
  final RxBool isLoadingToday = false.obs;
  final Rx<TodayAttendanceResponse?> todayAttendance =
  Rx<TodayAttendanceResponse?>(null);

  // ✅ NEW: per-student today cache (used by list rows)
  final RxMap<int, TodayAttendanceResponse?> todayByStudent =
      <int, TodayAttendanceResponse?>{}.obs;
  final RxSet<int> todayLoadingFor = <int>{}.obs;

  int? _currentStudentId;

  int get currentYear => currentMonth.value.year;
  String get currentMonthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[currentMonth.value.month - 1];
  }

  bool get canGoNext {
    final now = DateTime.now();
    return currentMonth.value.year < now.year ||
        (currentMonth.value.year == now.year &&
            currentMonth.value.month < now.month);
  }

  Future<void> loadHistory(int studentId) async {
    _currentStudentId = studentId;
    isLoading.value = true;
    try {
      final res = await _repo.getHistory(studentId);

      records.assignAll(res.allRecords);
      recordsByDate.clear();
      for (final rec in res.allRecords) {
        recordsByDate[rec.date] = rec;
      }

      availableStatuses.assignAll(res.availableStatuses);

      final latest = res.latestYearMonth;
      if (latest != null) {
        currentMonth.value = DateTime(latest.year, latest.month, 1);
      } else {
        final now = DateTime.now();
        currentMonth.value = DateTime(now.year, now.month, 1);
      }
    } catch (e) {
      FlutterToast.error('Failed to load attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<TodayAttendanceResponse?> loadTodayAttendance(int studentId) async {
    _currentStudentId = studentId;
    isLoadingToday.value = true;
    try {
      final res = await _repo.getTodayAttendance(studentId);
      todayAttendance.value = res;
      // Keep the per-student map in sync too
      todayByStudent[studentId] = res;
      return res;
    } catch (e) {
      FlutterToast.error('Failed to load today\'s attendance: $e');
      todayAttendance.value = null;
      return null;
    } finally {
      isLoadingToday.value = false;
    }
  }

  /// ✅ NEW: fetch today's status for ONE student (used by list rows).
  /// Idempotent — safe to call on every build; only hits the API once.
  Future<TodayAttendanceResponse?> loadTodayForStudent(
      int studentId, {
        bool force = false,
      }) async {
    if (!force && todayByStudent.containsKey(studentId)) {
      return todayByStudent[studentId];
    }
    if (todayLoadingFor.contains(studentId)) {
      return todayByStudent[studentId];
    }

    todayLoadingFor.add(studentId);
    try {
      final res = await _repo.getTodayAttendance(studentId);
      todayByStudent[studentId] = res;
      // If this is the currently selected student, also update the slot
      if (_currentStudentId == studentId) {
        todayAttendance.value = res;
      }
      return res;
    } catch (_) {
      todayByStudent[studentId] = null;
      return null;
    } finally {
      todayLoadingFor.remove(studentId);
    }
  }

  /// ✅ NEW: human-friendly status for a given student's today.
  /// - ''          → still loading (show spinner)
  /// - 'Not marked' → no record for today
  /// - 'present' / 'absent' / 'leave' → actual status
  String todayStatusFor(int studentId) {
    if (todayLoadingFor.contains(studentId) &&
        !todayByStudent.containsKey(studentId)) {
      return '';
    }
    final res = todayByStudent[studentId];
    if (res == null || !res.hasAttendance) return 'Not marked';
    return res.attendance!.attendanceStatus;
  }

  void goToPreviousMonth() {
    final m = currentMonth.value;
    currentMonth.value = DateTime(m.year, m.month - 1, 1);
  }

  void goToNextMonth() {
    if (!canGoNext) return;
    final m = currentMonth.value;
    currentMonth.value = DateTime(m.year, m.month + 1, 1);
  }

  Future<bool> saveOrUpdateForDate({
    required String date,
    required String status,
    required String remarks,
  }) async {
    if (_currentStudentId == null) return false;
    isSubmitting.value = true;
    try {
      await _repo.saveAttendance(
        studentId: _currentStudentId!,
        date: date,
        status: status,
        remarks: remarks,
      );
      await loadHistory(_currentStudentId!);
      // Refresh today's status if we just saved for today
      if (date == formatDate(DateTime.now())) {
        await loadTodayAttendance(_currentStudentId!);
        await loadTodayForStudent(_currentStudentId!, force: true);
      }
      FlutterToast.success('Attendance saved');
      return true;
    } catch (e) {
      FlutterToast.error('Save failed: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteForDate(String date) async {
    if (_currentStudentId == null) return false;
    isSubmitting.value = true;
    try {
      await _repo.deleteAttendance(studentId: _currentStudentId!, date: date);
      await loadHistory(_currentStudentId!);
      // Refresh today's status if we just deleted today's record
      if (date == formatDate(DateTime.now())) {
        await loadTodayAttendance(_currentStudentId!);
        await loadTodayForStudent(_currentStudentId!, force: true);
      }
      FlutterToast.success('Attendance deleted');
      return true;
    } catch (e) {
      FlutterToast.error('Delete failed: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  StudentAttendanceModel? getRecordForDate(DateTime d) {
    return recordsByDate[formatDate(d)];
  }

  String formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  String getTodayStatus(int studentId) {
    final rec = getRecordForDate(DateTime.now());
    return rec?.attendanceStatus ?? 'absent';
  }
}