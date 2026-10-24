// lib/feature/classes/controller/class_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../../main/controller/school_type_controller.dart';
import '../../main/model/school_type_model.dart';
import '../model/class_model.dart';
import '../repository/class_repository.dart';

class ClassController extends GetxController {
  final ClassRepository _repository = ClassRepository();
  final SchoolTypeController schoolController = Get.find<SchoolTypeController>();

  // ============ STATE ============
  final RxList<ClassApiModel> classes = <ClassApiModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // UI State
  final RxBool showRightPanel = false.obs;
  final Rx<ClassApiModel?> selectedClass = Rx<ClassApiModel?>(null);
  final RxBool isAddingNew = false.obs;

  // ============ FORM STATE ============
  final RxString newClassName = ''.obs;
  final RxList<String> newClassSections = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Setup listener on school selection
    ever(schoolController.selectedSchoolType, (SchoolTypeModel? school) {
      if (school?.id != null) {
        loadClassesBySchool(school!.id!);
      } else {
        classes.clear(); // Clear if "All Schools" is selected
      }
    });

    // Initial load if a school is already selected
    if (schoolController.selectedSchoolType.value?.id != null) {
      loadClassesBySchool(schoolController.selectedSchoolType.value!.id!);
    }
  }

  // ============ GETTERS ============
  List<ClassApiModel> get filteredClasses {
    var filtered = classes.toList();
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((c) =>
          c.className.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    return filtered;
  }

  // ============ API CALLS ============

  Future<void> loadClassesBySchool(int schoolId) async {
    try {
      isLoading.value = true;
      final result = await _repository.getClassesBySchool(schoolId);
      classes.assignAll(result);

      // ✅ FIX: Update the selected class with the newly fetched object
      // so the right panel rebuilds when a teacher is assigned/removed.
      if (selectedClass.value != null) {
        final updatedClass = result.firstWhereOrNull((c) => c.id == selectedClass.value!.id);
        if (updatedClass != null) {
          selectedClass.value = updatedClass;
        } else {
          // If the class no longer exists (deleted), close the panel
          selectedClass.value = null;
          showRightPanel.value = false;
        }
      }

    } catch (e) {
      FlutterToast.error('Failed to load classes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addClass() async {
    if (newClassName.value.trim().isEmpty) {
      FlutterToast.warning('Please enter a class name (e.g., 6A)');
      return;
    }

    final currentSchool = schoolController.selectedSchoolType.value;
    if (currentSchool == null) {
      FlutterToast.warning('Please select a school from the top dropdown first');
      return;
    }

    try {
      isLoading.value = true;
      final data = {
        'class_name': newClassName.value.trim(),
        'school_id': currentSchool.id,
        'sections': newClassSections, // e.g. ["A", "B"]
        'check_box': true,
      };

      final result = await _repository.createClass(data);
      if (result != null) {
        await loadClassesBySchool(currentSchool.id!); // Refresh list
        FlutterToast.success('Class created successfully!');
        _resetAndClose();
      } else {
        FlutterToast.error('Failed to create class');
      }
    } catch (e) {
      FlutterToast.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignTeacher(int classId, int? teacherId) async {
    try {
      isLoading.value = true;
      final success = await _repository.assignClassTeacher(classId, teacherId);
      if (success) {
        final currentSchoolId = schoolController.selectedSchoolType.value?.id;
        if (currentSchoolId != null) {
          // ✅ This will also update selectedClass.value automatically
          await loadClassesBySchool(currentSchoolId);
        }
        FlutterToast.success(teacherId == null ? 'Teacher unassigned' : 'Teacher assigned!');
      } else {
        FlutterToast.error('Failed to assign teacher. Ensure teacher belongs to this school.');
      }
    } catch (e) {
      FlutterToast.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ UI METHODS ============
  void setSearchQuery(String query) => searchQuery.value = query;

  void selectClass(ClassApiModel? classItem) {
    selectedClass.value = classItem;
    showRightPanel.value = classItem != null;
    isAddingNew.value = false;
  }

  void startAddNew() {
    if (schoolController.selectedSchoolType.value == null) {
      FlutterToast.warning('Please select a specific school from the top dropdown first.');
      return;
    }
    resetForm();
    isAddingNew.value = true;
    selectedClass.value = null;
    showRightPanel.value = true;
  }

  void closeRightPanel() {
    showRightPanel.value = false;
    selectedClass.value = null;
    isAddingNew.value = false;
    resetForm();
  }

  void _resetAndClose() {
    resetForm();
    showRightPanel.value = false;
    isAddingNew.value = false;
  }

  // ============ FORM METHODS ============
  void resetForm() {
    newClassName.value = '';
    newClassSections.clear();
  }

  void addSectionToForm() {
    final nextSection = String.fromCharCode(65 + newClassSections.length);
    if (!newClassSections.contains(nextSection)) {
      newClassSections.add(nextSection);
    }
  }

  void removeSectionFromForm(String section) => newClassSections.remove(section);
}