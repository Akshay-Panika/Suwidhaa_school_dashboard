// lib/feature/school_type/controller/school_type_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../model/school_type_model.dart';
import '../repository/school_type_repository.dart';

class SchoolTypeController extends GetxController {
  final SchoolTypeRepository _repository = SchoolTypeRepository();

  // ---------- Observable state ----------
  final schoolTypes = <SchoolTypeModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final selectedSchoolType = Rxn<SchoolTypeModel>();

  // ---------- Form controllers ----------
  final schoolNameController = TextEditingController();
  final schoolCodeController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final boardController = TextEditingController();
  final schoolTypeController = TextEditingController(); // e.g. "Nursery to 8"

  @override
  void onInit() {
    super.onInit();
    fetchSchoolTypes();
  }

  @override
  void onClose() {
    schoolNameController.dispose();
    schoolCodeController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
    boardController.dispose();
    schoolTypeController.dispose();
    super.onClose();
  }

  // ---------- FETCH ----------
  Future<void> fetchSchoolTypes({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      final result = await _repository.getSchoolTypes();
      schoolTypes.assignAll(result);
    } catch (e) {
      FlutterToast.error('Failed to fetch school types: $e');
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  // ---------- CREATE ----------
  Future<void> createSchoolType() async {
    if (!_validateForm()) return;

    try {
      isSubmitting.value = true;

      final school = SchoolTypeModel(
        schoolName: schoolNameController.text.trim(),
        schoolCode: schoolCodeController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        pincode: pincodeController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        website: websiteController.text.trim(),
        board: boardController.text.trim(),
        schoolType: schoolTypeController.text.trim(),
      );

      final created = await _repository.createSchoolType(school);

      schoolTypes.insert(0, created);
      _clearForm();

      FlutterToast.success('School type created successfully');
      Get.back();
    } catch (e) {
      FlutterToast.error('Failed to create school type: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ---------- UPDATE ----------
  Future<void> updateSchoolType(int id) async {
    if (!_validateForm()) return;

    try {
      isSubmitting.value = true;

      final school = SchoolTypeModel(
        schoolName: schoolNameController.text.trim(),
        schoolCode: schoolCodeController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        pincode: pincodeController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        website: websiteController.text.trim(),
        board: boardController.text.trim(),
        schoolType: schoolTypeController.text.trim(),
      );

      final updated = await _repository.updateSchoolType(id: id, school: school);

      final index = schoolTypes.indexWhere((s) => s.id == id);
      if (index != -1) {
        schoolTypes[index] = updated;
      }

      _clearForm();

      FlutterToast.success('School type updated successfully');
      Get.back();
    } catch (e) {
      FlutterToast.error('Failed to update school type: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ---------- DELETE ----------
  Future<void> deleteSchoolType(int id) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete School Type'),
          content: const Text('Are you sure you want to delete this school type?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isLoading.value = true;
        final success = await _repository.deleteSchoolType(id);
        if (success) {
          schoolTypes.removeWhere((s) => s.id == id);
          FlutterToast.success('School type deleted successfully');
        }
      }
    } catch (e) {
      FlutterToast.error('Failed to delete school type: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------- EDIT ----------
  void setSchoolTypeForEdit(SchoolTypeModel school) {
    selectedSchoolType.value = school;

    schoolNameController.text = school.schoolName;
    schoolCodeController.text = school.schoolCode;
    addressController.text = school.address ?? '';
    cityController.text = school.city ?? '';
    stateController.text = school.state ?? '';
    pincodeController.text = school.pincode ?? '';
    phoneController.text = school.phone ?? '';
    emailController.text = school.email ?? '';
    websiteController.text = school.website ?? '';
    boardController.text = school.board ?? '';
    schoolTypeController.text = school.schoolType ?? '';
  }

  // ---------- RESET ----------
  void _clearForm() {
    schoolNameController.clear();
    schoolCodeController.clear();
    addressController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    phoneController.clear();
    emailController.clear();
    websiteController.clear();
    boardController.clear();
    schoolTypeController.clear();
    selectedSchoolType.value = null;
  }

  // ---------- VALIDATION ----------
  bool _validateForm() {
    if (schoolNameController.text.trim().isEmpty) {
      FlutterToast.warning('School name is required');
      return false;
    }
    if (schoolCodeController.text.trim().isEmpty) {
      FlutterToast.warning('School code is required');
      return false;
    }
    return true;
  }
}