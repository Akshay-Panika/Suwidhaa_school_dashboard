import 'package:flutter/material.dart';
import 'package:suwidhaa_school_dashboard/feature/classes/screen/classes_screen.dart';
import 'package:suwidhaa_school_dashboard/feature/frees/screen/free_screen.dart';
import 'package:suwidhaa_school_dashboard/feature/messages/screen/message_screen.dart';
import 'package:suwidhaa_school_dashboard/feature/schedule/screen/schedule_screen.dart';
import 'package:suwidhaa_school_dashboard/feature/settings/screen/setting_screen.dart';
import 'package:suwidhaa_school_dashboard/feature/subjects/screen/subject_screen.dart';
import 'package:suwidhaa_school_dashboard/feature/teachers/screen/teachers_screen.dart';

import '../../auth/screen/auth_screen.dart';
import '../../auth/service/auth_pref.dart';
import '../../dashboard/screen/dashboard_screen.dart';
import '../../student/screen/student_screen.dart';
import '../../transport/screen/transport_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: Row(
        children: [
          /// Sidebar Menu
          Container(
            width: 220,
            color: Colors.white,
            child: Column(
              children: [
                // Logo/Header
                Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.school,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ST CHAINA ACADEMY",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Management",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(height: 1),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildMenuItem(
                        icon: Icons.dashboard,
                        title: "Dashboard",
                        isActive: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      _buildMenuItem(
                        icon: Icons.people,
                        title: "Students",
                        isActive: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      _buildMenuItem(
                        icon: Icons.person,
                        title: "Teachers",
                        isActive: _selectedIndex == 2,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      _buildMenuItem(
                        icon: Icons.class_,
                        title: "Classes",
                        isActive: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                      _buildMenuItem(
                        icon: Icons.book,
                        title: "Subjects",
                        isActive: _selectedIndex == 4,
                        onTap: () => setState(() => _selectedIndex = 4),
                      ),
                      _buildMenuItem(
                        icon: Icons.calendar_today,
                        title: "Schedule",
                        isActive: _selectedIndex == 5,
                        onTap: () => setState(() => _selectedIndex = 5),
                      ),

                      // ✅ Transport ko index 6 par rakha gaya hai
                      _buildMenuItem(
                        icon: Icons.directions_bus,
                        title: "Transport",
                        isActive: _selectedIndex == 6,
                        onTap: () => setState(() => _selectedIndex = 6),
                      ),

                      _buildMenuItem(
                        icon: Icons.attach_money,
                        title: "Fees",
                        isActive: _selectedIndex == 7,
                        onTap: () => setState(() => _selectedIndex = 7),
                      ),
                      _buildMenuItem(
                        icon: Icons.message,
                        title: "Messages",
                        isActive: _selectedIndex == 8,
                        onTap: () => setState(() => _selectedIndex = 8),
                      ),
                      _buildMenuItem(
                        icon: Icons.settings,
                        title: "Settings",
                        isActive: _selectedIndex == 9,
                        onTap: () => setState(() => _selectedIndex = 9),
                      ),

                      SizedBox(height: 20),

                      // Logout
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: "Logout",
                        color: Colors.red,
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Dashboard Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Welcome Section
                Container(
                  margin: EdgeInsets.only(bottom: 0, left: 20, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back, Admin! 👋",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Here's what's happening with your school today",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Switch Logic
                Expanded(
                  child: _buildScreen(_selectedIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Switch logic to return the appropriate screen
  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return DashboardScreen();
      case 1:
        return StudentScreen();
      case 2:
        return TeachersScreen();
      case 3:
        return ClassesScreen();
      case 4:
        return SubjectScreen();
      case 5:
        return ScheduleScreen();
      case 6:
        return TransportScreen(); // ✅ Transport Index 6
      case 7:
        return FeeScreen();       // ✅ Fees Index 7
      case 8:
        return MessageScreen();   // ✅ Messages Index 8
      case 9:
        return SettingScreen();   // ✅ Settings Index 9
      default:
        return DashboardScreen();
    }
  }

  // Sidebar Menu Item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isActive = false,
    Color? color,
  }) {
    return Material(
      color: isActive ? Colors.blue[50] : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.blue[700] : (color ?? Colors.grey[600]),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.blue[700] : (color ?? Colors.grey[700]),
          ),
        ),
        onTap: onTap,
        tileColor: isActive ? Colors.blue[50] : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Clear session using AuthPref
              await AuthPref.clearSession();

              // Navigate back to AuthScreen
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}