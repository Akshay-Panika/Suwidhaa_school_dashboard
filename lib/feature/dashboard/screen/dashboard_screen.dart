import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ============ ENUMS ============
enum SchoolFilter { all, schoolA, schoolB }
enum QuickStatType { students, teachers, requests, attendance }

// ============ MAIN SCREEN ============
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ============ STATE ============
  SchoolFilter _currentSchoolFilter = SchoolFilter.all;
  bool _showRightPanel = false;
  Map<String, dynamic>? _selectedActivity;
  int _selectedTabIndex = 0;
  QuickStatType _selectedStatType = QuickStatType.requests;
  String _selectedClassFilter = 'All';

  // ============ SAMPLE DATA ============
  final List<Map<String, dynamic>> _students = [
    // School A Students
    {
      'id': 'S001',
      'name': 'Aarav Sharma',
      'class': 'LKG',
      'school': 'School A',
      'status': 'Present',
    },
    {
      'id': 'S002',
      'name': 'Ishita Singh',
      'class': 'LKG',
      'school': 'School A',
      'status': 'Present',
    },
    {
      'id': 'S003',
      'name': 'Arjun Mehta',
      'class': 'UKG',
      'school': 'School A',
      'status': 'Absent',
    },
    {
      'id': 'S004',
      'name': 'Kavya Nair',
      'class': '1st',
      'school': 'School A',
      'status': 'Present',
    },
    {
      'id': 'S005',
      'name': 'Rohan Verma',
      'class': '2nd',
      'school': 'School A',
      'status': 'Leave',
    },
    // School B Students
    {
      'id': 'S006',
      'name': 'Priya Patel',
      'class': 'LKG',
      'school': 'School B',
      'status': 'Present',
    },
    {
      'id': 'S007',
      'name': 'Anjali Gupta',
      'class': '3rd',
      'school': 'School B',
      'status': 'Absent',
    },
    {
      'id': 'S008',
      'name': 'Vikram Kumar',
      'class': '1st',
      'school': 'School B',
      'status': 'Present',
    },
    {
      'id': 'S009',
      'name': 'Neha Reddy',
      'class': '2nd',
      'school': 'School B',
      'status': 'Leave',
    },
    {
      'id': 'S010',
      'name': 'Amit Singh',
      'class': '4th',
      'school': 'School B',
      'status': 'Present',
    },
  ];

  final List<Map<String, dynamic>> _teachers = [
    // School A Teachers
    {
      'id': 'T001',
      'name': 'Dr. Priya Sharma',
      'subject': 'Science',
      'school': 'School A',
      'status': 'Active',
    },
    {
      'id': 'T002',
      'name': 'Mr. Suresh Kumar',
      'subject': 'Mathematics',
      'school': 'School A',
      'status': 'Active',
    },
    {
      'id': 'T003',
      'name': 'Mrs. Meera Singh',
      'subject': 'English',
      'school': 'School A',
      'status': 'On Leave',
    },
    // School B Teachers
    {
      'id': 'T004',
      'name': 'Dr. Anil Gupta',
      'subject': 'Physics',
      'school': 'School B',
      'status': 'Active',
    },
    {
      'id': 'T005',
      'name': 'Mrs. Kavya Reddy',
      'subject': 'Chemistry',
      'school': 'School B',
      'status': 'Active',
    },
    {
      'id': 'T006',
      'name': 'Mr. Rajesh Nair',
      'subject': 'Biology',
      'school': 'School B',
      'status': 'Inactive',
    },
  ];

  final List<Map<String, dynamic>> _liveRequests = [
    {
      'id': 'R001',
      'title': 'Classroom Maintenance',
      'school': 'School A',
      'type': 'Maintenance',
      'status': 'Pending',
      'time': '2 min ago',
      'priority': 'High',
      'description': 'AC not working in Class 10-A',
    },
    {
      'id': 'R002',
      'title': 'New Student Admission',
      'school': 'School A',
      'type': 'Admission',
      'status': 'In Progress',
      'time': '15 min ago',
      'priority': 'Medium',
      'description': 'Admission request for Class LKG',
    },
    {
      'id': 'R003',
      'title': 'Teacher Leave Request',
      'school': 'School B',
      'type': 'Leave',
      'status': 'Pending',
      'time': '1 hour ago',
      'priority': 'High',
      'description': 'Medical leave for Dr. Anil Gupta',
    },
    {
      'id': 'R004',
      'title': 'Fee Payment Query',
      'school': 'School B',
      'type': 'Fee',
      'status': 'Resolved',
      'time': '2 hours ago',
      'priority': 'Low',
      'description': 'Payment receipt not generated',
    },
    {
      'id': 'R005',
      'title': 'Sports Equipment Request',
      'school': 'School B',
      'type': 'Sports',
      'status': 'Pending',
      'time': '3 hours ago',
      'priority': 'Medium',
      'description': 'New cricket kit required',
    },
    {
      'id': 'R006',
      'title': 'Parent Meeting Request',
      'school': 'School A',
      'type': 'Meeting',
      'status': 'In Progress',
      'time': '5 hours ago',
      'priority': 'High',
      'description': 'Request from parents of Class 10-A',
    },
  ];

  final List<Map<String, dynamic>> _notices = [
    {
      'id': 'N001',
      'title': '📢 Holiday Notice',
      'description': 'School will remain closed on December 25 for Christmas',
      'date': 'Dec 25, 2024',
      'school': 'School A',
      'type': 'Holiday',
    },
    {
      'id': 'N002',
      'title': '📝 Exam Schedule',
      'description': 'Final examinations will start from January 15, 2025',
      'date': 'Jan 15, 2025',
      'school': 'School A',
      'type': 'Exam',
    },
    {
      'id': 'N003',
      'title': '🏆 Sports Day',
      'description': 'Annual sports day scheduled on January 10, 2025',
      'date': 'Jan 10, 2025',
      'school': 'School B',
      'type': 'Sports',
    },
    {
      'id': 'N004',
      'title': '📚 Book Fair',
      'description': 'Book fair will be held on December 28-30, 2024',
      'date': 'Dec 28, 2024',
      'school': 'School B',
      'type': 'Event',
    },
  ];

  // ============ GETTERS ============
  List<Map<String, dynamic>> get _filteredStudents {
    var list = _students;
    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      list = list.where((s) => s['school'] == 'School A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      list = list.where((s) => s['school'] == 'School B').toList();
    }
    return list;
  }

  List<Map<String, dynamic>> get _filteredTeachers {
    var list = _teachers;
    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      list = list.where((t) => t['school'] == 'School A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      list = list.where((t) => t['school'] == 'School B').toList();
    }
    return list;
  }

  List<Map<String, dynamic>> get _filteredRequests {
    var list = _liveRequests;
    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      list = list.where((r) => r['school'] == 'School A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      list = list.where((r) => r['school'] == 'School B').toList();
    }
    return list;
  }

  List<Map<String, dynamic>> get _filteredNotices {
    var list = _notices;
    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      list = list.where((n) => n['school'] == 'School A').toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      list = list.where((n) => n['school'] == 'School B').toList();
    }
    return list;
  }

  int get _totalStudents => _filteredStudents.length;
  int get _presentStudents =>
      _filteredStudents.where((s) => s['status'] == 'Present').length;
  int get _absentStudents =>
      _filteredStudents.where((s) => s['status'] == 'Absent').length;
  int get _leaveStudents =>
      _filteredStudents.where((s) => s['status'] == 'Leave').length;
  int get _activeTeachers =>
      _filteredTeachers.where((t) => t['status'] == 'Active').length;
  int get _pendingRequests =>
      _filteredRequests.where((r) => r['status'] == 'Pending').length;

  // Get unique classes from filtered students
  List<String> get _classList {
    final classes = _filteredStudents.map((s) => s['class'] as String).toSet().toList();
    classes.sort();
    return ['All', ...classes];
  }

  // Get class-wise student count
  Map<String, int> get _classWiseCount {
    final Map<String, int> count = {};
    for (var student in _filteredStudents) {
      final className = student['class'] as String;
      count[className] = (count[className] ?? 0) + 1;
    }
    return count;
  }

  // Get filtered students by class
  List<Map<String, dynamic>> get _studentsByClass {
    if (_selectedClassFilter == 'All') {
      return _filteredStudents;
    }
    return _filteredStudents.where((s) => s['class'] == _selectedClassFilter).toList();
  }

  Map<String, dynamic> _getAttendanceStats() {
    final total = _totalStudents;
    if (total == 0)
      return {'present': 0, 'absent': 0, 'leave': 0, 'percentage': 0};
    return {
      'present': _presentStudents,
      'absent': _absentStudents,
      'leave': _leaveStudents,
      'percentage': ((_presentStudents / total) * 100).round(),
      'total': total,
    };
  }

  // ============ HELPERS ============
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
      case 'Active':
      case 'Resolved':
      case 'Paid':
        return Colors.green;
      case 'Absent':
      case 'Inactive':
      case 'Pending':
        return Colors.red;
      case 'Leave':
      case 'On Leave':
      case 'Partial':
      case 'In Progress':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getSchoolColor(String school) {
    switch (school) {
      case 'School A':
        return Colors.blue;
      case 'School B':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
    final attendance = _getAttendanceStats();

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              spreadRadius: 1,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Panel - Main Content
            Expanded(
              flex: _showRightPanel ? 5 : 8,
              child: Column(
                children: [
                  _buildHeader(attendance),
                  const SizedBox(height: 12),
                  _buildFilterBar(),
                  const SizedBox(height: 12),
                  _buildTabs(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildQuickStats(attendance),
                          const SizedBox(height: 16),
                          _buildAttendanceOverview(attendance),
                          const SizedBox(height: 16),
                          _buildNoticeBoard(),
                        ],
                      ),
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
                  left: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: _showRightPanel
                  ? (_selectedActivity != null
                  ? _buildDetailPanel()
                  : _buildRightPanelContent())
                  : _buildLiveRequestsPanel(),
            ),
          ],
        ),
      ),
    );
  }

  // ============ RIGHT PANEL CONTENT ============
  Widget _buildRightPanelContent() {
    switch (_selectedStatType) {
      case QuickStatType.students:
        return _buildStudentListPanel();
      case QuickStatType.teachers:
        return _buildTeacherListPanel();
      case QuickStatType.attendance:
        return _buildAttendanceDetailPanel();
      case QuickStatType.requests:
      default:
        return _buildLiveRequestsPanel();
    }
  }

  // ============ STUDENT LIST PANEL WITH CLASS FILTER ============
  Widget _buildStudentListPanel() {
    final students = _studentsByClass;
    final classCount = _classWiseCount;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student List',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${students.length} students • ${_presentStudents} present',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showRightPanel = false;
                    _selectedStatType = QuickStatType.requests;
                    _selectedActivity = null;
                    _selectedClassFilter = 'All';
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey[600]),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Class Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _classList.map((className) {
                final isSelected = _selectedClassFilter == className;
                final count = className == 'All'
                    ? _filteredStudents.length
                    : (classCount[className] ?? 0);

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedClassFilter = className;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (className != 'All')
                            Icon(
                              Icons.class_,
                              size: 14,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                          if (className != 'All') const SizedBox(width: 4),
                          Text(
                            '$className ($count)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Student List
          Expanded(
            child: students.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No students found in $_selectedClassFilter',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final statusColor = _getStatusColor(student['status']);
                final schoolColor = _getSchoolColor(student['school']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: schoolColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            student['name'][0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: schoolColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['name'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Class ${student['class']}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: schoolColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    student['school'],
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: schoolColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              student['status'] == 'Present'
                                  ? Icons.check_circle
                                  : student['status'] == 'Absent'
                                  ? Icons.cancel
                                  : Icons.beach_access,
                              size: 10,
                              color: statusColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              student['status'],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============ TEACHER LIST PANEL ============
  Widget _buildTeacherListPanel() {
    final teachers = _filteredTeachers;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school,
                  color: Colors.orange[700],
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Teacher List',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${teachers.length} teachers • $_activeTeachers active',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showRightPanel = false;
                    _selectedStatType = QuickStatType.requests;
                    _selectedActivity = null;
                    _selectedClassFilter = 'All';
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey[600]),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: teachers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No teachers found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];
                final statusColor = _getStatusColor(teacher['status']);
                final schoolColor = _getSchoolColor(teacher['school']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: schoolColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            teacher['name'][0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: schoolColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher['name'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    teacher['subject'],
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: schoolColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    teacher['school'],
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: schoolColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              teacher['status'] == 'Active'
                                  ? Icons.check_circle
                                  : teacher['status'] == 'Inactive'
                                  ? Icons.cancel
                                  : Icons.pending,
                              size: 10,
                              color: statusColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              teacher['status'],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============ ATTENDANCE DETAIL PANEL ============
  Widget _buildAttendanceDetailPanel() {
    final attendance = _getAttendanceStats();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.timeline,
                  color: Colors.purple[700],
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${attendance['total']} students • ${attendance['percentage']}% present',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showRightPanel = false;
                    _selectedStatType = QuickStatType.requests;
                    _selectedActivity = null;
                    _selectedClassFilter = 'All';
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey[600]),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildAttendanceSummaryCard(
                'Present',
                '${attendance['present']}',
                Colors.green,
                Icons.check_circle,
              ),
              const SizedBox(width: 8),
              _buildAttendanceSummaryCard(
                'Absent',
                '${attendance['absent']}',
                Colors.red,
                Icons.cancel,
              ),
              const SizedBox(width: 8),
              _buildAttendanceSummaryCard(
                'Leave',
                '${attendance['leave']}',
                Colors.orange,
                Icons.beach_access,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Student-wise Attendance',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredStudents.isEmpty
                ? Center(
              child: Text(
                'No students found',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
                : ListView.builder(
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                final student = _filteredStudents[index];
                final statusColor = _getStatusColor(student['status']);
                final schoolColor = _getSchoolColor(student['school']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: schoolColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            student['name'][0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: schoolColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['name'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Class ${student['class']} • ${student['school']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              student['status'] == 'Present'
                                  ? Icons.check_circle
                                  : student['status'] == 'Absent'
                                  ? Icons.cancel
                                  : Icons.beach_access,
                              size: 10,
                              color: statusColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              student['status'],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummaryCard(
      String label,
      String value,
      Color color,
      IconData icon,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
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
      ),
    );
  }

  // ============ HEADER ============
  Widget _buildHeader(Map<String, dynamic> attendance) {
    final schoolLabel = _currentSchoolFilter == SchoolFilter.all
        ? 'All Schools'
        : _currentSchoolFilter == SchoolFilter.schoolA
        ? 'School A'
        : 'School B';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
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
                  Icons.dashboard,
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
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
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
                    '${attendance['total']} students • ${_activeTeachers} active teachers',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // School Filter Dropdown - SINGLE FILTER
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        _showRightPanel = false;
                        _selectedActivity = null;
                        _selectedStatType = QuickStatType.requests;
                        _selectedClassFilter = 'All';
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_showRightPanel)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _selectedActivity = null;
                      _selectedStatType = QuickStatType.requests;
                      _selectedClassFilter = 'All';
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

  // ============ FILTER BAR - NO DUPLICATE ============
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          // Quick Stats - Clickable
          _buildQuickStatChip(
            icon: Icons.people,
            label: 'Students',
            count: _totalStudents,
            color: Colors.blue,
            type: QuickStatType.students,
          ),
          const SizedBox(width: 8),
          _buildQuickStatChip(
            icon: Icons.school,
            label: 'Teachers',
            count: _activeTeachers,
            color: Colors.orange,
            type: QuickStatType.teachers,
          ),
          const SizedBox(width: 8),
          _buildQuickStatChip(
            icon: Icons.notifications_active,
            label: 'Requests',
            count: _pendingRequests,
            color: Colors.red,
            type: QuickStatType.requests,
          ),
          const Spacer(),
          // Attendance Rate
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 14, color: Colors.purple[600]),
                const SizedBox(width: 4),
                Text(
                  '${_getAttendanceStats()['percentage']}% Attendance',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required QuickStatType type,
  }) {
    final isSelected = _selectedStatType == type && _showRightPanel;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatType = type;
          _showRightPanel = true;
          _selectedActivity = null;
          _selectedClassFilter = 'All';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? color : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              '$count $label',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ TABS ============
  Widget _buildTabs() {
    final tabs = [
      {'label': '📊 Overview'},
      {'label': '👨‍🏫 Teachers'},
      {'label': '🎓 Students'},
      {'label': '📌 Requests'},
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                  _showRightPanel = false;
                  _selectedActivity = null;
                  _selectedStatType = QuickStatType.requests;
                  _selectedClassFilter = 'All';
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    tab['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? Colors.blue[700] : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============ QUICK STATS ============
  Widget _buildQuickStats(Map<String, dynamic> attendance) {
    final stats = [
      {
        'label': 'Total Students',
        'value': '${attendance['total']}',
        'change': '+12%',
        'color': Colors.blue,
        'type': QuickStatType.students,
        'icon': Icons.people,
      },
      {
        'label': 'Present Today',
        'value': '${attendance['present']}',
        'change': '+8%',
        'color': Colors.green,
        'type': QuickStatType.attendance,
        'icon': Icons.check_circle,
      },
      {
        'label': 'Active Teachers',
        'value': '$_activeTeachers',
        'change': '+5%',
        'color': Colors.orange,
        'type': QuickStatType.teachers,
        'icon': Icons.school,
      },
      {
        'label': 'Attendance Rate',
        'value': '${attendance['percentage']}%',
        'change': '+3%',
        'color': Colors.purple,
        'type': QuickStatType.attendance,
        'icon': Icons.timeline,
      },
    ];

    return Row(
      children: stats
          .map(
            (stat) => Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatType = stat['type'] as QuickStatType;
                _showRightPanel = true;
                _selectedActivity = null;
                _selectedClassFilter = 'All';
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[100]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: (stat['color'] as Color)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              stat['icon'] as IconData,
                              size: 14,
                              color: stat['color'] as Color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            stat['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (stat['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 10,
                              color: stat['color'] as Color,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              stat['change'] as String,
                              style: TextStyle(
                                fontSize: 9,
                                color: stat['color'] as Color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (stat['value'] as String).contains('%')
                        ? double.parse(
                      (stat['value'] as String).replaceAll('%', ''),
                    ) /
                        100
                        : 0.75,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      stat['color'] as Color,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  // ============ ATTENDANCE OVERVIEW ============
  Widget _buildAttendanceOverview(Map<String, dynamic> attendance) {
    final data = [
      {
        'label': 'Present',
        'value': attendance['present'],
        'color': Colors.green,
      },
      {'label': 'Absent', 'value': attendance['absent'], 'color': Colors.red},
      {'label': 'Leave', 'value': attendance['leave'], 'color': Colors.orange},
    ];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatType = QuickStatType.attendance;
          _showRightPanel = true;
          _selectedActivity = null;
          _selectedClassFilter = 'All';
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Overview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  'Tap to view details →',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.purple[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            value: attendance['percentage'] / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey[100],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${attendance['percentage']}%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            Text(
                              'Attendance',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: data
                        .map(
                          (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: item['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Text(
                              '${item['value']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============ NOTICE BOARD ============
  Widget _buildNoticeBoard() {
    final notices = _filteredNotices;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📢 Notice Board',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (notices.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No notices available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.5,
              children: notices.map((notice) {
                final color = _getSchoolColor(notice['school']);
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.1)),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedActivity = notice;
                        _showRightPanel = true;
                        _selectedStatType = QuickStatType.requests;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 20,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                notice['title'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                notice['school'],
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 11),
                          child: Text(
                            notice['description'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ============ LIVE REQUESTS PANEL ============
  Widget _buildLiveRequestsPanel() {
    final requests = _filteredRequests;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: Colors.red[700],
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live Requests',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${requests.length} pending requests',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: requests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No pending requests',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final priorityColor = _getStatusColor(
                  request['priority'],
                );
                final statusColor = _getStatusColor(request['status']);
                final schoolColor = _getSchoolColor(request['school']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: request['status'] == 'Pending'
                        ? Colors.red[50]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: request['status'] == 'Pending'
                          ? Colors.red[200]!
                          : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedActivity = request;
                        _showRightPanel = true;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: schoolColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                request['school'],
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: schoolColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                request['priority'],
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: priorityColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                request['status'],
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              request['time'],
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          request['title'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          request['description'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.label_outline,
                              size: 12,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              request['type'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============ DETAIL PANEL ============
  Widget _buildDetailPanel() {
    if (_selectedActivity == null) return const SizedBox();

    final activity = _selectedActivity!;
    final isRequest = activity.containsKey('priority');
    final isNotice =
        activity.containsKey('description') &&
            !activity.containsKey('priority');

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      isRequest ? Icons.notifications : Icons.announcement,
                      color: Colors.blue[700],
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isRequest ? 'Request Details' : 'Notice Details',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showRightPanel = false;
                    _selectedActivity = null;
                    _selectedStatType = QuickStatType.requests;
                    _selectedClassFilter = 'All';
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey[600]),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('ID', activity['id']),
                  _buildDetailRow('Title', activity['title']),
                  _buildDetailRow('School', activity['school'] ?? 'N/A'),
                  if (isRequest) ...[
                    _buildDetailRow('Type', activity['type']),
                    _buildDetailRow(
                      'Priority',
                      activity['priority'],
                      color: _getStatusColor(activity['priority']),
                    ),
                    _buildDetailRow(
                      'Status',
                      activity['status'],
                      color: _getStatusColor(activity['status']),
                    ),
                    _buildDetailRow('Time', activity['time']),
                    _buildDetailRow('Description', activity['description']),
                  ],
                  if (isNotice) ...[
                    _buildDetailRow('Date', activity['date'] ?? 'N/A'),
                    _buildDetailRow('Type', activity['type'] ?? 'General'),
                    _buildDetailRow('Description', activity['description']),
                  ],
                  const SizedBox(height: 20),
                  if (isRequest)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
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
              style: TextStyle(fontSize: 13, color: color ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}