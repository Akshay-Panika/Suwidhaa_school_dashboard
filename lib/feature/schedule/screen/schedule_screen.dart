import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/widget/flutter_toast.dart';
import '../../main/controller/school_type_controller.dart';
import '../../main/widget/school_type_filter_widget.dart';
import '../../teachers/controller/teacher_controller.dart';
import '../controller/event_controller.dart';
import '../controller/notice_controller.dart';
import '../controller/meeting_controller.dart';
import '../controller/exam_controller.dart';
import '../model/event_model.dart';
import '../model/notice_model.dart';
import '../model/meeting_model.dart';
import '../model/exam_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final SchoolTypeController schoolController = Get.find<SchoolTypeController>();
  final NoticeController noticeController = Get.find<NoticeController>();
  final EventController eventController = Get.find<EventController>();
  final MeetingController meetingController = Get.find<MeetingController>();
  final ExamController examController = Get.find<ExamController>();
  final TeacherController teacherController = Get.find<TeacherController>();

  final List<Map<String, dynamic>> _modules = [
    {'title': 'Notice Board', 'subtitle': 'View and manage notices', 'icon': Icons.notifications_active},
    {'title': 'Events', 'subtitle': 'School events and activities', 'icon': Icons.event},
    {'title': 'Meetings', 'subtitle': 'Staff and parent meetings', 'icon': Icons.groups},
    {'title': 'Exams', 'subtitle': 'Exam schedules and results', 'icon': Icons.assignment},
  ];

  Map<String, dynamic>? _selectedModule;

  // Notice Variables
  NoticeModel? _selectedNotice;
  XFile? _noticeImage;
  String _formPriority = 'Normal';
  String _formAudience = 'Students';
  String _formAssignedClass = 'All Classes';
  bool _formIsPinned = false;
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();

  // Event Variables
  SchoolEvent? _selectedEvent;
  XFile? _eventImage;
  String _eventCategory = 'Sports';
  String _eventAudience = 'Both';
  String _eventStatus = 'Upcoming';
  String _eventStartDate = '';
  String _eventEndDate = '';
  String _eventStartTime = '';
  String _eventEndTime = '';
  bool _eventIsPinned = false;
  final _eventTitleController = TextEditingController();
  final _eventDescController = TextEditingController();
  final _eventVenueController = TextEditingController();

  // Meeting Variables
  MeetingModel? _selectedMeeting;
  final _meetingTitleController = TextEditingController();
  final _meetingZoomController = TextEditingController();
  String _meetingDate = '';
  String _meetingTime = '';
  String _meetingFor = 'Student';
  String _meetingClass = 'All Classes';

  // Exam Variables
  ExamTimetableModel? _selectedExam;
  String? _examClass;
  String? _examType;
  String _examFromDate = '';
  String _examToDate = '';
  final List<SubjectScheduleModel> _examSchedules = [];

  // Exam Bottom Sheet Variables
  String? _subSubject;
  int? _subInvigilatorId;
  String _subDate = '';
  String _subStartTime = '';
  String _subEndTime = '';
  final TextEditingController _roomController = TextEditingController();

  final List<String> _classesList = ['Class 1', 'Class 2', 'Class 3', 'Class 10 - A'];
  final Map<String, String> _examTypesMap = {
    'board': 'Board Exam',
    'halfYearly': 'Half Yearly',
    'annual': 'Annual Exam',
    'preBoard': 'Pre-Board',
    'unitTest': 'Unit Test',
  };

  bool _showRightPanel = false;
  bool _isEditing = false;
  bool _isAddingNew = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _eventTitleController.dispose();
    _eventDescController.dispose();
    _eventVenueController.dispose();
    _meetingTitleController.dispose();
    _meetingZoomController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _resetNoticeForm() {
    _titleController.clear();
    _subtitleController.clear();
    _noticeImage = null;
    _formPriority = 'Normal';
    _formAudience = 'Students';
    _formAssignedClass = 'All Classes';
    _formIsPinned = false;
  }

  void _resetEventForm() {
    _eventTitleController.clear();
    _eventDescController.clear();
    _eventVenueController.clear();
    _eventImage = null;
    _eventCategory = 'Sports';
    _eventAudience = 'Both';
    _eventStatus = 'Upcoming';
    _eventStartDate = '';
    _eventEndDate = '';
    _eventStartTime = '';
    _eventEndTime = '';
    _eventIsPinned = false;
  }

  void _resetMeetingForm() {
    _meetingTitleController.clear();
    _meetingZoomController.clear();
    _meetingDate = '';
    _meetingTime = '';
    _meetingFor = 'Student';
    _meetingClass = 'All Classes';
  }

  void _resetExamForm() {
    _examClass = null;
    _examType = null;
    _examFromDate = '';
    _examToDate = '';
    _examSchedules.clear();
  }

  Future<void> _pickImage(bool isEvent) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isEvent) _eventImage = pickedFile;
        else _noticeImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Obx(() {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              // ==================== LEFT PANEL ====================
              Expanded(
                flex: _showRightPanel ? 5 : 8,
                child: Column(
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        spacing: 4,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          _modules.length,
                              (index) => _buildModuleCard(_modules[index]),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _selectedModule == null
                          ? _buildEmptyState()
                          : (_selectedModule!['title'] == 'Notice Board'
                          ? _buildApiNoticeList()
                          : _selectedModule!['title'] == 'Events'
                          ? _buildApiEventList()
                          : _selectedModule!['title'] == 'Meetings'
                          ? _buildApiMeetingList()
                          : _selectedModule!['title'] == 'Exams'
                          ? _buildApiExamList()
                          : _buildNoDataAvailable()),
                    ),
                  ],
                ),
              ),

              // ==================== RIGHT PANEL ====================
              Container(
                width: 480,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                  border: Border(left: BorderSide(color: Colors.grey[200]!, width: 1)),
                ),
                child: !_showRightPanel
                    ? _buildEmptyRightPanel()
                    : (_selectedModule!['title'] == 'Events'
                    ? (_isAddingNew || _isEditing ? _buildEventFormPanel() : _selectedEvent != null ? _buildApiEventDetail(_selectedEvent!) : _buildEmptyRightPanel())
                    : _selectedModule!['title'] == 'Meetings'
                    ? (_isAddingNew || _isEditing ? _buildMeetingFormPanel() : _selectedMeeting != null ? _buildApiMeetingDetail(_selectedMeeting!) : _buildEmptyRightPanel())
                    : _selectedModule!['title'] == 'Exams'
                    ? (_isAddingNew || _isEditing ? _buildExamFormPanel() : _selectedExam != null ? _buildApiExamDetail(_selectedExam!) : _buildEmptyRightPanel())
                    : (_isAddingNew
                    ? _buildNoticeFormPanel('Create Notice')
                    : _isEditing
                    ? _buildNoticeFormPanel('Edit Notice')
                    : _selectedNotice != null
                    ? _buildApiNoticeDetail(_selectedNotice!)
                    : _buildEmptyRightPanel())),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    final isSelected = _selectedModule?['title'] == module['title'];
    final isSchoolSelected = schoolController.selectedSchoolType.value != null;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSchoolSelected) {
            FlutterToast.warning('Please select a school first');
            return;
          }
          setState(() {
            _selectedModule = isSelected ? null : module;
            _selectedNotice = null;
            _selectedEvent = null;
            _selectedMeeting = null;
            _selectedExam = null;
            _isEditing = false;
            _isAddingNew = false;
            _showRightPanel = false;

            if (!isSelected) {
              final schoolId = schoolController.selectedSchoolType.value!.id!;
              if (module['title'] == 'Events') {
                eventController.fetchEvents(schoolId);
              } else if (module['title'] == 'Meetings') {
                meetingController.fetchMeetings(schoolId);
              } else if (module['title'] == 'Exams') {
                examController.fetchExams(schoolId);
              }
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(module['icon'], color: Colors.blue[700], size: 18),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['title'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[700] : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module['subtitle'],
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataAvailable() {
    return const Center(
      child: Text(
        'No data available for this module yet.',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  // ==================== NOTICE FORM PANEL ====================
  Widget _buildNoticeFormPanel(String title) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_isEditing ? Icons.edit_outlined : Icons.add_alert, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _noticeImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb
                    ? Image.network(_noticeImage!.path, fit: BoxFit.cover)
                    : Image.file(File(_noticeImage!.path), fit: BoxFit.cover),
              )
                  : (_selectedNotice?.attachmentUrl != null && _isEditing)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(_selectedNotice!.attachmentUrl!, fit: BoxFit.cover),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 28, color: Colors.blue[300]),
                  const SizedBox(height: 4),
                  const Text('Add Notice Image', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                    schoolController.selectedSchoolType.value?.schoolName ?? 'No school selected',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPriorityButton('Normal', Icons.info_outline),
              const SizedBox(width: 10),
              _buildPriorityButton('Important', Icons.star_border),
              const SizedBox(width: 10),
              _buildPriorityButton('Urgent', Icons.priority_high),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Notice Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            maxLength: 80,
            onChanged: (val) => setState(() {}),
            decoration: _imageInputDecoration(
              hint: 'e.g. Annual Sports Meet 2025',
              icon: Icons.text_fields,
              showCounter: true,
              currentLength: _titleController.text.length,
              maxLength: 80,
            ),
          ),
          const SizedBox(height: 10),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _subtitleController,
            maxLines: 3,
            maxLength: 500,
            onChanged: (val) => setState(() {}),
            decoration: _imageInputDecoration(
              hint: 'Write detailed notice here...',
              showCounter: true,
              currentLength: _subtitleController.text.length,
              maxLength: 500,
            ),
          ),
          const SizedBox(height: 10),
          const Text('Assign to Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _formAssignedClass,
            icon: const Icon(Icons.keyboard_arrow_down),
            decoration: _imageInputDecoration(icon: Icons.book, isDropdown: true),
            items: ['All Classes', 'Class 1', 'Class 2', 'Class 3', 'Class 10 - A']
                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                .toList(),
            onChanged: (val) => setState(() => _formAssignedClass = val!),
          ),
          const SizedBox(height: 16),
          const Text('Audience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildAudienceChip('Students', Icons.school),
              _buildAudienceChip('Parents', Icons.people),
              _buildAudienceChip('Both', Icons.groups),
              _buildAudienceChip('Staff', Icons.badge),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.push_pin, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Pin to top', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Switch(
                  value: _formIsPinned,
                  activeColor: Colors.blue,
                  onChanged: (val) => setState(() => _formIsPinned = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _showRightPanel = false;
                    _isAddingNew = false;
                    _isEditing = false;
                    _selectedNotice = null;
                    _resetNoticeForm();
                  }),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (schoolController.selectedSchoolType.value == null) {
                      FlutterToast.warning('Please select a school first.');
                      return;
                    }
                    if (_titleController.text.trim().isEmpty) {
                      FlutterToast.warning('Title is required');
                      return;
                    }

                    bool success;
                    if (_isAddingNew) {
                      success = await noticeController.addNotice(
                        title: _titleController.text.trim(),
                        description: _subtitleController.text.trim(),
                        priority: _formPriority,
                        audience: _formAudience,
                        assignedClass: _formAssignedClass,
                        attachmentImage: _noticeImage,
                      );
                    } else {
                      success = await noticeController.updateNotice(
                        id: _selectedNotice!.id,
                        title: _titleController.text.trim(),
                        description: _subtitleController.text.trim(),
                        priority: _formPriority,
                        audience: _formAudience,
                        assignedClass: _formAssignedClass,
                        attachmentImage: _noticeImage,
                      );
                    }

                    if (success) {
                      FlutterToast.success(_isAddingNew ? 'Notice published successfully' : 'Notice updated successfully');
                      setState(() {
                        _showRightPanel = false;
                        _isAddingNew = false;
                        _isEditing = false;
                        _selectedNotice = null;
                        _resetNoticeForm();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(_isAddingNew ? 'Save' : 'Update', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApiNoticeDetail(NoticeModel item) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.notifications, color: Colors.blue[700], size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Notice Board', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _showRightPanel = false;
                _selectedNotice = null;
                _isEditing = false;
              }),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Divider(height: 32),
        if (item.attachmentUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(item.attachmentUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
        if (item.attachmentUrl != null) const SizedBox(height: 16),
        _buildDetailRow('Priority', item.priority),
        _buildDetailRow('Audience', item.audience),
        _buildDetailRow('Assigned Class', item.assignedClass),
        _buildDetailRow('Date', item.displayDate),
        _buildDetailRow('Pinned', item.isPinned ? 'Yes' : 'No'),
        _buildDetailRow('Description', item.description),
        if (item.school != null) _buildDetailRow('School', item.school!.schoolName),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            _startEditNotice(item);
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Notice'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 45),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityButton(String title, IconData icon) {
    bool isSelected = _formPriority == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _formPriority = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50] : Colors.white,
            border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.blue : Colors.grey[500], size: 20),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: isSelected ? Colors.blue : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudienceChip(String title, IconData icon) {
    bool isSelected = _formAudience == title;
    return GestureDetector(
      onTap: () => setState(() => _formAudience = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[600], size: 18),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  InputDecoration _imageInputDecoration({String? hint, IconData? icon, bool showCounter = false, int currentLength = 0, int maxLength = 0, bool isDropdown = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF4A55A2)) : null,
      suffixIcon: showCounter
          ? Padding(
        padding: const EdgeInsets.only(right: 12, bottom: 20),
        child: Text('$currentLength/$maxLength', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF4A55A2))),
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

  Widget _buildHeader() {
    final isSchoolSelected = schoolController.selectedSchoolType.value != null;

    int count = 0;
    if (_selectedModule != null) {
      if (_selectedModule!['title'] == 'Notice Board') count = noticeController.notices.length;
      if (_selectedModule!['title'] == 'Events') count = eventController.events.length;
      if (_selectedModule!['title'] == 'Meetings') count = meetingController.meetings.length;
      if (_selectedModule!['title'] == 'Exams') count = examController.exams.length;
    }

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
                child: Icon(Icons.dashboard, color: Colors.blue[700], size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dashboard & Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('$count items found', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          Row(
            children: [
              SchoolTypeFilterWidget(
                compact: true,
                value: schoolController.selectedSchoolType.value,
                onChanged: (school) {
                  schoolController.selectedSchoolType.value = school;
                  setState(() {
                    _showRightPanel = false;
                    _selectedNotice = null;
                    _selectedEvent = null;
                    _selectedMeeting = null;
                    _selectedExam = null;
                    _selectedModule = null;
                    _isEditing = false;
                    _isAddingNew = false;
                  });
                },
              ),
              const SizedBox(width: 8),
              if (isSchoolSelected && (!_showRightPanel || !_isAddingNew))
                ElevatedButton.icon(
                  onPressed: () {
                    if (_selectedModule == null) {
                      FlutterToast.warning('Select a module first');
                      return;
                    }
                    if (_selectedModule!['title'] == 'Notice Board') _resetNoticeForm();
                    if (_selectedModule!['title'] == 'Events') _resetEventForm();
                    if (_selectedModule!['title'] == 'Meetings') _resetMeetingForm();
                    if (_selectedModule!['title'] == 'Exams') _resetExamForm();

                    setState(() {
                      _isAddingNew = true;
                      _isEditing = false;
                      _selectedNotice = null;
                      _selectedEvent = null;
                      _selectedMeeting = null;
                      _selectedExam = null;
                      _showRightPanel = true;
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              if (_showRightPanel)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _selectedNotice = null;
                      _selectedEvent = null;
                      _selectedMeeting = null;
                      _selectedExam = null;
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

  Widget _buildApiNoticeList() {
    if (noticeController.isLoading.value) return const Center(child: CircularProgressIndicator());
    final items = noticeController.notices;
    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildApiNoticeCard(item);
      },
    );
  }

  Widget _buildApiNoticeCard(NoticeModel item) {
    bool isSelected = _selectedNotice?.id == item.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? Colors.blue[300]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              image: item.attachmentUrl != null
                  ? DecorationImage(image: NetworkImage(item.attachmentUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: item.attachmentUrl == null
                ? Icon(item.isPinned ? Icons.push_pin : Icons.notifications, size: 20, color: Colors.blue[700])
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => setState(() { _selectedNotice = item; _isEditing = false; _isAddingNew = false; _showRightPanel = true; }),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(
                    spacing: 10,
                    children: [
                      Text(item.priority, style: const TextStyle(fontSize: 12, color: Colors.red)),
                      Container(height: 12, width: 1, color: Colors.grey),
                      Text('Date: ${item.displayDate}', style: const TextStyle(fontSize: 12, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () => _startEditNotice(item),
                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue[700]),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () async {
                    bool success = await noticeController.deleteNotice(item.id);
                    if (success) FlutterToast.success('Deleted successfully');
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

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.event_busy, size: 50, color: Colors.grey[300]), const SizedBox(height: 12), Text('No Items Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500]))]));
  Widget _buildEmptyRightPanel() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.dashboard_customize, size: 60, color: Colors.grey[300]), const SizedBox(height: 16), Text('Select an item to view details', style: TextStyle(color: Colors.grey[500]))]));

  void _startEditNotice(NoticeModel item) {
    setState(() {
      _selectedNotice = item;
      _isEditing = true;
      _isAddingNew = false;
      _showRightPanel = true;
      _titleController.text = item.title;
      _subtitleController.text = item.description;
      _formPriority = item.priority;
      _formAudience = item.audience;
      _formAssignedClass = item.assignedClass;
      _formIsPinned = item.isPinned;
      _noticeImage = null;
    });
  }

  // =====================================================================
  // ==================== 🟢 EVENT SECTION ===============================
  // =====================================================================

  Widget _buildApiEventList() {
    if (eventController.isLoading.value) return const Center(child: CircularProgressIndicator());
    final items = eventController.events;
    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildApiEventCard(item);
      },
    );
  }

  Widget _buildApiEventCard(SchoolEvent item) {
    bool isSelected = _selectedEvent?.id == item.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? Colors.blue[300]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              image: item.bannerUrl != null
                  ? DecorationImage(image: NetworkImage(item.bannerUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: item.bannerUrl == null
                ? Icon(item.isPinned ? Icons.push_pin : Icons.event, size: 20, color: Colors.blue[700])
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => setState(() { _selectedEvent = item; _isEditing = false; _isAddingNew = false; _showRightPanel = true; }),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(
                    spacing: 10,
                    children: [
                      Text(item.category, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                      Container(height: 12, width: 1, color: Colors.grey),
                      Text('Date: ${item.startDate}', style: const TextStyle(fontSize: 12, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.venue, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () => _startEditEvent(item),
                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue[700]),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () async {
                    bool success = await eventController.deleteEvent(
                      schoolId: schoolController.selectedSchoolType.value!.id!,
                      eventId: item.id,
                    );
                    if (success) FlutterToast.success('Event deleted successfully');
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

  Widget _buildApiEventDetail(SchoolEvent item) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.event, color: Colors.blue[700], size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Event', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _showRightPanel = false;
                _selectedEvent = null;
              }),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Divider(height: 32),
        if (item.bannerUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(item.bannerUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
        if (item.bannerUrl != null) const SizedBox(height: 16),
        _buildDetailRow('Category', item.category),
        _buildDetailRow('Venue', item.venue),
        _buildDetailRow('Date', '${item.startDate} to ${item.endDate}'),
        _buildDetailRow('Time', '${item.startTime} - ${item.endTime}'),
        _buildDetailRow('Audience', item.audience),
        _buildDetailRow('Status', item.status),
        _buildDetailRow('Pinned', item.isPinned ? 'Yes' : 'No'),
        _buildDetailRow('Description', item.description),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _startEditEvent(item),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Event'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 45),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildEventFormPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_isEditing ? Icons.edit_outlined : Icons.event, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(_isEditing ? 'Edit Event' : 'Host Event', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _pickImage(true),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _eventImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb
                    ? Image.network(_eventImage!.path, fit: BoxFit.cover)
                    : Image.file(File(_eventImage!.path), fit: BoxFit.cover),
              )
                  : (_selectedEvent?.bannerUrl != null && _isEditing)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(_selectedEvent!.bannerUrl!, fit: BoxFit.cover),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 28, color: Colors.blue[300]),
                  const SizedBox(height: 4),
                  const Text('Add Event Banner', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                    schoolController.selectedSchoolType.value?.schoolName ?? 'No school selected',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Event Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _eventTitleController,
            decoration: _imageInputDecoration(hint: 'e.g. Annual Sports Meet 2026', icon: Icons.edit_calendar),
          ),
          const SizedBox(height: 12),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Sports', 'Cultural', 'Academic', 'Holiday', 'Meeting', 'Other']
                .map((cat) => _buildEventChoiceChip(cat, _eventCategory == cat, (val) => setState(() => _eventCategory = cat)))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _eventDescController,
            maxLines: 3,
            decoration: _imageInputDecoration(hint: 'Describe the event...'),
          ),
          const SizedBox(height: 16),
          const Text('Venue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _eventVenueController,
            decoration: _imageInputDecoration(hint: 'e.g. Main Ground / Auditorium', icon: Icons.location_on),
          ),
          const SizedBox(height: 16),
          const Text('Event Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildEventPickerBox('Start Date', _eventStartDate, () => _pickDate(true), Icons.calendar_today)),
              const SizedBox(width: 10),
              Expanded(child: _buildEventPickerBox('End Date', _eventEndDate, () => _pickDate(false), Icons.calendar_today)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Event Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildEventPickerBox('Start Time', _eventStartTime, () => _pickTime(true), Icons.access_time)),
              const SizedBox(width: 10),
              Expanded(child: _buildEventPickerBox('End Time', _eventEndTime, () => _pickTime(false), Icons.access_time)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Audience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Students', 'Parents', 'Both', 'Staff', 'All']
                .map((aud) => _buildEventChoiceChip(aud, _eventAudience == aud, (val) => setState(() => _eventAudience = aud)))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Upcoming', 'Ongoing', 'Completed', 'Cancelled']
                .map((stat) => _buildEventChoiceChip(stat, _eventStatus == stat, (val) => setState(() => _eventStatus = stat)))
                .toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.push_pin, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                const Expanded(child: Text('Pin to top', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                Switch(
                  value: _eventIsPinned,
                  activeColor: Colors.blue,
                  onChanged: (val) => setState(() => _eventIsPinned = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _showRightPanel = false;
                    _isAddingNew = false;
                    _isEditing = false;
                    _selectedEvent = null;
                    _resetEventForm();
                  }),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (schoolController.selectedSchoolType.value == null) {
                      FlutterToast.warning('Please select a school first.');
                      return;
                    }
                    if (_eventTitleController.text.trim().isEmpty) {
                      FlutterToast.warning('Title is required');
                      return;
                    }
                    if (_eventStartDate.isEmpty || _eventStartTime.isEmpty) {
                      FlutterToast.warning('Please select Start Date and Time');
                      return;
                    }

                    bool success;
                    if (_isEditing && _selectedEvent != null) {
                      success = await eventController.updateEvent(
                        schoolId: schoolController.selectedSchoolType.value!.id!,
                        eventId: _selectedEvent!.id,
                        title: _eventTitleController.text.trim(),
                        description: _eventDescController.text.trim(),
                        category: _eventCategory,
                        venue: _eventVenueController.text.trim(),
                        startDate: _eventStartDate,
                        endDate: _eventEndDate.isEmpty ? _eventStartDate : _eventEndDate,
                        startTime: _eventStartTime,
                        endTime: _eventEndTime.isEmpty ? '11:59 PM' : _eventEndTime,
                        audience: _eventAudience,
                        status: _eventStatus,
                        isPinned: _eventIsPinned,
                        bannerImage: _eventImage,
                      );
                    } else {
                      success = await eventController.addEvent(
                        schoolId: schoolController.selectedSchoolType.value!.id!,
                        title: _eventTitleController.text.trim(),
                        description: _eventDescController.text.trim(),
                        category: _eventCategory,
                        venue: _eventVenueController.text.trim(),
                        startDate: _eventStartDate,
                        endDate: _eventEndDate.isEmpty ? _eventStartDate : _eventEndDate,
                        startTime: _eventStartTime,
                        endTime: _eventEndTime.isEmpty ? '11:59 PM' : _eventEndTime,
                        audience: _eventAudience,
                        status: _eventStatus,
                        isPinned: _eventIsPinned,
                        bannerImage: _eventImage,
                      );
                    }

                    if (success) {
                      FlutterToast.success(_isEditing ? 'Event Updated Successfully' : 'Event Hosted Successfully');
                      setState(() {
                        _showRightPanel = false;
                        _isAddingNew = false;
                        _isEditing = false;
                        _selectedEvent = null;
                        _resetEventForm();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(_isEditing ? 'Update Event' : 'Host Event', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startEditEvent(SchoolEvent item) {
    setState(() {
      _selectedEvent = item;
      _isEditing = true;
      _isAddingNew = false;
      _showRightPanel = true;
      _eventTitleController.text = item.title;
      _eventDescController.text = item.description;
      _eventVenueController.text = item.venue;
      _eventCategory = item.category;
      _eventAudience = item.audience;
      _eventStatus = item.status;
      _eventStartDate = item.startDate;
      _eventEndDate = item.endDate;
      _eventStartTime = item.startTime;
      _eventEndTime = item.endTime;
      _eventIsPinned = item.isPinned;
      _eventImage = null;
    });
  }

  Widget _buildEventChoiceChip(String label, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: const Color(0xFF4A55A2),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!),
      ),
    );
  }

  Widget _buildEventPickerBox(String label, String value, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              value.isEmpty ? label : value,
              style: TextStyle(color: value.isEmpty ? Colors.grey[500] : Colors.black87, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      String formatted = DateFormat('dd MMM yyyy').format(picked);
      setState(() {
        if (isStart) _eventStartDate = formatted;
        else _eventEndDate = formatted;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      String formatted = picked.format(context);
      setState(() {
        if (isStart) _eventStartTime = formatted;
        else _eventEndTime = formatted;
      });
    }
  }

  // =====================================================================
  // ==================== 🟢 MEETING SECTION =============================
  // =====================================================================

  Widget _buildApiMeetingList() {
    if (meetingController.isLoading.value) return const Center(child: CircularProgressIndicator());
    final items = meetingController.meetings;
    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildApiMeetingCard(item);
      },
    );
  }

  Widget _buildApiMeetingCard(MeetingModel item) {
    bool isSelected = _selectedMeeting?.id == item.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? Colors.blue[300]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.groups, size: 20, color: Colors.blue[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => setState(() { _selectedMeeting = item; _isEditing = false; _isAddingNew = false; _showRightPanel = true; }),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(
                    spacing: 10,
                    children: [
                      Text(item.forMeeting, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                      Container(height: 12, width: 1, color: Colors.grey),
                      Text('${item.date} @ ${item.time}', style: const TextStyle(fontSize: 12, color: Colors.black)),
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
                child: IconButton(
                  onPressed: () => _startEditMeeting(item),
                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue[700]),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () async {
                    bool success = await meetingController.deleteMeeting(
                      schoolId: schoolController.selectedSchoolType.value!.id!,
                      id: item.id,
                    );
                    if (success) FlutterToast.success('Meeting deleted successfully');
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

  Widget _buildApiMeetingDetail(MeetingModel item) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.groups, color: Colors.blue[700], size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Meeting', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _showRightPanel = false;
                _selectedMeeting = null;
              }),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Divider(height: 32),
        _buildDetailRow('For', item.forMeeting),
        if (item.className != null) _buildDetailRow('Class', item.className!),
        _buildDetailRow('Date', item.date),
        _buildDetailRow('Time', item.time),
        if (item.zoomUrl != null) _buildDetailRow('Zoom Link', item.zoomUrl!),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _startEditMeeting(item),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Meeting'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 45),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingFormPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_isEditing ? Icons.edit_outlined : Icons.groups, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(_isEditing ? 'Edit Meeting' : 'Create Meeting', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
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
                    schoolController.selectedSchoolType.value?.schoolName ?? 'No school selected',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Meeting Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _meetingTitleController,
            decoration: _imageInputDecoration(hint: 'e.g. Parent Teacher Meeting', icon: Icons.title),
          ),
          const SizedBox(height: 16),

          const Text('For Meeting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Student', 'Staff']
                .map((val) => _buildEventChoiceChip(val, _meetingFor == val, (isSel) => setState(() => _meetingFor = val)))
                .toList(),
          ),
          const SizedBox(height: 16),

          const Text('Assign to Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _meetingClass,
            icon: const Icon(Icons.keyboard_arrow_down),
            decoration: _imageInputDecoration(icon: Icons.book, isDropdown: true),
            items: ['All Classes', 'Class 1', 'Class 2', 'Class 3', 'Class 10 - A']
                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                .toList(),
            onChanged: (val) => setState(() => _meetingClass = val!),
          ),
          const SizedBox(height: 16),

          const Text('Meeting Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildEventPickerBox('Select Date', _meetingDate, () => _pickDateForMeeting(), Icons.calendar_today),
          const SizedBox(height: 16),

          const Text('Meeting Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildEventPickerBox('Select Time', _meetingTime, () => _pickTimeForMeeting(), Icons.access_time),
          const SizedBox(height: 16),

          const Text('Zoom URL (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _meetingZoomController,
            decoration: _imageInputDecoration(hint: 'https://zoom.us/j/...', icon: Icons.link),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _showRightPanel = false;
                    _isAddingNew = false;
                    _isEditing = false;
                    _selectedMeeting = null;
                    _resetMeetingForm();
                  }),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (schoolController.selectedSchoolType.value == null) {
                      FlutterToast.warning('Please select a school first.');
                      return;
                    }
                    if (_meetingTitleController.text.trim().isEmpty || _meetingDate.isEmpty || _meetingTime.isEmpty) {
                      FlutterToast.warning('Title, Date, and Time are required');
                      return;
                    }

                    String rawZoomUrl = _meetingZoomController.text.trim();
                    String finalZoomUrl = '';
                    if (rawZoomUrl.isNotEmpty) {
                      if (rawZoomUrl.startsWith('http://') || rawZoomUrl.startsWith('https://')) {
                        finalZoomUrl = rawZoomUrl;
                      } else {
                        finalZoomUrl = 'https://$rawZoomUrl';
                      }
                    }

                    bool success;
                    if (_isEditing && _selectedMeeting != null) {
                      success = await meetingController.updateMeeting(
                        schoolId: schoolController.selectedSchoolType.value!.id!,
                        id: _selectedMeeting!.id,
                        title: _meetingTitleController.text.trim(),
                        date: _meetingDate,
                        time: _meetingTime,
                        forMeeting: _meetingFor,
                        className: _meetingClass,
                        zoomUrl: finalZoomUrl.isNotEmpty ? finalZoomUrl : null,
                      );
                    } else {
                      success = await meetingController.addMeeting(
                        schoolId: schoolController.selectedSchoolType.value!.id!,
                        title: _meetingTitleController.text.trim(),
                        date: _meetingDate,
                        time: _meetingTime,
                        forMeeting: _meetingFor,
                        className: _meetingClass,
                        zoomUrl: finalZoomUrl.isNotEmpty ? finalZoomUrl : null,
                      );
                    }

                    if (success) {
                      FlutterToast.success(_isEditing ? 'Meeting Updated Successfully' : 'Meeting Created Successfully');
                      setState(() {
                        _showRightPanel = false;
                        _isAddingNew = false;
                        _isEditing = false;
                        _selectedMeeting = null;
                        _resetMeetingForm();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(_isEditing ? 'Update' : 'Create', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startEditMeeting(MeetingModel item) {
    setState(() {
      _selectedMeeting = item;
      _isEditing = true;
      _isAddingNew = false;
      _showRightPanel = true;
      _meetingTitleController.text = item.title;
      _meetingZoomController.text = item.zoomUrl ?? '';
      _meetingDate = item.date;
      _meetingTime = item.time;
      _meetingFor = item.forMeeting;
      _meetingClass = item.className ?? 'All Classes';
    });
  }

  Future<void> _pickDateForMeeting() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _meetingDate = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _pickTimeForMeeting() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      String formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
      setState(() => _meetingTime = formatted);
    }
  }

  // =====================================================================
  // ==================== 🟢 EXAM SECTION ================================
  // =====================================================================

  Widget _buildApiExamList() {
    if (examController.isLoading.value) return const Center(child: CircularProgressIndicator());
    final items = examController.exams;
    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildApiExamCard(item);
      },
    );
  }

  Widget _buildApiExamCard(ExamTimetableModel item) {
    bool isSelected = _selectedExam?.id == item.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? Colors.blue[300]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.assignment, size: 20, color: Colors.blue[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => setState(() { _selectedExam = item; _isEditing = false; _isAddingNew = false; _showRightPanel = true; }),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.className} - ${item.examTypeLabel}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(
                    spacing: 10,
                    children: [
                      Text('${item.fromDate} to ${item.toDate}', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                      Container(height: 12, width: 1, color: Colors.grey),
                      Text('${item.schedules.length} Subjects', style: const TextStyle(fontSize: 12, color: Colors.black)),
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
                child: IconButton(
                  onPressed: () => _startEditExam(item),
                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue[700]),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () async {
                    bool success = await examController.deleteExam(
                      schoolId: schoolController.selectedSchoolType.value!.id!,
                      id: item.id,
                    );
                    if (success) FlutterToast.success('Exam deleted successfully');
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

  Widget _buildApiExamDetail(ExamTimetableModel item) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.assignment, color: Colors.blue[700], size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.className} - ${item.examTypeLabel}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Exam Timetable', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _showRightPanel = false;
                _selectedExam = null;
              }),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Divider(height: 32),
        _buildDetailRow('Class', item.className),
        _buildDetailRow('Exam Type', item.examTypeLabel),
        _buildDetailRow('From Date', item.fromDate),
        _buildDetailRow('To Date', item.toDate),
        const SizedBox(height: 16),
        const Text('Subject Schedule:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        ...item.schedules.map((s) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(s.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${s.date} | ${s.startTime} - ${s.endTime}\nInvigilator: ${s.invigilatorName ?? "None"}'),
            trailing: Text(s.room, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        )),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _startEditExam(item),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Exam'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 45),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  void _startEditExam(ExamTimetableModel item) {
    setState(() {
      _selectedExam = item;
      _isEditing = true;
      _isAddingNew = false;
      _showRightPanel = true;

      _examClass = item.className;
      _examType = item.examType;
      _examFromDate = item.fromDate;
      _examToDate = item.toDate;
      _examSchedules.clear();
      _examSchedules.addAll(item.schedules);
    });
  }

  Widget _buildExamFormPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(_isEditing ? 'Edit Timetable' : 'Create Timetable', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
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
                    schoolController.selectedSchoolType.value?.schoolName ?? 'No school selected',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _examClass,
            hint: const Text('Select Class'),
            icon: const Icon(Icons.keyboard_arrow_down),
            decoration: _imageInputDecoration(icon: Icons.class_),
            items: _classesList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _examClass = val),
          ),
          const SizedBox(height: 16),

          const Text('Exam Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _examType,
            hint: const Text('Select Exam Type'),
            icon: const Icon(Icons.keyboard_arrow_down),
            decoration: _imageInputDecoration(icon: Icons.assignment),
            items: _examTypesMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (val) => setState(() => _examType = val),
          ),
          const SizedBox(height: 16),

          const Text('Exam Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildEventPickerBox('From', _examFromDate, () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (picked != null) setState(() => _examFromDate = DateFormat('yyyy-MM-dd').format(picked));
              }, Icons.calendar_today)),
              const SizedBox(width: 10),
              Expanded(child: _buildEventPickerBox('To', _examToDate, () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (picked != null) setState(() => _examToDate = DateFormat('yyyy-MM-dd').format(picked));
              }, Icons.calendar_today)),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Subjects', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                    child: Text('${_examSchedules.length}', style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _showAddSubjectSheet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_examSchedules.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.playlist_add, size: 50, color: Colors.blue[100]),
                  const SizedBox(height: 12),
                  const Text('No subjects added yet', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Tap "Add" to create schedule', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          else
            ...List.generate(_examSchedules.length, (index) {
              final schedule = _examSchedules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(schedule.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${schedule.date} | ${schedule.startTime} - ${schedule.endTime}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _examSchedules.removeAt(index)),
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _showRightPanel = false;
                    _isAddingNew = false;
                    _isEditing = false;
                    _selectedExam = null;
                    _resetExamForm();
                  }),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (schoolController.selectedSchoolType.value == null) {
                      FlutterToast.warning('Please select a school first.');
                      return;
                    }
                    if (_examClass == null || _examType == null || _examFromDate.isEmpty || _examToDate.isEmpty) {
                      FlutterToast.warning('Please fill all exam details');
                      return;
                    }
                    if (_examSchedules.isEmpty) {
                      FlutterToast.warning('Please add at least one subject schedule');
                      return;
                    }

                    bool success;
                    if (_isEditing && _selectedExam != null) {
                      success = await examController.updateExam(
                        schoolId: schoolController.selectedSchoolType.value!.id!,
                        id: _selectedExam!.id,
                        className: _examClass!,
                        examType: _examType!,
                        fromDate: _examFromDate,
                        toDate: _examToDate,
                        schedules: _examSchedules,
                      );
                    } else {
                      success = await examController.addExam(
                        schoolId: schoolController.selectedSchoolType.value!.id!,
                        className: _examClass!,
                        examType: _examType!,
                        fromDate: _examFromDate,
                        toDate: _examToDate,
                        schedules: _examSchedules,
                      );
                    }

                    if (success) {
                      FlutterToast.success(_isEditing ? 'Timetable updated successfully' : 'Timetable saved successfully');
                      setState(() {
                        _showRightPanel = false;
                        _isAddingNew = false;
                        _isEditing = false;
                        _selectedExam = null;
                        _resetExamForm();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(_isEditing ? 'Update Timetable' : 'Save Timetable', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSubjectSheet() {
    // Reset Sheet State to empty
    _subSubject = null;
    _subInvigilatorId = null;
    _subDate = '';
    _subStartTime = '';
    _subEndTime = '';
    _roomController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: Color(0xFF4A55A2)),
                        SizedBox(width: 8),
                        Text('Add Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Subject Dropdown
                    const Text('SUBJECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2), letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _subSubject,
                      hint: const Text('Select Subject'),
                      decoration: _imageInputDecoration(icon: Icons.book),
                      items: ['Math', 'Science', 'English', 'History', 'Computer']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setSheetState(() => _subSubject = val),
                    ),
                    const SizedBox(height: 16),

                    // Invigilator Dropdown
                    const Text('INVIGILATOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2), letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    Obx(() {
                      return DropdownButtonFormField<int>(
                        value: _subInvigilatorId,
                        hint: const Text('Select Invigilator'),
                        decoration: _imageInputDecoration(icon: Icons.person_outline),
                        items: teacherController.teachers.map((t) {
                          return DropdownMenuItem<int>(
                            value: t.id,
                            child: Text(t.fullName),
                          );
                        }).toList(),
                        onChanged: (val) => setSheetState(() => _subInvigilatorId = val),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Date Picker
                    const Text('EXAM DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2), letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setSheetState(() => _subDate = DateFormat('yyyy-MM-dd').format(picked));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Color(0xFF4A55A2)),
                            const SizedBox(width: 10),
                            // Shows "Select Date" if empty
                            Text(
                              _subDate.isEmpty ? 'Select Date' : _subDate,
                              style: TextStyle(
                                fontWeight: _subDate.isEmpty ? FontWeight.normal : FontWeight.bold,
                                color: _subDate.isEmpty ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Pickers
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('START TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2), letterSpacing: 1.2)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                  if (picked != null) {
                                    setSheetState(() => _subStartTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00");
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 18, color: Color(0xFF4A55A2)),
                                      const SizedBox(width: 10),
                                      // Shows "Select Time" if empty
                                      Text(
                                        _subStartTime.isEmpty ? 'Select Time' : _subStartTime,
                                        style: TextStyle(
                                          fontWeight: _subStartTime.isEmpty ? FontWeight.normal : FontWeight.bold,
                                          color: _subStartTime.isEmpty ? Colors.grey : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('END TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2), letterSpacing: 1.2)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                  if (picked != null) {
                                    setSheetState(() => _subEndTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00");
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 18, color: Color(0xFF4A55A2)),
                                      const SizedBox(width: 10),
                                      // Shows "Select Time" if empty
                                      Text(
                                        _subEndTime.isEmpty ? 'Select Time' : _subEndTime,
                                        style: TextStyle(
                                          fontWeight: _subEndTime.isEmpty ? FontWeight.normal : FontWeight.bold,
                                          color: _subEndTime.isEmpty ? Colors.grey : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Room
                    const Text('ROOM / HALL (OPTIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2), letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _roomController,
                      decoration: _imageInputDecoration(icon: Icons.business).copyWith(hintText: 'Room / Hall'),
                    ),
                    const SizedBox(height: 24),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Validation: Prevent empty submission
                          if (_subSubject == null || _subDate.isEmpty || _subStartTime.isEmpty || _subEndTime.isEmpty) {
                            FlutterToast.warning('Please fill all subject details');
                            return;
                          }

                          // Validation: Check if End Time > Start Time
                          if (_subEndTime.compareTo(_subStartTime) <= 0) {
                            FlutterToast.warning('End time must be after start time');
                            return;
                          }

                          setState(() {
                            _examSchedules.add(SubjectScheduleModel(
                              subject: _subSubject!,
                              invigilatorId: _subInvigilatorId,
                              date: _subDate,
                              startTime: _subStartTime,
                              endTime: _subEndTime,
                              room: _roomController.text.trim(),
                            ));
                          });
                          Navigator.pop(context); // Close Bottom Sheet
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Add Subject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A55A2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}