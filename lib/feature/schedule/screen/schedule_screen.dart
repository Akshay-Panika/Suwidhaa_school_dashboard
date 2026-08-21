import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

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

// ============ MODEL ============
class ScheduleModel {
  final String id;
  final String title;
  final String description;
  final ScheduleType type;
  final DateTime startDate;
  final DateTime endDate;
  final String time;
  final String location;
  final Color color;
  final IconData icon;
  final String? attachment;
  final String? bannerImage;
  final String? pdfFile; // New field for PDF
  final List<String>? assignedClasses;
  final List<String>? assignedTeachers;
  final String? eventType;
  final String? examType;
  final String? otherType;
  final String? guestSpeaker;
  final String? expectedAttendees;
  final String? subjects;
  final String? examDuration;
  final String? organizer;
  final String? contactPerson;
  final String? eventDescription;
  final String? examInstructions;
  final String? otherNotes;
  final String school;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.location,
    required this.color,
    required this.icon,
    this.attachment,
    this.bannerImage,
    this.pdfFile,
    this.assignedClasses,
    this.assignedTeachers,
    this.eventType,
    this.examType,
    this.otherType,
    this.guestSpeaker,
    this.expectedAttendees,
    this.subjects,
    this.examDuration,
    this.organizer,
    this.contactPerson,
    this.eventDescription,
    this.examInstructions,
    this.otherNotes,
    this.school = 'School A',
  });

  String get typeDisplay {
    switch (type) {
      case ScheduleType.event:
        return 'Event';
      case ScheduleType.exam:
        return 'Exam';
      case ScheduleType.other:
        return 'Other';
    }
  }

  String get daysRemaining {
    final difference = startDate.difference(DateTime.now());
    return difference.inDays.toString();
  }
}

// ============ MAIN SCREEN ============
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<ScheduleModel> schedules = [];
  ScheduleFilter _currentFilter = ScheduleFilter.all;
  SchoolFilter _currentSchoolFilter = SchoolFilter.all;
  String _searchQuery = '';
  bool _showRightPanel = false;
  ScheduleModel? _selectedSchedule;
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
  final _examTypeController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _examDurationController = TextEditingController();
  final _examInstructionsController = TextEditingController();
  final _otherTypeController = TextEditingController();
  final _organizerController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _otherNotesController = TextEditingController();

  ScheduleType _selectedType = ScheduleType.event;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  Color _selectedColor = Colors.blue;
  String _selectedSchoolForm = 'School A';
  List<String> _selectedClasses = [];
  List<String> _selectedTeachers = [];
  File? _bannerImage;
  String? _bannerImagePath;
  File? _pdfFile;
  String? _pdfFilePath;

  final List<String> _classList = ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'];
  final List<String> _teacherList = ['Mr. John', 'Ms. Sarah', 'Dr. Smith', 'Mrs. Brown'];
  final List<String> _schoolList = ['School A', 'School B'];

  final List<Color> _colors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange,
    Colors.purple, Colors.teal, Colors.pink, Colors.amber,
  ];

  final List<IconData> _icons = [
    Icons.event, Icons.sports, Icons.science, Icons.music_note,
    Icons.school, Icons.book, Icons.people, Icons.circle,
  ];

  IconData _selectedIcon = Icons.event;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
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
    _examTypeController.dispose();
    _subjectsController.dispose();
    _examDurationController.dispose();
    _examInstructionsController.dispose();
    _otherTypeController.dispose();
    _organizerController.dispose();
    _contactPersonController.dispose();
    _otherNotesController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    schedules = [
      // School A Schedules
      ScheduleModel(
        id: '1',
        title: 'Annual Sports Day',
        description: 'School annual sports competition with various events including track, field, and team games',
        type: ScheduleType.event,
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        time: '9:00 AM - 4:00 PM',
        location: 'School Ground',
        color: Colors.blue,
        icon: Icons.sports,
        school: 'School A',
        eventType: 'Sports Event',
        guestSpeaker: 'Mr. Sports Coach',
        expectedAttendees: '500+ Students',
        eventDescription: 'Students will participate in various sports activities',
        assignedClasses: ['Class 1', 'Class 2', 'Class 3'],
        assignedTeachers: ['Mr. John', 'Ms. Sarah'],
        bannerImage: null,
        pdfFile: null,
      ),
      ScheduleModel(
        id: '2',
        title: 'Mid Term Exam',
        description: 'Mid term examination for all classes covering all subjects',
        type: ScheduleType.exam,
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        time: '8:00 AM - 12:00 PM',
        location: 'School Classrooms',
        color: Colors.red,
        icon: Icons.school,
        school: 'School A',
        examType: 'Mid Term',
        subjects: 'All Subjects',
        examDuration: '3 Hours',
        examInstructions: 'Bring your own stationery. No electronic devices allowed.',
        assignedClasses: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'],
        assignedTeachers: ['Dr. Smith', 'Mrs. Brown'],
        bannerImage: null,
        pdfFile: null,
      ),
      ScheduleModel(
        id: '3',
        title: 'Parent-Teacher Meeting',
        description: 'Quarterly parent-teacher meeting to discuss student progress',
        type: ScheduleType.other,
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        time: '10:00 AM - 2:00 PM',
        location: 'School Auditorium',
        color: Colors.green,
        icon: Icons.people,
        school: 'School A',
        otherType: 'Meeting',
        organizer: 'School Administration',
        contactPerson: 'Principal Office',
        otherNotes: 'All parents must attend. Report cards will be distributed.',
        assignedClasses: ['All Classes'],
        assignedTeachers: ['All Teachers'],
        bannerImage: null,
        pdfFile: null,
      ),
      ScheduleModel(
        id: '4',
        title: 'Science Fair 2026',
        description: 'Annual science exhibition by students showcasing their projects',
        type: ScheduleType.event,
        startDate: DateTime.now().add(const Duration(days: 12)),
        endDate: DateTime.now().add(const Duration(days: 13)),
        time: '9:00 AM - 5:00 PM',
        location: 'Science Lab & Hall',
        color: Colors.purple,
        icon: Icons.science,
        school: 'School A',
        eventType: 'Exhibition',
        guestSpeaker: 'Dr. Science Expert',
        expectedAttendees: '300+ Students',
        eventDescription: 'Students will display their science projects',
        assignedClasses: ['Class 3', 'Class 4', 'Class 5'],
        assignedTeachers: ['Mr. John', 'Dr. Smith'],
        bannerImage: null,
        pdfFile: null,
      ),
      // School B Schedules
      ScheduleModel(
        id: '5',
        title: 'Final Exam Time Table',
        description: 'Final examination schedule for all classes with subject details',
        type: ScheduleType.exam,
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 45)),
        time: '8:00 AM - 1:00 PM',
        location: 'All Classrooms',
        color: Colors.orange,
        icon: Icons.calendar_today,
        school: 'School B',
        examType: 'Final',
        subjects: 'All Subjects',
        examDuration: '3 Hours',
        examInstructions: 'Bring your own stationery. No electronic devices allowed.',
        assignedClasses: ['All Classes'],
        assignedTeachers: ['All Teachers'],
        bannerImage: null,
        pdfFile: null,
      ),
      ScheduleModel(
        id: '6',
        title: 'Teachers Training Workshop',
        description: 'Professional development workshop for teachers on modern teaching methods',
        type: ScheduleType.other,
        startDate: DateTime.now().add(const Duration(days: 8)),
        endDate: DateTime.now().add(const Duration(days: 9)),
        time: '9:00 AM - 4:00 PM',
        location: 'Conference Room',
        color: Colors.teal,
        icon: Icons.circle,
        school: 'School B',
        otherType: 'Workshop',
        organizer: 'HR Department',
        contactPerson: 'Training Coordinator',
        otherNotes: 'All teachers must attend. Certificate will be provided.',
        assignedTeachers: ['All Teachers'],
        bannerImage: null,
        pdfFile: null,
      ),
      ScheduleModel(
        id: '7',
        title: 'Annual Cultural Fest',
        description: 'Cultural festival with music, dance, and art competitions',
        type: ScheduleType.event,
        startDate: DateTime.now().add(const Duration(days: 20)),
        endDate: DateTime.now().add(const Duration(days: 22)),
        time: '10:00 AM - 8:00 PM',
        location: 'School Auditorium',
        color: Colors.pink,
        icon: Icons.music_note,
        school: 'School B',
        eventType: 'Cultural Event',
        guestSpeaker: 'Chief Guest',
        expectedAttendees: '1000+ People',
        eventDescription: 'Cultural performances, competitions, and prize distribution',
        assignedClasses: ['All Classes'],
        assignedTeachers: ['Ms. Sarah', 'Mrs. Brown'],
        bannerImage: null,
        pdfFile: null,
      ),
    ];
  }

  List<ScheduleModel> get _filteredSchedules {
    var filtered = schedules;

    // School Filter
    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      filtered = filtered.where((schedule) => schedule.school == 'School A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      filtered = filtered.where((schedule) => schedule.school == 'School B').toList();
    }

    // Type Filter
    if (_currentFilter != ScheduleFilter.all) {
      filtered = filtered.where((schedule) {
        if (_currentFilter == ScheduleFilter.event) {
          return schedule.type == ScheduleType.event;
        } else if (_currentFilter == ScheduleFilter.exam) {
          return schedule.type == ScheduleType.exam;
        } else {
          return schedule.type == ScheduleType.other;
        }
      }).toList();
    }

    // Search Filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((schedule) =>
      schedule.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          schedule.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          schedule.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          schedule.school.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  int get _totalEvents => schedules.where((s) => s.type == ScheduleType.event).length;
  int get _totalExams => schedules.where((s) => s.type == ScheduleType.exam).length;
  int get _totalOthers => schedules.where((s) => s.type == ScheduleType.other).length;

  Map<String, int> get _schoolWiseStats {
    Map<String, int> stats = {};
    for (var schedule in schedules) {
      stats[schedule.school] = (stats[schedule.school] ?? 0) + 1;
    }
    return stats;
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _timeController.clear();
    _eventTypeController.clear();
    _guestSpeakerController.clear();
    _expectedAttendeesController.clear();
    _eventDescriptionController.clear();
    _examTypeController.clear();
    _subjectsController.clear();
    _examDurationController.clear();
    _examInstructionsController.clear();
    _otherTypeController.clear();
    _organizerController.clear();
    _contactPersonController.clear();
    _otherNotesController.clear();
    _selectedType = ScheduleType.event;
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));
    _selectedColor = Colors.blue;
    _selectedIcon = Icons.event;
    _selectedSchoolForm = 'School A';
    _selectedClasses = [];
    _selectedTeachers = [];
    _bannerImage = null;
    _bannerImagePath = null;
    _pdfFile = null;
    _pdfFilePath = null;
  }

  void _loadScheduleToForm(ScheduleModel schedule) {
    _titleController.text = schedule.title;
    _descriptionController.text = schedule.description;
    _locationController.text = schedule.location;
    _timeController.text = schedule.time;
    _selectedType = schedule.type;
    _startDate = schedule.startDate;
    _endDate = schedule.endDate;
    _selectedColor = schedule.color;
    _selectedIcon = schedule.icon;
    _selectedSchoolForm = schedule.school;
    _selectedClasses = schedule.assignedClasses ?? [];
    _selectedTeachers = schedule.assignedTeachers ?? [];
    _bannerImagePath = schedule.bannerImage;
    _pdfFilePath = schedule.pdfFile;

    if (schedule.type == ScheduleType.event) {
      _eventTypeController.text = schedule.eventType ?? '';
      _guestSpeakerController.text = schedule.guestSpeaker ?? '';
      _expectedAttendeesController.text = schedule.expectedAttendees ?? '';
      _eventDescriptionController.text = schedule.eventDescription ?? '';
    } else if (schedule.type == ScheduleType.exam) {
      _examTypeController.text = schedule.examType ?? '';
      _subjectsController.text = schedule.subjects ?? '';
      _examDurationController.text = schedule.examDuration ?? '';
      _examInstructionsController.text = schedule.examInstructions ?? '';
    } else {
      _otherTypeController.text = schedule.otherType ?? '';
      _organizerController.text = schedule.organizer ?? '';
      _contactPersonController.text = schedule.contactPerson ?? '';
      _otherNotesController.text = schedule.otherNotes ?? '';
    }
  }

  ScheduleModel _createScheduleFromForm(String id) {
    return ScheduleModel(
      id: id,
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      time: _timeController.text,
      location: _locationController.text,
      color: _selectedColor,
      icon: _selectedIcon,
      school: _selectedSchoolForm,
      bannerImage: _bannerImagePath,
      pdfFile: _pdfFilePath,
      assignedClasses: _selectedType != ScheduleType.event ? _selectedClasses : null,
      assignedTeachers: _selectedTeachers.isNotEmpty ? _selectedTeachers : null,
      eventType: _selectedType == ScheduleType.event ? _eventTypeController.text : null,
      guestSpeaker: _selectedType == ScheduleType.event ? _guestSpeakerController.text : null,
      expectedAttendees: _selectedType == ScheduleType.event ? _expectedAttendeesController.text : null,
      eventDescription: _selectedType == ScheduleType.event ? _eventDescriptionController.text : null,
      examType: _selectedType == ScheduleType.exam ? _examTypeController.text : null,
      subjects: _selectedType == ScheduleType.exam ? _subjectsController.text : null,
      examDuration: _selectedType == ScheduleType.exam ? _examDurationController.text : null,
      examInstructions: _selectedType == ScheduleType.exam ? _examInstructionsController.text : null,
      otherType: _selectedType == ScheduleType.other ? _otherTypeController.text : null,
      organizer: _selectedType == ScheduleType.other ? _organizerController.text : null,
      contactPerson: _selectedType == ScheduleType.other ? _contactPersonController.text : null,
      otherNotes: _selectedType == ScheduleType.other ? _otherNotesController.text : null,
    );
  }

  // ============ BANNER IMAGE PICKER USING FILE_PICKER ============
  Future<void> _pickBannerImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Check if file size is reasonable (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          _showSnackbar('Image size too large. Please select an image under 5MB.', Colors.orange);
          return;
        }
        String? filePath = file.path;
        if (filePath != null) {
          setState(() {
            _bannerImage = File(filePath);
            _bannerImagePath = filePath;
          });
          _showSnackbar('Banner image uploaded successfully!', Colors.green);
        } else {
          _showSnackbar('Failed to get image file path', Colors.red);
        }
      }
    } catch (e) {
      _showSnackbar('Error picking image: ${e.toString()}', Colors.red);
    }
  }

  void _removeBannerImage() {
    setState(() {
      _bannerImage = null;
      _bannerImagePath = null;
    });
  }

  // ============ PDF PICKER USING FILE_PICKER ============
  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Check if file size is reasonable (max 10MB)
        if (file.size > 10 * 1024 * 1024) {
          _showSnackbar('PDF size too large. Please select a PDF under 10MB.', Colors.orange);
          return;
        }
        String? filePath = file.path;
        if (filePath != null) {
          setState(() {
            _pdfFile = File(filePath);
            _pdfFilePath = filePath;
          });
          _showSnackbar('PDF uploaded: ${file.name}', Colors.green);
        } else {
          _showSnackbar('Failed to get PDF file path', Colors.red);
        }
      }
    } catch (e) {
      _showSnackbar('Error selecting PDF: ${e.toString()}', Colors.red);
    }
  }

  void _removePDF() {
    setState(() {
      _pdfFile = null;
      _pdfFilePath = null;
    });
  }

  // ============ SNACKBAR HELPER ============
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

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
            // Left Panel - Schedule List
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

            // Right Panel - View/Edit/Add or Empty State
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
              '📊 ${schedules.length} Total Schedules',
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
                  _selectedSchedule = null;
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
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 20),
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
                        _selectedSchedule = null;
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
                      _selectedSchedule = null;
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
                      _selectedSchedule = null;
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

  Color _getSchoolColor(String school) {
    switch (school) {
      case 'School A': return Colors.blue;
      case 'School B': return Colors.green;
      default: return Colors.grey;
    }
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
  Widget _buildScheduleCard(ScheduleModel schedule) {
    final isSelected = _selectedSchedule?.id == schedule.id;
    final schoolColor = _getSchoolColor(schedule.school);

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
              color: schedule.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              schedule.icon,
              color: schedule.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedSchedule = schedule;
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
                          color: schedule.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          schedule.typeDisplay,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: schedule.color,
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
                      _buildInfoText(Icons.school, schedule.school, color: schoolColor),
                      _buildInfoText(Icons.calendar_today,
                          '${schedule.startDate.day}/${schedule.startDate.month}/${schedule.startDate.year}'),
                      _buildInfoText(Icons.access_time, schedule.time),
                      _buildInfoText(Icons.location_on, schedule.location),
                    ],
                  ),
                  // Show PDF indicator if attached
                  if (schedule.pdfFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _buildInfoText(
                        Icons.picture_as_pdf,
                        'PDF Attached',
                        color: Colors.red,
                      ),
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
                    _loadScheduleToForm(schedule);
                    setState(() {
                      _selectedSchedule = schedule;
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
                  onPressed: () => _deleteSchedule(schedule.id),
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
                _selectedSchedule = null;
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
    if (_selectedSchedule == null) return const SizedBox();

    final schedule = _selectedSchedule!;
    final schoolColor = _getSchoolColor(schedule.school);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          if (schedule.bannerImage != null)
            Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(schedule.bannerImage!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: schedule.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  schedule.icon,
                  color: schedule.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.title,
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
                                schedule.school,
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
                            color: schedule.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            schedule.typeDisplay,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: schedule.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(schedule),
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

          _buildDetailRow('🏫 School', schedule.school, color: schoolColor, isBold: true),
          _buildDetailRow('📅 Date Range',
              '${schedule.startDate.day}/${schedule.startDate.month}/${schedule.startDate.year} - '
                  '${schedule.endDate.day}/${schedule.endDate.month}/${schedule.endDate.year}'),
          _buildDetailRow('⏰ Time', schedule.time),
          _buildDetailRow('📍 Location', schedule.location),
          _buildDetailRow('📝 Description', schedule.description),

          // PDF Attachment
          if (schedule.pdfFile != null)
            _buildPDFAttachment(schedule.pdfFile!),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          if (schedule.type == ScheduleType.event)
            _buildEventViewDetails(schedule),
          if (schedule.type == ScheduleType.exam)
            _buildExamViewDetails(schedule),
          if (schedule.type == ScheduleType.other)
            _buildOtherViewDetails(schedule),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Show assigned classes only for Exam and Other types
          if (schedule.type != ScheduleType.event && schedule.assignedClasses != null)
            _buildAssignedList('📚 Assigned Classes', schedule.assignedClasses!),
          if (schedule.assignedTeachers != null)
            _buildAssignedList('👨‍🏫 Assigned Teachers', schedule.assignedTeachers!),



          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _selectedSchedule = null;
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
                  onPressed: () => _deleteSchedule(schedule.id),
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

  // ============ PDF ATTACHMENT WIDGET ============
  Widget _buildPDFAttachment(String pdfPath) {
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
            IconButton(
              onPressed: () {
                _showSnackbar('PDF viewer will open here', Colors.blue);
              },
              icon: Icon(Icons.visibility, color: Colors.red[700], size: 20),
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

  Widget _buildStatusBadge(ScheduleModel schedule) {
    final isUpcoming = schedule.startDate.isAfter(DateTime.now());
    final isOngoing = schedule.startDate.isBefore(DateTime.now()) &&
        schedule.endDate.isAfter(DateTime.now());

    Color color;
    String label;

    if (isUpcoming) {
      color = Colors.green;
      label = 'Upcoming';
    } else if (isOngoing) {
      color = Colors.orange;
      label = 'Ongoing';
    } else {
      color = Colors.grey;
      label = 'Completed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
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

  // ============ VIEW TYPE SPECIFIC DETAILS ============
  Widget _buildEventViewDetails(ScheduleModel schedule) {
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
        if (schedule.eventType != null)
          _buildDetailRow('Event Type', schedule.eventType!),
        if (schedule.guestSpeaker != null)
          _buildDetailRow('Guest/Speaker', schedule.guestSpeaker!),
        if (schedule.expectedAttendees != null)
          _buildDetailRow('Expected Attendees', schedule.expectedAttendees!),
        if (schedule.eventDescription != null)
          _buildDetailRow('Description', schedule.eventDescription!),
      ],
    );
  }

  Widget _buildExamViewDetails(ScheduleModel schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 Exam Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (schedule.examType != null)
          _buildDetailRow('Exam Type', schedule.examType!),
        if (schedule.subjects != null)
          _buildDetailRow('Subjects', schedule.subjects!),
        if (schedule.examDuration != null)
          _buildDetailRow('Duration', schedule.examDuration!),
        if (schedule.examInstructions != null)
          _buildDetailRow('Instructions', schedule.examInstructions!),
      ],
    );
  }

  Widget _buildOtherViewDetails(ScheduleModel schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 Activity Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (schedule.otherType != null)
          _buildDetailRow('Activity Type', schedule.otherType!),
        if (schedule.organizer != null)
          _buildDetailRow('Organizer', schedule.organizer!),
        if (schedule.contactPerson != null)
          _buildDetailRow('Contact Person', schedule.contactPerson!),
        if (schedule.otherNotes != null)
          _buildDetailRow('Notes', schedule.otherNotes!),
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
                  onPressed: () {
                    if (_titleController.text.isEmpty) {
                      _showSnackbar('Please enter a title', Colors.red);
                      return;
                    }

                    final newSchedule = _createScheduleFromForm(
                        DateTime.now().millisecondsSinceEpoch.toString());

                    setState(() {
                      schedules.add(newSchedule);
                      _showRightPanel = false;
                      _isAddingNew = false;
                    });

                    _showSnackbar('Schedule added successfully!', Colors.green);
                  },
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
    if (_selectedSchedule == null) return const SizedBox();

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
                  onPressed: () {
                    if (_titleController.text.isEmpty) {
                      _showSnackbar('Please enter a title', Colors.red);
                      return;
                    }

                    final updatedSchedule = _createScheduleFromForm(
                        _selectedSchedule!.id);

                    final index = schedules.indexWhere(
                            (s) => s.id == _selectedSchedule!.id);
                    if (index != -1) {
                      schedules[index] = updatedSchedule;
                    }

                    setState(() {
                      _selectedSchedule = updatedSchedule;
                      _isEditing = false;
                    });

                    _showSnackbar('Schedule updated successfully!', Colors.green);
                  },
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
          children: ScheduleType.values.map((type) {
            final isSelected = _selectedType == type;
            Map<ScheduleType, Color> typeColor = {
              ScheduleType.event: Colors.blue,
              ScheduleType.exam: Colors.red,
              ScheduleType.other: Colors.green,
            };
            Map<ScheduleType, IconData> typeIcon = {
              ScheduleType.event: Icons.event,
              ScheduleType.exam: Icons.school,
              ScheduleType.other: Icons.more_horiz,
            };
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    typeIcon[type],
                    size: 14,
                    color: isSelected ? Colors.white : typeColor[type],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    type.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : typeColor[type],
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type;
                  switch (type) {
                    case ScheduleType.event:
                      _selectedIcon = Icons.event;
                      _selectedColor = Colors.blue;
                      break;
                    case ScheduleType.exam:
                      _selectedIcon = Icons.school;
                      _selectedColor = Colors.red;
                      break;
                    case ScheduleType.other:
                      _selectedIcon = Icons.more_horiz;
                      _selectedColor = Colors.green;
                      break;
                  }
                });
              },
              selectedColor: typeColor[type],
              backgroundColor: Colors.grey[100],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Common Fields
        _buildFormTextField(_titleController, 'Title', Icons.title,
            hint: 'Enter schedule title'),
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
                  _showSnackbar('End date must be after start date', Colors.red);
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

        // Type Specific Fields
        if (_selectedType == ScheduleType.event)
          _buildEventFormFields(),
        if (_selectedType == ScheduleType.exam)
          _buildExamFormFields(),
        if (_selectedType == ScheduleType.other)
          _buildOtherFormFields(),

        const SizedBox(height: 10),

        // Banner Upload Section
        _buildBannerUploadSection(),

        const SizedBox(height: 10),

        // PDF Upload Section
        _buildPDFUploadSection(),

        const SizedBox(height: 10),

        // Assign Classes - Only for Exam and Other types
        if (_selectedType != ScheduleType.event) ...[
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
        ],

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
    );
  }

  // ============ BANNER UPLOAD SECTION ============
  Widget _buildBannerUploadSection() {
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
              // Banner Preview
              if (_bannerImage != null || _bannerImagePath != null)
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    image: DecorationImage(
                      image: _bannerImage != null
                          ? FileImage(_bannerImage!)
                          : FileImage(File(_bannerImagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
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
                    ],
                  ),
                ),
              // Upload Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickBannerImage,
                        icon: Icon(
                          _bannerImage != null || _bannerImagePath != null
                              ? Icons.change_circle
                              : Icons.upload_file,
                          size: 18,
                        ),
                        label: Text(
                          _bannerImage != null || _bannerImagePath != null
                              ? 'Change Banner'
                              : 'Upload Banner',
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
                    if (_bannerImage != null || _bannerImagePath != null)
                      const SizedBox(width: 8),
                    if (_bannerImage != null || _bannerImagePath != null)
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
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Recommended: 800 x 400 pixels, JPG/PNG format (Max 5MB)',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  // ============ PDF UPLOAD SECTION ============
  Widget _buildPDFUploadSection() {
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
              // PDF Info
              if (_pdfFile != null || _pdfFilePath != null)
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
                      Icon(Icons.picture_as_pdf, color: Colors.red[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PDF Selected',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _pdfFile != null
                                  ? _pdfFile!.path.split('/').last
                                  : _pdfFilePath!.split('/').last,
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
                      IconButton(
                        onPressed: _removePDF,
                        icon: Icon(Icons.close, color: Colors.red[700], size: 20),
                      ),
                    ],
                  ),
                ),
              // Upload Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickPDF,
                        icon: Icon(
                          _pdfFile != null || _pdfFilePath != null
                              ? Icons.change_circle
                              : Icons.upload_file,
                          size: 18,
                        ),
                        label: Text(
                          _pdfFile != null || _pdfFilePath != null
                              ? 'Change PDF'
                              : 'Upload PDF',
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
                    if (_pdfFile != null || _pdfFilePath != null)
                      const SizedBox(width: 8),
                    if (_pdfFile != null || _pdfFilePath != null)
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
        const SizedBox(height: 8),
        Text(
          'Upload PDF files only (Max 10MB)',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  // ============ EVENT FORM FIELDS ============
  Widget _buildEventFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            hint: 'e.g., Sports, Cultural, Exhibition'),
        const SizedBox(height: 8),
        _buildFormTextField(_guestSpeakerController, 'Guest/Speaker', Icons.person,
            hint: 'Enter guest name'),
        const SizedBox(height: 8),
        _buildFormTextField(_expectedAttendeesController, 'Expected Attendees', Icons.people,
            hint: 'e.g., 200 Students'),
        const SizedBox(height: 8),
        _buildFormTextField(_eventDescriptionController, 'Event Description', Icons.description,
            hint: 'Additional event details', maxLines: 2),
      ],
    );
  }

  // ============ EXAM FORM FIELDS ============
  Widget _buildExamFormFields() {
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
              Icon(Icons.school, color: Colors.red[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Exam Details',
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
        _buildFormTextField(_examTypeController, 'Exam Type', Icons.category,
            hint: 'e.g., Mid Term, Final, Weekly'),
        const SizedBox(height: 8),
        _buildFormTextField(_subjectsController, 'Subjects', Icons.book,
            hint: 'e.g., Mathematics, Science, English'),
        const SizedBox(height: 8),
        _buildFormTextField(_examDurationController, 'Duration', Icons.timer,
            hint: 'e.g., 3 Hours'),
        const SizedBox(height: 8),
        _buildFormTextField(_examInstructionsController, 'Instructions', Icons.info,
            hint: 'Special instructions for students', maxLines: 2),
      ],
    );
  }

  // ============ OTHER FORM FIELDS ============
  Widget _buildOtherFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.more_horiz, color: Colors.green[700], size: 16),
              const SizedBox(width: 8),
              Text(
                'Activity Details',
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
        _buildFormTextField(_otherTypeController, 'Activity Type', Icons.category,
            hint: 'e.g., Meeting, Workshop, Seminar'),
        const SizedBox(height: 8),
        _buildFormTextField(_organizerController, 'Organizer', Icons.business,
            hint: 'Enter organizer name'),
        const SizedBox(height: 8),
        _buildFormTextField(_contactPersonController, 'Contact Person', Icons.contact_phone,
            hint: 'Enter contact person'),
        const SizedBox(height: 8),
        _buildFormTextField(_otherNotesController, 'Notes', Icons.notes,
            hint: 'Additional notes', maxLines: 2),
      ],
    );
  }

  // ============ FORM HELPERS ============
  Widget _buildFormTextField(TextEditingController controller, String label,
      IconData icon, {
        String? hint,
        int maxLines = 1,
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

  // ============ DELETE FUNCTION ============
  void _deleteSchedule(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                schedules.removeWhere((s) => s.id == id);
                if (_selectedSchedule?.id == id) {
                  _showRightPanel = false;
                  _selectedSchedule = null;
                  _isEditing = false;
                  _isAddingNew = false;
                }
              });
              Navigator.pop(context);
              _showSnackbar('Schedule deleted successfully!', Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}