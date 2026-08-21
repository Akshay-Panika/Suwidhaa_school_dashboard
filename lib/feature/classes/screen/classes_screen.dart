import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

// ============ ENUMS ============
enum ClassFilter {
  all,
  nursery,
  lkg,
  ukg,
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  seventh,
  eighth,
  ninth,
  tenth,
  eleventh,
  twelfth,
}

enum ClassStatus {
  active,
  inactive,
  completed,
}

enum SchoolFilter {
  all,
  schoolA,
  schoolB,
}

// ============ MODEL ============
class ClassSection {
  final String section;
  final String classTeacher;
  final String teacherId;
  final String room;
  final List<String> subjects;
  final int studentCount;

  ClassSection({
    required this.section,
    required this.classTeacher,
    required this.teacherId,
    required this.room,
    required this.subjects,
    required this.studentCount,
  });

  Map<String, dynamic> toJson() => {
    'section': section,
    'classTeacher': classTeacher,
    'teacherId': teacherId,
    'room': room,
    'subjects': subjects,
    'studentCount': studentCount.toString(),
  };

  factory ClassSection.fromJson(Map<String, dynamic> json) => ClassSection(
    section: json['section'],
    classTeacher: json['classTeacher'],
    teacherId: json['teacherId'],
    room: json['room'],
    subjects: List<String>.from(json['subjects']),
    studentCount: int.parse(json['studentCount']),
  );
}

class ClassModel {
  final String id;
  final String classLevel;
  final String school;
  final List<ClassSection> sections;
  final ClassStatus status;
  final int totalStudents;

  ClassModel({
    required this.id,
    required this.classLevel,
    required this.school,
    required this.sections,
    this.status = ClassStatus.active,
    required this.totalStudents,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classLevel': classLevel,
    'school': school,
    'sections': sections.map((s) => s.toJson()).toList(),
    'status': status.toString().split('.').last,
    'totalStudents': totalStudents.toString(),
  };

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
    id: json['id'],
    classLevel: json['classLevel'],
    school: json['school'],
    sections: (json['sections'] as List).map((s) => ClassSection.fromJson(s)).toList(),
    status: ClassStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
      orElse: () => ClassStatus.active,
    ),
    totalStudents: int.parse(json['totalStudents']),
  );

  String get displayName => '$classLevel Class';
  String get statusDisplay => status.toString().split('.').last;
  Color get statusColor {
    switch (status) {
      case ClassStatus.active: return Colors.green;
      case ClassStatus.inactive: return Colors.red;
      case ClassStatus.completed: return Colors.blue;
    }
  }
}

// ============ MAIN SCREEN ============
class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  // ============ STATE ============
  List<ClassModel> _classes = [];
  ClassFilter _currentFilter = ClassFilter.all;
  SchoolFilter _currentSchoolFilter = SchoolFilter.all;
  String _searchQuery = '';
  bool _showRightPanel = false;
  ClassModel? _selectedClass;
  bool _isEditing = false;
  bool _isAddingNew = false;

  // ============ FORM CONTROLLERS ============
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _sectionController = TextEditingController();
  final _classTeacherController = TextEditingController();
  final _roomController = TextEditingController();
  final _subjectsController = TextEditingController();

  // ============ FORM STATE ============
  String _selectedClassLevel = 'Nursery';
  String _selectedSchoolForm = 'School A';
  ClassStatus _selectedStatus = ClassStatus.active;
  List<ClassSection> _formSections = [];
  File? _imageFile;

  // ============ CONSTANTS ============
  final List<String> _classLevels = [
    'Nursery', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th', '5th',
    '6th', '7th', '8th', '9th', '10th', '11th', '12th'
  ];
  final List<String> _schoolList = ['School A', 'School B'];
  final List<String> _sectionList = ['A', 'B', 'C', 'D', 'E', 'F'];
  final List<String> _subjectList = [
    'Mathematics', 'English', 'Science', 'History', 'Geography',
    'Computer Science', 'Physics', 'Chemistry', 'Biology', 'Art',
    'Music', 'Physical Education', 'Social Studies', 'Hindi', 'Sanskrit'
  ];

  final List<Map<String, String>> _availableTeachers = [
    {'id': 'T001', 'name': 'Dr. Rajesh Kumar'},
    {'id': 'T002', 'name': 'Ms. Meera Singh'},
    {'id': 'T003', 'name': 'Mr. Suresh Patel'},
    {'id': 'T004', 'name': 'Mrs. Anita Sharma'},
    {'id': 'T005', 'name': 'Mr. Vikram Reddy'},
    {'id': 'T006', 'name': 'Dr. Priya Gupta'},
    {'id': 'T007', 'name': 'Mr. Arjun Nair'},
    {'id': 'T008', 'name': 'Ms. Kavya Reddy'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _sectionController.dispose();
    _classTeacherController.dispose();
    _roomController.dispose();
    _subjectsController.dispose();
    super.dispose();
  }

  // ============ SAMPLE DATA ============
  void _loadSampleData() {
    _classes = [
      ClassModel(
        id: 'CLS001',
        classLevel: '10th',
        school: 'School A',
        sections: [
          ClassSection(
            section: 'A',
            classTeacher: 'Dr. Rajesh Kumar',
            teacherId: 'T001',
            room: '101',
            subjects: ['Mathematics', 'Science', 'English', 'History', 'Computer Science'],
            studentCount: 42,
          ),
          ClassSection(
            section: 'B',
            classTeacher: 'Mr. Suresh Patel',
            teacherId: 'T003',
            room: '102',
            subjects: ['Mathematics', 'Science', 'English', 'History', 'Computer Science'],
            studentCount: 38,
          ),
        ],
        totalStudents: 80,
      ),
      ClassModel(
        id: 'CLS002',
        classLevel: '9th',
        school: 'School A',
        sections: [
          ClassSection(
            section: 'A',
            classTeacher: 'Ms. Meera Singh',
            teacherId: 'T002',
            room: '201',
            subjects: ['Mathematics', 'Science', 'English', 'History', 'Computer Science'],
            studentCount: 40,
          ),
          ClassSection(
            section: 'B',
            classTeacher: 'Mrs. Anita Sharma',
            teacherId: 'T004',
            room: '202',
            subjects: ['Mathematics', 'Science', 'English', 'History', 'Computer Science'],
            studentCount: 36,
          ),
        ],
        totalStudents: 76,
      ),
      ClassModel(
        id: 'CLS003',
        classLevel: '8th',
        school: 'School B',
        sections: [
          ClassSection(
            section: 'A',
            classTeacher: 'Mr. Vikram Reddy',
            teacherId: 'T005',
            room: '301',
            subjects: ['Mathematics', 'Science', 'English', 'History', 'Computer Science'],
            studentCount: 35,
          ),
          ClassSection(
            section: 'B',
            classTeacher: 'Dr. Rajesh Kumar',
            teacherId: 'T001',
            room: '302',
            subjects: ['Mathematics', 'Science', 'English', 'History', 'Computer Science'],
            studentCount: 33,
          ),
        ],
        totalStudents: 68,
      ),
      ClassModel(
        id: 'CLS004',
        classLevel: '7th',
        school: 'School B',
        sections: [
          ClassSection(
            section: 'A',
            classTeacher: 'Dr. Priya Gupta',
            teacherId: 'T006',
            room: '401',
            subjects: ['Mathematics', 'Science', 'English', 'History', 'Geography'],
            studentCount: 30,
          ),
        ],
        totalStudents: 30,
      ),
      ClassModel(
        id: 'CLS005',
        classLevel: '6th',
        school: 'School A',
        sections: [
          ClassSection(
            section: 'A',
            classTeacher: 'Mr. Arjun Nair',
            teacherId: 'T007',
            room: '501',
            subjects: ['Mathematics', 'Science', 'English', 'History', 'Geography'],
            studentCount: 28,
          ),
          ClassSection(
            section: 'B',
            classTeacher: 'Ms. Kavya Reddy',
            teacherId: 'T008',
            room: '502',
            subjects: ['Mathematics', 'Science', 'English', 'History', 'Geography'],
            studentCount: 25,
          ),
        ],
        status: ClassStatus.inactive,
        totalStudents: 53,
      ),
      ClassModel(
        id: 'CLS006',
        classLevel: '5th',
        school: 'School B',
        sections: [
          ClassSection(
            section: 'A',
            classTeacher: 'Dr. Priya Gupta',
            teacherId: 'T006',
            room: '601',
            subjects: ['Mathematics', 'Science', 'English', 'History', 'Geography'],
            studentCount: 32,
          ),
        ],
        totalStudents: 32,
      ),
    ];
  }

  // ============ GETTERS ============
  List<ClassModel> get _filteredClasses {
    var filtered = _classes;

    // School Filter
    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      filtered = filtered.where((classItem) => classItem.school == 'School A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      filtered = filtered.where((classItem) => classItem.school == 'School B').toList();
    }

    // Class Level Filter
    if (_currentFilter != ClassFilter.all) {
      filtered = filtered.where((classItem) {
        final level = classItem.classLevel.toLowerCase();
        switch (_currentFilter) {
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

    // Search Filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((classItem) =>
      classItem.classLevel.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          classItem.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          classItem.school.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          classItem.sections.any((s) =>
          s.classTeacher.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.subjects.join(' ').toLowerCase().contains(_searchQuery.toLowerCase())
          )
      ).toList();
    }

    return filtered;
  }

  int get _totalClasses => _classes.length;
  int get _activeClasses => _classes.where((c) => c.status == ClassStatus.active).length;
  int get _inactiveClasses => _classes.where((c) => c.status == ClassStatus.inactive).length;
  int get _totalStudents => _classes.fold<int>(0, (sum, c) => sum + c.totalStudents);
  int get _totalSections => _classes.fold<int>(0, (sum, c) => sum + c.sections.length);

  Map<String, int> get _schoolWiseStats {
    Map<String, int> stats = {};
    for (var classItem in _classes) {
      stats[classItem.school] = (stats[classItem.school] ?? 0) + 1;
    }
    return stats;
  }

  // ============ FORM METHODS ============
  void _resetForm() {
    _classNameController.clear();
    _sectionController.clear();
    _classTeacherController.clear();
    _roomController.clear();
    _subjectsController.clear();
    _selectedClassLevel = 'Nursery';
    _selectedSchoolForm = 'School A';
    _selectedStatus = ClassStatus.active;
    _formSections = [];
    _imageFile = null;
  }

  void _loadClassToForm(ClassModel classItem) {
    _selectedClassLevel = classItem.classLevel;
    _selectedSchoolForm = classItem.school;
    _selectedStatus = classItem.status;
    _formSections = List.from(classItem.sections);
  }

  ClassModel _createClassFromForm(String id) {
    final totalStudents = _formSections.fold<int>(0, (sum, s) => sum + s.studentCount);

    return ClassModel(
      id: id,
      classLevel: _selectedClassLevel,
      school: _selectedSchoolForm,
      sections: _formSections.map((s) => ClassSection(
        section: s.section,
        classTeacher: s.classTeacher,
        teacherId: s.teacherId,
        room: s.room,
        subjects: s.subjects,
        studentCount: s.studentCount,
      )).toList(),
      status: _selectedStatus,
      totalStudents: totalStudents,
    );
  }

  // ============ CRUD OPERATIONS ============
  void _addClass() {
    if (!_formKey.currentState!.validate()) return;
    if (_formSections.isEmpty) {
      _showSnackbar('Please add at least one section', Colors.orange);
      return;
    }

    final newClass = _createClassFromForm('CLS${(_classes.length + 1).toString().padLeft(3, '0')}');

    setState(() {
      _classes.add(newClass);
      _showRightPanel = false;
      _isAddingNew = false;
      _resetForm();
    });

    _showSnackbar('Class added successfully!', Colors.green);
  }

  void _updateClass() {
    if (!_formKey.currentState!.validate()) return;
    if (_formSections.isEmpty) {
      _showSnackbar('Please add at least one section', Colors.orange);
      return;
    }

    final updatedClass = _createClassFromForm(_selectedClass!.id);
    final index = _classes.indexWhere((c) => c.id == _selectedClass!.id);

    if (index != -1) {
      setState(() {
        _classes[index] = updatedClass;
        _selectedClass = updatedClass;
        _isEditing = false;
        _resetForm();
      });
      _showSnackbar('Class updated successfully!', Colors.blue);
    }
  }

  void _deleteClass(ClassModel classItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete ${classItem.displayName}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _classes.removeWhere((c) => c.id == classItem.id);
                if (_selectedClass?.id == classItem.id) {
                  _showRightPanel = false;
                  _selectedClass = null;
                }
              });
              _showSnackbar('Class deleted successfully!', Colors.red);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ============ SECTION MANAGEMENT ============
  void _addSectionToForm() {
    setState(() {
      _formSections.add(ClassSection(
        section: 'A',
        classTeacher: '',
        teacherId: '',
        room: '',
        subjects: [],
        studentCount: 0,
      ));
    });
  }

  void _removeSectionFromForm(int index) {
    setState(() {
      _formSections.removeAt(index);
    });
  }

  void _updateSectionField(int index, String key, dynamic value) {
    setState(() {
      final section = _formSections[index];
      switch (key) {
        case 'section':
          _formSections[index] = ClassSection(
            section: value,
            classTeacher: section.classTeacher,
            teacherId: section.teacherId,
            room: section.room,
            subjects: section.subjects,
            studentCount: section.studentCount,
          );
          break;
        case 'classTeacher':
          final teacher = _availableTeachers.firstWhere(
                (t) => t['name'] == value,
            orElse: () => {'id': '', 'name': ''},
          );
          _formSections[index] = ClassSection(
            section: section.section,
            classTeacher: value,
            teacherId: teacher['id'] ?? '',
            room: section.room,
            subjects: section.subjects,
            studentCount: section.studentCount,
          );
          break;
        case 'room':
          _formSections[index] = ClassSection(
            section: section.section,
            classTeacher: section.classTeacher,
            teacherId: section.teacherId,
            room: value,
            subjects: section.subjects,
            studentCount: section.studentCount,
          );
          break;
        case 'studentCount':
          _formSections[index] = ClassSection(
            section: section.section,
            classTeacher: section.classTeacher,
            teacherId: section.teacherId,
            room: section.room,
            subjects: section.subjects,
            studentCount: int.tryParse(value) ?? 0,
          );
          break;
        case 'subjects':
          _formSections[index] = ClassSection(
            section: section.section,
            classTeacher: section.classTeacher,
            teacherId: section.teacherId,
            room: section.room,
            subjects: List<String>.from(value),
            studentCount: section.studentCount,
          );
          break;
      }
    });
  }

  void _toggleSubjectForSection(int index, String subject) {
    final section = _formSections[index];
    final subjects = List<String>.from(section.subjects);
    if (subjects.contains(subject)) {
      subjects.remove(subject);
    } else {
      subjects.add(subject);
    }
    _updateSectionField(index, 'subjects', subjects);
  }

  // ============ HELPERS ============
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Color _getSchoolColor(String school) {
    switch (school) {
      case 'School A': return Colors.blue;
      case 'School B': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return parts[0][0] + parts[1][0];
    return name.substring(0, 2).toUpperCase();
  }

  String _getClassFilterLabel(ClassFilter filter) {
    switch (filter) {
      case ClassFilter.all: return 'All';
      case ClassFilter.nursery: return 'Nursery';
      case ClassFilter.lkg: return 'LKG';
      case ClassFilter.ukg: return 'UKG';
      case ClassFilter.first: return '1st';
      case ClassFilter.second: return '2nd';
      case ClassFilter.third: return '3rd';
      case ClassFilter.fourth: return '4th';
      case ClassFilter.fifth: return '5th';
      case ClassFilter.sixth: return '6th';
      case ClassFilter.seventh: return '7th';
      case ClassFilter.eighth: return '8th';
      case ClassFilter.ninth: return '9th';
      case ClassFilter.tenth: return '10th';
      case ClassFilter.eleventh: return '11th';
      case ClassFilter.twelfth: return '12th';
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
                    child: _filteredClasses.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredClasses.length,
                      itemBuilder: (context, index) {
                        return _buildClassCard(_filteredClasses[index]);
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
                  : _buildViewPanel())
                  : _buildEmptyRightPanel(),
            ),
          ],
        ),
      ),
    );
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
                Icons.class_outlined,
                size: 60,
                color: Colors.blue[200],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Class Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a class from the list or create a new one',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '📚 ${_totalClasses} Total Classes',
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
                  icon: Icons.check_circle,
                  label: 'Active',
                  count: _activeClasses,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildEmptyStatCard(
                  icon: Icons.cancel,
                  label: 'Inactive',
                  count: _inactiveClasses,
                  color: Colors.red,
                ),
                const SizedBox(width: 12),
                _buildEmptyStatCard(
                  icon: Icons.people,
                  label: 'Students',
                  count: _totalStudents,
                  color: Colors.blue,
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
                  _selectedClass = null;
                  _showRightPanel = true;
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Class'),
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
                  Icons.class_,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Classes Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          schoolLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_filteredClasses.length} classes found',
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

              if (!_showRightPanel || !_isAddingNew)
                ElevatedButton.icon(
                  onPressed: () {
                    _resetForm();
                    setState(() {
                      _isAddingNew = true;
                      _isEditing = false;
                      _selectedClass = null;
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
                      _selectedClass = null;
                      _isEditing = false;
                      _isAddingNew = false;
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
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
                      hintText: 'Search classes...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                      prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
                    items: [
                      const DropdownMenuItem(
                        value: SchoolFilter.all,
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 16, color: Colors.grey),
                            SizedBox(width: 6),
                            Text('All Schools'),
                          ],
                        ),
                      ),
                      const DropdownMenuItem(
                        value: SchoolFilter.schoolA,
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 16, color: Colors.blue),
                            SizedBox(width: 6),
                            Text('School A'),
                          ],
                        ),
                      ),
                      const DropdownMenuItem(
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
                        _selectedClass = null;
                        _showRightPanel = false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', ClassFilter.all),
                const SizedBox(width: 4),
                _buildFilterChip('Nursery', ClassFilter.nursery),
                const SizedBox(width: 4),
                _buildFilterChip('LKG', ClassFilter.lkg),
                const SizedBox(width: 4),
                _buildFilterChip('UKG', ClassFilter.ukg),
                const SizedBox(width: 4),
                _buildFilterChip('1st', ClassFilter.first),
                const SizedBox(width: 4),
                _buildFilterChip('2nd', ClassFilter.second),
                const SizedBox(width: 4),
                _buildFilterChip('3rd', ClassFilter.third),
                const SizedBox(width: 4),
                _buildFilterChip('4th', ClassFilter.fourth),
                const SizedBox(width: 4),
                _buildFilterChip('5th', ClassFilter.fifth),
                const SizedBox(width: 4),
                _buildFilterChip('6th', ClassFilter.sixth),
                const SizedBox(width: 4),
                _buildFilterChip('7th', ClassFilter.seventh),
                const SizedBox(width: 4),
                _buildFilterChip('8th', ClassFilter.eighth),
                const SizedBox(width: 4),
                _buildFilterChip('9th', ClassFilter.ninth),
                const SizedBox(width: 4),
                _buildFilterChip('10th', ClassFilter.tenth),
                const SizedBox(width: 4),
                _buildFilterChip('11th', ClassFilter.eleventh),
                const SizedBox(width: 4),
                _buildFilterChip('12th', ClassFilter.twelfth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ClassFilter filter) {
    final isSelected = _currentFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[200]!,
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

  // ============ CLASS CARD ============
  Widget _buildClassCard(ClassModel classItem) {
    final isSelected = _selectedClass?.id == classItem.id;
    final schoolColor = _getSchoolColor(classItem.school);

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
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: schoolColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.class_,
              color: schoolColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedClass = classItem;
                  _showRightPanel = true;
                  _isEditing = false;
                  _isAddingNew = false;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          classItem.displayName,
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
                          color: classItem.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          classItem.statusDisplay,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: classItem.statusColor,
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
                      _buildInfoText(Icons.school, classItem.school, color: schoolColor),
                      _buildInfoText(Icons.view_list, '${classItem.sections.length} Sections'),
                      _buildInfoText(Icons.people, '${classItem.totalStudents} Students'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {
                    _loadClassToForm(classItem);
                    setState(() {
                      _selectedClass = classItem;
                      _isEditing = true;
                      _isAddingNew = false;
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
                  onPressed: () => _deleteClass(classItem),
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
            Icons.class_outlined,
            size: 50,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            'No Classes Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Click "Add New" to create a class',
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
                _selectedClass = null;
                _showRightPanel = true;
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New Class'),
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
    if (_selectedClass == null) return const SizedBox();

    final classItem = _selectedClass!;
    final schoolColor = _getSchoolColor(classItem.school);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  Icons.class_,
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
                      classItem.displayName,
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
                                classItem.school,
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
                            color: classItem.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            classItem.statusDisplay,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: classItem.statusColor,
                            ),
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
                            classItem.id,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
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

          // Info
          _buildDetailRow('🏫 School', classItem.school, color: schoolColor, isBold: true),
          _buildDetailRow('📚 Total Students', classItem.totalStudents.toString()),
          _buildDetailRow('📋 Total Sections', classItem.sections.length.toString()),
          _buildDetailRow('📊 Status', classItem.statusDisplay, color: classItem.statusColor),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Sections
          const Text(
            '📖 Sections',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...classItem.sections.map((section) => Container(
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
                      'Section ${section.section}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${section.studentCount} Students',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildDetailRow('👨‍🏫 Class Teacher', section.classTeacher),
                _buildDetailRow('🏠 Room', section.room),
                _buildDetailRow('📚 Subjects', section.subjects.join(', ')),
              ],
            ),
          )),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _selectedClass = null;
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
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _loadClassToForm(classItem);
                    setState(() {
                      _isEditing = true;
                      _isAddingNew = false;
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
                  onPressed: () => _deleteClass(classItem),
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
                'Add New Class',
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
                  onPressed: _addClass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Class',
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
    if (_selectedClass == null) return const SizedBox();

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
                'Edit Class',
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
                  onPressed: _updateClass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Class Information
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Class Information',
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
        Row(
          children: [
            Expanded(
              child: _buildDropdownField('Class Level', _classLevels, _selectedClassLevel, (value) {
                setState(() => _selectedClassLevel = value!);
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdownField('School', _schoolList, _selectedSchoolForm, (value) {
                setState(() => _selectedSchoolForm = value!);
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDropdownField('Status',
            ['Active', 'Inactive', 'Completed'],
            _selectedStatus.toString().split('.').last,
                (value) {
              setState(() {
                _selectedStatus = ClassStatus.values.firstWhere(
                      (e) => e.toString().split('.').last == value,
                  orElse: () => ClassStatus.active,
                );
              });
            }),
        const SizedBox(height: 12),

        // Sections
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.view_list, color: Colors.green[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Sections',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._formSections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          return _buildSectionForm(index, section);
        }).toList(),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addSectionToForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Section'),
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
    );
  }

  Widget _buildSectionForm(int index, ClassSection section) {
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
                'Section ${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              IconButton(
                onPressed: () => _removeSectionFromForm(index),
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
                child: _buildDropdownField('Section', _sectionList, section.section, (value) {
                  _updateSectionField(index, 'section', value);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFormTextField(
                  controller: TextEditingController(text: section.room),
                  label: 'Room',
                  icon: Icons.room,
                  onChanged: (value) => _updateSectionField(index, 'room', value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildDropdownSearchField(
            label: 'Class Teacher',
            value: section.classTeacher,
            items: _availableTeachers.map((t) => t['name'] as String).toList(),
            onChanged: (value) => _updateSectionField(index, 'classTeacher', value),
          ),
          const SizedBox(height: 4),
          _buildFormTextField(
            controller: TextEditingController(text: section.studentCount.toString()),
            label: 'Student Count',
            icon: Icons.people,
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateSectionField(index, 'studentCount', value),
          ),
          const SizedBox(height: 4),
          Text(
            'Subjects:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _subjectList.map((subject) {
              final isSelected = section.subjects.contains(subject);
              return FilterChip(
                label: Text(
                  subject,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => _toggleSubjectForSection(index, subject),
                selectedColor: Colors.blue[700],
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============ FORM HELPERS ============
  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
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
          prefixIcon: icon != null
              ? Icon(icon, size: 16, color: Colors.grey[600])
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
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
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          floatingLabelStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDropdownSearchField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DropdownButtonFormField<String>(
        value: value.isNotEmpty ? value : null,
        isExpanded: true,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.person, size: 16, color: Colors.grey[600]),
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
          labelStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          floatingLabelStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: '',
            child: Text('Select Teacher', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          ...items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13)),
            );
          }),
        ],
        onChanged: (value) => onChanged(value ?? ''),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}