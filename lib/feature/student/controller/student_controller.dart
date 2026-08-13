// student_controller.dart
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../model/student_model.dart';
import '../repository/student_repository.dart';

class StudentController extends GetxController {
  final StudentRepository _repository = StudentRepository();

  // Observable state variables
  var students = <StudentModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedStudent = Rxn<StudentModel>();

  // Get all students
  Future<void> fetchAllStudents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedStudents = await _repository.getAllStudents();
      students.value = fetchedStudents;

    } catch (e) {
      errorMessage.value = e.toString();
      Fluttertoast.showToast(msg: "Failed to load students: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Add new student
  Future<void> addStudent({
    required String firstName,
    required String middleName,
    required String lastName,
    required String dob,
    required String gender,
    required String fatherName,
    required String motherName,
    required String parentPhone,
    required String alternativePhone,
    required String studentClass,
    required String rollNumber,
    required String admissionNumber,
    required String email,
    required String address,
    required String casteCategory,
    required String adharNumber,
    required String sssmid,
    required String feeStatus,
    required String feeAmount,
    required String paidAmount,
    required bool checkBox,
    String? profileImage,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final newStudent = StudentModel(
        id: 0, // ID will be assigned by server
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        dob: dob,
        gender: gender,
        fatherName: fatherName,
        motherName: motherName,
        parentPhone: parentPhone,
        alternativePhone: alternativePhone,
        studentClass: studentClass,
        rollNumber: rollNumber,
        admissionNumber: admissionNumber,
        email: email,
        address: address,
        casteCategory: casteCategory,
        adharNumber: adharNumber,
        sssmid: sssmid,
        feeStatus: feeStatus,
        feeAmount: feeAmount,
        paidAmount: paidAmount,
        checkBox: checkBox,
        profileImage: profileImage,
        createdAt: DateTime.now().toIso8601String(),
      );

      final createdStudent = await _repository.addStudent(newStudent);
      students.add(createdStudent);

      Fluttertoast.showToast(msg: "Student added successfully!");

    } catch (e) {
      errorMessage.value = e.toString();
      Fluttertoast.showToast(msg: "Failed to add student: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Update student
  Future<void> updateStudent({
    required int id,
    required String firstName,
    required String middleName,
    required String lastName,
    required String dob,
    required String gender,
    required String fatherName,
    required String motherName,
    required String parentPhone,
    required String alternativePhone,
    required String studentClass,
    required String rollNumber,
    required String admissionNumber,
    required String email,
    required String address,
    required String casteCategory,
    required String adharNumber,
    required String sssmid,
    required String feeStatus,
    required String feeAmount,
    required String paidAmount,
    required bool checkBox,
    String? profileImage,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final updatedStudent = StudentModel(
        id: id,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        dob: dob,
        gender: gender,
        fatherName: fatherName,
        motherName: motherName,
        parentPhone: parentPhone,
        alternativePhone: alternativePhone,
        studentClass: studentClass,
        rollNumber: rollNumber,
        admissionNumber: admissionNumber,
        email: email,
        address: address,
        casteCategory: casteCategory,
        adharNumber: adharNumber,
        sssmid: sssmid,
        feeStatus: feeStatus,
        feeAmount: feeAmount,
        paidAmount: paidAmount,
        checkBox: checkBox,
        profileImage: profileImage,
        createdAt: DateTime.now().toIso8601String(),
      );

      final updated = await _repository.updateStudent(id, updatedStudent);

      final index = students.indexWhere((s) => s.id == id);
      if (index != -1) {
        students[index] = updated;
        students.refresh();
      }

      Fluttertoast.showToast(msg: "Student updated successfully!");
    } catch (e) {
      errorMessage.value = e.toString();
      Fluttertoast.showToast(msg: "Failed to update student: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Delete student
  Future<void> deleteStudent(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _repository.deleteStudent(id);
      students.removeWhere((s) => s.id == id);
      Fluttertoast.showToast(msg: 'Student deleted successfully!');
    } catch (e) {
      errorMessage.value = e.toString();
      Fluttertoast.showToast(msg: 'Failed to load student: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get single student
  Future<StudentModel?> getStudentById(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final student = await _repository.getStudentById(id);
      selectedStudent.value = student;
      return student;
    } catch (e) {
      errorMessage.value = e.toString();
      Fluttertoast.showToast(msg: 'Failed to load student: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}