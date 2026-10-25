// lib/feature/subjects/controller/subject_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../../main/controller/school_type_controller.dart';
import '../../main/model/school_type_model.dart';
import '../model/subject_model.dart';
import '../repository/subject_repository.dart';

class SubjectController extends GetxController {
  final SubjectRepository _repository = SubjectRepository();
  final SchoolTypeController schoolController = Get.find<SchoolTypeController>();

  // ============ STATE ============
  final RxList<SubjectApiModel> subjects = <SubjectApiModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString searchQuery = ''.obs;

  // UI State
  final RxBool showRightPanel = false.obs;
  final Rx<SubjectApiModel?> selectedSubject = Rx<SubjectApiModel?>(null);
  final RxBool isAddingNew = false.obs;
  final RxBool isEditing = false.obs; // ✅ Added for edit mode

  // ============ FORM STATE ============
  final nameController = TextEditingController();
  final codeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    ever(schoolController.selectedSchoolType, (SchoolTypeModel? school) {
      if (school?.id != null) {
        loadSubjects(school!.id!);
      } else {
        subjects.clear();
      }
    });

    if (schoolController.selectedSchoolType.value?.id != null) {
      loadSubjects(schoolController.selectedSchoolType.value!.id!);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    super.onClose();
  }

  // ============ GETTERS ============
  List<SubjectApiModel> get filteredSubjects {
    var filtered = subjects.toList();
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((s) =>
      s.subjectName.toLowerCase().contains(query) ||
          (s.code?.toLowerCase().contains(query) ?? false)).toList();
    }
    return filtered;
  }

  // ============ API CALLS ============
  Future<void> loadSubjects(int schoolId) async {
    try {
      isLoading.value = true;
      final result = await _repository.getSubjects(schoolId);
      subjects.assignAll(result);
    } catch (e) {
      FlutterToast.error('Failed to load subjects');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSubject() async {
    if (nameController.text.trim().isEmpty) {
      FlutterToast.warning('Please enter a subject name');
      return;
    }

    final currentSchool = schoolController.selectedSchoolType.value;
    if (currentSchool == null) {
      FlutterToast.warning('Please select a school first');
      return;
    }

    try {
      isSubmitting.value = true;
      final data = {
        'name': nameController.text.trim(),
        'code': codeController.text.trim().isEmpty ? null : codeController.text.trim(),
        'school_id': currentSchool.id,
      };

      final result = await _repository.createSubject(data);
      if (result != null) {
        await loadSubjects(currentSchool.id!);
        FlutterToast.success('Subject created successfully!');
        _resetAndClose();
      } else {
        FlutterToast.error('Failed to create subject');
      }
    } catch (e) {
      FlutterToast.error('Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ✅ NEW: Update Subject
  Future<void> updateSubject() async {
    if (nameController.text.trim().isEmpty) {
      FlutterToast.warning('Please enter a subject name');
      return;
    }

    final currentSchool = schoolController.selectedSchoolType.value;
    final currentSubjectId = selectedSubject.value?.id;
    if (currentSchool == null || currentSubjectId == null) return;

    try {
      isSubmitting.value = true;
      final data = {
        'name': nameController.text.trim(),
        'code': codeController.text.trim().isEmpty ? null : codeController.text.trim(),
        'school_id': currentSchool.id,
      };

      final result = await _repository.updateSubject(currentSubjectId, data);
      if (result != null) {
        await loadSubjects(currentSchool.id!);

        // Refresh selected subject object
        final updated = subjects.firstWhereOrNull((s) => s.id == currentSubjectId);
        if (updated != null) selectedSubject.value = updated;

        FlutterToast.success('Subject updated successfully!');
        isEditing.value = false;
      } else {
        FlutterToast.error('Failed to update subject');
      }
    } catch (e) {
      FlutterToast.error('Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ✅ NEW: Delete Subject
  Future<void> deleteSubject(SubjectApiModel subject) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${subject.subjectName}"?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              _confirmDelete(subject);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(SubjectApiModel subject) async {
    try {
      isLoading.value = true;
      final success = await _repository.deleteSubject(subject.id);

      if (success) {
        subjects.removeWhere((s) => s.id == subject.id);
        if (selectedSubject.value?.id == subject.id) {
          selectedSubject.value = null;
          showRightPanel.value = false;
        }
        FlutterToast.success('Subject deleted successfully!');
      } else {
        FlutterToast.error('Failed to delete subject');
      }
    } catch (e) {
      FlutterToast.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ UI METHODS ============
  void setSearchQuery(String query) => searchQuery.value = query;

  void selectSubject(SubjectApiModel? subject) {
    selectedSubject.value = subject;
    showRightPanel.value = subject != null;
    isAddingNew.value = false;
    isEditing.value = false;
  }

  void startAddNew() {
    if (schoolController.selectedSchoolType.value == null) {
      FlutterToast.warning('Please select a school first');
      return;
    }
    resetForm();
    isAddingNew.value = true;
    isEditing.value = false;
    selectedSubject.value = null;
    showRightPanel.value = true;
  }

  // ✅ NEW: Start Editing
  void startEditing(SubjectApiModel subject) {
    selectedSubject.value = subject;
    nameController.text = subject.subjectName;
    codeController.text = subject.code ?? '';

    isEditing.value = true;
    isAddingNew.value = false;
    showRightPanel.value = true;
  }

  void closeRightPanel() {
    showRightPanel.value = false;
    selectedSubject.value = null;
    isAddingNew.value = false;
    isEditing.value = false;
    resetForm();
  }

  void _resetAndClose() {
    resetForm();
    showRightPanel.value = false;
    isAddingNew.value = false;
    isEditing.value = false;
  }

  void resetForm() {
    nameController.clear();
    codeController.clear();
  }
}