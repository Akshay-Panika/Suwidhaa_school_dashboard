// lib/feature/dashboard/screen/dashboard_screen.dart
import 'package:flutter/material.dart';

import '../../main/model/school_type_model.dart';
import '../../main/widget/school_type_filter_widget.dart';

// ============ ENUMS ============
enum QuickStatType { requests, attendance }

// ============ MAIN SCREEN ============
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ============ STATE ============
  SchoolTypeModel? _selectedSchool; // null = All Schools
  bool _showRightPanel = false;
  Map<String, dynamic>? _selectedActivity;
  int _selectedTabIndex = 0;
  QuickStatType _selectedStatType = QuickStatType.requests;

  // ============ DUMMY DATA FOR REQUESTS & NOTICES ============
  // Note: We are using the exact school names returned by your API.
  final List<Map<String, dynamic>> _liveRequests = [
    {
      'id': 'R001',
      'title': 'Classroom Maintenance',
      'school': 'Suwidhaa Senior Secondary School',
      'type': 'Maintenance',
      'status': 'Pending',
      'time': '2 min ago',
      'priority': 'High',
      'description': 'AC not working in Class 10-A',
    },
    {
      'id': 'R002',
      'title': 'New Student Admission',
      'school': 'Suwidhaa Senior Secondary School',
      'type': 'Admission',
      'status': 'In Progress',
      'time': '15 min ago',
      'priority': 'Medium',
      'description': 'Admission request for Class LKG',
    },
    {
      'id': 'R003',
      'title': 'Teacher Leave Request',
      'school': 'Suwidhaa Little Scholars School',
      'type': 'Leave',
      'status': 'Pending',
      'time': '1 hour ago',
      'priority': 'High',
      'description': 'Medical leave for Dr. Anil Gupta',
    },
    {
      'id': 'R004',
      'title': 'Fee Payment Query',
      'school': 'Suwidhaa Little Scholars School',
      'type': 'Fee',
      'status': 'Resolved',
      'time': '2 hours ago',
      'priority': 'Low',
      'description': 'Payment receipt not generated',
    },
    {
      'id': 'R005',
      'title': 'Sports Equipment Request',
      'school': 'Suwidhaa Little Scholars School',
      'type': 'Sports',
      'status': 'Pending',
      'time': '3 hours ago',
      'priority': 'Medium',
      'description': 'New cricket kit required',
    },
    {
      'id': 'R006',
      'title': 'Parent Meeting Request',
      'school': 'Suwidhaa Senior Secondary School',
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
      'school': 'Suwidhaa Senior Secondary School',
      'type': 'Holiday',
    },
    {
      'id': 'N002',
      'title': '📝 Exam Schedule',
      'description': 'Final examinations will start from January 15, 2025',
      'date': 'Jan 15, 2025',
      'school': 'Suwidhaa Senior Secondary School',
      'type': 'Exam',
    },
    {
      'id': 'N003',
      'title': '🏆 Sports Day',
      'description': 'Annual sports day scheduled on January 10, 2025',
      'date': 'Jan 10, 2025',
      'school': 'Suwidhaa Little Scholars School',
      'type': 'Sports',
    },
    {
      'id': 'N004',
      'title': '📚 Book Fair',
      'description': 'Book fair will be held on December 28-30, 2024',
      'date': 'Dec 28, 2024',
      'school': 'Suwidhaa Little Scholars School',
      'type': 'Event',
    },
  ];

  // ============ SCHOOL MATCHING ============
  bool _matchesSchool(String schoolLabel) {
    if (_selectedSchool == null) return true;
    return schoolLabel == _selectedSchool!.schoolName ||
        schoolLabel == _selectedSchool!.schoolCode;
  }

  // ============ FILTERED GETTERS ============
  List<Map<String, dynamic>> get _filteredRequests =>
      _liveRequests.where((r) => _matchesSchool(r['school'])).toList();

  List<Map<String, dynamic>> get _filteredNotices =>
      _notices.where((n) => _matchesSchool(n['school'])).toList();

  // Dummy attendance stats for overview card (since student data is removed)
  Map<String, dynamic> _getAttendanceStats() {
    return {
      'present': 0,
      'absent': 0,
      'leave': 0,
      'percentage': 0,
      'total': 0,
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

  // Dynamic color based on the school name
  Color _getSchoolColor(String school) {
    if (school.contains('Senior')) return Colors.blue;
    if (school.contains('Little')) return Colors.green;
    return Colors.grey;
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // ❌ _buildQuickStats removed from here
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
      case QuickStatType.attendance:
        return _buildAttendanceDetailPanel();
      case QuickStatType.requests:
      default:
        return _buildLiveRequestsPanel();
    }
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
                child:
                Icon(Icons.timeline, color: Colors.purple[700], size: 18),
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
              _buildAttendanceSummaryCard('Present', '${attendance['present']}',
                  Colors.green, Icons.check_circle),
              const SizedBox(width: 8),
              _buildAttendanceSummaryCard('Absent', '${attendance['absent']}',
                  Colors.red, Icons.cancel),
              const SizedBox(width: 8),
              _buildAttendanceSummaryCard('Leave', '${attendance['leave']}',
                  Colors.orange, Icons.beach_access),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Student-wise Attendance',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text('No data available',
                  style: TextStyle(color: Colors.grey[500])),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummaryCard(
      String label, String value, Color color, IconData icon) {
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
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // ============ HEADER ============
  Widget _buildHeader(Map<String, dynamic> attendance) {
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
                child: Icon(Icons.dashboard,
                    color: Colors.purple[700], size: 20),
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
                    ],
                  ),
                  Text(
                    'School Overview',
                    style: TextStyle(fontSize: 12, color: Colors.grey[900]),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              SchoolTypeFilterWidget(
                compact: true,
                value: _selectedSchool,
                onChanged: (school) {
                  setState(() {
                    _selectedSchool = school;
                    _showRightPanel = false;
                    _selectedActivity = null;
                    _selectedStatType = QuickStatType.requests;
                  });
                },
              ),
              const SizedBox(width: 12),
              if (_showRightPanel)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _selectedActivity = null;
                      _selectedStatType = QuickStatType.requests;
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
                            value: (attendance['percentage'] as int) / 100,
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
                                  fontSize: 10, color: Colors.grey[500]),
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
                                    color: Colors.grey[600]),
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
                child: Text('No notices available',
                    style: TextStyle(color: Colors.grey)),
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
                                  horizontal: 6, vertical: 2),
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
                                fontSize: 10, color: Colors.grey[500]),
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
                child: Icon(Icons.notifications_active,
                    color: Colors.red[700], size: 18),
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
                  Icon(Icons.check_circle_outline,
                      size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No pending requests',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            )
                : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final priorityColor =
                _getStatusColor(request['priority']);
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
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: schoolColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  request['school'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: schoolColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
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
                                  horizontal: 6, vertical: 2),
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
                                  color: Colors.grey[400]),
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
                              fontSize: 11, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.label_outline,
                                size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              request['type'],
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400]),
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
    final isNotice = activity.containsKey('description') &&
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