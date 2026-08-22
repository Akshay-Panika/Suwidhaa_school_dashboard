import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import '../../../core/widget/flutter_toast.dart';
import '../model/student_model.dart';
import '../repository/student_repository.dart';

class StudentController extends GetxController {
  final StudentRepository _repository = StudentRepository();

  // Observable states
  final students = <StudentModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final selectedStudent = Rxn<StudentModel>();

  // Form controllers
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final alternativePhoneController = TextEditingController();
  final adharNumberController = TextEditingController();
  final sssmidController = TextEditingController();
  final studentClassController = TextEditingController();
  final rollNumberController = TextEditingController();
  final addressController = TextEditingController();
  final casteCategoryController = TextEditingController();
  final feeStatusController = TextEditingController();
  final feeAmountController = TextEditingController();
  final paidAmountController = TextEditingController();

  // File for student profile
  File? studentProfileFile;
  Uint8List? studentProfileBytes; // For Web support

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    genderController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    parentPhoneController.dispose();
    alternativePhoneController.dispose();
    adharNumberController.dispose();
    sssmidController.dispose();
    studentClassController.dispose();
    rollNumberController.dispose();
    addressController.dispose();
    casteCategoryController.dispose();
    feeStatusController.dispose();
    feeAmountController.dispose();
    paidAmountController.dispose();
    super.onClose();
  }

  Future<void> fetchStudents() async {
    try {
      isLoading.value = true;
      final result = await _repository.getStudents();
      students.assignAll(result);
    } catch (e) {
      FlutterToast.error('Failed to fetch students: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createStudent() async {
    if (!_validateForm()) return;

    try {
      isSubmitting.value = true;

      final student = StudentModel(
        firstName: firstNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dob: dobController.text.trim(),
        gender: genderController.text.trim(),
        fatherName: fatherNameController.text.trim(),
        motherName: motherNameController.text.trim(),
        parentPhone: parentPhoneController.text.trim(),
        alternativePhone: alternativePhoneController.text.trim(),
        adharNumber: adharNumberController.text.trim(),
        sssmid: sssmidController.text.trim(),
        studentClass: studentClassController.text.trim(),
        rollNumber: rollNumberController.text.trim(),
        address: addressController.text.trim(),
        casteCategory: casteCategoryController.text.trim(),
        feeStatus: feeStatusController.text.trim(),
        feeAmount: feeAmountController.text.trim().isEmpty ? '0.00' : feeAmountController.text.trim(),
        paidAmount: paidAmountController.text.trim().isEmpty ? '0.00' : paidAmountController.text.trim(),
        checkBox: true,
        schoolType: 'School A',
      );

      // Pass both File and Bytes
      final created = await _repository.createStudent(
        student: student,
        studentProfile: studentProfileFile,
        studentProfileBytes: studentProfileBytes,
      );

      students.insert(0, created);
      _clearForm();

      FlutterToast.success('Student created successfully');
      Get.back();
    } catch (e) {
      FlutterToast.error('Failed to create student: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateStudent(int id) async {
    if (!_validateForm()) return;

    try {
      isSubmitting.value = true;

      final student = StudentModel(
        firstName: firstNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dob: dobController.text.trim(),
        gender: genderController.text.trim(),
        fatherName: fatherNameController.text.trim(),
        motherName: motherNameController.text.trim(),
        parentPhone: parentPhoneController.text.trim(),
        alternativePhone: alternativePhoneController.text.trim(),
        adharNumber: adharNumberController.text.trim(),
        sssmid: sssmidController.text.trim(),
        studentClass: studentClassController.text.trim(),
        rollNumber: rollNumberController.text.trim(),
        address: addressController.text.trim(),
        casteCategory: casteCategoryController.text.trim(),
        feeStatus: feeStatusController.text.trim(),
        feeAmount: feeAmountController.text.trim().isEmpty ? '0.00' : feeAmountController.text.trim(),
        paidAmount: paidAmountController.text.trim().isEmpty ? '0.00' : paidAmountController.text.trim(),
        checkBox: true,
        schoolType: 'School A',
      );

      // Pass both File and Bytes
      final updated = await _repository.updateStudent(
        id: id,
        student: student,
        studentProfile: studentProfileFile,
        studentProfileBytes: studentProfileBytes,
      );

      final index = students.indexWhere((s) => s.id == id);
      if (index != -1) {
        students[index] = updated;
      }

      _clearForm();

      FlutterToast.success('Student updated successfully');
      Get.back();
    } catch (e) {
      FlutterToast.error('Failed to update student: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Student'),
          content: const Text('Are you sure you want to delete this student?'),
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
        final success = await _repository.deleteStudent(id);
        if (success) {
          students.removeWhere((s) => s.id == id);
          FlutterToast.success('Student deleted successfully');
        }
      }
    } catch (e) {
      FlutterToast.error('Failed to delete student: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setStudentForEdit(StudentModel student) {
    selectedStudent.value = student;

    firstNameController.text = student.firstName;
    middleNameController.text = student.middleName;
    lastNameController.text = student.lastName;
    dobController.text = student.dob;
    genderController.text = student.gender;
    fatherNameController.text = student.fatherName;
    motherNameController.text = student.motherName;
    parentPhoneController.text = student.parentPhone;
    alternativePhoneController.text = student.alternativePhone ?? '';
    adharNumberController.text = student.adharNumber;
    sssmidController.text = student.sssmid;
    studentClassController.text = student.studentClass;
    rollNumberController.text = student.rollNumber;
    addressController.text = student.address;
    casteCategoryController.text = student.casteCategory;
    feeStatusController.text = student.feeStatus;
    feeAmountController.text = student.feeAmount;
    paidAmountController.text = student.paidAmount;
  }

  void setProfileImage(File file) {
    studentProfileFile = file;
    update();
  }

  void setProfileImageBytes(Uint8List bytes) {
    studentProfileBytes = bytes;
    update();
  }

  void _clearForm() {
    firstNameController.clear();
    middleNameController.clear();
    lastNameController.clear();
    dobController.clear();
    genderController.clear();
    fatherNameController.clear();
    motherNameController.clear();
    parentPhoneController.clear();
    alternativePhoneController.clear();
    adharNumberController.clear();
    sssmidController.clear();
    studentClassController.clear();
    rollNumberController.clear();
    addressController.clear();
    casteCategoryController.clear();
    feeStatusController.clear();
    feeAmountController.clear();
    paidAmountController.clear();
    studentProfileFile = null;
    studentProfileBytes = null;
    selectedStudent.value = null;
  }

  bool _validateForm() {
    if (firstNameController.text.trim().isEmpty) {
      FlutterToast.warning('First name is required');
      return false;
    }

    if (dobController.text.trim().isEmpty) {
      FlutterToast.warning('Date of birth is required');
      return false;
    }

    if (parentPhoneController.text.trim().isEmpty) {
      FlutterToast.warning('Parent phone is required');
      return false;
    }

    return true;
  }
}