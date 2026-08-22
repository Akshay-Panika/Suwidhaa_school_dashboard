import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widget/flutter_toast.dart';
import '../controller/schedule_controller.dart';
import '../model/schedule_model.dart';

// ============ ENUMS ============
enum ScheduleType {
  event,
  exam,
  other,
}

enum ScheduleFilter {
  all,
  event,
  exam,
  other,
}

enum SchoolFilter {
  all,
  schoolA,
  schoolB,
}

// ============ MAIN SCREEN ============
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleController controller = Get.find<ScheduleController>();

  // ============ STATE ============
  ScheduleFilter _currentFilter = ScheduleFilter.all;
  SchoolFilter _currentSchoolFilter = SchoolFilter.all;
  String _searchQuery = '';
  bool _showRightPanel = false;
  bool _isEditing = false;
  bool _isAddingNew = false;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _eventTypeController = TextEditingController();
  final _guestSpeakerController = TextEditingController();
  final _expectedAttendeesController = TextEditingController();
  final _eventDescriptionController = TextEditingController();

  // Form State
  String _selectedType = 'Event';
  String _selectedSchoolForm = 'A';
  String _selectedStatus = 'Upcoming';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  List<String> _selectedClasses = [];
  List<String> _selectedTeachers = [];
  File? _bannerImage;
  String? _bannerImagePath;
  File? _pdfFile;
  String? _pdfFilePath;
  bool _checkBox = true;

  // Web-specific state variables
  Uint8List? _bannerImageBytes;
  String? _bannerImageName;
  Uint8List? _pdfFileBytes;
  String? _pdfFileName;

  // Track if banner is from existing schedule
  bool _isExistingBanner = false;

  final List<String> _classList = ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'];
  final List<String> _teacherList = ['Mr. John', 'Ms. Sarah', 'Dr. Smith', 'Mrs. Brown'];
  final List<String> _schoolList = ['A', 'B'];
  final List<String> _typeList = ['Event', 'Exam', 'Other'];
  final List<String> _statusList = ['Upcoming', 'Ongoing', 'Completed'];

  @override
  void initState() {
    super.initState();
    controller.loadSchedules();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _eventTypeController.dispose();
    _guestSpeakerController.dispose();
    _expectedAttendeesController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  // ============ GETTERS ============
  List<ScheduleUIModel> get _filteredSchedules {
    var filtered = controller.schedules.map((s) => ScheduleUIModel.fromApi(s)).toList();

    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      filtered = filtered.where((s) => s.schoolType.toUpperCase() == 'A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      filtered = filtered.where((s) => s.schoolType.toUpperCase() == 'B').toList();
    }

    if (_currentFilter != ScheduleFilter.all) {
      filtered = filtered.where((s) {
        if (_currentFilter == ScheduleFilter.event) {
          return s.type.toLowerCase() == 'event';
        } else if (_currentFilter == ScheduleFilter.exam) {
          return s.type.toLowerCase() == 'exam';
        } else {
          return s.type.toLowerCase() == 'other';
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) =>
      s.title.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query) ||
          s.location.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }

  int get _totalEvents => controller.schedules.where((s) => s.type.toLowerCase() == 'event').length;
  int get _totalExams => controller.schedules.where((s) => s.type.toLowerCase() == 'exam').length;
  int get _totalOthers => controller.schedules.where((s) => s.type.toLowerCase() == 'other').length;

  Map<String, int> get _schoolWiseStats => controller.schoolWiseStats;

  // ============ PDF VIEWER ============
  Future<void> _openPDF(String pdfPath) async {
    try {
      Uri uri;
      if (pdfPath.startsWith('http://') || pdfPath.startsWith('https://')) {
        uri = Uri.parse(pdfPath);
      } else {
        if (kIsWeb) {
          FlutterToast.warning('Local PDF viewing is not supported on web');
          return;
        } else {
          final file = File(pdfPath);
          if (await file.exists()) {
            uri = Uri.file(pdfPath);
          } else {
            FlutterToast.error('PDF file not found');
            return;
          }
        }
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        FlutterToast.error('Could not open PDF');
      }
    } catch (e) {
      FlutterToast.error('Error opening PDF: ${e.toString()}');
    }
  }

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
              width: 60,
              height: 60,
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
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _timeController.clear();
    _eventTypeController.clear();
    _guestSpeakerController.clear();
    _expectedAttendeesController.clear();
    _eventDescriptionController.clear();
    _selectedType = 'Event';
    _selectedSchoolForm = 'A';
    _selectedStatus = 'Upcoming';
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));
    _selectedClasses = [];
    _selectedTeachers = [];
    _bannerImage = null;
    _bannerImagePath = null;
    _pdfFile = null;
    _pdfFilePath = null;
    _bannerImageBytes = null;
    _bannerImageName = null;
    _pdfFileBytes = null;
    _pdfFileName = null;
    _checkBox = true;
    _isExistingBanner = false;
  }

  void _loadScheduleToForm(ScheduleApiModel schedule) {
    _titleController.text = schedule.title;
    _descriptionController.text = schedule.description;
    _locationController.text = schedule.location;
    _timeController.text = schedule.time;
    _selectedType = schedule.type;
    _selectedSchoolForm = schedule.schoolType;
    _selectedStatus = schedule.status;
    _selectedClasses = List.from(schedule.assignedClasses);
    _selectedTeachers = List.from(schedule.assignedTeachers);
    _checkBox = schedule.checkBox;

    if (schedule.eventDetails != null) {
      _eventTypeController.text = schedule.eventDetails!.eventType ?? '';
      _guestSpeakerController.text = schedule.eventDetails!.guestSpeaker ?? '';
      _expectedAttendeesController.text = schedule.eventDetails!.expectedAttendees ?? '';
      _eventDescriptionController.text = schedule.eventDetails!.eventDescription ?? '';
    }

    // Load existing banner
    if (schedule.bannerImage != null && schedule.bannerImage!.isNotEmpty) {
      _bannerImagePath = schedule.bannerImage;
      _bannerImage = null;
      _bannerImageBytes = null;
      _bannerImageName = null;
      _isExistingBanner = true;
    } else {
      _bannerImagePath = null;
      _bannerImage = null;
      _bannerImageBytes = null;
      _bannerImageName = null;
      _isExistingBanner = false;
    }

    // Load existing PDF
    if (schedule.pdfFile != null && schedule.pdfFile!.isNotEmpty) {
      _pdfFilePath = schedule.pdfFile;
      _pdfFile = null;
      _pdfFileBytes = null;
      _pdfFileName = null;
    } else {
      _pdfFilePath = null;
      _pdfFile = null;
      _pdfFileBytes = null;
      _pdfFileName = null;
    }
  }

  // ============ IMAGE PICKERS ============
  Future<void> _pickBannerImage() async {
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

        if (kIsWeb) {
          if (file.bytes != null) {
            setState(() {
              _bannerImageBytes = file.bytes;
              _bannerImageName = file.name;
              _bannerImagePath = null;
              _bannerImage = null;
              _isExistingBanner = false;
            });
            FlutterToast.success('Banner image uploaded successfully!');
          } else {
            FlutterToast.error('Failed to load image bytes');
          }
        } else {
          String? filePath = file.path;
          if (filePath != null) {
            final fileObj = File(filePath);
            if (await fileObj.exists()) {
              setState(() {
                _bannerImage = fileObj;
                _bannerImagePath = filePath;
                _bannerImageBytes = null;
                _bannerImageName = null;
                _isExistingBanner = false;
              });
              FlutterToast.success('Banner image uploaded successfully!');
            } else {
              FlutterToast.error('File does not exist');
            }
          } else {
            FlutterToast.error('Failed to get image file path');
          }
        }
      }
    } catch (e) {
      FlutterToast.error('Error picking image: ${e.toString()}');
    }
  }

  void _removeBannerImage() {
    setState(() {
      _bannerImage = null;
      _bannerImagePath = null;
      _bannerImageBytes = null;
      _bannerImageName = null;
      _isExistingBanner = false;
    });
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 10 * 1024 * 1024) {
          FlutterToast.warning('PDF size too large. Please select a PDF under 10MB.');
          return;
        }

        if (kIsWeb) {
          if (file.bytes != null) {
            setState(() {
              _pdfFileBytes = file.bytes;
              _pdfFileName = file.name;
              _pdfFilePath = null;
              _pdfFile = null;
            });
            FlutterToast.success('PDF uploaded successfully!');
          } else {
            FlutterToast.error('Failed to load PDF bytes');
          }
        } else {
          String? filePath = file.path;
          if (filePath != null) {
            final fileObj = File(filePath);
            if (await fileObj.exists()) {
              setState(() {
                _pdfFile = fileObj;
                _pdfFilePath = filePath;
                _pdfFileBytes = null;
                _pdfFileName = null;
              });
              FlutterToast.success('PDF uploaded successfully!');
            } else {
              FlutterToast.error('File does not exist');
            }
          } else {
            FlutterToast.error('Failed to get PDF file path');
          }
        }
      }
    } catch (e) {
      FlutterToast.error('Error selecting PDF: ${e.toString()}');
    }
  }

  void _removePDF() {
    setState(() {
      _pdfFile = null;
      _pdfFilePath = null;
      _pdfFileBytes = null;
      _pdfFileName = null;
    });
  }

  // ============ CRUD OPERATIONS ============

  void _addSchedule() {
    if (!_formKey.currentState!.validate()) return;

    controller.titleController.text = _titleController.text;
    controller.descriptionController.text = _descriptionController.text;
    controller.locationController.text = _locationController.text;
    controller.timeController.text = _timeController.text;
    controller.selectedType.value = _selectedType;
    controller.selectedSchoolType.value = _selectedSchoolForm;
    controller.selectedStatus.value = _selectedStatus;
    controller.selectedStartDate.value = DateFormat('yyyy-MM-dd').format(_startDate);
    controller.selectedEndDate.value = DateFormat('yyyy-MM-dd').format(_endDate);
    controller.assignedClasses.value = _selectedClasses;
    controller.assignedTeachers.value = _selectedTeachers;
    controller.checkBox.value = _checkBox;

    controller.eventTypeController.text = _eventTypeController.text;
    controller.guestSpeakerController.text = _guestSpeakerController.text;
    controller.expectedAttendeesController.text = _expectedAttendeesController.text;
    controller.eventDescriptionController.text = _eventDescriptionController.text;

    if (kIsWeb) {
      controller.setBannerImageBytes(_bannerImageBytes);
      controller.setPdfFileBytes(_pdfFileBytes);
    } else {
      controller.setBannerImage(_bannerImage);
      controller.setPdfFile(_pdfFile);
    }

    controller.addSchedule();
  }

  void _updateSchedule() {
    if (!_formKey.currentState!.validate()) return;

    controller.titleController.text = _titleController.text;
    controller.descriptionController.text = _descriptionController.text;
    controller.locationController.text = _locationController.text;
    controller.timeController.text = _timeController.text;
    controller.selectedType.value = _selectedType;
    controller.selectedSchoolType.value = _selectedSchoolForm;
    controller.selectedStatus.value = _selectedStatus;
    controller.selectedStartDate.value = DateFormat('yyyy-MM-dd').format(_startDate);
    controller.selectedEndDate.value = DateFormat('yyyy-MM-dd').format(_endDate);
    controller.assignedClasses.value = _selectedClasses;
    controller.assignedTeachers.value = _selectedTeachers;
    controller.checkBox.value = _checkBox;

    controller.eventTypeController.text = _eventTypeController.text;
    controller.guestSpeakerController.text = _guestSpeakerController.text;
    controller.expectedAttendeesController.text = _expectedAttendeesController.text;
    controller.eventDescriptionController.text = _eventDescriptionController.text;

    if (kIsWeb) {
      controller.setBannerImageBytes(_bannerImageBytes);
      controller.setPdfFileBytes(_pdfFileBytes);
    } else {
      controller.setBannerImage(_bannerImage);
      controller.setPdfFile(_pdfFile);
    }

    controller.updateSchedule();
  }

  void _deleteSchedule(ScheduleUIModel schedule) {
    final apiSchedule = controller.schedules.firstWhere(
          (s) => s.id.toString() == schedule.id,
      orElse: () => controller.schedules.first,
    );
    controller.deleteSchedule(apiSchedule);
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
      if (controller.isLoading.value && controller.schedules.isEmpty) {
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
              Expanded(
                flex: _showRightPanel ? 5 : 8,
                child: Column(
                  children: [
                    _buildHeader(schoolLabel, schoolStats),
                    _buildFilterSearchBar(),
                    Expanded(
                      child: _filteredSchedules.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredSchedules.length,
                        itemBuilder: (context, index) {
                          return _buildScheduleCard(_filteredSchedules[index]);
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
                Icons.calendar_today,
                size: 60,
                color: Colors.blue[200],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Schedule Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a schedule from the list or create a new one',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '📊 ${controller.totalSchedules} Total Schedules',
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
                  icon: Icons.event,
                  label: 'Events',
                  count: _totalEvents,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildEmptyStatCard(
                  icon: Icons.school,
                  label: 'Exams',
                  count: _totalExams,
                  color: Colors.red,
                ),
                const SizedBox(width: 12),
                _buildEmptyStatCard(
                  icon: Icons.more_horiz,
                  label: 'Other',
                  count: _totalOthers,
                  color: Colors.green,
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
                  controller.selectedSchedule.value = null;
                  _showRightPanel = true;
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create New Schedule'),
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
                  Icons.calendar_today,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${_filteredSchedules.length} schedules found',
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
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 20),
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
                        controller.selectedSchedule.value = null;
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
                      controller.selectedSchedule.value = null;
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
                      controller.selectedSchedule.value = null;
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

  Color _getSchoolColor(String schoolType) {
    return schoolType.toUpperCase() == 'A' ? Colors.blue : Colors.green;
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
                  hintText: 'Search schedules...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildFilterChip('All', ScheduleFilter.all),
          const SizedBox(width: 4),
          _buildFilterChip('Events', ScheduleFilter.event),
          const SizedBox(width: 4),
          _buildFilterChip('Exams', ScheduleFilter.exam),
          const SizedBox(width: 4),
          _buildFilterChip('Other', ScheduleFilter.other),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ScheduleFilter filter) {
    final isSelected = _currentFilter == filter;
    Color color = Colors.blue;
    if (filter == ScheduleFilter.event) color = Colors.blue;
    if (filter == ScheduleFilter.exam) color = Colors.red;
    if (filter == ScheduleFilter.other) color = Colors.green;

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

  // ============ SCHEDULE CARD ============
  Widget _buildScheduleCard(ScheduleUIModel schedule) {
    final isSelected = controller.selectedSchedule.value?.id.toString() == schedule.id;
    final schoolColor = _getSchoolColor(schedule.schoolType);
    final hasBanner = schedule.bannerImage != null && schedule.bannerImage!.isNotEmpty;

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
          // Banner Thumbnail - Larger size (60x60)
          Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: hasBanner ? Colors.grey[200] : Colors.grey[100],
              image: hasBanner
                  ? DecorationImage(
                image: NetworkImage(schedule.bannerImage!),
                fit: BoxFit.cover,
                onError: (_, __) {
                  // Fallback to icon if image fails to load
                },
              )
                  : null,
            ),
            child: !hasBanner
                ? Icon(
              _getTypeIcon(schedule.type),
              color: schedule.statusColor,
              size: 28,
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                final apiSchedule = controller.schedules.firstWhere(
                      (s) => s.id.toString() == schedule.id,
                  orElse: () => controller.schedules.first,
                );
                setState(() {
                  controller.selectedSchedule.value = apiSchedule;
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
                          schedule.title,
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
                          color: schedule.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          schedule.type,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: schedule.statusColor,
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
                      _buildInfoText(Icons.school, schedule.schoolDisplay, color: schoolColor),
                      _buildInfoText(Icons.calendar_today, schedule.startDate),
                      _buildInfoText(Icons.access_time, schedule.time),
                      _buildInfoText(Icons.location_on, schedule.location),
                    ],
                  ),
                  // Banner indicator with preview
                  if (hasBanner)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.image,
                            size: 12,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Banner attached',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (schedule.pdfFile != null && schedule.pdfFile!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 12,
                            color: Colors.red[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PDF attached',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[400],
                            ),
                          ),
                        ],
                      ),
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {
                    final apiSchedule = controller.schedules.firstWhere(
                          (s) => s.id.toString() == schedule.id,
                      orElse: () => controller.schedules.first,
                    );
                    _loadScheduleToForm(apiSchedule);
                    setState(() {
                      controller.selectedSchedule.value = apiSchedule;
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
                  onPressed: () => _deleteSchedule(schedule),
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

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'event': return Icons.event;
      case 'exam': return Icons.school;
      default: return Icons.more_horiz;
    }
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
            Icons.event_busy,
            size: 50,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            'No Schedules Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Click "Add New" to create a schedule',
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
                controller.selectedSchedule.value = null;
                _showRightPanel = true;
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New Schedule'),
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
    final schedule = controller.selectedSchedule.value;
    if (schedule == null) return const SizedBox();

    final uiSchedule = ScheduleUIModel.fromApi(schedule);
    final schoolColor = _getSchoolColor(uiSchedule.schoolType);
    final hasBanner = uiSchedule.bannerImage != null && uiSchedule.bannerImage!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image with better error handling and loading
          if (hasBanner)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  uiSchedule.bannerImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Loading banner...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load banner',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          // Schedule header with icon
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: uiSchedule.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(uiSchedule.type),
                  color: uiSchedule.statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      uiSchedule.title,
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
                                uiSchedule.schoolDisplay,
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
                            color: uiSchedule.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            uiSchedule.type,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: uiSchedule.statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(uiSchedule),
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

          // Details
          _buildDetailRow('🏫 School', uiSchedule.schoolDisplay, color: schoolColor, isBold: true),
          _buildDetailRow('📅 Start Date', uiSchedule.startDate),
          _buildDetailRow('📅 End Date', uiSchedule.endDate),
          _buildDetailRow('⏰ Time', uiSchedule.time),
          _buildDetailRow('📍 Location', uiSchedule.location),
          _buildDetailRow('📝 Description', uiSchedule.description),
          _buildDetailRow('📊 Status', uiSchedule.statusDisplay, color: uiSchedule.statusColor),

          // PDF Attachment with Open functionality
          if (uiSchedule.pdfFile != null && uiSchedule.pdfFile!.isNotEmpty)
            _buildPDFAttachment(uiSchedule.pdfFile!),


          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Event Details
          if (uiSchedule.type.toLowerCase() == 'event' && uiSchedule.eventDetails != null)
            _buildEventViewDetails(uiSchedule),

          // Assigned Classes
          if (uiSchedule.assignedClasses.isNotEmpty)
            _buildAssignedList('📚 Assigned Classes', uiSchedule.assignedClasses),

          // Assigned Teachers
          if (uiSchedule.assignedTeachers.isNotEmpty)
            _buildAssignedList('👨‍🏫 Assigned Teachers', uiSchedule.assignedTeachers),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      controller.selectedSchedule.value = null;
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
                    _loadScheduleToForm(schedule);
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
                  onPressed: () => _deleteSchedule(uiSchedule),
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

  Widget _buildPDFAttachment(String pdfPath) {
    final isNetwork = pdfPath.startsWith('http://') || pdfPath.startsWith('https://');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PDF Attachment',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    pdfPath.split('/').last,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Open PDF Button
            IconButton(
              onPressed: () => _openPDF(pdfPath),
              icon: Icon(
                Icons.open_in_new,
                color: Colors.red[700],
                size: 20,
              ),
              tooltip: 'Open PDF',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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

  Widget _buildStatusBadge(ScheduleUIModel schedule) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: schedule.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        schedule.statusDisplay,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: schedule.statusColor,
        ),
      ),
    );
  }

  Widget _buildAssignedList(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventViewDetails(ScheduleUIModel schedule) {
    final details = schedule.eventDetails!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 Event Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (details.eventType != null && details.eventType!.isNotEmpty)
          _buildDetailRow('Event Type', details.eventType!),
        if (details.guestSpeaker != null && details.guestSpeaker!.isNotEmpty)
          _buildDetailRow('Guest/Speaker', details.guestSpeaker!),
        if (details.expectedAttendees != null && details.expectedAttendees!.isNotEmpty)
          _buildDetailRow('Expected Attendees', details.expectedAttendees!),
        if (details.eventDescription != null && details.eventDescription!.isNotEmpty)
          _buildDetailRow('Description', details.eventDescription!),
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
                Icons.add_circle_outline,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Add New Schedule',
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
                  onPressed: controller.isSubmitting.value ? null : _addSchedule,
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
                    'Add Schedule',
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
    final schedule = controller.selectedSchedule.value;
    if (schedule == null) return const SizedBox();

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
                'Edit Schedule',
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
                  onPressed: controller.isSubmitting.value ? null : _updateSchedule,
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

          // Type Selector
          const Text(
            'Schedule Type',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: _typeList.map((type) {
              final isSelected = _selectedType == type;
              Color color = Colors.blue;
              IconData icon = Icons.event;
              if (type == 'Event') { color = Colors.blue; icon = Icons.event; }
              if (type == 'Exam') { color = Colors.red; icon = Icons.school; }
              if (type == 'Other') { color = Colors.green; icon = Icons.more_horiz; }

              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: isSelected ? Colors.white : color),
                    const SizedBox(width: 4),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = type;
                  });
                },
                selectedColor: color,
                backgroundColor: Colors.grey[100],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Status
          _buildDropdownField('Status', _statusList, _selectedStatus, (value) {
            setState(() => _selectedStatus = value!);
          }),
          const SizedBox(height: 10),

          // Common Fields
          _buildFormTextField(_titleController, 'Title', Icons.title,
              hint: 'Enter schedule title', required: true),
          const SizedBox(height: 10),

          _buildFormTextField(_descriptionController, 'Description', Icons.description,
              hint: 'Enter description', maxLines: 2),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildDatePicker('Start Date', _startDate, (date) {
                  setState(() {
                    _startDate = date;
                    if (_startDate.isAfter(_endDate)) {
                      _endDate = _startDate.add(const Duration(days: 1));
                    }
                  });
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDatePicker('End Date', _endDate, (date) {
                  if (date.isBefore(_startDate)) {
                    FlutterToast.warning('End date must be after start date');
                    return;
                  }
                  setState(() {
                    _endDate = date;
                  });
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildFormTextField(_timeController, 'Time', Icons.access_time,
                    hint: 'e.g., 9:00 AM - 12:00 PM'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFormTextField(_locationController, 'Location', Icons.location_on,
                    hint: 'Enter location'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Event Details (only for Event type)
          if (_selectedType == 'Event') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.event, color: Colors.blue[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Event Details',
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
            _buildFormTextField(_eventTypeController, 'Event Type', Icons.category,
                hint: 'e.g., Sports, Cultural'),
            const SizedBox(height: 8),
            _buildFormTextField(_guestSpeakerController, 'Guest/Speaker', Icons.person,
                hint: 'Enter guest name'),
            const SizedBox(height: 8),
            _buildFormTextField(_expectedAttendeesController, 'Expected Attendees', Icons.people,
                hint: 'e.g., 200 Students'),
            const SizedBox(height: 8),
            _buildFormTextField(_eventDescriptionController, 'Event Description', Icons.description,
                hint: 'Additional event details', maxLines: 2),
            const SizedBox(height: 10),
          ],

          // Banner Upload Section with integrated preview
          _buildBannerUploadSection(),
          const SizedBox(height: 10),

          // PDF Upload Section
          _buildPDFUploadSection(),
          const SizedBox(height: 10),

          // Assign Classes
          const Text(
            'Assign Classes',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: _classList.map((cls) {
              final isSelected = _selectedClasses.contains(cls);
              return FilterChip(
                label: Text(cls, style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedClasses.add(cls);
                    } else {
                      _selectedClasses.remove(cls);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                backgroundColor: Colors.grey[100],
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Assign Teachers
          const Text(
            'Assign Teachers',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: _teacherList.map((teacher) {
              final isSelected = _selectedTeachers.contains(teacher);
              return FilterChip(
                label: Text(teacher, style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTeachers.add(teacher);
                    } else {
                      _selectedTeachers.remove(teacher);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                backgroundColor: Colors.grey[100],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============ BANNER UPLOAD SECTION WITH EXISTING BANNER SUPPORT ============
  Widget _buildBannerUploadSection() {
    bool hasBanner = false;
    String? bannerDisplayName;
    bool isNetworkBanner = false;

    // Check for existing banner (network image)
    if (_isExistingBanner && _bannerImagePath != null && _bannerImagePath!.isNotEmpty) {
      hasBanner = true;
      bannerDisplayName = _bannerImagePath!.split('/').last;
      isNetworkBanner = true;
    }
    // Check for web uploaded banner
    else if (kIsWeb && _bannerImageBytes != null) {
      hasBanner = true;
      bannerDisplayName = _bannerImageName;
      isNetworkBanner = false;
    }
    // Check for mobile uploaded banner
    else if (!kIsWeb && _bannerImage != null) {
      hasBanner = true;
      bannerDisplayName = _bannerImage!.path.split('/').last;
      isNetworkBanner = false;
    }
    // Check for mobile uploaded banner path
    else if (!kIsWeb && _bannerImagePath != null && _bannerImagePath!.isNotEmpty && !_isExistingBanner) {
      hasBanner = true;
      bannerDisplayName = _bannerImagePath!.split('/').last;
      isNetworkBanner = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.image, color: Colors.orange[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Banner Image',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
              const Spacer(),
              if (hasBanner)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isExistingBanner ? 'Existing ✓' : 'Uploaded ✓',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Preview section
              if (hasBanner)
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: isNetworkBanner
                            ? Image.network(
                          _bannerImagePath!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Loading banner...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Failed to load banner',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                            : kIsWeb && _bannerImageBytes != null
                            ? Image.memory(
                          _bannerImageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Preview not available',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                            : (_bannerImage != null
                            ? Image.file(
                          _bannerImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Preview not available',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                            : const SizedBox.shrink()
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _removeBannerImage,
                            icon: const Icon(Icons.close, color: Colors.white, size: 16),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                      // Banner label overlay
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _isExistingBanner ? 'Current Banner' : 'Banner Preview',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // File info and actions
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    if (hasBanner && bannerDisplayName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                bannerDisplayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isNetworkBanner)
                              Text(
                                '${(kIsWeb ? _bannerImageBytes?.length ?? 0 : (_bannerImage?.lengthSync() ?? 0)) ~/ 1024} KB',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                ),
                              ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickBannerImage,
                            icon: Icon(
                              hasBanner ? Icons.change_circle : Icons.upload_file,
                              size: 18,
                            ),
                            label: Text(
                              hasBanner ? 'Change Banner' : 'Upload Banner',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        if (hasBanner)
                          const SizedBox(width: 8),
                        if (hasBanner)
                          OutlinedButton(
                            onPressed: _removeBannerImage,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: Colors.red[300]!),
                            ),
                            child: const Text('Remove'),
                          ),
                      ],
                    ),
                    if (_isExistingBanner && hasBanner)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '💡 This is the existing banner. Upload a new one to replace it.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============ PDF UPLOAD SECTION ============
  Widget _buildPDFUploadSection() {
    bool hasPdf = false;
    String? pdfDisplayName;
    bool isNetworkPdf = false;

    // Check for existing PDF (network)
    if (_pdfFilePath != null && _pdfFilePath!.isNotEmpty &&
        (_pdfFilePath!.startsWith('http://') || _pdfFilePath!.startsWith('https://'))) {
      hasPdf = true;
      pdfDisplayName = _pdfFilePath!.split('/').last;
      isNetworkPdf = true;
    }
    // Check for web uploaded PDF
    else if (kIsWeb && _pdfFileBytes != null) {
      hasPdf = true;
      pdfDisplayName = _pdfFileName;
      isNetworkPdf = false;
    }
    // Check for mobile uploaded PDF
    else if (!kIsWeb && _pdfFile != null) {
      hasPdf = true;
      pdfDisplayName = _pdfFile!.path.split('/').last;
      isNetworkPdf = false;
    }
    // Check for mobile uploaded PDF path
    else if (!kIsWeb && _pdfFilePath != null && _pdfFilePath!.isNotEmpty) {
      hasPdf = true;
      pdfDisplayName = _pdfFilePath!.split('/').last;
      isNetworkPdf = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'PDF Attachment',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
              const Spacer(),
              if (hasPdf)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isNetworkPdf ? 'Existing ✓' : 'Uploaded ✓',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              if (hasPdf)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red[700], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isNetworkPdf ? 'Existing PDF' : 'PDF Selected',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              pdfDisplayName ?? 'pdf_file.pdf',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!isNetworkPdf)
                              Text(
                                '${(kIsWeb ? _pdfFileBytes?.length ?? 0 : (_pdfFile?.lengthSync() ?? 0)) ~/ 1024} KB',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!isNetworkPdf)
                        IconButton(
                          onPressed: _removePDF,
                          icon: Icon(Icons.close, color: Colors.red[700], size: 24),
                        ),
                      if (isNetworkPdf)
                        IconButton(
                          onPressed: () => _openPDF(_pdfFilePath!),
                          icon: Icon(Icons.open_in_new, color: Colors.red[700], size: 24),
                          tooltip: 'Open PDF',
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickPDF,
                        icon: Icon(
                          hasPdf ? Icons.change_circle : Icons.upload_file,
                          size: 18,
                        ),
                        label: Text(
                          hasPdf ? 'Change PDF' : 'Upload PDF',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    if (hasPdf && !isNetworkPdf)
                      const SizedBox(width: 8),
                    if (hasPdf && !isNetworkPdf)
                      OutlinedButton(
                        onPressed: _removePDF,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.red[300]!),
                        ),
                        child: const Text('Remove'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============ FORM HELPERS ============
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
      value: items.contains(value) ? value : items.first,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label.isNotEmpty ? label : null,
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
          child: Text(item, style: TextStyle(fontSize: isCompact ? 12 : 13)),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}