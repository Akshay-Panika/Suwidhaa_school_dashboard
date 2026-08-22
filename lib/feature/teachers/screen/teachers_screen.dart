import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/widget/flutter_toast.dart';
import '../controller/teacher_controller.dart';
import '../model/teacher_model.dart';

// ============ ENUMS ============
enum TeacherFilter {
  all,
  active,
  inactive,
  onLeave,
}

enum SchoolFilter {
  all,
  schoolA,
  schoolB,
}

// ============ MAIN SCREEN ============
class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  // ============ CONTROLLER ============
  final TeacherController controller = Get.find<TeacherController>();

  // ============ STATE ============
  TeacherFilter _currentFilter = TeacherFilter.all;
  SchoolFilter _currentSchoolFilter = SchoolFilter.all;
  String _searchQuery = '';
  bool _showRightPanel = false;
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
  final _lastNameController = TextEditingController();
  final _teacherIdController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _joinDateController = TextEditingController();

  // ============ FORM STATE ============
  String _selectedGender = 'Male';
  String _selectedStatus = 'Active';
  String _selectedSchoolForm = 'School A';
  List<String> _selectedSubjects = [];
  File? _imageFile;
  Uint8List? _imageBytes;
  int? _editingTeacherId;

  // For showing existing image preview
  String? _existingImageUrl;

  // ============ CONSTANTS ============
  final List<String> _allSubjects = [
    'Mathematics', 'Science', 'English', 'History',
    'Computer Science', 'Biology', 'Physics', 'Chemistry', 'Art', 'Music',
    'Hindi', 'Social Science', 'Geography'
  ];
  final List<String> _genderList = ['Male', 'Female', 'Other'];
  final List<String> _statusList = ['Active', 'Inactive', 'On Leave'];
  final List<String> _schoolList = ['School A', 'School B'];

  bool get _isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();
    _generateSampleAttendance();
    controller.getTeachers();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _teacherIdController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _joinDateController.dispose();
    super.dispose();
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
    var filtered = controller.teachers.toList();

    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      filtered = filtered.where((teacher) => teacher.school == 'School A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      filtered = filtered.where((teacher) => teacher.school == 'School B').toList();
    }

    if (_currentFilter != TeacherFilter.all) {
      filtered = filtered.where((teacher) {
        if (_currentFilter == TeacherFilter.active) {
          return teacher.status == 'Active';
        } else if (_currentFilter == TeacherFilter.inactive) {
          return teacher.status == 'Inactive';
        } else {
          return teacher.status == 'On Leave';
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((teacher) =>
      teacher.fullName.toLowerCase().contains(query) ||
          teacher.idString.toLowerCase().contains(query) ||
          (teacher.subjects?.any((s) => s.toLowerCase().contains(query)) ?? false) ||
          teacher.email?.toLowerCase().contains(query) == true ||
          teacher.school.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }

  int get _totalTeachers => controller.totalTeachers;
  int get _activeTeachers => controller.activeTeachers;
  int get _inactiveTeachers => controller.inactiveTeachers;
  int get _onLeaveTeachers => controller.onLeaveTeachers;

  Map<String, int> get _schoolWiseStats => controller.schoolWiseStats;

  // ============ FORM METHODS ============
  void _resetForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _teacherIdController.clear();
    _dobController.clear();
    _emailController.clear();
    _phoneController.clear();
    _altPhoneController.clear();
    _addressController.clear();
    _qualificationController.clear();
    _experienceController.clear();
    _joinDateController.clear();
    _selectedSubjects = [];
    _selectedGender = 'Male';
    _selectedStatus = 'Active';
    _selectedSchoolForm = 'School A';
    _imageFile = null;
    _imageBytes = null;
    _editingTeacherId = null;
    _existingImageUrl = null;
    _formKey.currentState?.reset();
  }

  // Load teacher data into form without trying to convert URL to File
  void _loadTeacherToForm(TeacherModel teacher) {
    _firstNameController.text = teacher.firstName;
    _lastNameController.text = teacher.lastName;
    _teacherIdController.text = teacher.teacherId ?? '';
    _dobController.text = teacher.dob ?? '';
    _emailController.text = teacher.email ?? '';
    _phoneController.text = teacher.phone ?? '';
    _altPhoneController.text = teacher.altPhone ?? '';
    _addressController.text = teacher.address ?? '';
    _qualificationController.text = teacher.qualification ?? '';
    _experienceController.text = teacher.experience?.toString() ?? '';
    _joinDateController.text = teacher.joinDate ?? '';
    _selectedSubjects = List.from(teacher.subjects ?? []);
    _selectedGender = teacher.gender ?? 'Male';
    _selectedStatus = teacher.status;
    _selectedSchoolForm = teacher.school;
    _editingTeacherId = teacher.id;

    _existingImageUrl = teacher.teacherProfile;
    _imageFile = null;
    _imageBytes = null;
  }

  // ============ IMAGE PICKER ============
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 5 * 1024 * 1024) {
          FlutterToast.warning('Image size too large. Please select an image under 5MB.');
          return;
        }

        final extension = file.extension?.toLowerCase();
        if (extension != null && !['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
          FlutterToast.warning('Please select a valid image file (jpg, png, gif, etc.)');
          return;
        }

        if (_isWeb) {
          if (file.bytes != null) {
            setState(() {
              _imageBytes = file.bytes;
              _existingImageUrl = null;
            });
            FlutterToast.success('Image uploaded successfully!');
          } else {
            FlutterToast.error('Failed to load image bytes');
          }
        } else {
          String? filePath = file.path;
          if (filePath != null) {
            setState(() {
              _imageFile = File(filePath);
              _existingImageUrl = null;
            });
            FlutterToast.success('Image uploaded successfully!');
          } else {
            FlutterToast.error('Failed to get image file path');
          }
        }
      }
    } catch (e) {
      FlutterToast.error('Error picking image: ${e.toString()}');
    }
  }

  // ============ CRUD OPERATIONS ============
  Future<void> _addTeacher() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjects.isEmpty) {
      FlutterToast.warning('Please select at least one subject');
      return;
    }

    controller.isLoading.value = true;

    try {
      final success = await controller.createTeacher(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        teacherId: _teacherIdController.text.trim().isNotEmpty ? _teacherIdController.text.trim() : null,
        teacherProfile: _imageFile,
        gender: _selectedGender,
        dob: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        altPhone: _altPhoneController.text.trim().isNotEmpty ? _altPhoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        qualification: _qualificationController.text.trim().isNotEmpty ? _qualificationController.text.trim() : null,
        experience: _experienceController.text.trim().isNotEmpty ? int.tryParse(_experienceController.text.trim()) : null,
        salary: 0,
        joinDate: _joinDateController.text.trim().isNotEmpty ? _joinDateController.text.trim() : null,
        checkBox: _selectedStatus == 'Active',
        subjects: _selectedSubjects.isNotEmpty ? _selectedSubjects : null,
        schoolType: _selectedSchoolForm,
      );

      if (success) {
        setState(() {
          _showRightPanel = false;
          _isAddingNew = false;
          _resetForm();
        });
        FlutterToast.success('Teacher added successfully!');
      } else {
        FlutterToast.error(controller.errorMessage.value);
      }
    } catch (e) {
      FlutterToast.error('Failed to create teacher: $e');
    } finally {
      controller.isLoading.value = false;
    }
  }

  Future<void> _updateTeacher() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjects.isEmpty) {
      FlutterToast.warning('Please select at least one subject');
      return;
    }

    controller.isLoading.value = true;

    try {
      final success = await controller.updateTeacher(
        id: _editingTeacherId!,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        teacherId: _teacherIdController.text.trim().isNotEmpty ? _teacherIdController.text.trim() : null,
        teacherProfile: _imageFile,
        gender: _selectedGender,
        dob: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        altPhone: _altPhoneController.text.trim().isNotEmpty ? _altPhoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        qualification: _qualificationController.text.trim().isNotEmpty ? _qualificationController.text.trim() : null,
        experience: _experienceController.text.trim().isNotEmpty ? int.tryParse(_experienceController.text.trim()) : null,
        salary: 0,
        joinDate: _joinDateController.text.trim().isNotEmpty ? _joinDateController.text.trim() : null,
        checkBox: _selectedStatus == 'Active',
        subjects: _selectedSubjects.isNotEmpty ? _selectedSubjects : null,
        schoolType: _selectedSchoolForm,
      );

      if (success) {
        setState(() {
          _isEditing = false;
          _resetForm();
        });
        FlutterToast.success('Teacher updated successfully!');
      } else {
        FlutterToast.error(controller.errorMessage.value);
      }
    } catch (e) {
      FlutterToast.error('Failed to update teacher: $e');
    } finally {
      controller.isLoading.value = false;
    }
  }

  void _deleteTeacher(TeacherModel teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.fullName}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              controller.isLoading.value = true;
              try {
                final success = await controller.deleteTeacher(teacher.id);
                if (success) {
                  setState(() {
                    _showRightPanel = false;
                    controller.selectedTeacher.value = null;
                  });
                  FlutterToast.success('Teacher deleted successfully!');
                } else {
                  FlutterToast.error(controller.errorMessage.value);
                }
              } catch (e) {
                FlutterToast.error('Failed to delete teacher: $e');
              } finally {
                controller.isLoading.value = false;
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ============ HELPERS ============
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.green;
      case 'Inactive': return Colors.red;
      case 'On Leave': return Colors.orange;
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // ============ SHIMMER LOADING WIDGETS ============
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

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.teachers.isEmpty) {
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
                  flex: 5,
                  child: Column(
                    children: [
                      _buildHeader('All Schools'),
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
              Expanded(
                flex: _showRightPanel ? 5 : 8,
                child: Column(
                  children: [
                    _buildHeader(schoolLabel),
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
    });
  }

  // ============ HEADER ============
  Widget _buildHeader(String schoolLabel) {
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
                        controller.selectedTeacher.value = null;
                        _showRightPanel = false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!_showRightPanel || !_isAddingNew)
                ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                    _resetForm();
                    setState(() {
                      _isAddingNew = true;
                      _isEditing = false;
                      _showAttendance = false;
                      controller.selectedTeacher.value = null;
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
                      controller.selectedTeacher.value = null;
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
              '👨‍🏫 ${_totalTeachers} Total Teachers',
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
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                _resetForm();
                setState(() {
                  _isAddingNew = true;
                  _isEditing = false;
                  _showAttendance = false;
                  controller.selectedTeacher.value = null;
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
            onPressed: controller.isLoading.value
                ? null
                : () {
              _resetForm();
              setState(() {
                _isAddingNew = true;
                _isEditing = false;
                _showAttendance = false;
                controller.selectedTeacher.value = null;
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

  // ============ TEACHER CARD ============
  Widget _buildTeacherCard(TeacherModel teacher) {
    final isSelected = controller.selectedTeacher.value?.id == teacher.id;
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getGenderColor(teacher.gender ?? 'Male').withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: teacher.teacherProfile != null && teacher.teacherProfile!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                teacher.teacherProfile!,
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsAvatar(40, teacher.fullName, teacher.gender ?? 'Male');
                },
              ),
            )
                : _buildInitialsAvatar(40, teacher.fullName, teacher.gender ?? 'Male'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                controller.selectTeacher(teacher);
                setState(() {
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
                          teacher.fullName,
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
                      if (teacher.subjects != null && teacher.subjects!.isNotEmpty)
                        _buildInfoText(Icons.book, teacher.subjects!.take(2).join(', ')),
                      if (teacher.email != null)
                        _buildInfoText(Icons.email, teacher.email!),
                      _buildInfoText(Icons.work, teacher.experienceStr),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                    controller.selectTeacher(teacher);
                    setState(() {
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
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                    _loadTeacherToForm(teacher);
                    controller.selectTeacher(teacher);
                    setState(() {
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
                  onPressed: controller.isLoading.value ? null : () => _deleteTeacher(teacher),
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

  Widget _buildInitialsAvatar(double size, String name, String gender) {
    final initials = _getInitials(name);
    final color = _getGenderColor(gender);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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

  // ============ VIEW PANEL ============
  Widget _buildViewPanel() {
    final teacher = controller.selectedTeacher.value;
    if (teacher == null) return const SizedBox();

    final schoolColor = _getSchoolColor(teacher.school);

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
                  color: _getGenderColor(teacher.gender ?? 'Male').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: teacher.teacherProfile != null && teacher.teacherProfile!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    teacher.teacherProfile!,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitialsAvatar(50, teacher.fullName, teacher.gender ?? 'Male');
                    },
                  ),
                )
                    : _buildInitialsAvatar(50, teacher.fullName, teacher.gender ?? 'Male'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.fullName,
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
                            teacher.idString,
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
          _buildDetailRow('🏫 School', teacher.school, color: schoolColor, isBold: true),
          _buildDetailRow('📛 Name', teacher.fullName),
          _buildDetailRow('🎂 DOB', teacher.dob ?? 'N/A'),
          _buildDetailRow('⚧ Gender', teacher.gender ?? 'N/A'),
          _buildDetailRow('📧 Email', teacher.email ?? 'N/A'),
          _buildDetailRow('📱 Phone', teacher.phone ?? 'N/A'),
          if (teacher.altPhone != null)
            _buildDetailRow('📱 Alt Phone', teacher.altPhone!),
          _buildDetailRow('📍 Address', teacher.address ?? 'N/A'),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildDetailRow('🎓 Qualification', teacher.qualification ?? 'N/A'),
          _buildDetailRow('📚 Subjects', teacher.subjects?.join(', ') ?? 'N/A'),
          _buildDetailRow('💼 Experience', teacher.experienceStr),
          _buildDetailRow('📅 Join Date', teacher.joinDate ?? 'N/A'),
          _buildDetailRow('📅 Created', _formatDate(teacher.createdAt)),
          _buildDetailRow('📅 Updated', _formatDate(teacher.updatedAt)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                    setState(() {
                      _showRightPanel = false;
                      controller.selectedTeacher.value = null;
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
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
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
                  onPressed: controller.isLoading.value ? null : () => _deleteTeacher(teacher),
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
    final teacher = controller.selectedTeacher.value;
    if (teacher == null) return const SizedBox();

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
                'Attendance - ${teacher.fullName}',
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

  // ============ ADD/EDIT PANELS ============
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
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
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
                  onPressed: controller.isLoading.value ? null : _addTeacher,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
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

  Widget _buildEditPanel() {
    final teacher = controller.selectedTeacher.value;
    if (teacher == null) return const SizedBox();

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
                onPressed: controller.isLoading.value
                    ? null
                    : () {
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
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
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
                  onPressed: controller.isLoading.value ? null : _updateTeacher,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
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
          Align(
            alignment: Alignment.center,
            child: _buildPhotoUpload(),
          ),
          const SizedBox(height: 16),
          _buildFormTextField(_teacherIdController, 'Teacher ID', Icons.badge,
              hint: 'Optional - Auto generated if empty'),
          const SizedBox(height: 8),
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
                    hint: 'YYYY-MM-DD'),
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
          _buildFormTextField(_emailController, 'Email', Icons.email),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFormTextField(_phoneController, 'Primary Phone', Icons.phone),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFormTextField(_altPhoneController, 'Alt Phone', Icons.phone_android),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFormTextField(_addressController, 'Address', Icons.location_on,
              maxLines: 2),
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
          _buildFormTextField(_qualificationController, 'Qualification', Icons.school),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFormTextField(_experienceController, 'Experience (Years)', Icons.work),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFormTextField(_joinDateController, 'Join Date', Icons.event,
                    hint: 'YYYY-MM-DD'),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                  onSelected: controller.isLoading.value
                      ? null
                      : (selected) {
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
          _buildDropdownField('Status', _statusList, _selectedStatus, (value) {
            setState(() => _selectedStatus = value!);
          }),
        ],
      ),
    );
  }

  // Photo upload widget with existing image preview
  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: controller.isLoading.value ? null : _pickImage,
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
        child: _imageBytes != null && _isWeb
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            _imageBytes!,
            fit: BoxFit.cover,
          ),
        )
            : _imageFile != null && !_isWeb
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _imageFile!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.broken_image,
                color: Colors.grey[400],
                size: 30,
              );
            },
          ),
        )
            : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            _existingImageUrl!,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.purple[700],
                    size: 24,
                  ),
                  Text(
                    'Existing',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
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
            Text(
              'JPG, PNG',
              style: TextStyle(
                fontSize: 7,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
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
    String selectedValue = value;
    if (!items.contains(selectedValue) && items.isNotEmpty) {
      selectedValue = items.first;
    }

    return DropdownButtonFormField<String>(
      value: selectedValue,
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
      onChanged: controller.isLoading.value ? null : onChanged,
    );
  }
}