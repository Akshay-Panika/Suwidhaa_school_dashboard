import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color(0xFFF0F2F5),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Quick Stats Row
              _buildQuickStats(),
              const SizedBox(height: 24),

              // Charts & Overview Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildAttendanceOverview(),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: _buildQuickActions(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Activity & Events Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildRecentActivity(),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: _buildUpcomingEvents(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notice Board
              _buildNoticeBoard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }



  // ============ QUICK STATS ============
  Widget _buildQuickStats() {
    final stats = [
      {'label': 'Total Students', 'value': '1,248', 'change': '+12%', 'color': const Color(0xFF4CAF50)},
      {'label': 'Total Teachers', 'value': '64', 'change': '+5%', 'color': const Color(0xFF2196F3)},
      {'label': 'Total Classes', 'value': '32', 'change': '+8%', 'color': const Color(0xFFFF9800)},
      {'label': 'Passing Rate', 'value': '92%', 'change': '+3%', 'color': const Color(0xFF9C27B0)},
    ];

    return Row(
      children: stats.map((stat) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
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
                  Text(
                    stat['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          size: 12,
                          color: stat['color'] as Color,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          stat['change'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: stat['color'] as Color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                stat['value'] as String,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: 0.75,
                backgroundColor: Colors.grey[100],
                valueColor: AlwaysStoppedAnimation<Color>(stat['color'] as Color),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  // ============ ATTENDANCE OVERVIEW ============
  Widget _buildAttendanceOverview() {
    final attendanceData = [
      {'label': 'Present', 'value': 85, 'color': const Color(0xFF4CAF50)},
      {'label': 'Absent', 'value': 10, 'color': const Color(0xFFF44336)},
      {'label': 'Leave', 'value': 5, 'color': const Color(0xFFFF9800)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
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
                  fontSize: 16,
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
                  'View Details',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: CircularProgressIndicator(
                          value: 0.85,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[100],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '85%',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            'Attendance',
                            style: TextStyle(
                              fontSize: 11,
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
                  children: attendanceData.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Text(
                          '${item['value']}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ QUICK ACTIONS ============
  Widget _buildQuickActions() {
    final actions = [
      {'label': 'Add Student', 'icon': Icons.person_add, 'color': Colors.blue},
      {'label': 'Add Exam', 'icon': Icons.add_chart, 'color': Colors.green},
      {'label': 'Send Notice', 'icon': Icons.message, 'color': Colors.orange},
      {'label': 'Manage Fees', 'icon': Icons.attach_money, 'color': Colors.purple},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [(action['color'] as Color).withOpacity(0.08), Colors.white],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (action['color'] as Color).withOpacity(0.1),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 20,
                ),
              ),
              title: Text(
                action['label'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 14,
              ),
              onTap: () {},
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )).toList(),
        ],
      ),
    );
  }

  // ============ RECENT ACTIVITY ============
  Widget _buildRecentActivity() {
    final activities = [
      {'title': 'New student enrolled', 'time': '2 min ago', 'icon': Icons.person_add, 'color': Colors.blue},
      {'title': 'Exam results published', 'time': '1 hour ago', 'icon': Icons.grading, 'color': Colors.green},
      {'title': 'Teacher meeting scheduled', 'time': '3 hours ago', 'icon': Icons.meeting_room, 'color': Colors.orange},
      {'title': 'Fee payment received', 'time': '5 hours ago', 'icon': Icons.payment, 'color': Colors.purple},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
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
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
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
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activities.map((activity) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: activity['color'] as Color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['title'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        activity['time'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // ============ UPCOMING EVENTS ============
  Widget _buildUpcomingEvents() {
    final events = [
      {'title': 'Exam Week', 'date': 'Dec 15-20', 'color': Colors.blue},
      {'title': 'Parent Meeting', 'date': 'Dec 22', 'color': Colors.green},
      {'title': 'Graduation', 'date': 'Dec 30', 'color': Colors.orange},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
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
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 16,
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
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...events.map((event) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [(event['color'] as Color).withOpacity(0.08), Colors.white],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (event['color'] as Color).withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: event['color'] as Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        event['date'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // ============ NOTICE BOARD ============
  Widget _buildNoticeBoard() {
    final notices = [
      {'title': '📢 Holiday Notice', 'desc': 'School will remain closed on December 25', 'color': Colors.red},
      {'title': '📝 Exam Schedule', 'desc': 'Final examinations will start from January 15', 'color': Colors.blue},
      {'title': '🏆 Sports Day', 'desc': 'Annual sports day scheduled on January 10', 'color': Colors.green},
      {'title': '📚 Book Fair', 'desc': 'Book fair will be held on December 28-30', 'color': Colors.orange},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
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
                'Notice Board',
                style: TextStyle(
                  fontSize: 16,
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
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 6,
            children: notices.map((notice) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [(notice['color'] as Color).withOpacity(0.08), Colors.white],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (notice['color'] as Color).withOpacity(0.1),
                ),
              ),
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
                          color: notice['color'] as Color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notice['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: notice['color'] as Color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 11),
                    child: Text(
                      notice['desc'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}