// lib/feature/schedule/controller/exam_controller.dart

import 'package:get/get.dart';
import '../model/exam_model.dart';
import '../repository/exam_repository.dart';

class ExamController extends GetxController {
  final ExamRepository _repository = ExamRepository();

  var isLoading = false.obs;
  var exams = <ExamTimetableModel>[].obs;

  Future<void> fetchExams(int schoolId) async {
    try {
      isLoading.value = true;
      final result = await _repository.getExams(schoolId);
      exams.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addExam({
    required int schoolId,
    required String className,
    required String examType,
    required String fromDate,
    required String toDate,
    required List<SubjectScheduleModel> schedules,
  }) async {
    try {
      isLoading.value = true;
      bool success = await _repository.createExam(
        schoolId: schoolId,
        className: className,
        examType: examType,
        fromDate: fromDate,
        toDate: toDate,
        schedules: schedules,
      );
      if (success) {
        await fetchExams(schoolId);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 👇 ADDED UPDATE EXAM
  Future<bool> updateExam({
    required int schoolId,
    required int id,
    required String className,
    required String examType,
    required String fromDate,
    required String toDate,
    required List<SubjectScheduleModel> schedules,
  }) async {
    try {
      isLoading.value = true;
      bool success = await _repository.updateExam(
        schoolId: schoolId,
        id: id,
        className: className,
        examType: examType,
        fromDate: fromDate,
        toDate: toDate,
        schedules: schedules,
      );
      if (success) {
        await fetchExams(schoolId);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteExam({required int schoolId, required int id}) async {
    try {
      isLoading.value = true;
      bool success = await _repository.deleteExam(schoolId: schoolId, id: id);
      if (success) {
        await fetchExams(schoolId);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}