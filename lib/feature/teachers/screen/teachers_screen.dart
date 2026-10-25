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
import '../../subjects/controller/subject_controller.dart';
import '../controller/teacher_controller.dart';
import '../controller/teacher_attendance_controller.dart';
import '../model/teacher_attendance_model.dart';
import '../model/teacher_model.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TeacherController controller = Get.find<TeacherController>();
  final TeacherAttendanceController attController = Get.find<TeacherAttendanceController>();
  final SchoolTypeController schoolController = Get.find<SchoolTypeController>();
  final SubjectController subjectController = Get.find<SubjectController>();

  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  bool _showRightPanel = false;
  bool _isEditing = false;
  bool _isAddingNew = false;
  bool _showOnlyAttendance = false;

  DateTime? _selectedDate;
  TeacherAttendanceModel? _selectedRecord;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _teacherIdCardController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _joinDateController = TextEditingController();
  final _salaryController = TextEditingController();

  String _selectedGender = 'Male';
  bool _checkBox = true;
  List<String> _selectedSubjects = [];
  int? _editingTeacherId;

  SchoolTypeModel? _formSelectedSchool;

  File? _imageFile;
  Uint8List? _imageBytes;
  String? _existingImageUrl;

  final List<String> _genderList = ['Male', 'Female', 'Other'];
  @override
  void initState() {
    super.initState();
    final schoolId = schoolController.selectedSchoolType.value?.id;
    if (schoolId != null) {
      subjectController.loadSubjects(schoolId);
    }
  }
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _teacherIdCardController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _joinDateController.dispose();
    _salaryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<TeacherModel> get _filteredTeachers {
    List<TeacherModel> filtered = List.from(controller.teachers);
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((teacher) =>
      teacher.fullName.toLowerCase().contains(query) ||
          teacher.idString.toLowerCase().contains(query) ||
          (teacher.subjects?.any((s) => s.toLowerCase().contains(query)) ?? false) ||
          teacher.email?.toLowerCase().contains(query) == true ||
          teacher.schoolName?.toLowerCase().contains(query) == true
      ).toList();
    }
    return filtered;
  }

  void _resetForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _teacherIdCardController.clear();
    _dobController.clear();
    _emailController.clear();
    _phoneController.clear();
    _altPhoneController.clear();
    _addressController.clear();
    _qualificationController.clear();
    _experienceController.clear();
    _joinDateController.clear();
    _salaryController.clear();
    _selectedSubjects = [];
    _selectedGender = 'Male';
    _checkBox = true;
    _imageFile = null;
    _imageBytes = null;
    _existingImageUrl = null;
    _editingTeacherId = null;
    _formSelectedSchool = controller.selectedSchool.value;
    _formKey.currentState?.reset();
  }

  void _loadTeacherToForm(TeacherModel teacher) {
    _firstNameController.text = teacher.firstName;
    _lastNameController.text = teacher.lastName;
    _teacherIdCardController.text = teacher.teacherIdCard ?? '';
    _dobController.text = teacher.dob ?? '';
    _emailController.text = teacher.email ?? '';
    _phoneController.text = teacher.phone ?? '';
    _altPhoneController.text = teacher.altPhone ?? '';
    _addressController.text = teacher.address ?? '';
    _qualificationController.text = teacher.qualification ?? '';
    _experienceController.text = teacher.experience?.toString() ?? '';
    _joinDateController.text = teacher.joinDate ?? '';
    _salaryController.text = teacher.salary ?? '';
    _selectedSubjects = List.from(teacher.subjects ?? []);
    _selectedGender = _genderList.contains(teacher.gender) ? teacher.gender! : 'Male';
    _checkBox = teacher.checkBox;
    _editingTeacherId = teacher.id;

    _formSelectedSchool = schoolController.schoolTypes.firstWhereOrNull(
          (s) => s.id == teacher.schoolId,
    );

    _existingImageUrl = teacher.teacherProfile;
    _imageFile = null;
    _imageBytes = null;
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
    if (_selectedSubjects.isEmpty) {
      FlutterToast.warning('Please select at least one subject');
      return;
    }
    if (_formSelectedSchool == null) {
      FlutterToast.warning('Please select a school for this teacher.');
      return;
    }

    controller.selectedSchool.value = _formSelectedSchool;

    bool success;
    if (_isEditing && _editingTeacherId != null) {
      success = await controller.updateTeacher(
        id: _editingTeacherId!,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        teacherIdCard: _teacherIdCardController.text.trim().isNotEmpty ? _teacherIdCardController.text.trim() : null,
        teacherProfile: _imageFile,
        teacherProfileBytes: _imageBytes,
        gender: _selectedGender,
        dob: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        altPhone: _altPhoneController.text.trim().isNotEmpty ? _altPhoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        qualification: _qualificationController.text.trim().isNotEmpty ? _qualificationController.text.trim() : null,
        experience: _experienceController.text.trim().isNotEmpty ? int.tryParse(_experienceController.text.trim()) : null,
        salary: _salaryController.text.trim().isNotEmpty ? double.tryParse(_salaryController.text.trim()) : null,
        joinDate: _joinDateController.text.trim().isNotEmpty ? _joinDateController.text.trim() : null,
        checkBox: _checkBox,
        subjects: _selectedSubjects,
      );
    } else {
      success = await controller.createTeacher(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        teacherIdCard: _teacherIdCardController.text.trim().isNotEmpty ? _teacherIdCardController.text.trim() : null,
        teacherProfile: _imageFile,
        teacherProfileBytes: _imageBytes,
        gender: _selectedGender,
        dob: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        altPhone: _altPhoneController.text.trim().isNotEmpty ? _altPhoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        qualification: _qualificationController.text.trim().isNotEmpty ? _qualificationController.text.trim() : null,
        experience: _experienceController.text.trim().isNotEmpty ? int.tryParse(_experienceController.text.trim()) : null,
        salary: _salaryController.text.trim().isNotEmpty ? double.tryParse(_salaryController.text.trim()) : null,
        joinDate: _joinDateController.text.trim().isNotEmpty ? _joinDateController.text.trim() : null,
        checkBox: _checkBox,
        subjects: _selectedSubjects,
      );
    }

    if (success) {
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
                          : _filteredTeachers.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredTeachers.length,
                        itemBuilder: (context, index) => _buildTeacherCard(_filteredTeachers[index]),
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
                    ? _buildFormPanel('Add New Teacher')
                    : _isEditing
                    ? _buildFormPanel('Edit Teacher')
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
                  const Text('Teachers Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text('${_filteredTeachers.length} teachers found', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                      controller.selectedTeacher.value = null;
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
                      controller.selectedTeacher.value = null;
                      _isEditing = false;
                      _isAddingNew = false;
                      _showOnlyAttendance = false;
                      _selectedDate = null;
                      _selectedRecord = null;
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
        children: [
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, subject...',
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

  Widget _buildTeacherCard(TeacherModel teacher) {
    final isSelected = controller.selectedTeacher.value?.id == teacher.id;
    if (teacher.id != null && !attController.teacherStatusMap.containsKey(teacher.id)) {
      attController.fetchSingleTeacherStatus(teacher.id!);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? Colors.blue[300]! : Colors.grey[200]!, width: isSelected ? 1 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              image: teacher.teacherProfile != null && teacher.teacherProfile!.isNotEmpty
                  ? DecorationImage(image: NetworkImage(teacher.teacherProfile!), fit: BoxFit.cover)
                  : null,
            ),
            child: teacher.teacherProfile == null || teacher.teacherProfile!.isEmpty
                ? Center(
              child: Text(
                '${teacher.firstName.isNotEmpty ? teacher.firstName[0] : ''}${teacher.lastName.isNotEmpty ? teacher.lastName[0] : ''}'.toUpperCase(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[700]),
              ),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                controller.selectedTeacher.value = teacher;
                setState(() {
                  _showRightPanel = true;
                  _isEditing = false;
                  _isAddingNew = false;
                  _showOnlyAttendance = false;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.fullName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Text("ID: ${teacher.teacherIdCard ?? 'No ID'}", style: const TextStyle(fontSize: 12, color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      _buildInfoText(Icons.school, teacher.schoolName ?? 'N/A', color: Colors.blue),
                      if (teacher.subjects != null && teacher.subjects!.isNotEmpty)
                        _buildInfoText(Icons.book, teacher.subjects!.take(2).join(', ')),
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
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                child: TextButton.icon(
                  onPressed: () {
                    controller.selectedTeacher.value = teacher;
                    setState(() {
                      _isEditing = false;
                      _isAddingNew = false;
                      _showRightPanel = true;
                      _showOnlyAttendance = true;
                      _selectedDate = null;
                      _selectedRecord = null;
                    });
                    if (teacher.id != null) {
                      attController.currentMonth.value = DateTime.now();
                      attController.loadHistory(teacher.id!);
                    }
                  },
                  icon: Icon(Icons.calendar_month, size: 16, color: Colors.blue[700]),
                  label: Obx(() {
                    final liveStatus = attController.teacherStatusMap[teacher.id] ?? 'Loading...';
                    return Text(
                      _prettyStatus(liveStatus),
                      style: TextStyle(fontSize: 12, color: _colorForStatus(liveStatus), fontWeight: FontWeight.w600),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () {
                    _loadTeacherToForm(teacher);
                    controller.selectTeacher(teacher);
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
                    Get.defaultDialog(
                      title: 'Delete Teacher',
                      middleText: 'Are you sure you want to delete ${teacher.fullName}?',
                      textConfirm: 'Delete',
                      textCancel: 'Cancel',
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red,
                      onConfirm: () async {
                        Get.back();
                        bool success = await controller.deleteTeacher(teacher.id!);
                        if (success) {
                          FlutterToast.success('Teacher deleted successfully');
                          setState(() => _showRightPanel = false);
                        } else {
                          FlutterToast.error(controller.errorMessage.value);
                        }
                      },
                    );
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
                    Expanded(child: _buildFormTextField(_lastNameController, 'Last Name *', required: true)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDropdownField('Gender *', _genderList, _selectedGender, (val) => setState(() => _selectedGender = val!))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_dobController, 'DOB (YYYY-MM-DD)', required: false)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildFormTextField(_teacherIdCardController, 'Teacher ID Card')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_joinDateController, 'Join Date (YYYY-MM-DD)')),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('Contact Information', Colors.green),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildFormTextField(_phoneController, 'Phone *', required: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_altPhoneController, 'Alt Phone')),
                  ],
                ),
                const SizedBox(height: 8),
                _buildFormTextField(_emailController, 'Email Address'),
                const SizedBox(height: 8),
                _buildFormTextField(_addressController, 'Address', maxLines: 2),
                const SizedBox(height: 16),

                _buildSectionTitle('Professional Information', Colors.orange),
                const SizedBox(height: 8),
                _buildFormTextField(_qualificationController, 'Qualification (e.g. M.Sc, B.Ed)'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildFormTextField(_experienceController, 'Experience (Years)')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormTextField(_salaryController, 'Salary')),
                  ],
                ),
                const SizedBox(height: 16),

                // ============ SUBJECTS SECTION ============
                _buildSectionTitle('Subjects', Colors.blue),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  // ✅ Yahan Fix hai: Obx ke andar check karo ki school id match hai ya nahi
                  child: Obx(() {
                    final currentSchoolId = _formSelectedSchool?.id;

                    if (currentSchoolId == null) {
                      return const Text('Please select a school', style: TextStyle(fontSize: 12, color: Colors.grey));
                    }

                    // Agar subject controller load ho raha hai toh loading dikhao
                    if (subjectController.isLoading.value) {
                      return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                    }

                    // Agar subjects load nahi hue hain, toh yahin se load karo
                    final currentSubjects = subjectController.subjects;
                    if (currentSubjects.isEmpty || currentSubjects.first.schoolId != currentSchoolId) {
                      // Dhyan rakhein: Subject load karna async hai, isliye future microtask me dalna safe hai
                      Future.microtask(() => subjectController.loadSubjects(currentSchoolId));
                      return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                    }

                    if (currentSubjects.isEmpty) {
                      return const Text('No subjects found for this school', style: TextStyle(fontSize: 12, color: Colors.grey));
                    }

                    return Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: currentSubjects.map((subjectModel) {
                        final subjectName = subjectModel.subjectName;
                        final isSelected = _selectedSubjects.contains(subjectName);
                        return FilterChip(
                          label: Text(subjectName, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSubjects.add(subjectName);
                              } else {
                                _selectedSubjects.remove(subjectName);
                              }
                            });
                          },
                          selectedColor: Colors.blue[100],
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(color: isSelected ? Colors.blue[700] : Colors.grey[700]),
                          side: BorderSide(color: isSelected ? Colors.blue[400]! : Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        );
                      }).toList(),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('Status', Colors.red),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _checkBox,
                      onChanged: (val) => setState(() => _checkBox = val ?? false),
                      activeColor: Colors.blue[700],
                    ),
                    const Text('Active Status', style: TextStyle(fontSize: 12)),
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
      child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color[700])),
    );
  }

  Widget _buildViewPanel() {
    final teacher = controller.selectedTeacher.value;
    if (teacher == null) return const SizedBox();

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
                  image: teacher.teacherProfile != null && teacher.teacherProfile!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(teacher.teacherProfile!), fit: BoxFit.cover)
                      : null,
                ),
                child: teacher.teacherProfile == null || teacher.teacherProfile!.isEmpty
                    ? Center(
                  child: Text(
                    '${teacher.firstName.isNotEmpty ? teacher.firstName[0] : ''}${teacher.lastName.isNotEmpty ? teacher.lastName[0] : ''}'.toUpperCase(),
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
                    Text(teacher.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(teacher.schoolName ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() { _showRightPanel = false; controller.selectedTeacher.value = null; }),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(height: 32),

          _buildDetailRow('ID', teacher.id?.toString() ?? 'N/A'),
          _buildDetailRow('First Name', teacher.firstName),
          _buildDetailRow('Last Name', teacher.lastName),
          _buildDetailRow('Teacher ID Card', teacher.teacherIdCard ?? 'N/A'),
          _buildDetailRow('Date of Birth', teacher.dob ?? 'N/A'),
          _buildDetailRow('Gender', teacher.gender ?? 'N/A'),
          _buildDetailRow('Phone', teacher.phone ?? 'N/A'),
          _buildDetailRow('Alt Phone', teacher.altPhone ?? 'N/A'),
          _buildDetailRow('Email', teacher.email ?? 'N/A'),
          _buildDetailRow('Address', teacher.address ?? 'N/A'),
          _buildDetailRow('Qualification', teacher.qualification ?? 'N/A'),
          _buildDetailRow('Experience', teacher.experienceStr),
          _buildDetailRow('Salary', '₹${teacher.salary}'),
          _buildDetailRow('Join Date', teacher.joinDate ?? 'N/A'),
          _buildDetailRow('Subjects', teacher.subjects?.join(', ') ?? 'N/A'),
          _buildDetailRow('Status', teacher.checkBox ? 'Active' : 'Inactive'),
          _buildDetailRow('Created At', teacher.createdAt ?? 'N/A'),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _loadTeacherToForm(teacher);
              controller.selectedTeacher.value = teacher;
              setState(() { _isEditing = true; _isAddingNew = false; _showOnlyAttendance = false; });
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Teacher'),
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
    final teacher = controller.selectedTeacher.value;
    if (teacher == null) return const SizedBox();

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
                  image: teacher.teacherProfile != null && teacher.teacherProfile!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(teacher.teacherProfile!), fit: BoxFit.cover)
                      : null,
                ),
                child: teacher.teacherProfile == null || teacher.teacherProfile!.isEmpty
                    ? Center(
                  child: Text(
                    '${teacher.firstName.isNotEmpty ? teacher.firstName[0] : ''}${teacher.lastName.isNotEmpty ? teacher.lastName[0] : ''}'.toUpperCase(),
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
                    Text(teacher.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(teacher.schoolName ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() { _showRightPanel = false; controller.selectedTeacher.value = null; }),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildAttendanceSection(teacher.id!),
                if (_selectedDate != null) ...[
                  const SizedBox(height: 16),
                  _buildStatusCard(_selectedDate!, _selectedRecord),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(int teacherId) {
    return Obx(() {
      final month = attController.currentMonth.value;
      final monthName = _monthName(month.month);

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
                  onPressed: () => attController.currentMonth.value = DateTime(month.year, month.month - 1, 1),
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
                  onPressed: (month.year < DateTime.now().year || (month.year == DateTime.now().year && month.month < DateTime.now().month))
                      ? () => attController.currentMonth.value = DateTime(month.year, month.month + 1, 1)
                      : null,
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
                _buildCalendarGrid(month),
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

  Widget _buildCalendarGrid(DateTime month) {
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
      final record = _getRecordForDate(date);
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

      cells.add(_buildDayCell(date, record, isToday));
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

  Widget _buildDayCell(DateTime date, TeacherAttendanceModel? record, bool isToday) {
    Color bgColor;
    Color textColor;
    Border? border;
    bool isSelected = _selectedDate == date;

    if (record == null) {
      bgColor = Colors.grey[100]!;
      textColor = Colors.grey[700]!;
    } else {
      final c = _colorForStatus(record.status);
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
        // ✅ Bina condition ke tap allow karo
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

  Widget _buildStatusCard(DateTime date, TeacherAttendanceModel? record) {
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
                '${date.day} ${_monthName(date.month)} ${date.year}',
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
          if (record != null) ...[
            _buildDetailRow('Status', record.status.toUpperCase()),
            _buildDetailRow('Check In', record.checkInTime ?? '--'),
            _buildDetailRow('Check Out', record.checkOutTime ?? '--'),
            _buildDetailRow('Hours', '${record.workingHours} hrs'),
            if (record.remarks.isNotEmpty) _buildDetailRow('Remarks', record.remarks),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("No record found for this date.", style: TextStyle(color: Colors.grey)),
            )
          ],

          // ✅ Update Card
          _buildAttCard(
            teacherId: controller.selectedTeacher.value!.id!,
            date: date,
            existing: record,
          ),
        ],
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
          Text('No Teachers Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
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
          Text('Select a teacher to view details', style: TextStyle(color: Colors.grey[500])),
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

  // ================= HELPERS =================
  TeacherAttendanceModel? _getRecordForDate(DateTime d) {
    if (attController.historyResponse.value == null) return null;
    final yearStr = d.year.toString();
    final monthStr = _monthName(d.month);

    final monthData = attController.historyResponse.value!.history[yearStr]?[monthStr];
    if (monthData == null) return null;

    final dateStr = _fmtDate(d);
    for (final r in monthData) {
      if (r.date == dateStr) return r;
    }
    return null;
  }

  Widget _buildAttCard({
    required int teacherId,
    required DateTime date,
    TeacherAttendanceModel? existing,
  }) {
    final statuses = ['present', 'absent', 'leave'];
    final initialStatus = existing?.status ?? 'present';
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
                      bool ok = await attController.deleteStatus(existing.id!);
                      if (ok) {
                        FlutterToast.success('Deleted successfully!');
                        await attController.loadHistory(teacherId);
                        setState(() {
                          _selectedDate = null;
                          _selectedRecord = null;
                        });
                      }
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
                    bool ok = await attController.updateStatus(
                      teacherId: teacherId,
                      date: _fmtDate(date),
                      status: status.value,
                      remarks: remarksCtrl.text.trim(),
                    );
                    if (ok) {
                      FlutterToast.success("Saved successfully!");
                      setState(() {
                        _selectedDate = null;
                        _selectedRecord = null;
                      });
                    } else {
                      FlutterToast.error("Save failed");
                    }
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

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _monthName(int m) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[m - 1];
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
}