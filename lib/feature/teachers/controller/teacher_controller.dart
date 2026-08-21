import 'package:get/get.dart';
import 'dart:io';
import '../model/teacher_model.dart';
import '../repository/teacher_repository.dart';

class TeacherController extends GetxController {
  final TeacherRepository _repository = TeacherRepository();

  // Observable variables
  var teachers = <TeacherModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedTeacher = Rx<TeacherModel?>(null);

  // Filter states
  var selectedSchoolFilter = 'All'.obs;
  var selectedStatusFilter = 'All'.obs;

  // Computed getters
  List<TeacherModel> get filteredTeachers {
    var filtered = teachers.toList();

    if (selectedSchoolFilter.value != 'All') {
      filtered = filtered.where((t) => t.school == selectedSchoolFilter.value).toList();
    }

    if (selectedStatusFilter.value != 'All') {
      filtered = filtered.where((t) => t.status == selectedStatusFilter.value).toList();
    }

    return filtered;
  }

  int get totalTeachers => teachers.length;
  int get activeTeachers => teachers.where((t) => t.status == 'Active').length;
  int get inactiveTeachers => teachers.where((t) => t.status == 'Inactive').length;
  int get onLeaveTeachers => teachers.where((t) => t.status == 'On Leave').length;

  Map<String, int> get schoolWiseStats {
    Map<String, int> stats = {};
    for (var teacher in teachers) {
      stats[teacher.school] = (stats[teacher.school] ?? 0) + 1;
    }
    return stats;
  }

  // Create Teacher
  Future<bool> createTeacher({
    required String firstName,
    required String lastName,
    String? teacherId,
    File? teacherProfile,
    String? gender,
    String? dob,
    String? phone,
    String? altPhone,
    String? email,
    String? address,
    String? qualification,
    int? experience,
    double? salary,
    String? joinDate,
    bool? checkBox,
    List<String>? subjects,
    String? schoolType,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.createTeacher(
        firstName: firstName,
        lastName: lastName,
        teacherId: teacherId,
        teacherProfile: teacherProfile,
        gender: gender,
        dob: dob,
        phone: phone,
        altPhone: altPhone,
        email: email,
        address: address,
        qualification: qualification,
        experience: experience,
        salary: salary,
        joinDate: joinDate,
        checkBox: checkBox,
        subjects: subjects,
        schoolType: schoolType,
      );

      if (response.success && response.data != null) {
        teachers.insert(0, response.data!);
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to create teacher';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  // Get All Teachers
  Future<void> getTeachers() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getTeachers();

      if (response.success) {
        teachers.value = response.data;
      } else {
        errorMessage.value = 'Failed to load teachers';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    }

    isLoading.value = false;
  }

  // Get Teacher by ID
  Future<bool> getTeacherById(int id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getTeacherById(id);

      if (response.success && response.data != null) {
        selectedTeacher.value = response.data;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message ?? 'Teacher not found';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  // Update Teacher - FIXED: Only pass teacherProfile if a new file is selected
  Future<bool> updateTeacher({
    required int id,
    required String firstName,
    required String lastName,
    String? teacherId,
    String? gender,
    String? dob,
    String? phone,
    String? altPhone,
    String? email,
    String? address,
    String? qualification,
    int? experience,
    double? salary,
    String? joinDate,
    bool? checkBox,
    List<String>? subjects,
    String? schoolType,
    File? teacherProfile,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.updateTeacher(
        id: id,
        firstName: firstName,
        lastName: lastName,
        teacherId: teacherId,
        gender: gender,
        dob: dob,
        phone: phone,
        altPhone: altPhone,
        email: email,
        address: address,
        qualification: qualification,
        experience: experience,
        salary: salary,
        joinDate: joinDate,
        checkBox: checkBox,
        subjects: subjects,
        schoolType: schoolType,
        teacherProfile: teacherProfile, // Pass null if no new image
      );

      if (response.success && response.data != null) {
        final index = teachers.indexWhere((t) => t.id == id);
        if (index != -1) {
          teachers[index] = response.data!;
        }
        selectedTeacher.value = response.data;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to update teacher';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  // Delete Teacher
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
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to delete teacher';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  // Set filters
  void setSchoolFilter(String filter) {
    selectedSchoolFilter.value = filter;
  }

  void setStatusFilter(String filter) {
    selectedStatusFilter.value = filter;
  }

  // Select teacher
  void selectTeacher(TeacherModel? teacher) {
    selectedTeacher.value = teacher;
  }

  // Refresh
  Future<void> refreshTeachers() async {
    await getTeachers();
  }

  // Clear error
  void clearError() {
    errorMessage.value = '';
  }
}