import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// ============ ENUMS ============
enum TeacherFilter {
  all,
  active,
  inactive,
  onLeave,
  retired,
}

enum SchoolFilter {
  all,
  schoolA,
  schoolB,
}

// ============ MODEL ============
class TeacherModel {
  final String id;
  final String name;
  final List<String> subjects;
  final String email;
  final String phone;
  final String? altPhone;
  final String classes;
  final String experience;
  final String qualification;
  final String gender;
  final String dob;
  final String address;
  final String status;
  final String joinDate;
  final String? photo;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String school;

  TeacherModel({
    required this.id,
    required this.name,
    required this.subjects,
    required this.email,
    required this.phone,
    this.altPhone,
    required this.classes,
    required this.experience,
    required this.qualification,
    required this.gender,
    required this.dob,
    required this.address,
    required this.status,
    required this.joinDate,
    this.photo,
    this.firstName,
    this.middleName,
    this.lastName,
    this.school = 'School A',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subjects': subjects,
    'email': email,
    'phone': phone,
    'altPhone': altPhone,
    'classes': classes,
    'experience': experience,
    'qualification': qualification,
    'gender': gender,
    'dob': dob,
    'address': address,
    'status': status,
    'joinDate': joinDate,
    'photo': photo,
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'school': school,
  };

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
    id: json['id'],
    name: json['name'],
    subjects: List<String>.from(json['subjects']),
    email: json['email'],
    phone: json['phone'],
    altPhone: json['altPhone'],
    classes: json['classes'],
    experience: json['experience'],
    qualification: json['qualification'],
    gender: json['gender'],
    dob: json['dob'],
    address: json['address'],
    status: json['status'],
    joinDate: json['joinDate'],
    photo: json['photo'],
    firstName: json['firstName'],
    middleName: json['middleName'],
    lastName: json['lastName'],
    school: json['school'] ?? 'School A',
  );
}

// ============ MAIN SCREEN ============
class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  // ============ STATE ============
  List<TeacherModel> _teachers = [];
  TeacherFilter _currentFilter = TeacherFilter.all;
  SchoolFilter _currentSchoolFilter = SchoolFilter.all;
  String _searchQuery = '';
  bool _showRightPanel = false;
  TeacherModel? _selectedTeacher;
  bool _isEditing = false;
  bool _isAddingNew = false;
  bool _showAttendance = false;

  // ============ ATTENDANCE STATE ============
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;
  int _selectedMonthIndex = DateTime.now().month - 1;
  Map<String, String> _attendanceStatus = {};

  // ============ FORM CONTROLLERS ============
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _joinDateController = TextEditingController();
  final _classesController = TextEditingController();

  // ============ FORM STATE ============
  String _selectedGender = 'Male';
  String _selectedStatus = 'Active';
  String _selectedSchoolForm = 'School A';
  List<String> _selectedSubjects = [];
  File? _imageFile;

  // ============ CONSTANTS ============
  final List<String> _allSubjects = [
    'Mathematics', 'Science', 'English', 'History',
    'Computer Science', 'Biology', 'Physics', 'Chemistry', 'Art', 'Music',
    'Hindi', 'Social Science', 'Geography'
  ];
  final List<String> _genderList = ['Male', 'Female', 'Other'];
  final List<String> _statusList = ['Active', 'Inactive', 'On Leave', 'Retired'];
  final List<String> _schoolList = ['School A', 'School B'];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
    _generateSampleAttendance();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _joinDateController.dispose();
    _classesController.dispose();
    super.dispose();
  }

  // ============ SAMPLE DATA ============
  void _loadSampleData() {
    _teachers = [
      // ===== School A Teachers =====
      TeacherModel(
        id: 'T001',
        name: 'Dr. Rajesh Kumar',
        subjects: ['Mathematics', 'Physics', 'Computer Science'],
        email: 'rajesh@school.com',
        phone: '+91 98765 43210',
        altPhone: '+91 98765 43211',
        classes: '10-A, 10-B',
        experience: '12 Years',
        qualification: 'Ph.D. in Mathematics',
        gender: 'Male',
        dob: '15 Mar 1980',
        address: '123, Teacher Colony, Mumbai',
        status: 'Active',
        joinDate: 'Jan 2010',
        firstName: 'Rajesh',
        lastName: 'Kumar',
        school: 'School A',
      ),
      TeacherModel(
        id: 'T002',
        name: 'Ms. Meera Singh',
        subjects: ['Science', 'Physics', 'Chemistry'],
        email: 'meera@school.com',
        phone: '+91 98765 43211',
        altPhone: '+91 98765 43212',
        classes: '9-A, 9-B',
        experience: '8 Years',
        qualification: 'M.Sc. in Physics',
        gender: 'Female',
        dob: '22 Jun 1985',
        address: '45, Science Nagar, Delhi',
        status: 'Active',
        joinDate: 'Mar 2014',
        firstName: 'Meera',
        lastName: 'Singh',
        school: 'School A',
      ),
      TeacherModel(
        id: 'T003',
        name: 'Mr. Suresh Patel',
        subjects: ['English', 'Hindi'],
        email: 'suresh@school.com',
        phone: '+91 98765 43212',
        altPhone: '+91 98765 43213',
        classes: '8-A, 8-B',
        experience: '10 Years',
        qualification: 'M.A. in English',
        gender: 'Male',
        dob: '10 Sep 1982',
        address: '78, Patel Nagar, Jaipur',
        status: 'Active',
        joinDate: 'Jun 2012',
        firstName: 'Suresh',
        lastName: 'Patel',
        school: 'School A',
      ),
      TeacherModel(
        id: 'T004',
        name: 'Mrs. Anita Sharma',
        subjects: ['History', 'Social Science', 'Geography'],
        email: 'anita@school.com',
        phone: '+91 98765 43213',
        altPhone: '+91 98765 43214',
        classes: '7-A, 7-B',
        experience: '6 Years',
        qualification: 'M.A. in History',
        gender: 'Female',
        dob: '05 Dec 1987',
        address: '234, Heritage Lane, Hyderabad',
        status: 'Active',
        joinDate: 'Aug 2016',
        firstName: 'Anita',
        lastName: 'Sharma',
        school: 'School A',
      ),
      TeacherModel(
        id: 'T005',
        name: 'Mr. Vikram Reddy',
        subjects: ['Computer Science', 'Mathematics'],
        email: 'vikram@school.com',
        phone: '+91 98765 43214',
        altPhone: '+91 98765 43215',
        classes: '10-A, 9-A',
        experience: '5 Years',
        qualification: 'M.Tech in CS',
        gender: 'Male',
        dob: '18 Feb 1990',
        address: '567, Tech Park, Chennai',
        status: 'Inactive',
        joinDate: 'Jan 2017',
        firstName: 'Vikram',
        lastName: 'Reddy',
        school: 'School A',
      ),
      // ===== School B Teachers =====
      TeacherModel(
        id: 'T006',
        name: 'Dr. Priya Gupta',
        subjects: ['Biology', 'Science'],
        email: 'priya@school.com',
        phone: '+91 98765 43215',
        altPhone: '+91 98765 43216',
        classes: '10-A, 9-B',
        experience: '7 Years',
        qualification: 'Ph.D. in Biology',
        gender: 'Female',
        dob: '12 Apr 1988',
        address: '890, Science Colony, Lucknow',
        status: 'Active',
        joinDate: 'Mar 2015',
        firstName: 'Priya',
        lastName: 'Gupta',
        school: 'School B',
      ),
      TeacherModel(
        id: 'T007',
        name: 'Mr. Arjun Nair',
        subjects: ['Physics', 'Mathematics'],
        email: 'arjun@school.com',
        phone: '+91 98765 43216',
        altPhone: '+91 98765 43217',
        classes: '11-A, 11-B',
        experience: '9 Years',
        qualification: 'M.Sc. in Physics',
        gender: 'Male',
        dob: '03 Jul 1983',
        address: '123, Science Park, Kochi',
        status: 'Active',
        joinDate: 'Jul 2013',
        firstName: 'Arjun',
        lastName: 'Nair',
        school: 'School B',
      ),
      TeacherModel(
        id: 'T008',
        name: 'Ms. Kavya Reddy',
        subjects: ['Chemistry', 'Biology'],
        email: 'kavya@school.com',
        phone: '+91 98765 43217',
        altPhone: '+91 98765 43218',
        classes: '12-A, 12-B',
        experience: '4 Years',
        qualification: 'M.Sc. in Chemistry',
        gender: 'Female',
        dob: '28 Nov 1992',
        address: '456, Reddy Colony, Hyderabad',
        status: 'On Leave',
        joinDate: 'Aug 2020',
        firstName: 'Kavya',
        lastName: 'Reddy',
        school: 'School B',
      ),
      TeacherModel(
        id: 'T009',
        name: 'Dr. Anil Kumar',
        subjects: ['English', 'Literature'],
        email: 'anil@school.com',
        phone: '+91 98765 43218',
        altPhone: '+91 98765 43219',
        classes: '11-A, 11-B',
        experience: '15 Years',
        qualification: 'Ph.D. in English',
        gender: 'Male',
        dob: '15 Jan 1978',
        address: '789, Literature Lane, Delhi',
        status: 'Retired',
        joinDate: 'Jan 2005',
        firstName: 'Anil',
        lastName: 'Kumar',
        school: 'School B',
      ),
    ];
  }

  // ============ ATTENDANCE METHODS ============
  void _generateSampleAttendance() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      if (date.weekday == 6 || date.weekday == 7) continue;
      final random = DateTime.now().millisecond;
      if (random % 10 < 7) {
        _attendanceStatus[DateFormat('yyyy-MM-dd').format(date)] = 'Present';
      } else if (random % 10 < 9) {
        _attendanceStatus[DateFormat('yyyy-MM-dd').format(date)] = 'Absent';
      } else {
        _attendanceStatus[DateFormat('yyyy-MM-dd').format(date)] = 'Leave';
      }
    }
  }

  void _toggleAttendance(String dateKey) {
    setState(() {
      final currentStatus = _attendanceStatus[dateKey];
      if (currentStatus == null || currentStatus == 'Absent') {
        _attendanceStatus[dateKey] = 'Present';
      } else if (currentStatus == 'Present') {
        _attendanceStatus[dateKey] = 'Absent';
      } else {
        _attendanceStatus[dateKey] = 'Present';
      }
    });
  }

  void _changeMonth(int increment) {
    setState(() {
      _selectedMonthIndex += increment;
      if (_selectedMonthIndex > 11) {
        _selectedMonthIndex = 0;
        _selectedYear++;
      } else if (_selectedMonthIndex < 0) {
        _selectedMonthIndex = 11;
        _selectedYear--;
      }
      _selectedMonth = DateTime(_selectedYear, _selectedMonthIndex + 1);
    });
  }

  Map<String, dynamic> _getAttendanceStats() {
    int present = 0, absent = 0, leave = 0, total = 0;
    _attendanceStatus.forEach((key, value) {
      total++;
      if (value == 'Present') present++;
      else if (value == 'Absent') absent++;
      else if (value == 'Leave') leave++;
    });
    final percentage = total > 0 ? (present / total * 100).round() : 0;
    return {
      'present': present,
      'absent': absent,
      'leave': leave,
      'total': total,
      'percentage': percentage,
    };
  }

  // ============ GETTERS ============
  List<TeacherModel> get _filteredTeachers {
    var filtered = _teachers;

    // School Filter
    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      filtered = filtered.where((teacher) => teacher.school == 'School A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      filtered = filtered.where((teacher) => teacher.school == 'School B').toList();
    }

    // Status Filter
    if (_currentFilter != TeacherFilter.all) {
      filtered = filtered.where((teacher) {
        if (_currentFilter == TeacherFilter.active) {
          return teacher.status == 'Active';
        } else if (_currentFilter == TeacherFilter.inactive) {
          return teacher.status == 'Inactive';
        } else if (_currentFilter == TeacherFilter.onLeave) {
          return teacher.status == 'On Leave';
        } else {
          return teacher.status == 'Retired';
        }
      }).toList();
    }

    // Search Filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((teacher) =>
      teacher.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          teacher.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          teacher.subjects.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          teacher.classes.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          teacher.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          teacher.school.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  int get _totalTeachers => _teachers.length;
  int get _activeTeachers => _teachers.where((t) => t.status == 'Active').length;
  int get _onLeaveTeachers => _teachers.where((t) => t.status == 'On Leave').length;
  int get _inactiveTeachers => _teachers.where((t) => t.status == 'Inactive').length;

  Map<String, int> get _schoolWiseStats {
    Map<String, int> stats = {};
    for (var teacher in _teachers) {
      stats[teacher.school] = (stats[teacher.school] ?? 0) + 1;
    }
    return stats;
  }

  // ============ FORM METHODS ============
  void _resetForm() {
    _firstNameController.clear();
    _middleNameController.clear();
    _lastNameController.clear();
    _dobController.clear();
    _emailController.clear();
    _phoneController.clear();
    _altPhoneController.clear();
    _addressController.clear();
    _qualificationController.clear();
    _experienceController.clear();
    _joinDateController.clear();
    _classesController.clear();
    _selectedSubjects = [];
    _selectedGender = 'Male';
    _selectedStatus = 'Active';
    _selectedSchoolForm = 'School A';
    _imageFile = null;
  }

  void _loadTeacherToForm(TeacherModel teacher) {
    final nameParts = teacher.name.split(' ');
    _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
    _middleNameController.text = nameParts.length > 2 ? nameParts[1] : '';
    _lastNameController.text = nameParts.length > 2 ? nameParts.sublist(2).join(' ') : (nameParts.length > 1 ? nameParts[1] : '');
    _dobController.text = teacher.dob;
    _emailController.text = teacher.email;
    _phoneController.text = teacher.phone;
    _altPhoneController.text = teacher.altPhone ?? '';
    _addressController.text = teacher.address;
    _qualificationController.text = teacher.qualification;
    _experienceController.text = teacher.experience;
    _joinDateController.text = teacher.joinDate;
    _classesController.text = teacher.classes;
    _selectedSubjects = List.from(teacher.subjects);
    _selectedGender = teacher.gender;
    _selectedStatus = teacher.status;
    _selectedSchoolForm = teacher.school;
    _imageFile = teacher.photo != null ? File(teacher.photo!) : null;
  }

  TeacherModel _createTeacherFromForm(String id) {
    final name = '${_firstNameController.text.trim()} ${_middleNameController.text.trim()} ${_lastNameController.text.trim()}'
        .replaceAll(RegExp(r'\s+'), ' ').trim();

    return TeacherModel(
      id: id,
      name: name,
      subjects: List.from(_selectedSubjects),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      altPhone: _altPhoneController.text.trim().isNotEmpty ? _altPhoneController.text.trim() : null,
      classes: _classesController.text.trim(),
      experience: _experienceController.text.trim(),
      qualification: _qualificationController.text.trim(),
      gender: _selectedGender,
      dob: _dobController.text.trim(),
      address: _addressController.text.trim(),
      status: _selectedStatus,
      joinDate: _joinDateController.text.trim().isNotEmpty
          ? _joinDateController.text.trim()
          : DateFormat('MMM yyyy').format(DateTime.now()),
      photo: _imageFile?.path,
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      school: _selectedSchoolForm,
    );
  }

  // ============ CRUD OPERATIONS ============
  void _addTeacher() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjects.isEmpty) {
      _showSnackbar('Please select at least one subject', Colors.orange);
      return;
    }

    final newTeacher = _createTeacherFromForm(
        'T${(_teachers.length + 1).toString().padLeft(3, '0')}');

    setState(() {
      _teachers.add(newTeacher);
      _showRightPanel = false;
      _isAddingNew = false;
      _resetForm();
    });

    _showSnackbar('Teacher added successfully!', Colors.green);
  }

  void _updateTeacher() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjects.isEmpty) {
      _showSnackbar('Please select at least one subject', Colors.orange);
      return;
    }

    final updatedTeacher = _createTeacherFromForm(_selectedTeacher!.id);
    final index = _teachers.indexWhere((t) => t.id == _selectedTeacher!.id);

    if (index != -1) {
      setState(() {
        _teachers[index] = updatedTeacher;
        _selectedTeacher = updatedTeacher;
        _isEditing = false;
        _resetForm();
      });
      _showSnackbar('Teacher updated successfully!', Colors.blue);
    }
  }

  void _deleteTeacher(TeacherModel teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.name}?'),
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
                _teachers.removeWhere((t) => t.id == teacher.id);
                if (_selectedTeacher?.id == teacher.id) {
                  _showRightPanel = false;
                  _selectedTeacher = null;
                }
              });
              _showSnackbar('Teacher deleted successfully!', Colors.red);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

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
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.green;
      case 'Inactive': return Colors.red;
      case 'On Leave': return Colors.orange;
      case 'Retired': return Colors.grey;
      default: return Colors.grey;
    }
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

  Color _getGenderColor(String gender) {
    switch (gender) {
      case 'Male': return Colors.blue;
      case 'Female': return Colors.pink;
      default: return Colors.purple;
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
            // Left Panel - Teacher List
            Expanded(
              flex: _showRightPanel ? 5 : 8,
              child: Column(
                children: [
                  _buildHeader(schoolLabel, schoolStats),
                  _buildFilterSearchBar(),
                  Expanded(
                    child: _filteredTeachers.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredTeachers.length,
                      itemBuilder: (context, index) {
                        return _buildTeacherCard(_filteredTeachers[index]);
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
                  : _showAttendance
                  ? _buildAttendancePanel()
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
                color: Colors.purple[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 60,
                color: Colors.purple[200],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Teacher Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a teacher from the list or create a new one',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '👨‍🏫 ${_teachers.length} Total Teachers',
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
                  count: _activeTeachers,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildEmptyStatCard(
                  icon: Icons.warning,
                  label: 'On Leave',
                  count: _onLeaveTeachers,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildEmptyStatCard(
                  icon: Icons.cancel,
                  label: 'Inactive',
                  count: _inactiveTeachers,
                  color: Colors.red,
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
                  _showAttendance = false;
                  _selectedTeacher = null;
                  _showRightPanel = true;
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Teacher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
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
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.people,
                  color: Colors.purple[700],
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
                        'Teachers Management',
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
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Text(
                          schoolLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_filteredTeachers.length} teachers found',
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
              // School Filter Dropdown
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
                        _selectedTeacher = null;
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
                      _showAttendance = false;
                      _selectedTeacher = null;
                      _showRightPanel = true;
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
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
                      _selectedTeacher = null;
                      _isEditing = false;
                      _isAddingNew = false;
                      _showAttendance = false;
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
                  hintText: 'Search teachers...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildFilterChip('All', TeacherFilter.all),
          const SizedBox(width: 4),
          _buildFilterChip('Active', TeacherFilter.active),
          const SizedBox(width: 4),
          _buildFilterChip('On Leave', TeacherFilter.onLeave),
          const SizedBox(width: 4),
          _buildFilterChip('Inactive', TeacherFilter.inactive),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TeacherFilter filter) {
    final isSelected = _currentFilter == filter;
    Color color = Colors.purple;
    if (filter == TeacherFilter.active) color = Colors.green;
    if (filter == TeacherFilter.inactive) color = Colors.red;
    if (filter == TeacherFilter.onLeave) color = Colors.orange;

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

  // ============ TEACHER CARD ============
  Widget _buildTeacherCard(TeacherModel teacher) {
    final isSelected = _selectedTeacher?.id == teacher.id;
    final schoolColor = _getSchoolColor(teacher.school);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.purple[300]! : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getGenderColor(teacher.gender).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getInitials(teacher.name),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getGenderColor(teacher.gender),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTeacher = teacher;
                  _showRightPanel = true;
                  _isEditing = false;
                  _isAddingNew = false;
                  _showAttendance = false;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          teacher.name,
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
                          color: _getStatusColor(teacher.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          teacher.status,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(teacher.status),
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
                      _buildInfoText(Icons.school, teacher.school, color: schoolColor),
                      _buildInfoText(Icons.book, teacher.subjects.take(2).join(', ')),
                      _buildInfoText(Icons.class_, teacher.classes),
                      _buildInfoText(Icons.work, teacher.experience),
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
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedTeacher = teacher;
                      _showAttendance = true;
                      _showRightPanel = true;
                      _isEditing = false;
                      _isAddingNew = false;
                    });
                  },
                  icon: Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: Colors.purple[700],
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
                    _loadTeacherToForm(teacher);
                    setState(() {
                      _selectedTeacher = teacher;
                      _isEditing = true;
                      _isAddingNew = false;
                      _showAttendance = false;
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
                  onPressed: () => _deleteTeacher(teacher),
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
            Icons.person_off,
            size: 50,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            'No Teachers Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Click "Add New" to create a teacher',
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
                _showAttendance = false;
                _selectedTeacher = null;
                _showRightPanel = true;
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New Teacher'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
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
    if (_selectedTeacher == null) return const SizedBox();

    final teacher = _selectedTeacher!;
    final schoolColor = _getSchoolColor(teacher.school);

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
                  color: _getGenderColor(teacher.gender).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getInitials(teacher.name),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getGenderColor(teacher.gender),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
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
                                teacher.school,
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
                            color: _getStatusColor(teacher.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            teacher.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(teacher.status),
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
                            teacher.id,
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

          // School Info
          _buildDetailRow('🏫 School', teacher.school, color: schoolColor, isBold: true),

          // Personal Info
          _buildDetailRow('📛 Name', teacher.name),
          _buildDetailRow('🎂 DOB', teacher.dob),
          _buildDetailRow('⚧ Gender', teacher.gender),
          _buildDetailRow('📧 Email', teacher.email),
          _buildDetailRow('📱 Phone', teacher.phone),
          if (teacher.altPhone != null)
            _buildDetailRow('📱 Alt Phone', teacher.altPhone!),
          _buildDetailRow('📍 Address', teacher.address),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Professional Info
          _buildDetailRow('🎓 Qualification', teacher.qualification),
          _buildDetailRow('📚 Subjects', teacher.subjects.join(', ')),
          _buildDetailRow('🏫 Classes', teacher.classes),
          _buildDetailRow('💼 Experience', teacher.experience),
          _buildDetailRow('📅 Join Date', teacher.joinDate),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _selectedTeacher = null;
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
                    _loadTeacherToForm(teacher);
                    setState(() {
                      _isEditing = true;
                      _isAddingNew = false;
                      _showAttendance = false;
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
                  onPressed: () => _deleteTeacher(teacher),
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
      padding: const EdgeInsets.only(bottom: 8),
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

  // ============ ATTENDANCE PANEL ============
  Widget _buildAttendancePanel() {
    if (_selectedTeacher == null) return const SizedBox();

    final stats = _getAttendanceStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.purple[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Attendance - ${_selectedTeacher!.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showAttendance = false;
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _attendanceStatItem(
                        'Present',
                        stats['present'].toString(),
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    Expanded(
                      child: _attendanceStatItem(
                        'Absent',
                        stats['absent'].toString(),
                        Colors.red,
                        Icons.cancel,
                      ),
                    ),
                    Expanded(
                      child: _attendanceStatItem(
                        'Leave',
                        stats['leave'].toString(),
                        Colors.orange,
                        Icons.beach_access,
                      ),
                    ),
                    Expanded(
                      child: _attendanceStatItem(
                        'Total',
                        stats['total'].toString(),
                        Colors.purple,
                        Icons.calendar_today,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attendance Percentage',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: stats['percentage'] >= 85
                            ? Colors.green.withOpacity(0.2)
                            : stats['percentage'] >= 70
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${stats['percentage']}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: stats['percentage'] >= 85
                              ? Colors.green
                              : stats['percentage'] >= 70
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stats['percentage'] / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stats['percentage'] >= 85
                        ? Colors.green
                        : stats['percentage'] >= 70
                        ? Colors.orange
                        : Colors.red,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Calendar
          Container(
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
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonthIndex + 1)),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _changeMonth(-1),
                          icon: const Icon(Icons.chevron_left),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            padding: const EdgeInsets.all(4),
                            minimumSize: const Size(30, 30),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () => _changeMonth(1),
                          icon: const Icon(Icons.chevron_right),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            padding: const EdgeInsets.all(4),
                            minimumSize: const Size(30, 30),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCalendarGrid(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem('Present', Colors.green),
                    const SizedBox(width: 16),
                    _legendItem('Absent', Colors.red),
                    const SizedBox(width: 16),
                    _legendItem('Leave', Colors.orange),
                    const SizedBox(width: 16),
                    _legendItem('No Record', Colors.grey[300]!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
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
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonthIndex + 1, 1);
    final daysInMonth = DateTime(_selectedYear, _selectedMonthIndex + 2, 0).day;
    final firstWeekday = firstDayOfMonth.weekday;
    final startOffset = firstWeekday == 7 ? 0 : firstWeekday;

    final List<Widget> dayWidgets = [];

    for (int i = 0; i < startOffset - 1; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedYear, _selectedMonthIndex + 1, day);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final status = _attendanceStatus[dateKey];
      final isWeekend = date.weekday == 6 || date.weekday == 7;
      final isToday = date.day == DateTime.now().day &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            if (!isWeekend) {
              _toggleAttendance(dateKey);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isWeekend
                  ? Colors.grey[200]
                  : status == 'Present'
                  ? Colors.green.withOpacity(0.7)
                  : status == 'Absent'
                  ? Colors.red.withOpacity(0.7)
                  : status == 'Leave'
                  ? Colors.orange.withOpacity(0.7)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: isToday
                  ? Border.all(color: Colors.purple, width: 2)
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isWeekend || status != null
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  if (status != null && !isWeekend)
                    Icon(
                      status == 'Present'
                          ? Icons.check_circle
                          : status == 'Absent'
                          ? Icons.cancel
                          : Icons.beach_access,
                      size: 10,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    while (dayWidgets.length % 7 != 0) {
      dayWidgets.add(const SizedBox.shrink());
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      childAspectRatio: 1.2,
      children: [
        ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => Container(
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: day == 'Sat' || day == 'Sun' ? Colors.red : Colors.grey[600],
            ),
          ),
        )),
        ...dayWidgets,
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
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
                Icons.person_add,
                color: Colors.purple[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Add New Teacher',
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
                  onPressed: _addTeacher,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Teacher',
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
    if (_selectedTeacher == null) return const SizedBox();

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
                'Edit Teacher',
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
                  onPressed: _updateTeacher,
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

        // School Selection
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.school, color: Colors.blue[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'School Information',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 140,
                child: _buildDropdownField('', _schoolList, _selectedSchoolForm, (value) {
                  setState(() => _selectedSchoolForm = value!);
                }, isCompact: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Personal Information
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.purple[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Personal Information',
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
        Row(
          children: [
            Expanded(
              child: _buildFormTextField(_firstNameController, 'First Name', Icons.person_outline,
                  required: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFormTextField(_middleNameController, 'Middle Name', Icons.person_outline),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFormTextField(_lastNameController, 'Last Name', Icons.person_outline,
                  required: true),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFormTextField(_dobController, 'Date of Birth', Icons.calendar_today,
                  hint: 'DD MMM YYYY', required: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdownField('Gender', _genderList, _selectedGender, (value) {
                setState(() => _selectedGender = value!);
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Contact Information
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.contact_phone, color: Colors.blue[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Contact Information',
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
        _buildFormTextField(_emailController, 'Email', Icons.email,
            required: true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFormTextField(_phoneController, 'Primary Phone', Icons.phone,
                  required: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFormTextField(_altPhoneController, 'Alt Phone', Icons.phone_android),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildFormTextField(_addressController, 'Address', Icons.location_on,
            maxLines: 2, required: true),
        const SizedBox(height: 12),

        // Professional Information
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.work, color: Colors.green[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Professional Information',
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
        _buildFormTextField(_qualificationController, 'Qualification', Icons.school,
            required: true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFormTextField(_experienceController, 'Experience', Icons.work,
                  required: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFormTextField(_classesController, 'Classes', Icons.class_,
                  required: true),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Subjects
        const Text(
          'Subjects',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _allSubjects.map((subject) {
              final isSelected = _selectedSubjects.contains(subject);
              return FilterChip(
                label: Text(subject, style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSubjects.add(subject);
                    } else {
                      _selectedSubjects.remove(subject);
                    }
                  });
                },
                selectedColor: Colors.purple[100],
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.purple[700] : Colors.grey[700],
                ),
                side: BorderSide(
                  color: isSelected ? Colors.purple[400]! : Colors.grey[300]!,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Status Information
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
                'Status Information',
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
        Row(
          children: [
            Expanded(
              child: _buildFormTextField(_joinDateController, 'Join Date', Icons.event,
                  hint: 'MMM YYYY', required: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdownField('Status', _statusList, _selectedStatus, (value) {
                setState(() => _selectedStatus = value!);
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormTextField(TextEditingController controller, String label,
      IconData icon, {
        String? hint,
        int maxLines = 1,
        bool required = false,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
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
          borderSide: BorderSide(color: Colors.purple[700]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator: required
          ? (v) => v?.trim().isEmpty ?? true ? '$label is required' : null
          : null,
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value,
      Function(String?) onChanged, {bool isCompact = false}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label.isNotEmpty ? label : null,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
          borderSide: BorderSide(color: Colors.purple[700]!),
        ),
        contentPadding: isCompact
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: isCompact,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: TextStyle(fontSize: isCompact ? 12 : 13)),
        );
      }).toList(),
      onChanged: onChanged,
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
            style: BorderStyle.solid,
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
              color: Colors.purple[700],
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