// lib/feature/student/screen/student_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import '../../../core/widget/flutter_toast.dart';
import '../../main/widget/school_type_filter_widget.dart';
import '../../main/controller/school_type_controller.dart';
import '../../main/model/school_type_model.dart';
import '../controller/student_attendance_controller.dart';
import '../controller/student_controller.dart';
import '../model/student_attendance_model.dart';
import '../model/student_model.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final StudentController controller = Get.find<StudentController>();
  final StudentAttendanceController attController = Get.find<StudentAttendanceController>();
  final SchoolTypeController schoolController = Get.find<SchoolTypeController>();

  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedClassFilter = 'All';
  bool _showRightPanel = false;
  bool _isEditing = false;
  bool _isAddingNew = false;
  bool _showOnlyAttendance = false;

  DateTime? _selectedDate;
  StudentAttendanceModel? _selectedRecord;

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _alternativePhoneController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _studentIdCardController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _casteCategoryController = TextEditingController();
  final _adharNumberController = TextEditingController();
  final _sssmidController = TextEditingController();
  final _feeAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedClass = 'KG';
  String _selectedFeeStatus = 'Paid';
  bool _checkBox = true;

  SchoolTypeModel? _formSelectedSchool;

  File? _imageFile;
  Uint8List? _imageBytes;
  String? _existingImageUrl;

  final List<String> _classList = [
    'KG', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th', '5th',
    '6th', '7th', '8th', '9th', '10th', '11th', '12th'
  ];
  final List<String> _genderList = ['Male', 'Female', 'Other'];
  final List<String> _feeStatusList = ['Paid', 'Pending', 'Overdue'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _parentPhoneController.dispose();
    _alternativePhoneController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _studentIdCardController.dispose();
    _rollNumberController.dispose();
    _addressController.dispose();
    _casteCategoryController.dispose();
    _adharNumberController.dispose();
    _sssmidController.dispose();
    _feeAmountController.dispose();
    _paidAmountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _availableClasses {
    final set = <String>{};
    for (final s in controller.students) {
      final cls = s.studentClass.trim();
      if (cls.isNotEmpty) set.add(cls);
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  List<StudentModel> get _filteredStudents {
    List<StudentModel> filtered = List.from(controller.students);
    if (_selectedClassFilter != 'All') {
      filtered = filtered
          .where((s) => s.studentClass.trim() == _selectedClassFilter)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((student) =>
      '${student.firstName} ${student.middleName} ${student.lastName}'.toLowerCase().contains(query) ||
          student.id?.toString().contains(query) == true ||
          student.rollNumber.toLowerCase().contains(query) ||
          student.studentClass.toLowerCase().contains(query) ||
          student.studentIdCard?.toLowerCase().contains(query) == true ||
          student.schoolName?.toLowerCase().contains(query) == true
      ).toList();
    }
    return filtered;
  }

  void _resetForm() {
    _firstNameController.clear();
    _middleNameController.clear();
    _lastNameController.clear();
    _dobController.clear();
    _rollNumberController.clear();
    _addressController.clear();
    _fatherNameController.clear();
    _motherNameController.clear();
    _parentPhoneController.clear();
    _alternativePhoneController.clear();
    _casteCategoryController.clear();
    _adharNumberController.clear();
    _sssmidController.clear();
    _feeAmountController.clear();
    _paidAmountController.clear();
    _studentIdCardController.clear();
    _selectedGender = 'Male';
    _selectedClass = 'KG';
    _selectedFeeStatus = 'Paid';
    _checkBox = true;
    _imageFile = null;
    _imageBytes = null;
    _existingImageUrl = null;
    _formSelectedSchool = controller.selectedSchool.value;
    _formKey.currentState?.reset();
  }

  void _loadStudentToForm(StudentModel student) {
    _firstNameController.text = student.firstName;
    _middleNameController.text = student.middleName;
    _lastNameController.text = student.lastName;
    _dobController.text = student.dob;
    _rollNumberController.text = student.rollNumber;
    _addressController.text = student.address;
    _fatherNameController.text = student.fatherName;
    _motherNameController.text = student.motherName;
    _parentPhoneController.text = student.parentPhone;
    _alternativePhoneController.text = student.alternativePhone ?? '';
    _casteCategoryController.text = student.casteCategory;
    _adharNumberController.text = student.adharNumber;
    _sssmidController.text = student.sssmid;
    _feeAmountController.text = student.feeAmount;
    _paidAmountController.text = student.paidAmount;
    _studentIdCardController.text = student.studentIdCard ?? '';

    _selectedClass = _classList.contains(student.studentClass) ? student.studentClass : 'KG';
    _selectedGender = _genderList.contains(student.gender) ? student.gender : 'Male';
    _selectedFeeStatus = _feeStatusList.contains(student.feeStatus) ? student.feeStatus : 'Paid';
    _checkBox = student.checkBox;

    _formSelectedSchool = schoolController.schoolTypes.firstWhereOrNull(
          (s) => s.id == student.schoolId,
    );

    _imageFile = null;
    _imageBytes = null;
    _existingImageUrl = student.studentProfile;
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, allowMultiple: false, withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 5 * 1024 * 1024) {
          FlutterToast.warning('Image size too large. Under 5MB only.');
          return;
        }
        if (kIsWeb) {
          if (file.bytes != null) setState(() => _imageBytes = file.bytes);
        } else {
          if (file.path != null) setState(() => _imageFile = File(file.path!));
        }
      }
    } catch (e) {
      FlutterToast.error('Error picking image: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_formSelectedSchool == null) {
      FlutterToast.warning('Please select a school for this student.');
      return;
    }

    controller.selectedSchool.value = _formSelectedSchool;

    controller.firstNameController.text = _firstNameController.text.trim();
    controller.middleNameController.text = _middleNameController.text.trim();
    controller.lastNameController.text = _lastNameController.text.trim();
    controller.dobController.text = _dobController.text.trim();
    controller.genderController.text = _selectedGender;
    controller.fatherNameController.text = _fatherNameController.text.trim();
    controller.motherNameController.text = _motherNameController.text.trim();
    controller.parentPhoneController.text = _parentPhoneController.text.trim();
    controller.alternativePhoneController.text = _alternativePhoneController.text.trim();
    controller.adharNumberController.text = _adharNumberController.text.trim();
    controller.sssmidController.text = _sssmidController.text.trim();
    controller.studentClassController.text = _selectedClass;
    controller.rollNumberController.text = _rollNumberController.text.trim();
    controller.addressController.text = _addressController.text.trim();
    controller.casteCategoryController.text = _casteCategoryController.text.trim();
    controller.feeStatusController.text = _selectedFeeStatus;
    controller.feeAmountController.text = _feeAmountController.text.trim().isEmpty ? '0.00' : _feeAmountController.text.trim();
    controller.paidAmountController.text = _paidAmountController.text.trim().isEmpty ? '0.00' : _paidAmountController.text.trim();
    controller.studentIdCardController.text = _studentIdCardController.text.trim();

    controller.studentProfileFile = _imageFile;
    controller.studentProfileBytes = _imageBytes;

    if (_isEditing && controller.selectedStudent.value != null) {
      await controller.updateStudent(controller.selectedStudent.value!.id!);
    } else {
      await controller.createStudent();
    }

    if (!controller.isSubmitting.value) {
      setState(() {
        _showRightPanel = false;
        _isAddingNew = false;
        _isEditing = false;
        _showOnlyAttendance = false;
        _resetForm();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Expanded(
                flex: _showRightPanel ? 5 : 8,
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildFilterSearchBar(),
                    Expanded(
                      child: controller.isLoading.value
                          ? _buildShimmerList()
                          : _filteredStudents.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) => _buildStudentCard(_filteredStudents[index]),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 480,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                  border: Border(left: BorderSide(color: Colors.grey[200]!, width: 1)),
                ),
                child: _showRightPanel
                    ? (_isAddingNew
                    ? _buildFormPanel('Add New Student')
                    : _isEditing
                    ? _buildFormPanel('Edit Student')
                    : _showOnlyAttendance
                    ? _buildAttendanceOnlyPanel()
                    : _buildViewPanel())
                    : _buildEmptyRightPanel(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.people, color: Colors.blue[700], size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Students Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text('${_filteredStudents.length} students found', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          Row(
            children: [
              SchoolTypeFilterWidget(
                compact: true,
                value: controller.selectedSchool.value,
                onChanged: (school) {
                  controller.setSelectedSchool(school);
                  setState(() {
                    _showRightPanel = false;
                    _showOnlyAttendance = false;
                  });
                },
              ),
              const SizedBox(width: 8),
              if (!_showRightPanel || !_isAddingNew)
                ElevatedButton.icon(
                  onPressed: () {
                    if (controller.selectedSchool.value == null) {
                      FlutterToast.warning('Please select a specific school from the top dropdown first.');
                      return;
                    }
                    _resetForm();
                    setState(() {
                      _isAddingNew = true;
                      _isEditing = false;
                      _showOnlyAttendance = false;
                      controller.selectedStudent.value = null;
                      _showRightPanel = true;
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              if (_showRightPanel)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      controller.selectedStudent.value = null;
                      _isEditing = false;
                      _isAddingNew = false;
                      _showOnlyAttendance = false;
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

  Widget _buildFilterSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        spacing: 16,
        children: [
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedClassFilter,
                isDense: true,
                icon: Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[600]),
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                items: _availableClasses.map((c) {
                  return DropdownMenuItem<String>(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => _selectedClassFilter = val);
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, class...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    final isSelected = controller.selectedStudent.value?.id == student.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? Colors.blue[300]! : Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              image: student.studentProfile != null && student.studentProfile!.isNotEmpty
                  ? DecorationImage(image: NetworkImage(student.studentProfile!), fit: BoxFit.cover)
                  : null,
            ),
            child: student.studentProfile == null || student.studentProfile!.isEmpty
                ? Center(
              child: Text(
                '${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}'.toUpperCase(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[700]),
              ),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                controller.selectedStudent.value = student;
                setState(() {
                  _showRightPanel = true;
                  _isEditing = false;
                  _isAddingNew = false;
                  _showOnlyAttendance = false;
                });
                if (student.id != null) attController.loadHistory(student.id!);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student.firstName} ${student.middleName} ${student.lastName}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Text("ID: ${student.studentIdCard ?? 'No ID'}", style: TextStyle(fontSize: 12, color: Colors.red)),
                          Container(height: 12, width: 1, color: Colors.grey),
                          Text("Class: ${student.studentClass}", style: TextStyle(fontSize: 12, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildInfoText(Icons.school, student.schoolName ?? 'N/A', color: Colors.blue),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                child: TextButton.icon(
                  onPressed: () {
                    controller.selectedStudent.value = student;
                    setState(() {
                      _isEditing = false;
                      _isAddingNew = false;
                      _showRightPanel = true;
                      _showOnlyAttendance = true;
                    });
                    if (student.id != null) attController.loadHistory(student.id!);
                  },
                  icon: Icon(Icons.calendar_month, size: 18, color: Colors.blue[700]),

                  label: Text(
                    "",
                    style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () {
                    _loadStudentToForm(student);
                    controller.setStudentForEdit(student);
                    setState(() {
                      _isEditing = true;
                      _isAddingNew = false;
                      _showOnlyAttendance = false;
                      _showRightPanel = true;
                    });
                  },
                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue[700]),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () {
                    controller.deleteStudent(student.id!);
                  },
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
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
        Icon(icon, size: 12, color: color ?? Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: color ?? Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildFormPanel(String title) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_isEditing ? Icons.edit_outlined : Icons.person_add, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formSelectedSchool?.schoolName ?? 'No school selected',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                        image: _imageBytes != null && kIsWeb
                            ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                            : _imageFile != null && !kIsWeb
                            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                            : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                            ? DecorationImage(image: NetworkImage(_existingImageUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: (_imageBytes == null && _imageFile == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty))
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.blue[700], size: 24),
                          const SizedBox(height: 4),
                          Text('Upload', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                        ],
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Personal Information', Colors.blue),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildFormTextField(_firstNameController, 'First Name *', required: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_middleNameController, 'Middle Name')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildFormTextField(_lastNameController, 'Last Name *', required: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_dobController, 'DOB (YYYY-MM-DD) *', required: true)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDropdownField('Gender *', _genderList, _selectedGender, (val) => setState(() => _selectedGender = val!))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_studentIdCardController, 'Student ID Card *', required: true)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Parent Information', Colors.green),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildFormTextField(_fatherNameController, 'Father Name')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_motherNameController, 'Mother Name')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildFormTextField(_parentPhoneController, 'Parent Phone *', required: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_alternativePhoneController, 'Alt Phone')),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Academic Information', Colors.orange),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDropdownField('Class *', _classList, _selectedClass, (val) => setState(() => _selectedClass = val!))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_rollNumberController, 'Roll Number')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildFormTextField(_casteCategoryController, 'Caste Category')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_adharNumberController, 'Aadhar Number')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildFormTextField(_sssmidController, 'SSSMID')),
                    const SizedBox(width: 8),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: 8),
                _buildFormTextField(_addressController, 'Address', maxLines: 2),
                const SizedBox(height: 16),
                _buildSectionTitle('Fee & Status', Colors.red),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildFormTextField(_feeAmountController, 'Fee Amount')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_paidAmountController, 'Paid Amount')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDropdownField('Fee Status', _feeStatusList, _selectedFeeStatus, (val) => setState(() => _selectedFeeStatus = val!))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _checkBox,
                            onChanged: (val) => setState(() => _checkBox = val ?? false),
                            activeColor: Colors.blue[700],
                          ),
                          const Text('Active Status', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() { _showRightPanel = false; _isAddingNew = false; _isEditing = false; _showOnlyAttendance = false; }),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: controller.isSubmitting.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isEditing ? 'Update' : 'Save', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color[200]!),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color[700]),
      ),
    );
  }

  Widget _buildViewPanel() {
    final student = controller.selectedStudent.value;
    if (student == null) return const SizedBox();

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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  image: student.studentProfile != null && student.studentProfile!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(student.studentProfile!), fit: BoxFit.cover)
                      : null,
                ),
                child: student.studentProfile == null || student.studentProfile!.isEmpty
                    ? Center(
                  child: Text(
                    '${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}'.toUpperCase(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${student.firstName} ${student.middleName} ${student.lastName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(student.schoolName ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() { _showRightPanel = false; controller.selectedStudent.value = null; }),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(height: 32),

          _buildDetailRow('ID', student.id?.toString() ?? 'N/A'),
          _buildDetailRow('First Name', student.firstName),
          _buildDetailRow('Middle Name', student.middleName.isNotEmpty ? student.middleName : 'N/A'),
          _buildDetailRow('Last Name', student.lastName),
          _buildDetailRow('Date of Birth', student.dob.isNotEmpty ? student.dob : 'N/A'),
          _buildDetailRow('Gender', student.gender.isNotEmpty ? student.gender : 'N/A'),
          _buildDetailRow('Class', student.studentClass.isNotEmpty ? student.studentClass : 'N/A'),
          _buildDetailRow('Roll No', student.rollNumber.isNotEmpty ? student.rollNumber : 'N/A'),
          _buildDetailRow('Student ID Card', student.studentIdCard ?? 'N/A'),
          _buildDetailRow('Father Name', student.fatherName.isNotEmpty ? student.fatherName : 'N/A'),
          _buildDetailRow('Mother Name', student.motherName.isNotEmpty ? student.motherName : 'N/A'),
          _buildDetailRow('Parent Phone', student.parentPhone.isNotEmpty ? student.parentPhone : 'N/A'),
          _buildDetailRow('Alt Phone', student.alternativePhone ?? 'N/A'),
          _buildDetailRow('Aadhar Number', student.adharNumber.isNotEmpty ? student.adharNumber : 'N/A'),
          _buildDetailRow('SSSMID', student.sssmid.isNotEmpty ? student.sssmid : 'N/A'),
          _buildDetailRow('Caste Category', student.casteCategory.isNotEmpty ? student.casteCategory : 'N/A'),
          _buildDetailRow('Address', student.address.isNotEmpty ? student.address : 'N/A'),
          _buildDetailRow('Fee Amount', '₹${student.feeAmount}'),
          _buildDetailRow('Paid Amount', '₹${student.paidAmount}'),
          _buildDetailRow('Fee Status', student.feeStatus.isNotEmpty ? student.feeStatus : 'N/A'),
          _buildDetailRow('Active', student.checkBox ? 'Yes' : 'No'),
          _buildDetailRow('Created At', student.createdAt ?? 'N/A'),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _loadStudentToForm(student);
              controller.setStudentForEdit(student);
              setState(() { _isEditing = true; _isAddingNew = false; _showOnlyAttendance = false; });
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Student'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceOnlyPanel() {
    final student = controller.selectedStudent.value;
    if (student == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  image: student.studentProfile != null && student.studentProfile!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(student.studentProfile!), fit: BoxFit.cover)
                      : null,
                ),
                child: student.studentProfile == null || student.studentProfile!.isEmpty
                    ? Center(
                  child: Text(
                    '${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}'.toUpperCase(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${student.firstName} ${student.middleName} ${student.lastName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(student.schoolName ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() { _showRightPanel = false; controller.selectedStudent.value = null; }),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildAttendanceSection(student.id!),
                if (_selectedDate != null) ...[
                  const SizedBox(height: 16),
                  _buildStatusCard(studentId: student.id!, date: _selectedDate!, existing: _selectedRecord),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(int studentId) {
    return Obx(() {
      final month = attController.currentMonth.value;
      final monthName = attController.currentMonthName;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 6),
                Text(
                  'Attendance History',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue[700]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: attController.goToPreviousMonth,
                  icon: const Icon(Icons.chevron_left, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$monthName ${month.year}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: attController.canGoNext ? attController.goToNextMonth : null,
                  icon: const Icon(Icons.chevron_right, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            attController.isLoading.value
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
                : Column(
              children: [
                _buildCalendarWeekHeader(),
                const SizedBox(height: 4),
                _buildCalendarGrid(studentId),
                const SizedBox(height: 10),
                _buildAttendanceLegend(),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCalendarWeekHeader() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: days.map((d) {
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(int studentId) {
    final month = attController.currentMonth.value;
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startOffset = (firstDay.weekday - 1) % 7;

    final cells = <Widget>[];
    for (var i = 0; i < startOffset; i++) {
      cells.add(const SizedBox());
    }

    final today = DateTime.now();

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final record = attController.getRecordForDate(date);
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

      cells.add(_buildDayCell(studentId, date, record, isToday));
    }

    while (cells.length % 7 != 0) {
      cells.add(const SizedBox());
    }

    return Column(
      children: List.generate(cells.length ~/ 7, (row) {
        return Row(
          children: List.generate(7, (col) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: cells[row * 7 + col],
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildDayCell(
      int studentId,
      DateTime date,
      StudentAttendanceModel? record,
      bool isToday,
      ) {
    Color bgColor;
    Color textColor;
    Border? border;
    bool isSelected = _selectedDate == date;

    if (record == null) {
      bgColor = Colors.grey[100]!;
      textColor = Colors.grey[700]!;
    } else {
      final c = _colorForStatus(record.attendanceStatus);
      bgColor = c.withOpacity(0.15);
      textColor = c;
    }

    if (isToday) {
      border = Border.all(color: Colors.blue, width: 2);
    } else if (isSelected) {
      border = Border.all(color: Colors.orange, width: 2);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          _selectedRecord = record;
        });
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: border,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceLegend() {
    if (attController.availableStatuses.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: attController.availableStatuses.map((s) {
        return _legendDot(_colorForStatus(s).withOpacity(0.2), _prettyStatus(s));
      }).toList(),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStatusCard({
    required int studentId,
    required DateTime date,
    StudentAttendanceModel? existing,
  }) {
    final statuses = ['present', 'absent', 'leave'];
    final initialStatus = existing?.attendanceStatus ?? 'present';
    final status = initialStatus.obs;
    final remarksCtrl = TextEditingController(text: existing?.remarks ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${date.day} ${_monthNameFromNum(date.month)} ${date.year}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _selectedDate = null;
                  _selectedRecord = null;
                }),
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Divider(),
          const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(() => Row(
            children: statuses.map((s) {
              final selected = status.value == s;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => status.value = s,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? _colorForStatus(s) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _prettyStatus(s),
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
          const SizedBox(height: 12),
          TextField(
            controller: remarksCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Remarks (optional)',
              labelStyle: const TextStyle(fontSize: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (existing != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await attController.deleteForDate(attController.formatDate(date));
                      setState(() {
                        _selectedDate = null;
                        _selectedRecord = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              if (existing != null) const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await attController.saveOrUpdateForDate(
                      date: attController.formatDate(date),
                      status: status.value,
                      remarks: remarksCtrl.text.trim(),
                    );
                    setState(() {
                      _selectedDate = null;
                      _selectedRecord = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorForStatus(String s) {
    final key = s.toLowerCase();
    if (key == 'present') return Colors.green;
    if (key == 'absent') return Colors.red;
    if (key == 'leave') return Colors.blue;
    if (key == 'holiday') return Colors.purple;
    if (key == 'late') return Colors.orange;

    final palette = [Colors.teal, Colors.indigo, Colors.cyan, Colors.brown, Colors.pink];
    return palette[key.hashCode.abs() % palette.length];
  }

  String _prettyStatus(String s) {
    if (s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }

  String _monthNameFromNum(int m) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return months[m - 1];
  }

  Widget _buildFormTextField(TextEditingController controller, String label, {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      validator: required ? (v) => v?.trim().isEmpty ?? true ? '$label is required' : null : null,
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No Students Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildEmptyRightPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Select a student to view details', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 60, margin: const EdgeInsets.only(bottom: 8), color: Colors.white),
      ),
    );
  }
}