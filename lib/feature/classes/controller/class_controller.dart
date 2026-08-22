import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../model/class_model.dart';
import '../repository/class_repository.dart';

class ClassController extends GetxController {
  final ClassRepository _repository = ClassRepository();

  // ============ STATE ============
  final RxList<ClassApiModel> classes = <ClassApiModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // UI State
  final Rx<ClassFilter> currentFilter = ClassFilter.all.obs;
  final Rx<SchoolFilter> currentSchoolFilter = SchoolFilter.all.obs;
  final RxString searchQuery = ''.obs;
  final RxBool showRightPanel = false.obs;
  final Rx<ClassApiModel?> selectedClass = Rx<ClassApiModel?>(null);
  final RxBool isEditing = false.obs;
  final RxBool isAddingNew = false.obs;

  // ============ FORM STATE ============
  final formKey = GlobalKey<FormState>();
  final RxString selectedClassLevel = 'Nursery'.obs;
  final RxString selectedSchoolForm = 'School A'.obs;
  final Rx<ClassStatus> selectedStatus = ClassStatus.active.obs;
  final RxList<Map<String, dynamic>> formSections = <Map<String, dynamic>>[].obs;

  // ============ CONSTANTS ============
  final List<String> classLevels = [
    'Nursery', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th', '5th',
    '6th', '7th', '8th', '9th', '10th', '11th', '12th'
  ];

  final List<String> schoolList = ['School A', 'School B'];
  final List<String> sectionList = ['A', 'B', 'C', 'D', 'E', 'F'];

  final List<String> subjectList = [
    'Mathematics', 'English', 'Science', 'History', 'Geography',
    'Computer Science', 'Physics', 'Chemistry', 'Biology', 'Art',
    'Music', 'Physical Education', 'Social Studies', 'Hindi', 'Sanskrit'
  ];

  final List<Map<String, String>> availableTeachers = [
    {'id': 'T001', 'name': 'Dr. Rajesh Kumar'},
    {'id': 'T002', 'name': 'Ms. Meera Singh'},
    {'id': 'T003', 'name': 'Mr. Suresh Patel'},
    {'id': 'T004', 'name': 'Mrs. Anita Sharma'},
    {'id': 'T005', 'name': 'Mr. Vikram Reddy'},
    {'id': 'T006', 'name': 'Dr. Priya Gupta'},
    {'id': 'T007', 'name': 'Mr. Arjun Nair'},
    {'id': 'T008', 'name': 'Ms. Kavya Reddy'},
  ];

  // ============ GETTERS ============
  List<ClassApiModel> get filteredClasses {
    var filtered = classes.toList();

    if (currentSchoolFilter.value == SchoolFilter.schoolA) {
      filtered = filtered.where((c) => c.schoolName == 'School A').toList();
    } else if (currentSchoolFilter.value == SchoolFilter.schoolB) {
      filtered = filtered.where((c) => c.schoolName == 'School B').toList();
    }

    if (currentFilter.value != ClassFilter.all) {
      filtered = filtered.where((c) {
        final level = c.className.toLowerCase();
        switch (currentFilter.value) {
          case ClassFilter.nursery: return level == 'nursery';
          case ClassFilter.lkg: return level == 'lkg';
          case ClassFilter.ukg: return level == 'ukg';
          case ClassFilter.first: return level == '1st';
          case ClassFilter.second: return level == '2nd';
          case ClassFilter.third: return level == '3rd';
          case ClassFilter.fourth: return level == '4th';
          case ClassFilter.fifth: return level == '5th';
          case ClassFilter.sixth: return level == '6th';
          case ClassFilter.seventh: return level == '7th';
          case ClassFilter.eighth: return level == '8th';
          case ClassFilter.ninth: return level == '9th';
          case ClassFilter.tenth: return level == '10th';
          case ClassFilter.eleventh: return level == '11th';
          case ClassFilter.twelfth: return level == '12th';
          default: return true;
        }
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((c) =>
      c.className.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          c.schoolName.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  int get totalClasses => classes.length;
  int get totalStudents => classes.fold<int>(0, (sum, c) =>
  sum + c.sections.fold<int>(0, (s, sec) => s + sec.totalStudent)
  );

  String get schoolLabel {
    if (currentSchoolFilter.value == SchoolFilter.all) return 'All Schools';
    if (currentSchoolFilter.value == SchoolFilter.schoolA) return 'School A';
    return 'School B';
  }

  Map<String, int> get schoolWiseStats {
    Map<String, int> stats = {};
    for (var classItem in classes) {
      stats[classItem.schoolName] = (stats[classItem.schoolName] ?? 0) + 1;
    }
    return stats;
  }

  // ============ CRUD OPERATIONS ============

  Future<void> loadClasses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getClasses();
      if (result.isNotEmpty) {
        classes.value = result;
      } else {
        _loadSampleData();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load classes';
      FlutterToast.error('Failed to load classes');
      _loadSampleData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addClass() async {
    if (!formKey.currentState!.validate()) return;
    if (formSections.isEmpty) {
      FlutterToast.warning('Please add at least one section');
      return;
    }

    try {
      isLoading.value = true;

      final data = _buildApiData();
      final result = await _repository.createClass(data);

      if (result != null) {
        classes.add(result);
        FlutterToast.success('Class added successfully!');
        _resetAndClose();
      } else {
        FlutterToast.error('Failed to add class');
      }
    } catch (e) {
      FlutterToast.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateClass() async {
    if (!formKey.currentState!.validate()) return;
    if (formSections.isEmpty) {
      FlutterToast.warning('Please add at least one section');
      return;
    }

    try {
      isLoading.value = true;

      final id = selectedClass.value?.id ?? 0;
      final data = _buildApiData();
      final result = await _repository.updateClass(id, data);

      if (result != null) {
        final index = classes.indexWhere((c) => c.id == selectedClass.value?.id);
        if (index != -1) {
          classes[index] = result;
          selectedClass.value = result;
        }
        FlutterToast.success('Class updated successfully!');
        _resetAndClose();
      } else {
        FlutterToast.error('Failed to update class');
      }
    } catch (e) {
      FlutterToast.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClass(ClassApiModel classItem) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete ${classItem.className} Class?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              _confirmDelete(classItem);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(ClassApiModel classItem) async {
    try {
      isLoading.value = true;

      final success = await _repository.deleteClass(classItem.id);
      if (success) {
        classes.removeWhere((c) => c.id == classItem.id);
        if (selectedClass.value?.id == classItem.id) {
          selectedClass.value = null;
          showRightPanel.value = false;
        }
        FlutterToast.success('Class deleted successfully!');
      } else {
        FlutterToast.error('Failed to delete class');
      }
    } catch (e) {
      FlutterToast.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ FORM HELPERS ============

  Map<String, dynamic> _buildApiData() {
    return {
      'class_name': selectedClassLevel.value,
      'school_name': selectedSchoolForm.value,
      'sections': formSections.map((s) => {
        'name': s['section'] ?? '',
        'room_number': s['room'] ?? '',
        'class_teacher_name': s['classTeacher'] ?? '',
        'total_student': s['studentCount'] ?? 0,
        'subject_names': s['subjects'] ?? [],
      }).toList(),
      'check_box': true,
    };
  }

  void _resetAndClose() {
    resetForm();
    showRightPanel.value = false;
    isAddingNew.value = false;
    isEditing.value = false;
  }

  // ============ UI METHODS ============
  void setFilter(ClassFilter filter) => currentFilter.value = filter;

  void setSchoolFilter(SchoolFilter filter) {
    currentSchoolFilter.value = filter;
    selectedClass.value = null;
    showRightPanel.value = false;
  }

  void setSearchQuery(String query) => searchQuery.value = query;

  void selectClass(ClassApiModel? classItem) {
    selectedClass.value = classItem;
    showRightPanel.value = classItem != null;
    isEditing.value = false;
    isAddingNew.value = false;
    if (classItem != null) loadClassToForm(classItem);
  }

  void startAddNew() {
    resetForm();
    isAddingNew.value = true;
    isEditing.value = false;
    selectedClass.value = null;
    showRightPanel.value = true;
  }

  void startEditing(ClassApiModel classItem) {
    loadClassToForm(classItem);
    selectedClass.value = classItem;
    isEditing.value = true;
    isAddingNew.value = false;
    showRightPanel.value = true;
  }

  void closeRightPanel() {
    showRightPanel.value = false;
    selectedClass.value = null;
    isEditing.value = false;
    isAddingNew.value = false;
    resetForm();
  }

  // ============ FORM METHODS ============
  void resetForm() {
    selectedClassLevel.value = 'Nursery';
    selectedSchoolForm.value = 'School A';
    selectedStatus.value = ClassStatus.active;
    formSections.clear();
  }

  void loadClassToForm(ClassApiModel classItem) {
    selectedClassLevel.value = classItem.className;
    selectedSchoolForm.value = classItem.schoolName;
    formSections.value = classItem.sections.map((s) => {
      'section': s.name,
      'classTeacher': s.classTeacherName,
      'teacherId': '',
      'room': s.roomNumber,
      'subjects': List<String>.from(s.subjectNames),
      'studentCount': s.totalStudent,
    }).toList();
  }

  // ============ SECTION MANAGEMENT ============
  void addSectionToForm() {
    formSections.add({
      'section': 'A',
      'classTeacher': '',
      'teacherId': '',
      'room': '',
      'subjects': <String>[],
      'studentCount': 0,
    });
  }

  void removeSectionFromForm(int index) => formSections.removeAt(index);

  void updateSectionField(int index, String key, dynamic value) {
    final s = Map<String, dynamic>.from(formSections[index]);
    s[key] = value;
    formSections[index] = s;
  }

  void toggleSubjectForSection(int index, String subject) {
    final s = Map<String, dynamic>.from(formSections[index]);
    final subjects = List<String>.from(s['subjects'] ?? []);
    if (subjects.contains(subject)) {
      subjects.remove(subject);
    } else {
      subjects.add(subject);
    }
    s['subjects'] = subjects;
    formSections[index] = s;
  }

  // ============ HELPERS ============
  Color getSchoolColor(String school) {
    switch (school) {
      case 'School A': return Colors.blue;
      case 'School B': return Colors.green;
      default: return Colors.grey;
    }
  }

  int getTotalStudents(ClassApiModel classItem) {
    return classItem.sections.fold<int>(0, (sum, s) => sum + s.totalStudent);
  }

  // ============ SAMPLE DATA ============
  void _loadSampleData() {
    classes.value = [
      ClassApiModel(
        id: 1,
        className: '10th',
        schoolName: 'School A',
        sections: [
          SectionApiModel(
            name: 'A',
            roomNumber: '101',
            subjectNames: ['Mathematics', 'Science', 'English', 'Hindi'],
            totalStudent: 42,
            classTeacherName: 'Dr. Rajesh Kumar',
          ),
        ],
        checkBox: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      ClassApiModel(
        id: 2,
        className: '9th',
        schoolName: 'School B',
        sections: [
          SectionApiModel(
            name: 'A',
            roomNumber: '201',
            subjectNames: ['Mathematics', 'Science', 'English'],
            totalStudent: 40,
            classTeacherName: 'Ms. Meera Singh',
          ),
        ],
        checkBox: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    loadClasses();
  }

  @override
  void onClose() {
    // Dispose any resources if needed
    super.onClose();
  }
}