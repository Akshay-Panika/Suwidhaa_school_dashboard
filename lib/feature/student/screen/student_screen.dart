import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// ============ ENUMS ============
enum StudentFilter {
  all,
  classKG,
  classLKG,
  classUKG,
  class1st,
  class2nd,
  class3rd,
  class4th,
  class5th,
  class6th,
  class7th,
  class8th,
  class9th,
  class10th,
  class11th,
  class12th,
}

enum SchoolFilter {
  all,
  schoolA,
  schoolB,
}

// ============ MODEL ============
class StudentModel {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String dob;
  final String gender;
  final String fatherName;
  final String motherName;
  final String parentPhone;
  final String alternativePhone;
  final String studentClass;
  final String rollNumber;
  final String admissionNumber;
  final String email;
  final String address;
  final String casteCategory;
  final String adharNumber;
  final String sssmid;
  final String feeStatus;
  final String feeAmount;
  final String paidAmount;
  final bool checkBox;
  final String? profileImage;
  final String school;
  final String createdAt;

  StudentModel({
    required this.id,
    required this.firstName,
    this.middleName = '',
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.fatherName,
    required this.motherName,
    required this.parentPhone,
    this.alternativePhone = '',
    required this.studentClass,
    required this.rollNumber,
    required this.admissionNumber,
    required this.email,
    required this.address,
    this.casteCategory = '',
    this.adharNumber = '',
    this.sssmid = '',
    required this.feeStatus,
    this.feeAmount = '0.00',
    this.paidAmount = '0.00',
    this.checkBox = true,
    this.profileImage,
    this.school = 'School A',
    this.createdAt = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'dob': dob,
    'gender': gender,
    'fatherName': fatherName,
    'motherName': motherName,
    'parentPhone': parentPhone,
    'alternativePhone': alternativePhone,
    'studentClass': studentClass,
    'rollNumber': rollNumber,
    'admissionNumber': admissionNumber,
    'email': email,
    'address': address,
    'casteCategory': casteCategory,
    'adharNumber': adharNumber,
    'sssmid': sssmid,
    'feeStatus': feeStatus,
    'feeAmount': feeAmount,
    'paidAmount': paidAmount,
    'checkBox': checkBox,
    'profileImage': profileImage,
    'school': school,
    'createdAt': createdAt,
  };

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'],
    firstName: json['firstName'],
    middleName: json['middleName'] ?? '',
    lastName: json['lastName'],
    dob: json['dob'],
    gender: json['gender'],
    fatherName: json['fatherName'],
    motherName: json['motherName'],
    parentPhone: json['parentPhone'],
    alternativePhone: json['alternativePhone'] ?? '',
    studentClass: json['studentClass'],
    rollNumber: json['rollNumber'],
    admissionNumber: json['admissionNumber'],
    email: json['email'],
    address: json['address'],
    casteCategory: json['casteCategory'] ?? '',
    adharNumber: json['adharNumber'] ?? '',
    sssmid: json['sssmid'] ?? '',
    feeStatus: json['feeStatus'],
    feeAmount: json['feeAmount'] ?? '0.00',
    paidAmount: json['paidAmount'] ?? '0.00',
    checkBox: json['checkBox'] ?? true,
    profileImage: json['profileImage'],
    school: json['school'] ?? 'School A',
    createdAt: json['createdAt'] ?? '',
  );
}

// ============ MAIN SCREEN ============
class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  // ============ STATE ============
  List<StudentModel> _students = [];
  StudentFilter _currentFilter = StudentFilter.all;
  SchoolFilter _currentSchoolFilter = SchoolFilter.all;
  String _searchQuery = '';
  bool _showRightPanel = false;
  StudentModel? _selectedStudent;
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
  final _rollNoController = TextEditingController();
  final _admissionNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _casteCategoryController = TextEditingController();
  final _adharNumberController = TextEditingController();
  final _sssmidController = TextEditingController();
  final _feeAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();

  // ============ FORM STATE ============
  String _selectedGender = 'Male';
  String _selectedClass = 'KG';
  String _selectedFeeStatus = 'Paid';
  String _selectedSchoolForm = 'School A';
  bool _checkBox = true;
  File? _imageFile;

  // ============ CONSTANTS ============
  final List<String> _classList = [
    'KG', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th', '5th',
    '6th', '7th', '8th', '9th', '10th', '11th', '12th',
  ];
  final List<String> _genderList = ['Male', 'Female', 'Other'];
  final List<String> _feeStatusList = ['Paid', 'Pending', 'Overdue'];
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
    _rollNoController.dispose();
    _admissionNoController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _parentPhoneController.dispose();
    _casteCategoryController.dispose();
    _adharNumberController.dispose();
    _sssmidController.dispose();
    _feeAmountController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  // ============ SAMPLE DATA ============
  void _loadSampleData() {
    _students = [
      // ===== School A Students =====
      StudentModel(
        id: 'S001',
        firstName: 'Aarav',
        middleName: 'Kumar',
        lastName: 'Sharma',
        dob: '15 Jan 2015',
        gender: 'Male',
        fatherName: 'Rajesh Sharma',
        motherName: 'Sunita Sharma',
        parentPhone: '+91 98765 43210',
        alternativePhone: '+91 98765 43211',
        studentClass: '5th',
        rollNumber: '101',
        admissionNumber: 'ADM2023001',
        email: 'aarav@student.com',
        address: '123, Green Park, New Delhi',
        casteCategory: 'General',
        adharNumber: '1234 5678 9012',
        sssmid: 'SSM2023001',
        feeStatus: 'Paid',
        feeAmount: '5000',
        paidAmount: '5000',
        checkBox: true,
        school: 'School A',
        createdAt: 'Jan 2023',
      ),
      StudentModel(
        id: 'S002',
        firstName: 'Priya',
        middleName: '',
        lastName: 'Patel',
        dob: '22 Jun 2014',
        gender: 'Female',
        fatherName: 'Mukesh Patel',
        motherName: 'Rekha Patel',
        parentPhone: '+91 98765 43212',
        alternativePhone: '+91 98765 43213',
        studentClass: '6th',
        rollNumber: '102',
        admissionNumber: 'ADM2023002',
        email: 'priya@student.com',
        address: '45, Patel Nagar, Mumbai',
        casteCategory: 'OBC',
        adharNumber: '2345 6789 0123',
        sssmid: 'SSM2023002',
        feeStatus: 'Pending',
        feeAmount: '5500',
        paidAmount: '2000',
        checkBox: true,
        school: 'School A',
        createdAt: 'Jan 2023',
      ),
      StudentModel(
        id: 'S003',
        firstName: 'Rohan',
        middleName: 'Singh',
        lastName: 'Verma',
        dob: '10 Sep 2013',
        gender: 'Male',
        fatherName: 'Vikram Verma',
        motherName: 'Neha Verma',
        parentPhone: '+91 98765 43214',
        alternativePhone: '+91 98765 43215',
        studentClass: '7th',
        rollNumber: '103',
        admissionNumber: 'ADM2023003',
        email: 'rohan@student.com',
        address: '78, Verma Colony, Jaipur',
        casteCategory: 'General',
        adharNumber: '3456 7890 1234',
        sssmid: 'SSM2023003',
        feeStatus: 'Paid',
        feeAmount: '6000',
        paidAmount: '6000',
        checkBox: true,
        school: 'School A',
        createdAt: 'Feb 2023',
      ),
      StudentModel(
        id: 'S004',
        firstName: 'Sneha',
        middleName: '',
        lastName: 'Reddy',
        dob: '05 Dec 2015',
        gender: 'Female',
        fatherName: 'Suresh Reddy',
        motherName: 'Lakshmi Reddy',
        parentPhone: '+91 98765 43216',
        alternativePhone: '',
        studentClass: '4th',
        rollNumber: '104',
        admissionNumber: 'ADM2023004',
        email: 'sneha@student.com',
        address: '234, Reddy Nagar, Hyderabad',
        casteCategory: 'SC',
        adharNumber: '4567 8901 2345',
        sssmid: 'SSM2023004',
        feeStatus: 'Overdue',
        feeAmount: '4500',
        paidAmount: '1000',
        checkBox: false,
        school: 'School A',
        createdAt: 'Mar 2023',
      ),
      StudentModel(
        id: 'S005',
        firstName: 'Arjun',
        middleName: 'Kumar',
        lastName: 'Nair',
        dob: '18 Feb 2016',
        gender: 'Male',
        fatherName: 'Rajan Nair',
        motherName: 'Sindhu Nair',
        parentPhone: '+91 98765 43218',
        alternativePhone: '+91 98765 43219',
        studentClass: '3rd',
        rollNumber: '105',
        admissionNumber: 'ADM2023005',
        email: 'arjun@student.com',
        address: '567, Nair House, Kochi',
        casteCategory: 'General',
        adharNumber: '5678 9012 3456',
        sssmid: 'SSM2023005',
        feeStatus: 'Paid',
        feeAmount: '4000',
        paidAmount: '4000',
        checkBox: true,
        school: 'School A',
        createdAt: 'Apr 2023',
      ),
      // ===== School B Students =====
      StudentModel(
        id: 'S006',
        firstName: 'Kavya',
        middleName: '',
        lastName: 'Gupta',
        dob: '12 Apr 2014',
        gender: 'Female',
        fatherName: 'Rahul Gupta',
        motherName: 'Pooja Gupta',
        parentPhone: '+91 98765 43220',
        alternativePhone: '+91 98765 43221',
        studentClass: '6th',
        rollNumber: '201',
        admissionNumber: 'ADM2023006',
        email: 'kavya@student.com',
        address: '890, Gupta Colony, Lucknow',
        casteCategory: 'General',
        adharNumber: '6789 0123 4567',
        sssmid: 'SSM2023006',
        feeStatus: 'Pending',
        feeAmount: '5500',
        paidAmount: '3000',
        checkBox: true,
        school: 'School B',
        createdAt: 'Jan 2023',
      ),
      StudentModel(
        id: 'S007',
        firstName: 'Vikram',
        middleName: 'Singh',
        lastName: 'Rathore',
        dob: '03 Jul 2015',
        gender: 'Male',
        fatherName: 'Thakur Rathore',
        motherName: 'Rani Rathore',
        parentPhone: '+91 98765 43222',
        alternativePhone: '+91 98765 43223',
        studentClass: '5th',
        rollNumber: '202',
        admissionNumber: 'ADM2023007',
        email: 'vikram@student.com',
        address: '123, Rathore Palace, Jodhpur',
        casteCategory: 'OBC',
        adharNumber: '7890 1234 5678',
        sssmid: 'SSM2023007',
        feeStatus: 'Paid',
        feeAmount: '5000',
        paidAmount: '5000',
        checkBox: true,
        school: 'School B',
        createdAt: 'Feb 2023',
      ),
      StudentModel(
        id: 'S008',
        firstName: 'Ananya',
        middleName: '',
        lastName: 'Iyer',
        dob: '28 Nov 2013',
        gender: 'Female',
        fatherName: 'Subramanian Iyer',
        motherName: 'Lakshmi Iyer',
        parentPhone: '+91 98765 43224',
        alternativePhone: '+91 98765 43225',
        studentClass: '7th',
        rollNumber: '203',
        admissionNumber: 'ADM2023008',
        email: 'ananya@student.com',
        address: '456, Iyer Street, Chennai',
        casteCategory: 'General',
        adharNumber: '8901 2345 6789',
        sssmid: 'SSM2023008',
        feeStatus: 'Overdue',
        feeAmount: '6000',
        paidAmount: '1500',
        checkBox: false,
        school: 'School B',
        createdAt: 'Mar 2023',
      ),
      StudentModel(
        id: 'S009',
        firstName: 'Dhruv',
        middleName: 'Kumar',
        lastName: 'Mishra',
        dob: '15 Jan 2016',
        gender: 'Male',
        fatherName: 'Ram Mishra',
        motherName: 'Sita Mishra',
        parentPhone: '+91 98765 43226',
        alternativePhone: '',
        studentClass: '4th',
        rollNumber: '204',
        admissionNumber: 'ADM2023009',
        email: 'dhruv@student.com',
        address: '789, Mishra Nagar, Patna',
        casteCategory: 'SC',
        adharNumber: '9012 3456 7890',
        sssmid: 'SSM2023009',
        feeStatus: 'Paid',
        feeAmount: '4500',
        paidAmount: '4500',
        checkBox: true,
        school: 'School B',
        createdAt: 'Apr 2023',
      ),
      StudentModel(
        id: 'S010',
        firstName: 'Meera',
        middleName: '',
        lastName: 'Menon',
        dob: '22 Aug 2015',
        gender: 'Female',
        fatherName: 'Gopal Menon',
        motherName: 'Radha Menon',
        parentPhone: '+91 98765 43228',
        alternativePhone: '+91 98765 43229',
        studentClass: '5th',
        rollNumber: '205',
        admissionNumber: 'ADM2023010',
        email: 'meera@student.com',
        address: '321, Menon House, Trivandrum',
        casteCategory: 'General',
        adharNumber: '0123 4567 8901',
        sssmid: 'SSM2023010',
        feeStatus: 'Pending',
        feeAmount: '5000',
        paidAmount: '2500',
        checkBox: true,
        school: 'School B',
        createdAt: 'May 2023',
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
  List<StudentModel> get _filteredStudents {
    var filtered = _students;

    // School Filter
    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      filtered = filtered.where((student) => student.school == 'School A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      filtered = filtered.where((student) => student.school == 'School B').toList();
    }

    // Class Filter
    if (_currentFilter != StudentFilter.all) {
      final classMap = {
        StudentFilter.classKG: 'KG',
        StudentFilter.classLKG: 'LKG',
        StudentFilter.classUKG: 'UKG',
        StudentFilter.class1st: '1st',
        StudentFilter.class2nd: '2nd',
        StudentFilter.class3rd: '3rd',
        StudentFilter.class4th: '4th',
        StudentFilter.class5th: '5th',
        StudentFilter.class6th: '6th',
        StudentFilter.class7th: '7th',
        StudentFilter.class8th: '8th',
        StudentFilter.class9th: '9th',
        StudentFilter.class10th: '10th',
        StudentFilter.class11th: '11th',
        StudentFilter.class12th: '12th',
      };
      final className = classMap[_currentFilter];
      if (className != null) {
        filtered = filtered.where((student) => student.studentClass == className).toList();
      }
    }

    // Search Filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((student) =>
      '${student.firstName} ${student.middleName} ${student.lastName}'.toLowerCase().contains(query) ||
          student.id.toLowerCase().contains(query) ||
          student.rollNumber.toLowerCase().contains(query) ||
          student.admissionNumber.toLowerCase().contains(query) ||
          student.studentClass.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query) ||
          student.school.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }

  int get _totalStudents => _students.length;
  int get _paidStudents => _students.where((s) => s.feeStatus == 'Paid').length;
  int get _pendingStudents => _students.where((s) => s.feeStatus == 'Pending' || s.feeStatus == 'Overdue').length;

  Map<String, int> get _schoolWiseStats {
    Map<String, int> stats = {};
    for (var student in _students) {
      stats[student.school] = (stats[student.school] ?? 0) + 1;
    }
    return stats;
  }

  // ============ FORM METHODS ============
  void _resetForm() {
    _firstNameController.clear();
    _middleNameController.clear();
    _lastNameController.clear();
    _dobController.clear();
    _rollNoController.clear();
    _admissionNoController.clear();
    _emailController.clear();
    _phoneController.clear();
    _altPhoneController.clear();
    _addressController.clear();
    _fatherNameController.clear();
    _motherNameController.clear();
    _parentPhoneController.clear();
    _casteCategoryController.clear();
    _adharNumberController.clear();
    _sssmidController.clear();
    _feeAmountController.clear();
    _paidAmountController.clear();
    _selectedGender = 'Male';
    _selectedClass = 'KG';
    _selectedFeeStatus = 'Paid';
    _selectedSchoolForm = 'School A';
    _checkBox = true;
    _imageFile = null;
    _formKey.currentState?.reset();
  }

  void _loadStudentToForm(StudentModel student) {
    _firstNameController.text = student.firstName;
    _middleNameController.text = student.middleName;
    _lastNameController.text = student.lastName;
    _dobController.text = student.dob;
    _rollNoController.text = student.rollNumber;
    _admissionNoController.text = student.admissionNumber;
    _emailController.text = student.email;
    _phoneController.text = student.parentPhone;
    _altPhoneController.text = student.alternativePhone;
    _addressController.text = student.address;
    _fatherNameController.text = student.fatherName;
    _motherNameController.text = student.motherName;
    _parentPhoneController.text = student.parentPhone;
    _casteCategoryController.text = student.casteCategory;
    _adharNumberController.text = student.adharNumber;
    _sssmidController.text = student.sssmid;
    _feeAmountController.text = student.feeAmount;
    _paidAmountController.text = student.paidAmount;
    _selectedGender = student.gender;
    _selectedClass = student.studentClass;
    _selectedFeeStatus = student.feeStatus;
    _selectedSchoolForm = student.school;
    _checkBox = student.checkBox;
    _imageFile = student.profileImage != null ? File(student.profileImage!) : null;
  }

  StudentModel _createStudentFromForm(String id) {
    return StudentModel(
      id: id,
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _selectedGender,
      fatherName: _fatherNameController.text.trim(),
      motherName: _motherNameController.text.trim(),
      parentPhone: _parentPhoneController.text.trim(),
      alternativePhone: _altPhoneController.text.trim(),
      studentClass: _selectedClass,
      rollNumber: _rollNoController.text.trim(),
      admissionNumber: _admissionNoController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      casteCategory: _casteCategoryController.text.trim(),
      adharNumber: _adharNumberController.text.trim(),
      sssmid: _sssmidController.text.trim(),
      feeStatus: _selectedFeeStatus,
      feeAmount: _feeAmountController.text.trim().isEmpty ? '0.00' : _feeAmountController.text.trim(),
      paidAmount: _paidAmountController.text.trim().isEmpty ? '0.00' : _paidAmountController.text.trim(),
      checkBox: _checkBox,
      profileImage: _imageFile?.path,
      school: _selectedSchoolForm,
      createdAt: DateFormat('MMM yyyy').format(DateTime.now()),
    );
  }

  // ============ CRUD OPERATIONS ============
  void _addStudent() {
    if (!_formKey.currentState!.validate()) return;

    final newStudent = _createStudentFromForm(
        'S${(_students.length + 1).toString().padLeft(3, '0')}'
    );

    setState(() {
      _students.add(newStudent);
      _showRightPanel = false;
      _isAddingNew = false;
      _resetForm();
    });

    _showSnackbar('Student added successfully!', Colors.green);
  }

  void _updateStudent() {
    if (!_formKey.currentState!.validate()) return;

    final updatedStudent = _createStudentFromForm(_selectedStudent!.id);
    final index = _students.indexWhere((s) => s.id == _selectedStudent!.id);

    if (index != -1) {
      setState(() {
        _students[index] = updatedStudent;
        _selectedStudent = updatedStudent;
        _isEditing = false;
        _resetForm();
      });
      _showSnackbar('Student updated successfully!', Colors.blue);
    }
  }

  void _deleteStudent(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.firstName} ${student.lastName}?'),
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
                _students.removeWhere((s) => s.id == student.id);
                if (_selectedStudent?.id == student.id) {
                  _showRightPanel = false;
                  _selectedStudent = null;
                }
              });
              _showSnackbar('Student deleted successfully!', Colors.red);
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
  Color _getFeeStatusColor(String status) {
    switch (status) {
      case 'Paid': return Colors.green;
      case 'Pending': return Colors.orange;
      case 'Overdue': return Colors.red;
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

  String _getInitials(String firstName, String lastName) {
    if (firstName.isEmpty || lastName.isEmpty) return '??';
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
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
            // Left Panel - Student List
            Expanded(
              flex: _showRightPanel ? 5 : 8,
              child: Column(
                children: [
                  _buildHeader(schoolLabel, schoolStats),
                  _buildFilterSearchBar(),
                  Expanded(
                    child: _filteredStudents.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        return _buildStudentCard(_filteredStudents[index]);
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
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 60,
                color: Colors.blue[200],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Student Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a student from the list or create a new one',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '👨‍🎓 ${_students.length} Total Students',
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
                  label: 'Paid',
                  count: _paidStudents,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildEmptyStatCard(
                  icon: Icons.warning,
                  label: 'Pending',
                  count: _pendingStudents,
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
                  _showAttendance = false;
                  _selectedStudent = null;
                  _showRightPanel = true;
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Student'),
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
                  Icons.people,
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
                        'Students Management',
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
                    '${_filteredStudents.length} students found',
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
                        _selectedStudent = null;
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
                      _selectedStudent = null;
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
                      _selectedStudent = null;
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
                  hintText: 'Search students...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildClassFilterChip('All', StudentFilter.all, Colors.blue),
          const SizedBox(width: 4),
          _buildClassFilterChip('KG', StudentFilter.classKG, Colors.purple),
          const SizedBox(width: 4),
          _buildClassFilterChip('1st', StudentFilter.class1st, Colors.green),
          const SizedBox(width: 4),
          _buildClassFilterChip('5th', StudentFilter.class5th, Colors.orange),
          const SizedBox(width: 4),
          _buildClassFilterChip('10th', StudentFilter.class10th, Colors.red),
        ],
      ),
    );
  }

  Widget _buildClassFilterChip(String label, StudentFilter filter, Color color) {
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

  // ============ STUDENT CARD ============
  Widget _buildStudentCard(StudentModel student) {
    final isSelected = _selectedStudent?.id == student.id;
    final schoolColor = _getSchoolColor(student.school);

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
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getGenderColor(student.gender).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getInitials(student.firstName, student.lastName),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getGenderColor(student.gender),
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
                  _selectedStudent = student;
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
                          '${student.firstName} ${student.middleName.isNotEmpty ? student.middleName + ' ' : ''}${student.lastName}',
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
                          color: _getFeeStatusColor(student.feeStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          student.feeStatus,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _getFeeStatusColor(student.feeStatus),
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
                      _buildInfoText(Icons.school, student.school, color: schoolColor),
                      _buildInfoText(Icons.class_, student.studentClass),
                      _buildInfoText(Icons.numbers, 'Roll ${student.rollNumber}'),
                      _buildInfoText(Icons.badge, student.admissionNumber),
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
                    setState(() {
                      _selectedStudent = student;
                      _showAttendance = true;
                      _showRightPanel = true;
                      _isEditing = false;
                      _isAddingNew = false;
                    });
                  },
                  icon: Icon(
                    Icons.calendar_month,
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {
                    _loadStudentToForm(student);
                    setState(() {
                      _selectedStudent = student;
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
                  onPressed: () => _deleteStudent(student),
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
            'No Students Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Click "Add New" to create a student',
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
                _selectedStudent = null;
                _showRightPanel = true;
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New Student'),
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
    if (_selectedStudent == null) return const SizedBox();

    final student = _selectedStudent!;
    final schoolColor = _getSchoolColor(student.school);

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
                  color: _getGenderColor(student.gender).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getInitials(student.firstName, student.lastName),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getGenderColor(student.gender),
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
                      '${student.firstName} ${student.middleName.isNotEmpty ? student.middleName + ' ' : ''}${student.lastName}',
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
                                student.school,
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
                            color: _getFeeStatusColor(student.feeStatus).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            student.feeStatus,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getFeeStatusColor(student.feeStatus),
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
                            student.id,
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

          // Personal Info
          _buildDetailRow('📛 Name', '${student.firstName} ${student.middleName.isNotEmpty ? student.middleName + ' ' : ''}${student.lastName}'),
          _buildDetailRow('🎂 DOB', student.dob),
          _buildDetailRow('⚧ Gender', student.gender),
          _buildDetailRow('🏫 School', student.school, color: schoolColor, isBold: true),
          _buildDetailRow('📧 Email', student.email),
          _buildDetailRow('📱 Phone', student.parentPhone),
          if (student.alternativePhone.isNotEmpty)
            _buildDetailRow('📱 Alt Phone', student.alternativePhone),
          _buildDetailRow('📍 Address', student.address),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Parent Info
          _buildDetailRow('👨 Father', student.fatherName),
          _buildDetailRow('👩 Mother', student.motherName),
          _buildDetailRow('📱 Parent Phone', student.parentPhone),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Academic Info
          _buildDetailRow('📚 Class', student.studentClass),
          _buildDetailRow('🔢 Roll No', student.rollNumber),
          _buildDetailRow('🎫 Admission No', student.admissionNumber),
          _buildDetailRow('📋 Caste', student.casteCategory.isNotEmpty ? student.casteCategory : 'N/A'),
          _buildDetailRow('🪪 Aadhar', student.adharNumber.isNotEmpty ? student.adharNumber : 'N/A'),
          _buildDetailRow('🔑 SSSMID', student.sssmid.isNotEmpty ? student.sssmid : 'N/A'),
          _buildDetailRow('📅 Created', student.createdAt),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Fee Info
          _buildDetailRow('💰 Fee Amount', '₹${student.feeAmount}'),
          _buildDetailRow('💵 Paid Amount', '₹${student.paidAmount}'),
          _buildDetailRow('📊 Fee Status', student.feeStatus, color: _getFeeStatusColor(student.feeStatus), isBold: true),
          _buildDetailRow('📌 Status', student.checkBox ? 'Active ✅' : 'Inactive ❌',
              color: student.checkBox ? Colors.green : Colors.red, isBold: true),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _selectedStudent = null;
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
                    _loadStudentToForm(student);
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
                  onPressed: () => _deleteStudent(student),
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
    if (_selectedStudent == null) return const SizedBox();

    final stats = _getAttendanceStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Attendance - ${_selectedStudent!.firstName} ${_selectedStudent!.lastName}',
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
                        Colors.blue,
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
                  ? Border.all(color: Colors.blue, width: 2)
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
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Add New Student',
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
                  onPressed: _addStudent,
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
                    'Add Student',
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
    if (_selectedStudent == null) return const SizedBox();

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
                'Edit Student',
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
                  onPressed: _updateStudent,
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

        // Parent Information
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.family_restroom, color: Colors.green[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Parent Information',
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
        Row(
          children: [
            Expanded(
              child: _buildFormTextField(_fatherNameController, 'Father Name', Icons.person,
                  required: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFormTextField(_motherNameController, 'Mother Name', Icons.person,
                  required: true),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildFormTextField(_parentPhoneController, 'Parent Phone', Icons.phone,
            required: true),
        const SizedBox(height: 12),

        // Academic Information
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.school, color: Colors.orange[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Academic Information',
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
              child: _buildDropdownField('Class', _classList, _selectedClass, (value) {
                setState(() => _selectedClass = value!);
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFormTextField(_rollNoController, 'Roll No', Icons.numbers,
                  required: true),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildFormTextField(_admissionNoController, 'Admission No', Icons.badge,
            required: true),
        const SizedBox(height: 12),

        // Contact & Additional Information
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.contact_mail, color: Colors.teal[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Contact & Additional Information',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[700],
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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFormTextField(_casteCategoryController, 'Caste Category', Icons.category),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFormTextField(_adharNumberController, 'Aadhar Number', Icons.card_membership),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildFormTextField(_sssmidController, 'SSSMID', Icons.numbers),
        const SizedBox(height: 12),

        // Fee & Status Information
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.payment, color: Colors.red[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Fee & Status Information',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFormTextField(_feeAmountController, 'Fee Amount', Icons.money),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFormTextField(_paidAmountController, 'Paid Amount', Icons.payment),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField('Fee Status', _feeStatusList, _selectedFeeStatus, (value) {
                setState(() => _selectedFeeStatus = value!);
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SwitchListTile(
                title: const Text('Active'),
                value: _checkBox,
                onChanged: (v) => setState(() => _checkBox = v),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
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
          borderSide: BorderSide(color: Colors.blue[700]!),
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
          borderSide: BorderSide(color: Colors.blue[700]!),
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