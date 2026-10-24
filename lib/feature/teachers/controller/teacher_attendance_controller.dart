import 'package:get/get.dart';
import '../model/teacher_attendance_model.dart';
import '../repository/teacher_attendance_repository.dart';

class TeacherAttendanceController extends GetxController {
  final TeacherAttendanceRepository _repo = TeacherAttendanceRepository();

  var isLoading = false.obs;
  var historyResponse = Rxn<TeacherAttendanceHistoryResponse>();
  var availableStatuses = <String>[].obs;
  var currentMonth = DateTime.now().obs;

  var teacherList = <TeacherListModel>[].obs;
  var teacherStatusMap = <int, String>{}.obs;

  Future<void> fetchAllTeachers() async {
    isLoading.value = true;
    try {
      final list = await _repo.getAllTeachersList();
      teacherList.value = list;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSingleTeacherStatus(int teacherId) async {
    try {
      final res = await _repo.getSingleTeacherStatus(teacherId);
      if (res != null) {
        teacherStatusMap[teacherId] = res.attendanceStatus.todayIs;
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> loadHistory(int teacherId) async {
    isLoading.value = true;
    try {
      final res = await _repo.getHistory(teacherId);
      historyResponse.value = res;
      availableStatuses.value = res.availableStatuses;

      final latest = res.latestYearMonth;
      if (latest != null) {
        currentMonth.value = latest;
      } else {
        currentMonth.value = DateTime.now();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateStatus({
    required int teacherId,
    required String date,
    required String status,
    String? remarks,
  }) async {
    isLoading.value = true;
    try {
      final success = await _repo.updateTeacherStatus(
        teacherId: teacherId,
        date: date,
        status: status,
        remarks: remarks,
      );
      if (success) {
        await loadHistory(teacherId);
        await fetchSingleTeacherStatus(teacherId);
      }
      return success;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteStatus(int attendanceId) async {
    try {
      final success = await _repo.deleteTeacherAttendance(attendanceId);
      return success;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}