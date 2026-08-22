import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/widget/flutter_toast.dart';
import '../controller/subject_controller.dart';
import '../model/subject_model.dart';

// ============ ENUMS ============
enum SubjectFilter {
  all,
  active,
  inactive,
  upcoming,
  completed,
  withTeacher,
  withoutTeacher,
  withSchedule,
  withoutSchedule,
}

enum SubjectStatus {
  active,
  inactive,
  upcoming,
  completed,
}

enum SchoolFilter {
  all,
  schoolA,
  schoolB,
}

// ============ UI HELPER CLASS ============
class SubjectUIModel {
  final String id;
  final String name;
  final String code;
  final List<String> teachers;
  final bool isActive;
  final List<Map<String, dynamic>> asign;
  final String school;

  SubjectUIModel({
    required this.id,
    required this.name,
    required this.code,
    required this.teachers,
    required this.isActive,
    required this.asign,
    required this.school,
  });

  factory SubjectUIModel.fromApi(SubjectApiModel api) {
    return SubjectUIModel(
      id: api.id.toString(),
      name: api.subjectName,
      code: api.subjectName.substring(0, 3).toUpperCase(),
      teachers: api.asign.map((a) => a.teacherName).toList(),
      isActive: api.checkBox,
      asign: api.asign.map((a) => ({
        'slotTime': a.slotTime,
        'classLevel': a.className,
        'room': a.roomNumber,
        'section': a.sectionName,
        'teacher': a.teacherName,
      })).toList(),
      school: api.schoolType == 'a' ? 'School A' : 'School B',
    );
  }
}

// ============ MAIN SCREEN ============
class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final SubjectController controller = Get.find<SubjectController>();

  // ============ STATE ============
  SubjectFilter _currentFilter = SubjectFilter.all;
  SchoolFilter _currentSchoolFilter = SchoolFilter.all;
  String _searchQuery = '';
  bool _showRightPanel = false;
  bool _isEditing = false;
  bool _isAddingNew = false;
  bool _showScheduleView = false;

  // ============ FORM CONTROLLERS ============
  final _formKey = GlobalKey<FormState>();
  final _subjectNameController = TextEditingController();

  // ============ FORM STATE ============
  String _selectedSchoolForm = 'a';
  bool _checkBox = true;
  List<Map<String, dynamic>> _formAsign = [];

  // ============ CONSTANTS ============
  final List<String> _classLevels = [
    'Nursery', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th', '5th',
    '6th', '7th', '8th', '9th', '10th', '11th', '12th'
  ];
  final List<String> _sectionList = ['A', 'B', 'C', 'D', 'E', 'F'];
  final List<String> _timeSlots = [
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
  final List<String> _schoolList = ['School A', 'School B'];

  final List<Map<String, String>> _availableTeachers = [
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

  @override
  void initState() {
    super.initState();
    controller.loadSubjects();
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    super.dispose();
  }

  // ============ GETTERS ============
  List<SubjectUIModel> get _filteredSubjects {
    var filtered = controller.subjects.map((s) => SubjectUIModel.fromApi(s)).toList();

    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      filtered = filtered.where((s) => s.school == 'School A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      filtered = filtered.where((s) => s.school == 'School B').toList();
    }

    if (_currentFilter != SubjectFilter.all) {
      filtered = filtered.where((s) {
        switch (_currentFilter) {
          case SubjectFilter.active: return s.isActive == true;
          case SubjectFilter.inactive: return s.isActive == false;
          case SubjectFilter.withTeacher: return s.teachers.isNotEmpty;
          case SubjectFilter.withoutTeacher: return s.teachers.isEmpty;
          case SubjectFilter.withSchedule: return s.asign.any((a) => a['slotTime'] != null);
          case SubjectFilter.withoutSchedule: return s.asign.every((a) => a['slotTime'] == null);
          default: return true;
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) =>
      s.name.toLowerCase().contains(query) ||
          s.code.toLowerCase().contains(query) ||
          s.teachers.any((t) => t.toLowerCase().contains(query)) ||
          s.school.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }

  int get _totalSubjects => controller.subjects.length;
  int get _activeSubjects => controller.subjects.where((s) => s.checkBox).length;
  int get _subjectsWithTeachers => controller.subjects.where((s) => s.asign.isNotEmpty).length;
  int get _subjectsWithSchedule => controller.subjects.where((s) => s.asign.any((a) => a.slotTime != null)).length;

  Map<String, int> get _schoolWiseStats => controller.schoolWiseStats;

  // ============ SHIMMER WIDGETS ============
  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 10,
                    width: 100,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerRightPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 20,
                width: 200,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 14,
                width: 150,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ FORM METHODS ============
  void _resetForm() {
    _subjectNameController.clear();
    _selectedSchoolForm = 'a';
    _checkBox = true;
    _formAsign = [];
  }

  void _loadSubjectToForm(SubjectApiModel subject) {
    _subjectNameController.text = subject.subjectName;
    _selectedSchoolForm = subject.schoolType;
    _checkBox = subject.checkBox;
    _formAsign = subject.asign.map((a) => ({
      'slotTime': a.slotTime,
      'classLevel': a.className,
      'room': a.roomNumber,
      'section': a.sectionName,
      'teacher': a.teacherName,
    })).toList();
  }

  // ============ CRUD OPERATIONS ============

  // ADD SUBJECT - Using controller.addSubject()
  void _addSubject() {
    if (!_formKey.currentState!.validate()) return;
    if (_formAsign.isEmpty) {
      FlutterToast.warning('Please add at least one teacher assignment');
      return;
    }

    // Set form data in controller
    controller.nameController.text = _subjectNameController.text.trim();
    controller.selectedSchoolForm.value = _selectedSchoolForm;
    controller.checkBox.value = _checkBox;
    controller.formAsign.value = _formAsign;

    // Call controller's addSubject method
    controller.addSubject();

    // Close panel after add (will be handled by controller)
  }

  // UPDATE SUBJECT - Using controller.updateSubject()
  void _updateSubject() {
    if (!_formKey.currentState!.validate()) return;
    if (_formAsign.isEmpty) {
      FlutterToast.warning('Please add at least one teacher assignment');
      return;
    }

    // Set form data in controller
    controller.nameController.text = _subjectNameController.text.trim();
    controller.selectedSchoolForm.value = _selectedSchoolForm;
    controller.checkBox.value = _checkBox;
    controller.formAsign.value = _formAsign;

    // Call controller's updateSubject method
    controller.updateSubject();
  }

  // DELETE SUBJECT - Using controller.deleteSubject()
  void _deleteSubject(SubjectApiModel subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.subjectName}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Call controller's deleteSubject method
              controller.deleteSubject(subject);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ============ ASSIGNMENT MANAGEMENT ============
  void _addAssignmentToForm() {
    setState(() {
      _formAsign.add({
        'slotTime': null,
        'classLevel': '10th',
        'room': null,
        'section': 'A',
        'teacher': _availableTeachers.isNotEmpty ? _availableTeachers[0]['name'] : '',
      });
    });
  }

  void _removeAssignmentFromForm(int index) {
    setState(() {
      _formAsign.removeAt(index);
    });
  }

  void _updateAssignmentField(int index, String key, dynamic value) {
    setState(() {
      final asign = Map<String, dynamic>.from(_formAsign[index]);
      asign[key] = value;
      _formAsign[index] = asign;
    });
  }

  // ============ TEACHER SELECTION ============
  void _showTeacherSelectionDialog() {
    List<String> tempSelected = _formAsign.map((a) => a['teacher'] as String).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Select Teachers'),
            content: Container(
              width: double.maxFinite,
              height: 350,
              child: ListView.builder(
                itemCount: _availableTeachers.length,
                itemBuilder: (context, index) {
                  final teacher = _availableTeachers[index];
                  final isSelected = tempSelected.contains(teacher['name']);
                  final isSchoolMatch = _selectedSchoolForm == teacher['school'];

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
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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

  // ============ HELPERS ============
  Color _getSchoolColor(String school) {
    switch (school) {
      case 'School A': return Colors.blue;
      case 'School B': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }

  String _getFilterLabel(SubjectFilter filter) {
    switch (filter) {
      case SubjectFilter.all: return 'All';
      case SubjectFilter.active: return 'Active';
      case SubjectFilter.inactive: return 'Inactive';
      case SubjectFilter.withTeacher: return 'With Teacher';
      case SubjectFilter.withoutTeacher: return 'No Teacher';
      case SubjectFilter.withSchedule: return 'Scheduled';
      case SubjectFilter.withoutSchedule: return 'No Schedule';
      default: return '';
    }
  }

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
    final schoolStats = _schoolWiseStats;
    final schoolLabel = _currentSchoolFilter == SchoolFilter.all
        ? 'All Schools'
        : _currentSchoolFilter == SchoolFilter.schoolA
        ? 'School A'
        : 'School B';

    return Obx(() {
      // Show shimmer while loading
      if (controller.isLoading.value && controller.subjects.isEmpty) {
        return Scaffold(
          body: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: _showRightPanel ? 5 : 8,
                  child: Column(
                    children: [
                      _buildHeader(schoolLabel, schoolStats),
                      _buildFilterSearchBar(),
                      Expanded(child: _buildShimmerList()),
                    ],
                  ),
                ),
                Container(
                  width: 480,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                      left: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: _buildShimmerRightPanel(),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        body: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              // Left Panel
              Expanded(
                flex: _showRightPanel ? 5 : 8,
                child: Column(
                  children: [
                    _buildHeader(schoolLabel, schoolStats),
                    _buildFilterSearchBar(),
                    Expanded(
                      child: _filteredSubjects.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredSubjects.length,
                        itemBuilder: (context, index) {
                          return _buildSubjectCard(_filteredSubjects[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Right Panel
              Container(
                width: 480,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: _showRightPanel
                    ? (_isAddingNew
                    ? _buildAddPanel()
                    : _isEditing
                    ? _buildEditPanel()
                    : _showScheduleView
                    ? _buildSchedulePanel()
                    : _buildViewPanel())
                    : _buildEmptyRightPanel(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ============ EMPTY RIGHT PANEL ============
  Widget _buildEmptyRightPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book_outlined,
                size: 60,
                color: Colors.blue[200],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Subject Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a subject from the list or create a new one',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '📚 ${_totalSubjects} Total Subjects',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEmptyStatCard(
                  icon: Icons.person,
                  label: 'With Teacher',
                  count: _subjectsWithTeachers,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildEmptyStatCard(
                  icon: Icons.schedule,
                  label: 'Scheduled',
                  count: _subjectsWithSchedule,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _resetForm();
                setState(() {
                  _isAddingNew = true;
                  _isEditing = false;
                  _showScheduleView = false;
                  controller.selectedSubject.value = null;
                  _showRightPanel = true;
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Subject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ============ HEADER ============
  Widget _buildHeader(String schoolLabel, Map<String, int> schoolStats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.book,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subjects Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${_filteredSubjects.length} subjects found',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SchoolFilter>(
                    value: _currentSchoolFilter,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    icon: Icon(Icons.school, color: Colors.grey[600], size: 18),
                    items: const [
                      DropdownMenuItem(
                        value: SchoolFilter.all,
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 16, color: Colors.grey),
                            SizedBox(width: 6),
                            Text('All Schools'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: SchoolFilter.schoolA,
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 16, color: Colors.blue),
                            SizedBox(width: 6),
                            Text('School A'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: SchoolFilter.schoolB,
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 16, color: Colors.green),
                            SizedBox(width: 6),
                            Text('School B'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _currentSchoolFilter = value!;
                        controller.selectedSubject.value = null;
                        _showRightPanel = false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!_showRightPanel || !_isAddingNew)
                ElevatedButton.icon(
                  onPressed: () {
                    _resetForm();
                    setState(() {
                      _isAddingNew = true;
                      _isEditing = false;
                      _showScheduleView = false;
                      controller.selectedSubject.value = null;
                      _showRightPanel = true;
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              if (_showRightPanel)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      controller.selectedSubject.value = null;
                      _isEditing = false;
                      _isAddingNew = false;
                      _showScheduleView = false;
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ FILTER AND SEARCH ============
  Widget _buildFilterSearchBar() {
    final filters = [
      SubjectFilter.all,
      SubjectFilter.active,
      SubjectFilter.inactive,
      SubjectFilter.withTeacher,
      SubjectFilter.withoutTeacher,
      SubjectFilter.withSchedule,
      SubjectFilter.withoutSchedule,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search subjects...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _buildFilterChip(_getFilterLabel(filter), filter),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SubjectFilter filter) {
    final isSelected = _currentFilter == filter;
    Color color = Colors.blue;
    if (filter == SubjectFilter.active) color = Colors.green;
    if (filter == SubjectFilter.inactive) color = Colors.red;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // ============ SUBJECT CARD ============
  Widget _buildSubjectCard(SubjectUIModel subject) {
    final isSelected = controller.selectedSubject.value?.id.toString() == subject.id;
    final schoolColor = _getSchoolColor(subject.school);
    final hasTeacher = subject.teachers.isNotEmpty;
    final hasSchedule = subject.asign.any((a) => a['slotTime'] != null);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasTeacher ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasTeacher ? Icons.check_circle : Icons.warning,
              color: hasTeacher ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                final apiSubject = controller.subjects.firstWhere(
                      (s) => s.id.toString() == subject.id,
                  orElse: () => controller.subjects.first,
                );
                setState(() {
                  controller.selectedSubject.value = apiSubject;
                  _showRightPanel = true;
                  _isEditing = false;
                  _isAddingNew = false;
                  _showScheduleView = false;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subject.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subject.code,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(subject.isActive).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subject.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(subject.isActive),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      _buildInfoText(Icons.school, subject.school, color: schoolColor),
                      _buildInfoText(Icons.person, '${subject.teachers.length} Teacher(s)'),
                      _buildInfoText(Icons.schedule, '${subject.asign.length} Schedule(s)'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSchedule)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    onPressed: () {
                      final apiSubject = controller.subjects.firstWhere(
                            (s) => s.id.toString() == subject.id,
                        orElse: () => controller.subjects.first,
                      );
                      setState(() {
                        controller.selectedSubject.value = apiSubject;
                        _showScheduleView = true;
                        _showRightPanel = true;
                        _isEditing = false;
                        _isAddingNew = false;
                      });
                    },
                    icon: Icon(
                      Icons.schedule,
                      size: 18,
                      color: Colors.orange[700],
                    ),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {
                    final apiSubject = controller.subjects.firstWhere(
                          (s) => s.id.toString() == subject.id,
                      orElse: () => controller.subjects.first,
                    );
                    _loadSubjectToForm(apiSubject);
                    setState(() {
                      controller.selectedSubject.value = apiSubject;
                      _isEditing = true;
                      _isAddingNew = false;
                      _showScheduleView = false;
                      _showRightPanel = true;
                    });
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.blue[700],
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {
                    final apiSubject = controller.subjects.firstWhere(
                          (s) => s.id.toString() == subject.id,
                      orElse: () => controller.subjects.first,
                    );
                    _deleteSubject(apiSubject);
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red[400],
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color ?? Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: color ?? Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ============ EMPTY STATE ============
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 50,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            'No Subjects Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Click "Add New" to create a subject',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _resetForm();
              setState(() {
                _isAddingNew = true;
                _isEditing = false;
                _showScheduleView = false;
                controller.selectedSubject.value = null;
                _showRightPanel = true;
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New Subject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ============ VIEW PANEL ============
  Widget _buildViewPanel() {
    final subject = controller.selectedSubject.value;
    if (subject == null) return const SizedBox();

    final uiSubject = SubjectUIModel.fromApi(subject);
    final schoolColor = _getSchoolColor(uiSubject.school);
    final hasTeacher = uiSubject.teachers.isNotEmpty;
    final hasSchedule = uiSubject.asign.any((a) => a['slotTime'] != null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: schoolColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.book,
                  color: schoolColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      uiSubject.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: schoolColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: schoolColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.school, size: 12, color: schoolColor),
                              const SizedBox(width: 4),
                              Text(
                                uiSubject.school,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: schoolColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Code: ${uiSubject.code}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(uiSubject.isActive).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            uiSubject.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(uiSubject.isActive),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailRow('🏫 School', uiSubject.school, color: schoolColor, isBold: true),
          _buildDetailRow('📚 Subject', uiSubject.name),
          _buildDetailRow('🏷️ Code', uiSubject.code),
          _buildDetailRow('👨‍🏫 Teachers', uiSubject.teachers.isEmpty ? 'No teachers assigned' : uiSubject.teachers.join(', ')),
          _buildDetailRow('📋 Status', uiSubject.isActive ? 'Active' : 'Inactive', color: _getStatusColor(uiSubject.isActive)),
          if (hasSchedule) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              '📖 Class Schedule',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...uiSubject.asign.map((assignment) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${assignment['classLevel']} - Section ${assignment['section']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Room ${assignment['room'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildDetailRow('⏰ Time', assignment['slotTime'] ?? 'Not Scheduled'),
                  _buildDetailRow('👨‍🏫 Teacher', assignment['teacher']),
                ],
              ),
            )),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      controller.selectedSubject.value = null;
                    });
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Close'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (hasSchedule)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showScheduleView = true;
                      });
                    },
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('Schedule'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _loadSubjectToForm(subject);
                    setState(() {
                      _isEditing = true;
                      _isAddingNew = false;
                      _showScheduleView = false;
                    });
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteSubject(subject),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: color ?? Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ SCHEDULE PANEL ============
  Widget _buildSchedulePanel() {
    final subject = controller.selectedSubject.value;
    if (subject == null) return const SizedBox();

    final uiSubject = SubjectUIModel.fromApi(subject);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Schedule - ${uiSubject.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showScheduleView = false;
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (uiSubject.asign.isEmpty || uiSubject.asign.every((a) => a['slotTime'] == null))
            Center(
              child: Column(
                children: [
                  Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No Schedule Assigned',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Add schedule from edit mode',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          else
            ...uiSubject.asign.map((assignment) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${assignment['classLevel']} - Section ${assignment['section']}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Room ${assignment['room'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.purple[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        assignment['slotTime'] ?? 'Not Scheduled',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Teacher: ${assignment['teacher']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  // ============ ADD PANEL ============
  Widget _buildAddPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_box_outlined,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Add New Subject',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormFields(isAdding: true),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _isAddingNew = false;
                      _resetForm();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : _addSubject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Add Subject',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ EDIT PANEL ============
  Widget _buildEditPanel() {
    final subject = controller.selectedSubject.value;
    if (subject == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Edit Subject',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormFields(isAdding: false),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : _updateSubject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Update',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ FORM FIELDS ============
  Widget _buildFormFields({required bool isAdding}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.book, color: Colors.blue[700], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Subject Information',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildFormTextField(_subjectNameController, 'Subject Name', Icons.book,
              hint: 'e.g., Mathematics', required: true),
          const SizedBox(height: 8),
          _buildDropdownField('School', _schoolList, _selectedSchoolForm == 'a' ? 'School A' : 'School B', (value) {
            setState(() {
              _selectedSchoolForm = value == 'School A' ? 'a' : 'b';
            });
          }, isCompact: true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.person_add, color: Colors.green[700], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Teacher Assignments',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 130,
                  child: _buildDropdownField('Status', ['Active', 'Inactive'],
                      _checkBox ? 'Active' : 'Inactive', (value) {
                        setState(() {
                          _checkBox = value == 'Active';
                        });
                      }, isCompact: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._formAsign.asMap().entries.map((entry) {
            final index = entry.key;
            final asign = entry.value;
            return _buildAsignForm(index, asign);
          }).toList(),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _addAssignmentToForm,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Teacher Assignment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[100],
              foregroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsignForm(int index, Map<String, dynamic> asign) {
    final availableTeachers = _availableTeachers
        .where((t) => t['school'] == _selectedSchoolForm)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assignment ${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              IconButton(
                onPressed: () => _removeAssignmentFromForm(index),
                icon: Icon(Icons.close, size: 16, color: Colors.red[400]),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField('Class', _classLevels, asign['classLevel'] ?? '10th', (value) {
                  _updateAssignmentField(index, 'classLevel', value);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdownField('Section', _sectionList, asign['section'] ?? 'A', (value) {
                  _updateAssignmentField(index, 'section', value);
                }),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildDropdownField('Time Slot', _timeSlots, asign['slotTime'] ?? _timeSlots[0], (value) {
            _updateAssignmentField(index, 'slotTime', value);
          }),
          const SizedBox(height: 4),
          _buildFormTextField(
            TextEditingController(text: asign['room'] ?? ''),
            'Room Number',
            Icons.room,
            hint: 'e.g., 101',
            onChanged: (value) {
              _updateAssignmentField(index, 'room', value);
            },
          ),
          const SizedBox(height: 4),
          if (availableTeachers.isNotEmpty)
            _buildDropdownField('Teacher', availableTeachers.map((t) => t['name']!).toList(), asign['teacher'] ?? '', (value) {
              _updateAssignmentField(index, 'teacher', value);
            })
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'No teachers available for this school',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============ FORM HELPERS ============
  Widget _buildFormTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        String? hint,
        bool required = false,
        int maxLines = 1,
        TextInputType? keyboardType,
        Function(String)? onChanged,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 16, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
          floatingLabelStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
        validator: required
            ? (v) => v?.trim().isEmpty ?? true ? '$label is required' : null
            : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value,
      Function(String?) onChanged, {bool isCompact = false}) {
    String selectedValue = value;
    if (!items.contains(selectedValue) && items.isNotEmpty) {
      selectedValue = items.first;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 1),
          ),
          contentPadding: isCompact
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: isCompact,
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
          floatingLabelStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: TextStyle(fontSize: isCompact ? 12 : 13)),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}