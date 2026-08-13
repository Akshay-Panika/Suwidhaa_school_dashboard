import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../controller/student_controller.dart';
import '../model/student_model.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final StudentController controller = Get.find<StudentController>();

  // ============ STATE ============
  String searchQuery = '';
  String selectedFilter = 'All';
  StudentModel? selectedStudent;
  bool _isAdding = false;
  bool _isLoading = false;
  int _currentPage = 0;
  final int _itemsPerPage = 8;
  File? _imageFile;

  // ============ RIGHT PANEL MODE ============
  String _rightPanelMode = 'details';

  // ============ ATTENDANCE CALENDAR STATE ============
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
  bool _checkBox = false;

  // ============ CONSTANTS ============
  final List<String> _classList = [
    'All', 'KG', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th', '5th',
    '6th', '7th', '8th', '9th', '10th', '11th', '12th',
  ];
  final List<String> _genderList = ['Male', 'Female', 'Other'];
  final List<String> _feeStatusList = ['Paid', 'Pending', 'Overdue'];

  // ============ GETTERS ============
  List<StudentModel> get _filteredStudents {
    return controller.students.where((student) {
      final search = searchQuery.toLowerCase();
      final fullName = '${student.firstName} ${student.middleName} ${student.lastName}'.toLowerCase();
      final matchesSearch = fullName.contains(search) ||
          student.id.toString().contains(search) ||
          student.studentClass.toLowerCase().contains(search) ||
          student.rollNumber.toLowerCase().contains(search) ||
          student.admissionNumber.toLowerCase().contains(search);

      if (selectedFilter == 'All') return matchesSearch;
      return matchesSearch && student.studentClass == selectedFilter;
    }).toList();
  }

  List<StudentModel> get _paginatedStudents {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage) > _filteredStudents.length
        ? _filteredStudents.length
        : start + _itemsPerPage;
    return _filteredStudents.sublist(start, end);
  }

  int get _totalPages => (_filteredStudents.length / _itemsPerPage).ceil();

  // ============ LIFECYCLE ============
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

  @override
  void initState() {
    super.initState();
    _generateSampleAttendance();
    controller.fetchAllStudents();
  }

  // ============ ATTENDANCE CALENDAR METHODS ============
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

  // ============ CRUD OPERATIONS ============
  void _clearForm() {
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
    _checkBox = false;
    _imageFile = null;
    _formKey.currentState?.reset();
  }

  void _addStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await controller.addStudent(
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
      );

      setState(() {
        _isAdding = false;
        _clearForm();
        _isLoading = false;
        _rightPanelMode = 'details';
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _updateStudent(StudentModel student) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await controller.updateStudent(
        id: student.id,
        firstName: _firstNameController.text.trim().isNotEmpty ? _firstNameController.text.trim() : student.firstName,
        middleName: _middleNameController.text.trim().isNotEmpty ? _middleNameController.text.trim() : student.middleName,
        lastName: _lastNameController.text.trim().isNotEmpty ? _lastNameController.text.trim() : student.lastName,
        dob: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : student.dob,
        gender: _selectedGender,
        fatherName: _fatherNameController.text.trim().isNotEmpty ? _fatherNameController.text.trim() : student.fatherName,
        motherName: _motherNameController.text.trim().isNotEmpty ? _motherNameController.text.trim() : student.motherName,
        parentPhone: _parentPhoneController.text.trim().isNotEmpty ? _parentPhoneController.text.trim() : student.parentPhone,
        alternativePhone: _altPhoneController.text.trim().isNotEmpty ? _altPhoneController.text.trim() : student.alternativePhone,
        studentClass: _selectedClass,
        rollNumber: _rollNoController.text.trim().isNotEmpty ? _rollNoController.text.trim() : student.rollNumber,
        admissionNumber: _admissionNoController.text.trim().isNotEmpty ? _admissionNoController.text.trim() : student.admissionNumber,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : student.email,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : student.address,
        casteCategory: _casteCategoryController.text.trim().isNotEmpty ? _casteCategoryController.text.trim() : student.casteCategory,
        adharNumber: _adharNumberController.text.trim().isNotEmpty ? _adharNumberController.text.trim() : student.adharNumber,
        sssmid: _sssmidController.text.trim().isNotEmpty ? _sssmidController.text.trim() : student.sssmid,
        feeStatus: _selectedFeeStatus,
        feeAmount: _feeAmountController.text.trim().isNotEmpty ? _feeAmountController.text.trim() : student.feeAmount,
        paidAmount: _paidAmountController.text.trim().isNotEmpty ? _paidAmountController.text.trim() : student.paidAmount,
        checkBox: _checkBox,
        profileImage: _imageFile?.path ?? student.profileImage,
      );

      setState(() {
        _isAdding = false;
        _clearForm();
        _isLoading = false;
        _rightPanelMode = 'details';
        selectedStudent = null;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _deleteStudent(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.firstName} ${student.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await controller.deleteStudent(student.id);
                if (selectedStudent?.id == student.id) {
                  setState(() => selectedStudent = null);
                }
                setState(() => _isLoading = false);
              } catch (e) {
                setState(() => _isLoading = false);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editStudent(StudentModel student) {
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
    _checkBox = student.checkBox;
    _imageFile = student.profileImage != null ? File(student.profileImage!) : null;

    setState(() {
      _isAdding = true;
      _rightPanelMode = 'edit';
      selectedStudent = student;
    });
  }


  Color _getFeeStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(String firstName, String lastName) {
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left Panel
              Expanded(
                flex: _isAdding ? 1 : 2,
                child: Column(
                  children: [
                    // Stats
                    Obx(() => _buildStats(
                      controller.students.length,
                      controller.students.where((s) => s.feeStatus == 'Paid').length,
                      controller.students.where((s) => s.feeStatus == 'Pending').length,
                    )),

                    // Search & Add
                    _buildToolbar(),

                    Row(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(onPressed: () {

                        }, child: Text("School A")),
                        ElevatedButton(onPressed: () {

                        }, child: Text("School B")),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // List
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (controller.errorMessage.value.isNotEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.red, size: 60),
                                const SizedBox(height: 16),
                                Text(
                                  controller.errorMessage.value,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: controller.fetchAllStudents,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (controller.students.isEmpty) {
                          return const Center(
                            child: Text('No students found'),
                          );
                        }

                        if (_filteredStudents.isEmpty) {
                          return _buildEmptyState();
                        }

                        return _buildStudentList();
                      }),
                    ),

                    // Pagination
                    if (_filteredStudents.length > _itemsPerPage)
                      _buildPagination(),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Right Panel
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isAdding
                      ? _buildForm()
                      : selectedStudent != null
                      ? _buildRightPanelContent(selectedStudent!)
                      : _buildEmptyDetails(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ RIGHT PANEL CONTENT ============
  Widget _buildRightPanelContent(StudentModel student) {
    switch (_rightPanelMode) {
      case 'attendance':
        return _buildAttendanceCard(student);
      case 'edit':
        return _buildForm();
      case 'details':
      default:
        return _buildDetails(student);
    }
  }

  // ============ ATTENDANCE CARD ============
  Widget _buildAttendanceCard(StudentModel student) {
    final stats = _getAttendanceStats();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              _buildAvatar(student),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${student.firstName} ${student.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${student.studentClass} • Roll ${student.rollNumber}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _rightPanelMode = 'details');
                },
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                          Expanded(child: _attendanceStatItem('Present', stats['present'].toString(), Colors.green, Icons.check_circle)),
                          Expanded(child: _attendanceStatItem('Absent', stats['absent'].toString(), Colors.red, Icons.cancel)),
                          Expanded(child: _attendanceStatItem('Leave', stats['leave'].toString(), Colors.orange, Icons.beach_access)),
                          Expanded(child: _attendanceStatItem('Total', stats['total'].toString(), Colors.blue, Icons.calendar_today)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Attendance Percentage', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: stats['percentage'] >= 85 ? Colors.green.withOpacity(0.2) : stats['percentage'] >= 70 ? Colors.orange.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${stats['percentage']}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: stats['percentage'] >= 85 ? Colors.green : stats['percentage'] >= 70 ? Colors.orange : Colors.red,
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
                          stats['percentage'] >= 85 ? Colors.green : stats['percentage'] >= 70 ? Colors.orange : Colors.red,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                          Text('${DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonthIndex + 1))}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left),
                                  style: IconButton.styleFrom(backgroundColor: Colors.grey[200], padding: const EdgeInsets.all(4), minimumSize: const Size(30, 30))),
                              IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right),
                                  style: IconButton.styleFrom(backgroundColor: Colors.grey[200], padding: const EdgeInsets.all(4), minimumSize: const Size(30, 30))),
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
          ),
        ),
      ],
    );
  }

  Widget _attendanceStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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
      final isToday = date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year;

      dayWidgets.add(
        GestureDetector(
          onTap: () { if (!isWeekend) _toggleAttendance(dateKey); },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isWeekend ? Colors.grey[200] : status == 'Present' ? Colors.green.withOpacity(0.7) : status == 'Absent' ? Colors.red.withOpacity(0.7) : status == 'Leave' ? Colors.orange.withOpacity(0.7) : Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(day.toString(),
                      style: TextStyle(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isWeekend || status != null ? Colors.white : Colors.black87,
                        fontSize: 12,
                      )),
                  if (status != null && !isWeekend)
                    Icon(status == 'Present' ? Icons.check_circle : status == 'Absent' ? Icons.cancel : Icons.beach_access,
                        size: 10, color: Colors.white),
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
          child: Text(day, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: day == 'Sat' || day == 'Sun' ? Colors.red : Colors.grey[600])),
        )).toList(),
        ...dayWidgets,
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  // ============ STATS ============
  Widget _buildStats(int total, int paid, int pending) {
    return Row(
      children: [
        _statCard('Total', total.toString(), Icons.people, Colors.blue),
        _statCard('Paid', paid.toString(), Icons.check_circle, Colors.green),
        _statCard('Pending', pending.toString(), Icons.warning, Colors.orange),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ TOOLBAR ============
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[400], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) { setState(() { searchQuery = value; _currentPage = 0; }); },
                      decoration: const InputDecoration(hintText: 'Search students...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      onPressed: () { setState(() { searchQuery = ''; _currentPage = 0; }); },
                      icon: Icon(Icons.clear, color: Colors.grey[400], size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                items: _classList.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (String? newValue) { setState(() { selectedFilter = newValue!; _currentPage = 0; }); },
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                if (_isAdding) { _isAdding = false; _clearForm(); }
                else { _isAdding = true; _clearForm(); selectedStudent = null; _rightPanelMode = 'edit'; }
              });
            },
            icon: Icon(_isAdding ? Icons.close : Icons.add, size: 18),
            label: Text(_isAdding ? 'Close' : 'Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAdding ? Colors.red : const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ============ STUDENT LIST ============
  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: _paginatedStudents.length,
      itemBuilder: (context, index) {
        final student = _paginatedStudents[index];
        final isSelected = selectedStudent?.id == student.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? Colors.blue[300]! : Colors.grey[200]!, width: isSelected ? 1 : 1),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                if (_isAdding) { _isAdding = false; _clearForm(); }
                selectedStudent = student;
                _rightPanelMode = 'details';
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildAvatar(student),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Roll: ${student.rollNumber}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                        Text('${student.firstName} ${student.middleName} ${student.lastName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 20,),
                Row(
                  children: [
                    _buildChip('Class: ${student.studentClass}', Colors.blue),
                    const SizedBox(width: 16),
                    _buildChip('Fee: ${student.feeStatus}', _getFeeStatusColor(student.feeStatus)),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () { setState(() { selectedStudent = student; _rightPanelMode = 'attendance'; }); },
                        icon: const Icon(Icons.calendar_month, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () { setState(() { selectedStudent = student; _rightPanelMode = 'details'; }); },
                        icon: Icon(selectedStudent?.id == student.id ? Icons.visibility : Icons.visibility_off),
                      ),
                      IconButton(
                        onPressed: () { _editStudent(student); },
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () { _deleteStudent(student); },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(StudentModel student) {
    if (student.profileImage != null && File(student.profileImage!).existsSync()) {
      return CircleAvatar(radius: 20, backgroundImage: FileImage(File(student.profileImage!)));
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.blue[100],
      child: Text(_getInitials(student.firstName, student.lastName), style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }

  // ============ PAGINATION ============
  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(backgroundColor: _currentPage > 0 ? Colors.grey[100] : Colors.transparent),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
            child: Text('${_currentPage + 1} / $_totalPages', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue[700])),
          ),
          IconButton(
            onPressed: _currentPage < _totalPages - 1 ? () => setState(() => _currentPage++) : null,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(backgroundColor: _currentPage < _totalPages - 1 ? Colors.grey[100] : Colors.transparent),
          ),
        ],
      ),
    );
  }

  // ============ EMPTY STATES ============
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('No students found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          Text('Try adjusting your search or filter', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildEmptyDetails() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('Select a Student', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          Text('Click on a student to view details', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  // ============ FORM ============
  Widget _buildForm() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                    child: Icon(selectedStudent != null ? Icons.edit : Icons.person_add, color: Colors.blue[700], size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(selectedStudent != null ? 'Edit Student' : 'Add Student', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      onPressed: () { setState(() { _isAdding = false; _clearForm(); _rightPanelMode = 'details'; }); },
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(alignment: Alignment.topRight, child: _buildPhotoUpload()),
                  const SizedBox(height: 10),
                  _buildFormSection('Personal Information'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildTextField(controller: _firstNameController, label: 'First Name', icon: Icons.person_outline, required: true)),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: _buildTextField(controller: _middleNameController, label: 'Middle Name', icon: Icons.person_outline)),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: _buildTextField(controller: _lastNameController, label: 'Last Name', icon: Icons.person_outline, required: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _dobController, label: 'Date of Birth', icon: Icons.calendar_today, required: true, hintText: 'YYYY-MM-DD')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDropdown(value: _selectedGender, label: 'Gender', items: _genderList, onChanged: (v) => setState(() => _selectedGender = v!))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildFormSection('Parent Information'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _fatherNameController, label: 'Father Name', icon: Icons.person, required: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller: _motherNameController, label: 'Mother Name', icon: Icons.person, required: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _parentPhoneController, label: 'Parent Phone', icon: Icons.phone, required: true, keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  _buildFormSection('Academic Information'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown(value: _selectedClass, label: 'Class', items: _classList.where((c) => c != 'All').toList(), onChanged: (v) => setState(() => _selectedClass = v!))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller: _rollNoController, label: 'Roll No', icon: Icons.numbers, required: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _admissionNoController, label: 'Admission No', icon: Icons.badge, required: true),
                  const SizedBox(height: 10),
                  _buildFormSection('Contact & Additional Information'),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email, required: true),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _phoneController, label: 'Primary Phone', icon: Icons.phone, required: true, keyboardType: TextInputType.phone)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller: _altPhoneController, label: 'Alt Phone', icon: Icons.phone_android, keyboardType: TextInputType.phone)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _addressController, label: 'Address', icon: Icons.location_on, maxLines: 2, required: true),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _casteCategoryController, label: 'Caste Category', icon: Icons.category)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller: _adharNumberController, label: 'Aadhar Number', icon: Icons.card_membership)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _sssmidController, label: 'SSSMID', icon: Icons.numbers),
                  const SizedBox(height: 10),
                  _buildFormSection('Fee & Status Information'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _feeAmountController, label: 'Fee Amount', icon: Icons.money, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller: _paidAmountController, label: 'Paid Amount', icon: Icons.payment, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown(value: _selectedFeeStatus, label: 'Fee Status', items: _feeStatusList, onChanged: (v) => setState(() => _selectedFeeStatus = v!))),
                      const SizedBox(width: 12),
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () { setState(() { _isAdding = false; _clearForm(); _rightPanelMode = 'details'; }); },
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), side: BorderSide(color: Colors.grey[300]!)),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: selectedStudent != null ? () => _updateStudent(selectedStudent!) : _addStudent,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            elevation: 2,
                          ),
                          child: Text(selectedStudent != null ? 'Update Student' : 'Save Student', style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 3, height: 16, decoration: BoxDecoration(color: const Color(0xFF1A73E8), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700], letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.grey[600]) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red[300]!, width: 2)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red[300]!, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
          floatingLabelStyle: const TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.w500),
        ),
        validator: required ? (v) => v?.trim().isEmpty ?? true ? '$label is required' : null : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red[300]!)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red[300]!, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
          floatingLabelStyle: const TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.w500),
        ),
        items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: _imageFile != null
            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imageFile!, fit: BoxFit.cover))
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
              child: Icon(Icons.camera_alt, color: Colors.blue[700], size: 28),
            ),
            const SizedBox(height: 6),
            Text('Upload Photo', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ============ DETAILS ============
  Widget _infoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color ?? Colors.black)),
            ],
          ),
        ),
      ],
    );
  }
  // ============ DETAILS ============
  Widget _buildDetails(StudentModel student) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]),
                child: _buildAvatar(student),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${student.firstName} ${student.middleName.isNotEmpty ? student.middleName + ' ' : ''}${student.lastName}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: Text(student.studentClass, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: Text('Roll ${student.rollNumber}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: IconButton(onPressed: () => _editStudent(student), icon: const Icon(Icons.edit, color: Colors.white, size: 18), padding: const EdgeInsets.all(8)),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: IconButton(onPressed: () => _deleteStudent(student), icon: const Icon(Icons.delete_outline, color: Colors.white, size: 18), padding: const EdgeInsets.all(8)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Basic Information Grid
                _buildInfoGrid(student),
                const SizedBox(height: 16),

                // Parent Information
                _buildParentInfoCard(student),
                const SizedBox(height: 16),

                // Contact Information
                _buildContactInfoCard(student),
                const SizedBox(height: 16),

                // Academic & Personal Details
                _buildAcademicPersonalCard(student),
                const SizedBox(height: 16),

                // Fee Information
                _buildFeeInfoCard(student),
                const SizedBox(height: 16),

                // SSSMID & Created At
                _buildSSSMIDCard(student),
                const SizedBox(height: 16),

                // Status
                _buildStatusCard(student),
              ],
            ),
          ),
        ),
      ],
    );
  }

// ============ BASIC INFO GRID ============
  Widget _buildInfoGrid(StudentModel student) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 4.5,
      children: [
        _gridInfoItem(Icons.badge, 'ID', student.id.toString()),
        _gridInfoItem(Icons.email, 'Email', student.email),
        _gridInfoItem(Icons.phone, 'Phone', student.parentPhone),
        _gridInfoItem(Icons.phone_android, 'Alt Phone', student.alternativePhone.isNotEmpty ? student.alternativePhone : 'N/A'),
        _gridInfoItem(Icons.calendar_today, 'DOB', student.dob),
        _gridInfoItem(Icons.person_outline, 'Gender', student.gender),
        _gridInfoItem(Icons.category, 'Caste', student.casteCategory),
        _gridInfoItem(Icons.card_membership, 'Aadhar', student.adharNumber.isNotEmpty ? student.adharNumber : 'N/A'),
      ],
    );
  }

  Widget _gridInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[400]!)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Icon(icon, size: 14, color: Colors.blue[700])),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ============ PARENT INFO CARD ============
  Widget _buildParentInfoCard(StudentModel student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.family_restroom, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Parent Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.person, 'Father', student.fatherName),
          const SizedBox(height: 8),
          _infoRow(Icons.person_outline, 'Mother', student.motherName),
          const SizedBox(height: 8),
          _infoRow(Icons.phone, 'Parent Phone', student.parentPhone),
          const SizedBox(height: 8),
          _infoRow(Icons.phone_android, 'Alternative Phone', student.alternativePhone.isNotEmpty ? student.alternativePhone : 'N/A'),
        ],
      ),
    );
  }

// ============ CONTACT INFO CARD ============
  Widget _buildContactInfoCard(StudentModel student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_mail, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.email, 'Email', student.email),
          const SizedBox(height: 8),
          _infoRow(Icons.location_on, 'Address', student.address),
        ],
      ),
    );
  }

// ============ ACADEMIC & PERSONAL CARD ============
  Widget _buildAcademicPersonalCard(StudentModel student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Academic & Personal Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.class_, 'Class', student.studentClass),
          const SizedBox(height: 8),
          _infoRow(Icons.numbers, 'Roll Number', student.rollNumber),
          const SizedBox(height: 8),
          _infoRow(Icons.confirmation_number, 'Admission Number', student.admissionNumber),
          const SizedBox(height: 8),
          _infoRow(Icons.person, 'Full Name', '${student.firstName} ${student.middleName.isNotEmpty ? student.middleName + ' ' : ''}${student.lastName}'),
          const SizedBox(height: 8),
          _infoRow(Icons.calendar_today, 'Date of Birth', student.dob),
          const SizedBox(height: 8),
          _infoRow(Icons.person_outline, 'Gender', student.gender),
          const SizedBox(height: 8),
          _infoRow(Icons.category, 'Caste Category', student.casteCategory),
          const SizedBox(height: 8),
          _infoRow(Icons.card_membership, 'Aadhar Number', student.adharNumber.isNotEmpty ? student.adharNumber : 'N/A'),
        ],
      ),
    );
  }

// ============ FEE INFO CARD ============
  Widget _buildFeeInfoCard(StudentModel student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Fee Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.money, 'Fee Status', student.feeStatus, color: _getFeeStatusColor(student.feeStatus)),
          const SizedBox(height: 8),
          _infoRow(Icons.attach_money, 'Total Fee', '₹${student.feeAmount}'),
          const SizedBox(height: 8),
          _infoRow(Icons.payment, 'Paid Amount', '₹${student.paidAmount}'),
          const SizedBox(height: 8),
          _infoRow(Icons.currency_exchange, 'Pending Amount', '₹${(double.tryParse(student.feeAmount) ?? 0) - (double.tryParse(student.paidAmount) ?? 0)}',
              color: (double.tryParse(student.feeAmount) ?? 0) > (double.tryParse(student.paidAmount) ?? 0) ? Colors.red : Colors.green),
        ],
      ),
    );
  }

// ============ SSSMID CARD ============
  Widget _buildSSSMIDCard(StudentModel student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Additional Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.qr_code, 'SSSMID', student.sssmid.isNotEmpty ? student.sssmid : 'N/A'),
          const SizedBox(height: 8),
          _infoRow(Icons.access_time, 'Created At', student.createdAt),
        ],
      ),
    );
  }

// ============ STATUS CARD ============
  Widget _buildStatusCard(StudentModel student) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: student.checkBox ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: student.checkBox ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(student.checkBox ? Icons.check_circle : Icons.cancel, color: student.checkBox ? Colors.green : Colors.red, size: 20),
          const SizedBox(width: 8),
          Text('Status: ${student.checkBox ? 'Active' : 'Inactive'}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: student.checkBox ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}