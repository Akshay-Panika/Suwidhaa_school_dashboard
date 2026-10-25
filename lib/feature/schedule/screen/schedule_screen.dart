import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Modules ki list
  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Notice Board',
      'subtitle': 'View and manage notices',
      'icon': Icons.notifications_active,
      'color': Colors.orange,
    },
    {
      'title': 'Events',
      'subtitle': 'School events and activities',
      'icon': Icons.event,
      'color': Colors.purple,
    },
    {
      'title': 'Meetings',
      'subtitle': 'Staff and parent meetings',
      'icon': Icons.groups,
      'color': Colors.indigo,
    },
    {
      'title': 'Exams',
      'subtitle': 'Exam schedules and results',
      'icon': Icons.assignment,
      'color': Colors.red,
    },
  ];

  // ✅ Selected Module track karne ke liye state variable
  Map<String, dynamic>? _selectedModule;

  @override
  Widget build(BuildContext context) {
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
            // ==========================================
            // LEFT PANEL: Modules Grid
            // ==========================================
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 cards per row
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.8, // Adjust card shape
                        ),
                        itemCount: _modules.length,
                        itemBuilder: (context, index) {
                          return _buildModuleCard(_modules[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // RIGHT PANEL: Selected Module Details
            // ==========================================
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
              // ✅ Right panel conditional rendering
              child: _selectedModule == null
                  ? _buildEmptyRightPanel()
                  : _buildSelectedRightPanel(_selectedModule!),
            ),
          ],
        ),
      ),
    );
  }

  // ============ HEADER ============
  Widget _buildHeader() {
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
                  Icons.dashboard,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard & Modules',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${_modules.length} modules available',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ MODULE CARD ============
  Widget _buildModuleCard(Map<String, dynamic> module) {
    // ✅ Check karo ki ye card selected hai ya nahi
    final isSelected = _selectedModule?['title'] == module['title'];

    return InkWell(
      onTap: () {
        // ✅ Click karne par state update karo
        setState(() {
          _selectedModule = module;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color: isSelected ? module['color'].withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // ✅ Agar selected hai toh colored border, warna grey
            color: isSelected ? module['color'] : Colors.grey[200]!,
            width: isSelected ? 1: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: module['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                module['icon'],
                color: module['color'],
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              module['title'],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                // ✅ Selected hone par text color change
                color: isSelected ? module['color'] : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              module['subtitle'],
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ============ RIGHT PANEL: EMPTY STATE ============
  Widget _buildEmptyRightPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_customize, size: 80, color: Colors.blue[100]),
          const SizedBox(height: 16),
          Text(
            'Select a module to view details',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ============ RIGHT PANEL: SELECTED STATE ============
  Widget _buildSelectedRightPanel(Map<String, dynamic> module) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header of Right Panel
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
            ),
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: module['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      module['icon'],
                      color: module['color'],
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: module['color'],
                        ),
                      ),
                      Text(
                        module['subtitle'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ✅ Close Button Action Updated
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedModule = null;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.grey),
                tooltip: 'Close Panel',
              ),
            ],
          ),
        ),

        // Body of Right Panel (Future Content)
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction,
                  size: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  '${module['title']} content will be displayed here.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}