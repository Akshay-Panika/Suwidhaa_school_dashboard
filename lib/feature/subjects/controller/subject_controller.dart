import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../model/subject_model.dart';
import '../repository/subject_repository.dart';

class SubjectController extends GetxController {
  final SubjectRepository _repository = SubjectRepository();

  // ============ STATE ============
  final RxList<SubjectApiModel> subjects = <SubjectApiModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // UI State
  final Rx<SubjectFilter> currentFilter = SubjectFilter.all.obs;
  final RxString searchQuery = ''.obs;
  final RxBool showRightPanel = false.obs;
  final Rx<SubjectApiModel?> selectedSubject = Rx<SubjectApiModel?>(null);
  final RxBool isEditing = false.obs;
  final RxBool isAddingNew = false.obs;
  final RxBool showScheduleView = false.obs;

  // ============ FORM STATE ============
  final nameController = TextEditingController();

  final RxString selectedSchoolForm = 'a'.obs;
  final RxBool checkBox = true.obs;
  final RxList<Map<String, dynamic>> formAsign = <Map<String, dynamic>>[].obs;

  // ============ CONSTANTS ============
  final List<String> classLevels = [
    'Nursery', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th', '5th',
    '6th', '7th', '8th', '9th', '10th', '11th', '12th'
  ];

  final List<String> sectionList = ['A', 'B', 'C', 'D', 'E', 'F'];

  final List<String> timeSlots = [
    '8:00 AM - 8:45 AM',
    '8:45 AM - 9:30 AM',
    '9:30 AM - 10:15 AM',
    '10:30 AM - 11:15 AM',
    '11:15 AM - 12:00 PM',
    '12:00 PM - 12:45 PM',
    '1:15 PM - 2:00 PM',
    '2:00 PM - 2:45 PM',
    '2:45 PM - 3:30 PM',
  ];

  final List<String> schoolList = ['a', 'b'];

  final List<Map<String, String>> availableTeachers = [
    {'id': 'T001', 'name': 'Dr. Rajesh Kumar', 'subject': 'Mathematics', 'school': 'a'},
    {'id': 'T002', 'name': 'Ms. Meera Singh', 'subject': 'Science', 'school': 'a'},
    {'id': 'T003', 'name': 'Mr. Suresh Patel', 'subject': 'English', 'school': 'a'},
    {'id': 'T004', 'name': 'Mrs. Anita Sharma', 'subject': 'History', 'school': 'a'},
    {'id': 'T005', 'name': 'Mr. Vikram Reddy', 'subject': 'Computer Science', 'school': 'a'},
    {'id': 'T006', 'name': 'Dr. Priya Gupta', 'subject': 'Biology', 'school': 'b'},
    {'id': 'T007', 'name': 'Mr. Arjun Nair', 'subject': 'Physics', 'school': 'b'},
    {'id': 'T008', 'name': 'Ms. Kavya Reddy', 'subject': 'Chemistry', 'school': 'b'},
    {'id': 'T009', 'name': 'Mr. Amit Singh', 'subject': 'Geography', 'school': 'b'},
    {'id': 'T010', 'name': 'Ms. Neha Sharma', 'subject': 'Art', 'school': 'b'},
  ];

  // ============ GETTERS ============
  List<SubjectApiModel> get filteredSubjects {
    var filtered = subjects.toList();

    if (currentFilter.value != SubjectFilter.all) {
      filtered = filtered.where((s) {
        switch (currentFilter.value) {
          case SubjectFilter.active: return s.checkBox == true;
          case SubjectFilter.inactive: return s.checkBox == false;
          case SubjectFilter.withTeacher: return s.asign.isNotEmpty;
          case SubjectFilter.withoutTeacher: return s.asign.isEmpty;
          case SubjectFilter.withSchedule:
            return s.asign.any((a) => a.slotTime != null && a.slotTime!.isNotEmpty);
          case SubjectFilter.withoutSchedule:
            return s.asign.every((a) => a.slotTime == null || a.slotTime!.isEmpty);
          default: return true;
        }
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((s) =>
      s.subjectName.toLowerCase().contains(query) ||
          s.schoolType.toLowerCase().contains(query) ||
          s.asign.any((a) =>
          a.teacherName.toLowerCase().contains(query) ||
              a.className.toLowerCase().contains(query) ||
              a.sectionName.toLowerCase().contains(query)
          )
      ).toList();
    }

    return filtered;
  }

  int get totalSubjects => subjects.length;
  int get activeSubjects => subjects.where((s) => s.checkBox).length;
  int get inactiveSubjects => subjects.where((s) => !s.checkBox).length;
  int get subjectsWithTeachers => subjects.where((s) => s.asign.isNotEmpty).length;

  Map<String, int> get schoolWiseStats {
    Map<String, int> stats = {};
    for (var subject in subjects) {
      final school = subject.schoolType == 'a' ? 'School A' : 'School B';
      stats[school] = (stats[school] ?? 0) + 1;
    }
    return stats;
  }

  String getSchoolDisplay(String schoolType) {
    return schoolType == 'a' ? 'School A' : 'School B';
  }

  Color getSchoolColor(String schoolType) {
    return schoolType == 'a' ? Colors.blue : Colors.green;
  }

  Color getStatusColor(bool checkBox) {
    return checkBox ? Colors.green : Colors.red;
  }

  String getStatusText(bool checkBox) {
    return checkBox ? 'Active' : 'Inactive';
  }

  // ============ CRUD OPERATIONS ============

  Future<void> loadSubjects() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getSubjects();
      if (result.isNotEmpty) {
        subjects.value = result;
      } else {
        _loadSampleData();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load subjects';
      FlutterToast.error('Failed to load subjects');
      _loadSampleData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSubject() async {
    // Get name safely
    final subjectName = nameController.text.trim();
    if (subjectName.isEmpty) {
      FlutterToast.warning('Subject name is required');
      return;
    }

    if (formAsign.isEmpty) {
      FlutterToast.warning('Please add at least one teacher assignment');
      return;
    }

    try {
      isSubmitting.value = true;

      final data = {
        'subject_name': subjectName,
        'school_type': selectedSchoolForm.value,
        'asign': formAsign.map((a) => {
          'slot_time': a['slotTime'] ?? null,
          'class_name': a['classLevel'] ?? '',
          'room_number': a['room'] ?? null,
          'section_name': a['section'] ?? '',
          'teacher_name': a['teacher'] ?? '',
        }).toList(),
        'check_box': checkBox.value,
      };

      print('📡 POST Create Subject Payload: $data');

      final result = await _repository.createSubject(data);

      if (result != null) {
        subjects.add(result);
        FlutterToast.success('Subject added successfully!');

        // Reset form and close panel
        _resetAndClose();
      } else {
        FlutterToast.error('Failed to add subject');
      }
    } catch (e) {
      print('❌ Error in addSubject: $e');
      FlutterToast.error('Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateSubject() async {
    // Get name safely
    final subjectName = nameController.text.trim();
    if (subjectName.isEmpty) {
      FlutterToast.warning('Subject name is required');
      return;
    }

    if (formAsign.isEmpty) {
      FlutterToast.warning('Please add at least one teacher assignment');
      return;
    }

    try {
      isSubmitting.value = true;

      final id = selectedSubject.value?.id ?? 0;
      if (id == 0) {
        FlutterToast.error('Invalid subject ID');
        return;
      }

      final data = {
        'subject_name': subjectName,
        'school_type': selectedSchoolForm.value,
        'asign': formAsign.map((a) => {
          'slot_time': a['slotTime'] ?? null,
          'class_name': a['classLevel'] ?? '',
          'room_number': a['room'] ?? null,
          'section_name': a['section'] ?? '',
          'teacher_name': a['teacher'] ?? '',
        }).toList(),
        'check_box': checkBox.value,
      };

      print('📡 PUT Update Subject $id Payload: $data');

      final result = await _repository.updateSubject(id, data);

      if (result != null) {
        final index = subjects.indexWhere((s) => s.id == selectedSubject.value?.id);
        if (index != -1) {
          subjects[index] = result;
          selectedSubject.value = result;
        }
        FlutterToast.success('Subject updated successfully!');

        // Reset form and close panel
        _resetAndClose();
      } else {
        FlutterToast.error('Failed to update subject');
      }
    } catch (e) {
      print('❌ Error in updateSubject: $e');
      FlutterToast.error('Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

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

  // ============ FORM HELPERS ============

  void _resetAndClose() {
    resetForm();
    showRightPanel.value = false;
    isAddingNew.value = false;
    isEditing.value = false;
  }

  // ============ UI METHODS ============
  void setFilter(SubjectFilter filter) => currentFilter.value = filter;
  void setSearchQuery(String query) => searchQuery.value = query;

  void selectSubject(SubjectApiModel? subject) {
    selectedSubject.value = subject;
    showRightPanel.value = subject != null;
    isEditing.value = false;
    isAddingNew.value = false;
    showScheduleView.value = false;
    if (subject != null) loadSubjectToForm(subject);
  }

  void startAddNew() {
    resetForm();
    isAddingNew.value = true;
    isEditing.value = false;
    showScheduleView.value = false;
    selectedSubject.value = null;
    showRightPanel.value = true;
  }

  void startEditing(SubjectApiModel subject) {
    loadSubjectToForm(subject);
    selectedSubject.value = subject;
    isEditing.value = true;
    isAddingNew.value = false;
    showScheduleView.value = false;
    showRightPanel.value = true;
  }

  void showSchedule(SubjectApiModel subject) {
    selectedSubject.value = subject;
    showScheduleView.value = true;
    showRightPanel.value = true;
    isEditing.value = false;
    isAddingNew.value = false;
  }

  void closeRightPanel() {
    showRightPanel.value = false;
    selectedSubject.value = null;
    isEditing.value = false;
    isAddingNew.value = false;
    showScheduleView.value = false;
    resetForm();
  }

  // ============ FORM METHODS ============
  void resetForm() {
    nameController.clear();
    selectedSchoolForm.value = 'a';
    checkBox.value = true;
    formAsign.clear();
  }

  void loadSubjectToForm(SubjectApiModel subject) {
    nameController.text = subject.subjectName;
    selectedSchoolForm.value = subject.schoolType;
    checkBox.value = subject.checkBox;
    formAsign.value = subject.asign.map((a) => ({
      'slotTime': a.slotTime,
      'classLevel': a.className,
      'room': a.roomNumber,
      'section': a.sectionName,
      'teacher': a.teacherName,
    })).toList();
  }

  // ============ ASIGN MANAGEMENT ============
  void addAsignToForm() {
    formAsign.add({
      'slotTime': null,
      'classLevel': '10th',
      'room': null,
      'section': 'A',
      'teacher': availableTeachers.isNotEmpty ? availableTeachers[0]['name'] : '',
    });
  }

  void removeAsignFromForm(int index) {
    formAsign.removeAt(index);
  }

  void updateAsignField(int index, String key, dynamic value) {
    final asign = Map<String, dynamic>.from(formAsign[index]);
    asign[key] = value;
    formAsign[index] = asign;
  }

  // ============ TEACHER SELECTION ============
  void showTeacherSelectionDialog() {
    List<String> tempSelected = formAsign.map((a) => a['teacher'] as String).toList();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Select Teachers'),
            content: SizedBox(
              width: double.maxFinite,
              height: 350,
              child: ListView.builder(
                itemCount: availableTeachers.length,
                itemBuilder: (context, index) {
                  final teacher = availableTeachers[index];
                  final isSelected = tempSelected.contains(teacher['name']);
                  final isSchoolMatch = selectedSchoolForm.value == teacher['school'];

                  return CheckboxListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(teacher['name'].toString()),
                            if (!isSchoolMatch)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Different School',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '${teacher['subject'] ?? ''} • ${teacher['school'] == 'a' ? 'School A' : 'School B'}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    value: isSelected,
                    onChanged: isSchoolMatch
                        ? (bool? value) {
                      setStateDialog(() {
                        if (value == true) {
                          tempSelected.add(teacher['name'].toString());
                        } else {
                          tempSelected.remove(teacher['name']);
                        }
                      });
                    }
                        : null,
                    activeColor: Colors.blue,
                    dense: true,
                    secondary: !isSchoolMatch
                        ? Icon(Icons.warning, color: Colors.orange, size: 16)
                        : null,
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============ SAMPLE DATA ============
  void _loadSampleData() {
    subjects.value = [
      SubjectApiModel(
        id: 1,
        subjectName: 'Mathematics',
        schoolType: 'a',
        asign: [
          AsignApiModel(
            slotTime: '8:00 AM - 8:45 AM',
            className: '10th',
            roomNumber: '101',
            sectionName: 'A',
            teacherName: 'Dr. Rajesh Kumar',
          ),
          AsignApiModel(
            slotTime: '9:30 AM - 10:15 AM',
            className: '10th',
            roomNumber: '102',
            sectionName: 'B',
            teacherName: 'Dr. Rajesh Kumar',
          ),
        ],
        checkBox: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      SubjectApiModel(
        id: 2,
        subjectName: 'Science',
        schoolType: 'a',
        asign: [
          AsignApiModel(
            slotTime: '8:45 AM - 9:30 AM',
            className: '10th',
            roomNumber: '101',
            sectionName: 'A',
            teacherName: 'Ms. Meera Singh',
          ),
        ],
        checkBox: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      SubjectApiModel(
        id: 3,
        subjectName: 'Physics',
        schoolType: 'b',
        asign: [],
        checkBox: false,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    loadSubjects();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}