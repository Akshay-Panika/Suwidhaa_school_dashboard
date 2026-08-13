import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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

// ============ MODEL ============
class ClassAssignment {
  final String classLevel;
  final String section;
  final String timeSlot;
  final String room;
  final String teacher;

  ClassAssignment({
    required this.classLevel,
    required this.section,
    required this.timeSlot,
    required this.room,
    required this.teacher,
  });

  Map<String, dynamic> toJson() => {
    'classLevel': classLevel,
    'section': section,
    'timeSlot': timeSlot,
    'room': room,
    'teacher': teacher,
  };

  factory ClassAssignment.fromJson(Map<String, dynamic> json) => ClassAssignment(
    classLevel: json['classLevel'],
    section: json['section'],
    timeSlot: json['timeSlot'],
    room: json['room'],
    teacher: json['teacher'],
  );
}

class SubjectModel {
  final String id;
  final String name;
  final String code;
  final List<String> teachers;
  final List<String> teacherIds;
  final SubjectStatus status;
  final String? photo;
  final List<ClassAssignment> classAssignments;

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.teachers,
    required this.teacherIds,
    this.status = SubjectStatus.active,
    this.photo,
    this.classAssignments = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'teachers': teachers,
    'teacherIds': teacherIds,
    'status': status.toString().split('.').last,
    'photo': photo,
    'classAssignments': classAssignments.map((a) => a.toJson()).toList(),
  };

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
    id: json['id'],
    name: json['name'],
    code: json['code'],
    teachers: List<String>.from(json['teachers']),
    teacherIds: List<String>.from(json['teacherIds']),
    status: SubjectStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
      orElse: () => SubjectStatus.active,
    ),
    photo: json['photo'],
    classAssignments: (json['classAssignments'] as List)
        .map((a) => ClassAssignment.fromJson(a))
        .toList(),
  );

  String get statusDisplay => status.toString().split('.').last;
  Color get statusColor {
    switch (status) {
      case SubjectStatus.active: return Colors.green;
      case SubjectStatus.inactive: return Colors.red;
      case SubjectStatus.upcoming: return Colors.orange;
      case SubjectStatus.completed: return Colors.blue;
    }
  }
}

// ============ MAIN SCREEN ============
class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  // ============ STATE ============
  List<SubjectModel> _subjects = [];
  SubjectFilter _currentFilter = SubjectFilter.all;
  String _searchQuery = '';
  bool _showRightPanel = false;
  SubjectModel? _selectedSubject;
  bool _isEditing = false;
  bool _isAddingNew = false;
  bool _showScheduleView = false;

  // ============ FORM CONTROLLERS ============
  final _formKey = GlobalKey<FormState>();
  final _subjectNameController = TextEditingController();
  final _subjectCodeController = TextEditingController();

  // ============ FORM STATE ============
  SubjectStatus _selectedStatus = SubjectStatus.active;
  List<String> _selectedTeachers = [];
  List<ClassAssignment> _formAssignments = [];
  File? _imageFile;

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
  final List<String> _statusList = ['Active', 'Inactive', 'Upcoming', 'Completed'];

  final List<Map<String, String>> _availableTeachers = [
    {'id': 'T001', 'name': 'Dr. Rajesh Kumar', 'subject': 'Mathematics'},
    {'id': 'T002', 'name': 'Ms. Meera Singh', 'subject': 'Science'},
    {'id': 'T003', 'name': 'Mr. Suresh Patel', 'subject': 'English'},
    {'id': 'T004', 'name': 'Mrs. Anita Sharma', 'subject': 'History'},
    {'id': 'T005', 'name': 'Mr. Vikram Reddy', 'subject': 'Computer Science'},
    {'id': 'T006', 'name': 'Dr. Priya Gupta', 'subject': 'Biology'},
    {'id': 'T007', 'name': 'Mr. Arjun Nair', 'subject': 'Physics'},
    {'id': 'T008', 'name': 'Ms. Kavya Reddy', 'subject': 'Chemistry'},
    {'id': 'T009', 'name': 'Mr. Amit Singh', 'subject': 'Geography'},
    {'id': 'T010', 'name': 'Ms. Neha Sharma', 'subject': 'Art'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    super.dispose();
  }

  // ============ SAMPLE DATA ============
  void _loadSampleData() {
    _subjects = [
      SubjectModel(
        id: 'SUB001',
        name: 'Mathematics',
        code: 'MATH',
        teachers: ['Dr. Rajesh Kumar', 'Mr. Arjun Nair'],
        teacherIds: ['T001', 'T007'],
        classAssignments: [
          ClassAssignment(
            classLevel: '10th',
            section: 'A',
            timeSlot: '8:00 AM - 8:45 AM',
            room: '101',
            teacher: 'Dr. Rajesh Kumar',
          ),
          ClassAssignment(
            classLevel: '10th',
            section: 'B',
            timeSlot: '9:30 AM - 10:15 AM',
            room: '102',
            teacher: 'Dr. Rajesh Kumar',
          ),
          ClassAssignment(
            classLevel: '9th',
            section: 'A',
            timeSlot: '10:30 AM - 11:15 AM',
            room: '201',
            teacher: 'Mr. Arjun Nair',
          ),
        ],
      ),
      SubjectModel(
        id: 'SUB002',
        name: 'Science',
        code: 'SCI',
        teachers: ['Ms. Meera Singh', 'Dr. Priya Gupta'],
        teacherIds: ['T002', 'T006'],
        classAssignments: [
          ClassAssignment(
            classLevel: '10th',
            section: 'A',
            timeSlot: '8:45 AM - 9:30 AM',
            room: '101',
            teacher: 'Ms. Meera Singh',
          ),
          ClassAssignment(
            classLevel: '9th',
            section: 'B',
            timeSlot: '11:15 AM - 12:00 PM',
            room: '202',
            teacher: 'Dr. Priya Gupta',
          ),
        ],
      ),
      SubjectModel(
        id: 'SUB003',
        name: 'English',
        code: 'ENG',
        teachers: ['Mr. Suresh Patel'],
        teacherIds: ['T003'],
        classAssignments: [
          ClassAssignment(
            classLevel: '8th',
            section: 'A',
            timeSlot: '9:30 AM - 10:15 AM',
            room: '301',
            teacher: 'Mr. Suresh Patel',
          ),
        ],
      ),
      SubjectModel(
        id: 'SUB004',
        name: 'History',
        code: 'HIS',
        teachers: ['Mrs. Anita Sharma'],
        teacherIds: ['T004'],
        classAssignments: [],
      ),
      SubjectModel(
        id: 'SUB005',
        name: 'Computer Science',
        code: 'CS',
        teachers: ['Mr. Vikram Reddy', 'Ms. Kavya Reddy'],
        teacherIds: ['T005', 'T008'],
        classAssignments: [
          ClassAssignment(
            classLevel: '10th',
            section: 'A',
            timeSlot: '11:15 AM - 12:00 PM',
            room: 'Computer Lab',
            teacher: 'Mr. Vikram Reddy',
          ),
          ClassAssignment(
            classLevel: '9th',
            section: 'A',
            timeSlot: '12:00 PM - 12:45 PM',
            room: 'Computer Lab',
            teacher: 'Ms. Kavya Reddy',
          ),
        ],
      ),
      SubjectModel(
        id: 'SUB006',
        name: 'Geography',
        code: 'GEO',
        teachers: [],
        teacherIds: [],
        status: SubjectStatus.inactive,
        classAssignments: [],
      ),
      SubjectModel(
        id: 'SUB007',
        name: 'Physics',
        code: 'PHY',
        teachers: ['Mr. Arjun Nair', 'Dr. Priya Gupta'],
        teacherIds: ['T007', 'T006'],
        status: SubjectStatus.upcoming,
        classAssignments: [
          ClassAssignment(
            classLevel: '11th',
            section: 'A',
            timeSlot: '8:00 AM - 8:45 AM',
            room: 'Physics Lab',
            teacher: 'Mr. Arjun Nair',
          ),
        ],
      ),
      SubjectModel(
        id: 'SUB008',
        name: 'Chemistry',
        code: 'CHE',
        teachers: ['Ms. Kavya Reddy', 'Ms. Meera Singh'],
        teacherIds: ['T008', 'T002'],
        status: SubjectStatus.upcoming,
        classAssignments: [],
      ),
      SubjectModel(
        id: 'SUB009',
        name: 'Art',
        code: 'ART',
        teachers: [],
        teacherIds: [],
        classAssignments: [],
      ),
    ];
  }

  // ============ GETTERS ============
  List<SubjectModel> get _filteredSubjects {
    var filtered = _subjects;

    if (_currentFilter != SubjectFilter.all) {
      filtered = filtered.where((subject) {
        switch (_currentFilter) {
          case SubjectFilter.active: return subject.status == SubjectStatus.active;
          case SubjectFilter.inactive: return subject.status == SubjectStatus.inactive;
          case SubjectFilter.upcoming: return subject.status == SubjectStatus.upcoming;
          case SubjectFilter.completed: return subject.status == SubjectStatus.completed;
          case SubjectFilter.withTeacher: return subject.teachers.isNotEmpty;
          case SubjectFilter.withoutTeacher: return subject.teachers.isEmpty;
          case SubjectFilter.withSchedule: return subject.classAssignments.isNotEmpty;
          case SubjectFilter.withoutSchedule: return subject.classAssignments.isEmpty;
          default: return true;
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((subject) =>
      subject.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          subject.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          subject.teachers.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    return filtered;
  }

  int get _totalSubjects => _subjects.length;
  int get _activeSubjects => _subjects.where((s) => s.status == SubjectStatus.active).length;
  int get _subjectsWithTeachers => _subjects.where((s) => s.teachers.isNotEmpty).length;
  int get _subjectsWithSchedule => _subjects.where((s) => s.classAssignments.isNotEmpty).length;

  // ============ FORM METHODS ============
  void _resetForm() {
    _subjectNameController.clear();
    _subjectCodeController.clear();
    _selectedTeachers = [];
    _selectedStatus = SubjectStatus.active;
    _formAssignments = [];
    _imageFile = null;
  }

  void _loadSubjectToForm(SubjectModel subject) {
    _subjectNameController.text = subject.name;
    _subjectCodeController.text = subject.code;
    _selectedTeachers = List.from(subject.teachers);
    _selectedStatus = subject.status;
    _formAssignments = List.from(subject.classAssignments);
    _imageFile = subject.photo != null ? File(subject.photo!) : null;
  }

  SubjectModel _createSubjectFromForm(String id) {
    final teacherIds = _selectedTeachers.map((name) {
      return _availableTeachers.firstWhere(
            (t) => t['name'] == name,
        orElse: () => {'id': 'UNKNOWN'},
      )['id']!;
    }).toList();

    return SubjectModel(
      id: id,
      name: _subjectNameController.text.trim(),
      code: _subjectCodeController.text.trim().toUpperCase(),
      teachers: List.from(_selectedTeachers),
      teacherIds: teacherIds,
      status: _selectedStatus,
      photo: _imageFile?.path,
      classAssignments: _formAssignments.map((a) => ClassAssignment(
        classLevel: a.classLevel,
        section: a.section,
        timeSlot: a.timeSlot,
        room: a.room,
        teacher: a.teacher,
      )).toList(),
    );
  }

  // ============ CRUD OPERATIONS ============
  void _addSubject() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeachers.isEmpty) {
      _showSnackbar('Please select at least one teacher', Colors.orange);
      return;
    }

    final newSubject = _createSubjectFromForm('SUB${(_subjects.length + 1).toString().padLeft(3, '0')}');

    setState(() {
      _subjects.add(newSubject);
      _showRightPanel = false;
      _isAddingNew = false;
      _resetForm();
    });

    _showSnackbar('Subject added successfully!', Colors.green);
  }

  void _updateSubject() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeachers.isEmpty) {
      _showSnackbar('Please select at least one teacher', Colors.orange);
      return;
    }

    final updatedSubject = _createSubjectFromForm(_selectedSubject!.id);
    final index = _subjects.indexWhere((s) => s.id == _selectedSubject!.id);

    if (index != -1) {
      setState(() {
        _subjects[index] = updatedSubject;
        _selectedSubject = updatedSubject;
        _isEditing = false;
        _resetForm();
      });
      _showSnackbar('Subject updated successfully!', Colors.blue);
    }
  }

  void _deleteSubject(SubjectModel subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.name}?'),
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
                _subjects.removeWhere((s) => s.id == subject.id);
                if (_selectedSubject?.id == subject.id) {
                  _showRightPanel = false;
                  _selectedSubject = null;
                }
              });
              _showSnackbar('Subject deleted successfully!', Colors.red);
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
      _formAssignments.add(ClassAssignment(
        classLevel: '10th',
        section: 'A',
        timeSlot: '8:00 AM - 8:45 AM',
        room: '',
        teacher: _selectedTeachers.isNotEmpty ? _selectedTeachers[0] : '',
      ));
    });
  }

  void _removeAssignmentFromForm(int index) {
    setState(() {
      _formAssignments.removeAt(index);
    });
  }

  void _updateAssignmentField(int index, String key, dynamic value) {
    setState(() {
      final assignment = _formAssignments[index];
      switch (key) {
        case 'classLevel':
          _formAssignments[index] = ClassAssignment(
            classLevel: value,
            section: assignment.section,
            timeSlot: assignment.timeSlot,
            room: assignment.room,
            teacher: assignment.teacher,
          );
          break;
        case 'section':
          _formAssignments[index] = ClassAssignment(
            classLevel: assignment.classLevel,
            section: value,
            timeSlot: assignment.timeSlot,
            room: assignment.room,
            teacher: assignment.teacher,
          );
          break;
        case 'timeSlot':
          _formAssignments[index] = ClassAssignment(
            classLevel: assignment.classLevel,
            section: assignment.section,
            timeSlot: value,
            room: assignment.room,
            teacher: assignment.teacher,
          );
          break;
        case 'room':
          _formAssignments[index] = ClassAssignment(
            classLevel: assignment.classLevel,
            section: assignment.section,
            timeSlot: assignment.timeSlot,
            room: value,
            teacher: assignment.teacher,
          );
          break;
        case 'teacher':
          _formAssignments[index] = ClassAssignment(
            classLevel: assignment.classLevel,
            section: assignment.section,
            timeSlot: assignment.timeSlot,
            room: assignment.room,
            teacher: value,
          );
          break;
      }
    });
  }

  // ============ TEACHER SELECTION ============
  void _showTeacherSelectionDialog() {
    List<String> tempSelected = List.from(_selectedTeachers);

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
                  return CheckboxListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teacher['name'].toString()),
                        Text(
                          teacher['subject'] ?? '',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setStateDialog(() {
                        if (value == true) {
                          tempSelected.add(teacher['name'].toString());
                        } else {
                          tempSelected.remove(teacher['name']);
                        }
                      });
                    },
                    activeColor: Colors.blue,
                    dense: true,
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
                  setState(() {
                    _selectedTeachers = List.from(tempSelected);
                  });
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

  // ============ IMAGE PICKER ============
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
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

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return parts[0][0] + parts[1][0];
    return name.substring(0, 2).toUpperCase();
  }

  String _getFilterLabel(SubjectFilter filter) {
    switch (filter) {
      case SubjectFilter.all: return 'All';
      case SubjectFilter.active: return 'Active';
      case SubjectFilter.inactive: return 'Inactive';
      case SubjectFilter.upcoming: return 'Upcoming';
      case SubjectFilter.completed: return 'Completed';
      case SubjectFilter.withTeacher: return 'With Teacher';
      case SubjectFilter.withoutTeacher: return 'No Teacher';
      case SubjectFilter.withSchedule: return 'Scheduled';
      case SubjectFilter.withoutSchedule: return 'No Schedule';
    }
  }

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
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
                  _buildHeader(),
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
                  icon: Icons.check_circle,
                  label: 'Active',
                  count: _activeSubjects,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
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
                  _selectedSubject = null;
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
  Widget _buildHeader() {
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
                  const Text(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$_activeSubjects Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
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
                      _selectedSubject = null;
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
                      _selectedSubject = null;
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
      SubjectFilter.upcoming,
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

  // ============ SUBJECT CARD ============
  Widget _buildSubjectCard(SubjectModel subject) {
    final isSelected = _selectedSubject?.id == subject.id;

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
              color: subject.teachers.isNotEmpty ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              subject.teachers.isNotEmpty ? Icons.check_circle : Icons.warning,
              color: subject.teachers.isNotEmpty ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedSubject = subject;
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
                          color: subject.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subject.statusDisplay,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: subject.statusColor,
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
                      _buildInfoText(Icons.person, '${subject.teachers.length} Teacher(s)'),
                      _buildInfoText(Icons.schedule, '${subject.classAssignments.length} Schedule(s)'),
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
              if (subject.classAssignments.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedSubject = subject;
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
                    _loadSubjectToForm(subject);
                    setState(() {
                      _selectedSubject = subject;
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
                  onPressed: () => _deleteSubject(subject),
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

  Widget _buildInfoText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
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
                _selectedSubject = null;
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
    if (_selectedSubject == null) return const SizedBox();

    final subject = _selectedSubject!;
    final hasTeacher = subject.teachers.isNotEmpty;
    final hasSchedule = subject.classAssignments.isNotEmpty;

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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.book,
                  color: Colors.blue[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
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
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Code: ${subject.code}',
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
                            color: subject.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            subject.statusDisplay,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subject.statusColor,
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
          _buildDetailRow('📚 Subject', subject.name),
          _buildDetailRow('🏷️ Code', subject.code),
          _buildDetailRow('👨‍🏫 Teachers', subject.teachers.isEmpty ? 'No teachers assigned' : subject.teachers.join(', ')),
          _buildDetailRow('📋 Status', subject.statusDisplay),

          if (hasSchedule) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Schedule
            const Text(
              '📖 Class Schedule',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...subject.classAssignments.map((assignment) => Container(
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
                        '${assignment.classLevel} - Section ${assignment.section}',
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
                          'Room ${assignment.room}',
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
                  _buildDetailRow('⏰ Time', assignment.timeSlot),
                  _buildDetailRow('👨‍🏫 Teacher', assignment.teacher),
                ],
              ),
            )),
          ],

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _selectedSubject = null;
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

  Widget _buildDetailRow(String label, String value) {
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
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ SCHEDULE PANEL ============
  Widget _buildSchedulePanel() {
    if (_selectedSubject == null) return const SizedBox();

    final subject = _selectedSubject!;

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
                  'Schedule - ${subject.name}',
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

          if (subject.classAssignments.isEmpty)
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
            ...subject.classAssignments.map((assignment) => Container(
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
                          '${assignment.classLevel} - Section ${assignment.section}',
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
                          'Room ${assignment.room}',
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
                        assignment.timeSlot,
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
                        'Teacher: ${assignment.teacher}',
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
                  onPressed: _addSubject,
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
    if (_selectedSubject == null) return const SizedBox();

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
                  onPressed: _updateSubject,
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
        // Photo Upload
        Align(
          alignment: Alignment.center,
          child: _buildPhotoUpload(),
        ),
        const SizedBox(height: 16),

        // Subject Information
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
        _buildFormTextField(_subjectCodeController, 'Subject Code', Icons.code,
            hint: 'e.g., MATH', required: true),
        const SizedBox(height: 12),

        // Teachers
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
                'Teachers',
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
        GestureDetector(
          onTap: _showTeacherSelectionDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.person_add, color: Colors.green[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Teachers',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_selectedTeachers.isNotEmpty)
                        Text(
                          _selectedTeachers.join(', '),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          'Tap to select teachers (${_availableTeachers.length} available)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
              ],
            ),
          ),
        ),
        if (_selectedTeachers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTeachers.map((teacher) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      teacher,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        const SizedBox(height: 12),

        // Status
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdownField('Status', _statusList, _selectedStatus.toString().split('.').last, (value) {
          setState(() {
            _selectedStatus = SubjectStatus.values.firstWhere(
                  (e) => e.toString().split('.').last == value,
              orElse: () => SubjectStatus.active,
            );
          });
        }),
        const SizedBox(height: 12),

        // Class Schedule
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule, color: Colors.purple[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Class Schedule',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._formAssignments.asMap().entries.map((entry) {
          final index = entry.key;
          final assignment = entry.value;
          return _buildAssignmentForm(index, assignment);
        }).toList(),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addAssignmentToForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Schedule'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[100],
            foregroundColor: Colors.purple[700],
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

  Widget _buildAssignmentForm(int index, ClassAssignment assignment) {
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
                'Schedule ${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
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
                child: _buildDropdownField('Class', _classLevels, assignment.classLevel, (value) {
                  _updateAssignmentField(index, 'classLevel', value);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdownField('Section', _sectionList, assignment.section, (value) {
                  _updateAssignmentField(index, 'section', value);
                }),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildDropdownField('Time Slot', _timeSlots, assignment.timeSlot, (value) {
            _updateAssignmentField(index, 'timeSlot', value);
          }),
          const SizedBox(height: 4),
          _buildFormTextField(
            TextEditingController(
              text: assignment.room,
            ),
            'Room',
            Icons.room,
            hint: 'e.g., 101',
            onChanged: (value) {
              _updateAssignmentField(
                index,
                'room',
                value,
              );
            },
          ),
          const SizedBox(height: 4),
          if (_selectedTeachers.isNotEmpty)
            _buildDropdownField('Teacher', _selectedTeachers, assignment.teacher, (value) {
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
                    'Please select teachers first',
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
        style: const TextStyle(
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,

          prefixIcon: Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 1,
            ),
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),

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
            ? (v) => v?.trim().isEmpty ?? true
            ? '$label is required'
            : null
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

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: _imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _imageFile!,
            fit: BoxFit.cover,
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              color: Colors.blue[700],
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              'Upload Photo',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}