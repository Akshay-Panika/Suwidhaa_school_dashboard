import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../../main/model/school_type_model.dart'; // Ensure path is correct
import '../model/teacher_salary_model.dart';
import '../repository/teacher_salary_repository.dart';

class TeacherSalaryController extends GetxController {
  final TeacherSalaryRepository _repository = TeacherSalaryRepository();

  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var isLoadingHistory = false.obs;

  var salaryList = <TeacherSalaryModel>[].obs;
  var historyList = <SalaryHistoryModel>[].obs;
  var selectedTeacher = Rxn<TeacherSalaryModel>();

  var searchQuery = ''.obs;

  // ✅ Local variable for selected school (Fixes the error)
  var selectedSchool = Rxn<SchoolTypeModel>();

  @override
  void onInit() {
    super.onInit();
    // Jab screen load ho toh list fetch karo
    fetchSalaryList();
  }

  List<TeacherSalaryModel> get filteredList {
    if (searchQuery.value.isEmpty) return salaryList;
    final q = searchQuery.value.toLowerCase();
    return salaryList.where((t) =>
    '${t.firstName} ${t.lastName}'.toLowerCase().contains(q) ||
        (t.teacherIdCard ?? '').toLowerCase().contains(q)
    ).toList();
  }

  Future<void> fetchSalaryList() async {
    try {
      isLoading.value = true;
      final schoolId = selectedSchool.value?.id;
      final data = await _repository.getSalaryList(schoolId: schoolId);
      salaryList.assignAll(data);
    } catch (e) {
      FlutterToast.error(e.toString().replaceAll("Exception: ", ""));
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedSchool(SchoolTypeModel? school) {
    selectedSchool.value = school;
    fetchSalaryList(); // School change hone par list refresh karo
  }

  Future<void> loadHistory(int teacherId) async {
    try {
      isLoadingHistory.value = true;
      final data = await _repository.getTransactionHistory(teacherId);
      historyList.assignAll(data);
    } catch (e) {
      FlutterToast.error(e.toString().replaceAll("Exception: ", ""));
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<bool> addTransaction({
    required int teacherId,
    required double amount,
    required int month,
    required int year,
    String? remarks,
  }) async {
    try {
      isSubmitting.value = true;
      await _repository.createTransaction(
        teacherId: teacherId,
        amountPaid: amount,
        month: month,
        year: year,
        remarks: remarks,
      );
      FlutterToast.success('Transaction added successfully');

      // List aur History refresh karo
      await fetchSalaryList();
      await loadHistory(teacherId);

      final updatedTeacher = salaryList.firstWhereOrNull((t) => t.id == teacherId);
      if (updatedTeacher != null) selectedTeacher.value = updatedTeacher;

      return true;
    } catch (e) {
      FlutterToast.error(e.toString().replaceAll("Exception: ", ""));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteTransaction(int teacherId, int transactionId) async {
    try {
      await _repository.deleteTransaction(teacherId, transactionId);
      FlutterToast.success('Transaction deleted successfully');

      // List aur History refresh karo
      await fetchSalaryList();
      await loadHistory(teacherId);

      final updatedTeacher = salaryList.firstWhereOrNull((t) => t.id == teacherId);
      if (updatedTeacher != null) selectedTeacher.value = updatedTeacher;

    } catch (e) {
      FlutterToast.error(e.toString().replaceAll("Exception: ", ""));
    }
  }
}