import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../model/schedule_model.dart';
import '../repository/schedule_repository.dart';

// ============ ENUMS ============
enum ScheduleFilter {
  all,
  event,
  exam,
  other,
}

// ============ CONTROLLER ============
class ScheduleController extends GetxController {
  final ScheduleRepository _repository = ScheduleRepository();

  // ============ STATE ============
  final RxList<ScheduleApiModel> schedules = <ScheduleApiModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // UI State
  final Rx<ScheduleFilter> currentFilter = ScheduleFilter.all.obs;
  final RxString searchQuery = ''.obs;
  final RxBool showRightPanel = false.obs;
  final Rx<ScheduleApiModel?> selectedSchedule = Rx<ScheduleApiModel?>(null);
  final RxBool isEditing = false.obs;
  final RxBool isAddingNew = false.obs;

  // ============ FORM STATE ============
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final timeController = TextEditingController();
  final eventTypeController = TextEditingController();
  final guestSpeakerController = TextEditingController();
  final expectedAttendeesController = TextEditingController();
  final eventDescriptionController = TextEditingController();

  final RxString selectedType = 'Event'.obs;
  final RxString selectedSchoolType = 'A'.obs;
  final RxString selectedStatus = 'Upcoming'.obs;
  final RxString selectedStartDate = ''.obs;
  final RxString selectedEndDate = ''.obs;
  final RxList<String> assignedClasses = <String>[].obs;
  final RxList<String> assignedTeachers = <String>[].obs;

  // File state
  final Rx<File?> bannerImage = Rx<File?>(null);
  final Rx<File?> pdfFile = Rx<File?>(null);
  final Rx<Uint8List?> bannerImageBytes = Rx<Uint8List?>(null);
  final Rx<Uint8List?> pdfFileBytes = Rx<Uint8List?>(null);

  // NEW: For existing file paths
  final Rx<String?> existingBannerPath = Rx<String?>(null);
  final Rx<String?> existingPdfPath = Rx<String?>(null);
  final RxBool isExistingBanner = false.obs;
  final RxBool isExistingPdf = false.obs;

  final RxBool checkBox = true.obs;

  // ============ CONSTANTS ============
  final List<String> typeList = ['Event', 'Exam', 'Other'];
  final List<String> schoolTypeList = ['A', 'B'];
  final List<String> statusList = ['Upcoming', 'Ongoing', 'Completed'];
  final List<String> classList = ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'];
  final List<String> teacherList = ['Mr. John', 'Ms. Sarah', 'Dr. Smith', 'Mrs. Brown'];

  // ============ GETTERS ============
  List<ScheduleApiModel> get filteredSchedules {
    var filtered = schedules.toList();

    if (currentFilter.value != ScheduleFilter.all) {
      filtered = filtered.where((s) {
        if (currentFilter.value == ScheduleFilter.event) {
          return s.type.toLowerCase() == 'event';
        } else if (currentFilter.value == ScheduleFilter.exam) {
          return s.type.toLowerCase() == 'exam';
        } else {
          return s.type.toLowerCase() == 'other';
        }
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((s) =>
      s.title.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query) ||
          s.location.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }

  int get totalSchedules => schedules.length;
  int get eventCount => schedules.where((s) => s.type.toLowerCase() == 'event').length;
  int get examCount => schedules.where((s) => s.type.toLowerCase() == 'exam').length;
  int get otherCount => schedules.where((s) => s.type.toLowerCase() == 'other').length;

  Map<String, int> get schoolWiseStats {
    Map<String, int> stats = {};
    for (var schedule in schedules) {
      final school = schedule.schoolType.toUpperCase() == 'A' ? 'School A' : 'School B';
      stats[school] = (stats[school] ?? 0) + 1;
    }
    return stats;
  }

  // ============ CRUD OPERATIONS ============

  Future<void> loadSchedules() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getSchedules();
      if (result.isNotEmpty) {
        schedules.value = result;
      } else {
        _loadSampleData();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load schedules';
      FlutterToast.error('Failed to load schedules');
      _loadSampleData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSchedule() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      FlutterToast.warning('Please enter a title');
      return;
    }

    try {
      isSubmitting.value = true;

      final data = _buildApiData();
      final result = await _repository.createSchedule(
        data,
        bannerImage.value,
        pdfFile.value,
        bannerImageBytes.value,
        pdfFileBytes.value,
      );

      if (result != null) {
        schedules.add(result);
        FlutterToast.success('Schedule added successfully!');
        _resetAndClose();
      } else {
        FlutterToast.error('Failed to add schedule');
      }
    } catch (e) {
      print('❌ Error in addSchedule: $e');
      FlutterToast.error('Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateSchedule() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      FlutterToast.warning('Please enter a title');
      return;
    }

    try {
      isSubmitting.value = true;

      final id = selectedSchedule.value?.id ?? 0;
      if (id == 0) {
        FlutterToast.error('Invalid schedule ID');
        return;
      }

      final data = _buildApiData();

      // NEW: Handle existing banner and PDF paths
      // If we have an existing banner path and no new file/bytes, keep the existing path
      final hasNewBanner = bannerImage.value != null || bannerImageBytes.value != null;
      final hasNewPdf = pdfFile.value != null || pdfFileBytes.value != null;

      // Only send new files if they exist, otherwise the repository should keep existing
      final result = await _repository.updateSchedule(
        id,
        data,
        hasNewBanner ? bannerImage.value : null,
        hasNewPdf ? pdfFile.value : null,
        hasNewBanner ? bannerImageBytes.value : null,
        hasNewPdf ? pdfFileBytes.value : null,
      );

      if (result != null) {
        final index = schedules.indexWhere((s) => s.id == selectedSchedule.value?.id);
        if (index != -1) {
          schedules[index] = result;
          selectedSchedule.value = result;
        }
        FlutterToast.success('Schedule updated successfully!');
        _resetAndClose();
      } else {
        FlutterToast.error('Failed to update schedule');
      }
    } catch (e) {
      print('❌ Error in updateSchedule: $e');
      FlutterToast.error('Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteSchedule(ScheduleApiModel schedule) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text('Are you sure you want to delete "${schedule.title}"?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              _confirmDelete(schedule);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(ScheduleApiModel schedule) async {
    try {
      isLoading.value = true;

      final success = await _repository.deleteSchedule(schedule.id);
      if (success) {
        schedules.removeWhere((s) => s.id == schedule.id);
        if (selectedSchedule.value?.id == schedule.id) {
          selectedSchedule.value = null;
          showRightPanel.value = false;
        }
        FlutterToast.success('Schedule deleted successfully!');
      } else {
        FlutterToast.error('Failed to delete schedule');
      }
    } catch (e) {
      FlutterToast.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============ FORM HELPERS ============

  Map<String, dynamic> _buildApiData() {
    final Map<String, dynamic> eventDetails = {
      'event_type': eventTypeController.text.trim(),
      'guest_speaker': guestSpeakerController.text.trim(),
      'expected_attendees': expectedAttendeesController.text.trim(),
      'event_description': eventDescriptionController.text.trim(),
    };

    eventDetails.removeWhere((key, value) => value == null || value.toString().isEmpty);

    return {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'type': selectedType.value,
      'start_date': selectedStartDate.value,
      'end_date': selectedEndDate.value,
      'school_type': selectedSchoolType.value,
      'time': timeController.text.trim(),
      'location': locationController.text.trim(),
      'status': selectedStatus.value,
      'assigned_classes': assignedClasses.toList(),
      'assigned_teachers': assignedTeachers.toList(),
      'check_box': checkBox.value,
      'event_details': eventDetails,
    };
  }

  void _resetAndClose() {
    resetForm();
    showRightPanel.value = false;
    isAddingNew.value = false;
    isEditing.value = false;
  }

  // ============ UI METHODS ============
  void setFilter(ScheduleFilter filter) => currentFilter.value = filter;
  void setSearchQuery(String query) => searchQuery.value = query;

  void selectSchedule(ScheduleApiModel? schedule) {
    selectedSchedule.value = schedule;
    showRightPanel.value = schedule != null;
    isEditing.value = false;
    isAddingNew.value = false;
    if (schedule != null) loadScheduleToForm(schedule);
  }

  void startAddNew() {
    resetForm();
    isAddingNew.value = true;
    isEditing.value = false;
    selectedSchedule.value = null;
    showRightPanel.value = true;
  }

  void startEditing(ScheduleApiModel schedule) {
    loadScheduleToForm(schedule);
    selectedSchedule.value = schedule;
    isEditing.value = true;
    isAddingNew.value = false;
    showRightPanel.value = true;
  }

  void closeRightPanel() {
    showRightPanel.value = false;
    selectedSchedule.value = null;
    isEditing.value = false;
    isAddingNew.value = false;
    resetForm();
  }

  // ============ FORM METHODS ============
  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    timeController.clear();
    eventTypeController.clear();
    guestSpeakerController.clear();
    expectedAttendeesController.clear();
    eventDescriptionController.clear();
    selectedType.value = 'Event';
    selectedSchoolType.value = 'A';
    selectedStatus.value = 'Upcoming';
    selectedStartDate.value = '';
    selectedEndDate.value = '';
    assignedClasses.clear();
    assignedTeachers.clear();
    bannerImage.value = null;
    pdfFile.value = null;
    bannerImageBytes.value = null;
    pdfFileBytes.value = null;
    existingBannerPath.value = null;
    existingPdfPath.value = null;
    isExistingBanner.value = false;
    isExistingPdf.value = false;
    checkBox.value = true;
  }

  void loadScheduleToForm(ScheduleApiModel schedule) {
    titleController.text = schedule.title;
    descriptionController.text = schedule.description;
    locationController.text = schedule.location;
    timeController.text = schedule.time;
    selectedType.value = schedule.type;
    selectedSchoolType.value = schedule.schoolType;
    selectedStatus.value = schedule.status;
    selectedStartDate.value = schedule.startDate;
    selectedEndDate.value = schedule.endDate;
    assignedClasses.value = List.from(schedule.assignedClasses);
    assignedTeachers.value = List.from(schedule.assignedTeachers);
    checkBox.value = schedule.checkBox;

    if (schedule.eventDetails != null) {
      eventTypeController.text = schedule.eventDetails!.eventType ?? '';
      guestSpeakerController.text = schedule.eventDetails!.guestSpeaker ?? '';
      expectedAttendeesController.text = schedule.eventDetails!.expectedAttendees ?? '';
      eventDescriptionController.text = schedule.eventDetails!.eventDescription ?? '';
    }

    // NEW: Load existing banner and PDF paths
    if (schedule.bannerImage != null && schedule.bannerImage!.isNotEmpty) {
      existingBannerPath.value = schedule.bannerImage;
      isExistingBanner.value = true;
      bannerImage.value = null;
      bannerImageBytes.value = null;
    } else {
      existingBannerPath.value = null;
      isExistingBanner.value = false;
    }

    if (schedule.pdfFile != null && schedule.pdfFile!.isNotEmpty) {
      existingPdfPath.value = schedule.pdfFile;
      isExistingPdf.value = true;
      pdfFile.value = null;
      pdfFileBytes.value = null;
    } else {
      existingPdfPath.value = null;
      isExistingPdf.value = false;
    }
  }

  // ============ FILE PICKERS ============
  void setBannerImage(File? file) {
    bannerImage.value = file;
    if (file != null) {
      isExistingBanner.value = false;
      existingBannerPath.value = null;
    }
  }

  void setBannerImageBytes(Uint8List? bytes) {
    bannerImageBytes.value = bytes;
    if (bytes != null) {
      isExistingBanner.value = false;
      existingBannerPath.value = null;
    }
  }

  void setPdfFile(File? file) {
    pdfFile.value = file;
    if (file != null) {
      isExistingPdf.value = false;
      existingPdfPath.value = null;
    }
  }

  void setPdfFileBytes(Uint8List? bytes) {
    pdfFileBytes.value = bytes;
    if (bytes != null) {
      isExistingPdf.value = false;
      existingPdfPath.value = null;
    }
  }

  void removeBannerImage() {
    bannerImage.value = null;
    bannerImageBytes.value = null;
    existingBannerPath.value = null;
    isExistingBanner.value = false;
  }

  void removePdfFile() {
    pdfFile.value = null;
    pdfFileBytes.value = null;
    existingPdfPath.value = null;
    isExistingPdf.value = false;
  }

  // NEW: Methods to get existing file paths
  String? getExistingBannerPath() => existingBannerPath.value;
  String? getExistingPdfPath() => existingPdfPath.value;
  bool get hasExistingBanner => isExistingBanner.value;
  bool get hasExistingPdf => isExistingPdf.value;

  // ============ HELPERS ============
  String getSchoolDisplay(String schoolType) {
    return schoolType.toUpperCase() == 'A' ? 'School A' : 'School B';
  }

  Color getSchoolColor(String schoolType) {
    return schoolType.toUpperCase() == 'A' ? Colors.blue : Colors.green;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming': return Colors.green;
      case 'ongoing': return Colors.orange;
      case 'completed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String getStatusDisplay(String status) {
    return status.isNotEmpty ? status : 'Upcoming';
  }

  // ============ SAMPLE DATA ============
  void _loadSampleData() {
    schedules.value = [
      ScheduleApiModel(
        id: 1,
        title: 'Annual Sports Day',
        description: 'School annual sports competition',
        type: 'Event',
        startDate: DateTime.now().add(const Duration(days: 5)).toString().split(' ')[0],
        endDate: DateTime.now().add(const Duration(days: 6)).toString().split(' ')[0],
        schoolType: 'A',
        time: '9:00 AM - 4:00 PM',
        location: 'School Ground',
        status: 'Upcoming',
        assignedClasses: ['Class 1', 'Class 2', 'Class 3'],
        assignedTeachers: ['Mr. John', 'Ms. Sarah'],
        eventDetails: EventDetails(
          eventType: 'Sports Event',
          guestSpeaker: 'Mr. Sports Coach',
          expectedAttendees: '500+ Students',
          eventDescription: 'Various sports activities',
        ),
        checkBox: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        bannerImage: null,
        pdfFile: null,
      ),
      ScheduleApiModel(
        id: 2,
        title: 'Mid Term Exam',
        description: 'Mid term examination',
        type: 'Exam',
        startDate: DateTime.now().add(const Duration(days: 15)).toString().split(' ')[0],
        endDate: DateTime.now().add(const Duration(days: 20)).toString().split(' ')[0],
        schoolType: 'A',
        time: '8:00 AM - 12:00 PM',
        location: 'School Classrooms',
        status: 'Upcoming',
        assignedClasses: ['All Classes'],
        assignedTeachers: ['All Teachers'],
        eventDetails: null,
        checkBox: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        bannerImage: null,
        pdfFile: null,
      ),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    timeController.dispose();
    eventTypeController.dispose();
    guestSpeakerController.dispose();
    expectedAttendeesController.dispose();
    eventDescriptionController.dispose();
    super.onClose();
  }
}