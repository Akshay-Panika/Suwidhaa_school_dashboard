// lib/feature/teachers/controller/teacher_controller.dart

import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import '../../../core/widget/flutter_toast.dart';
import '../../main/model/school_type_model.dart';
import '../model/teacher_model.dart';
import '../repository/teacher_repository.dart';

class TeacherController extends GetxController {
  final TeacherRepository _repository = TeacherRepository();

  var teachers = <TeacherModel>[].obs;
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var errorMessage = ''.obs;
  var selectedTeacher = Rx<TeacherModel?>(null);

  final selectedSchool = Rxn<SchoolTypeModel>();

  @override
  void onInit() {
    super.onInit();
    getTeachers();
  }

  Future<void> getTeachers() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getTeachers(
        schoolId: selectedSchool.value?.id,
      );

      if (response.success) {
        teachers.value = response.data;
      } else {
        errorMessage.value = 'Failed to load teachers';
        FlutterToast.error(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      FlutterToast.error(errorMessage.value);
    }

    isLoading.value = false;
  }

  void setSelectedSchool(SchoolTypeModel? school) {
    selectedSchool.value = school;
    getTeachers();
  }

  Future<bool> createTeacher({
    required String firstName,
    required String lastName,
    String? gender,
    String? dob,
    String? phone,
    String? altPhone,
    String? email,
    String? teacherIdCard,
    String? address,
    String? qualification,
    int? experience,
    double? salary,
    String? joinDate,
    bool? checkBox,
    List<String>? subjects,
    File? teacherProfile,
    Uint8List? teacherProfileBytes,
  }) async {
    if (selectedSchool.value == null) {
      FlutterToast.warning('Please select a school first');
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final teacher = TeacherModel(
        schoolId: selectedSchool.value!.id,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dob: dob,
        phone: phone,
        altPhone: altPhone,
        email: email,
        teacherIdCard: teacherIdCard,
        address: address,
        qualification: qualification,
        experience: experience,
        salary: salary != null ? salary.toString() : null,
        joinDate: joinDate,
        checkBox: checkBox ?? false,
        subjects: subjects,
      );

      final response = await _repository.createTeacher(
        teacher: teacher,
        teacherProfile: teacherProfile,
        teacherProfileBytes: teacherProfileBytes,
      );

      if (response.success && response.data != null) {
        if (selectedSchool.value == null || response.data!.schoolId == selectedSchool.value!.id) {
          teachers.insert(0, response.data!);
        }
        FlutterToast.success('Teacher created successfully');
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to create teacher';
        FlutterToast.error(errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      FlutterToast.error(errorMessage.value);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateTeacher({
    required int id,
    required String firstName,
    required String lastName,
    String? gender,
    String? dob,
    String? phone,
    String? altPhone,
    String? email,
    String? teacherIdCard,
    String? address,
    String? qualification,
    int? experience,
    double? salary,
    String? joinDate,
    bool? checkBox,
    List<String>? subjects,
    File? teacherProfile,
    Uint8List? teacherProfileBytes,
  }) async {
    if (selectedSchool.value == null) {
      FlutterToast.warning('Please select a school first');
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      final teacher = TeacherModel(
        schoolId: selectedSchool.value!.id,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dob: dob,
        phone: phone,
        altPhone: altPhone,
        email: email,
        teacherIdCard: teacherIdCard,
        address: address,
        qualification: qualification,
        experience: experience,
        salary: salary != null ? salary.toString() : null,
        joinDate: joinDate,
        checkBox: checkBox ?? false,
        subjects: subjects,
      );

      final response = await _repository.updateTeacher(
        id: id,
        teacher: teacher,
        teacherProfile: teacherProfile,
        teacherProfileBytes: teacherProfileBytes,
      );

      if (response.success && response.data != null) {
        final index = teachers.indexWhere((t) => t.id == id);
        if (index != -1) {
          teachers[index] = response.data!;
        }
        selectedTeacher.value = response.data;
        FlutterToast.success('Teacher updated successfully');
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to update teacher';
        FlutterToast.error(errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      FlutterToast.error(errorMessage.value);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteTeacher(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.deleteTeacher(id);
      if (response['success'] == true) {
        teachers.removeWhere((teacher) => teacher.id == id);
        if (selectedTeacher.value?.id == id) {
          selectedTeacher.value = null;
        }
        FlutterToast.success('Teacher deleted successfully');
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to delete teacher';
        FlutterToast.error(errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      FlutterToast.error(errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void selectTeacher(TeacherModel? teacher) {
    selectedTeacher.value = teacher;
  }
}