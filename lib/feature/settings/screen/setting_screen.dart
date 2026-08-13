import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // Notification Settings
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool smsNotifications = true;
  bool attendanceAlerts = true;
  bool examAlerts = true;
  bool feeAlerts = false;

  // General Settings
  String selectedTheme = 'Light';
  String selectedLanguage = 'English';
  String selectedCurrency = '₹ INR';
  String selectedTimeZone = 'IST (UTC+5:30)';

  // School Settings
  String academicYear = '2024-2025';
  String schoolName = 'Sunrise School';
  String schoolEmail = 'info@sunriseschool.com';
  String schoolPhone = '+91 98765 43210';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar - Admin Navigation
          Container(
            width: 220,
            color: Colors.white,
            child: Column(
              children: [
                // Admin Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/seed/admin/200/200',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Admin User",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Super Admin",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildNavItem(
                        icon: Icons.dashboard,
                        title: "Dashboard",
                        isActive: false,
                        onTap: () {},
                      ),
                      _buildNavItem(
                        icon: Icons.settings,
                        title: "Settings",
                        isActive: true,
                        onTap: () {},
                      ),
                      _buildNavItem(
                        icon: Icons.person,
                        title: "Profile",
                        isActive: false,
                        onTap: () {},
                      ),
                      _buildNavItem(
                        icon: Icons.security,
                        title: "Security",
                        isActive: false,
                        onTap: () {},
                      ),
                      _buildNavItem(
                        icon: Icons.notifications,
                        title: "Notifications",
                        isActive: false,
                        onTap: () {},
                      ),
                      _buildNavItem(
                        icon: Icons.backup,
                        title: "Backup",
                        isActive: false,
                        onTap: () {},
                      ),
                      _buildNavItem(
                        icon: Icons.analytics,
                        title: "Analytics",
                        isActive: false,
                        onTap: () {},
                      ),
                      _buildNavItem(
                        icon: Icons.help,
                        title: "Help & Support",
                        isActive: false,
                        onTap: () {},
                      ),

                      SizedBox(height: 20),
                      Divider(height: 1),
                      SizedBox(height: 10),

                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Content - Settings
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Settings",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Manage your school settings and preferences",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.save, size: 18),
                            label: Text("Save Changes"),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.refresh, size: 18),
                            label: Text("Reset All"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // General Settings Card
                  _buildSettingsCard(
                    title: "General Settings",
                    icon: Icons.settings,
                    children: [
                      _buildSettingRow(
                        label: "School Name",
                        value: schoolName,
                        icon: Icons.school,
                        onTap: () {
                          _showEditDialog(context, "School Name", schoolName, (value) {
                            setState(() {
                              schoolName = value;
                            });
                          });
                        },
                      ),
                      _buildSettingRow(
                        label: "School Email",
                        value: schoolEmail,
                        icon: Icons.email,
                        onTap: () {
                          _showEditDialog(context, "School Email", schoolEmail, (value) {
                            setState(() {
                              schoolEmail = value;
                            });
                          });
                        },
                      ),
                      _buildSettingRow(
                        label: "School Phone",
                        value: schoolPhone,
                        icon: Icons.phone,
                        onTap: () {
                          _showEditDialog(context, "School Phone", schoolPhone, (value) {
                            setState(() {
                              schoolPhone = value;
                            });
                          });
                        },
                      ),
                      _buildDropdownRow(
                        label: "Language",
                        value: selectedLanguage,
                        icon: Icons.language,
                        items: ['English', 'Hindi', 'Spanish', 'French'],
                        onChanged: (value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),
                      _buildDropdownRow(
                        label: "Theme",
                        value: selectedTheme,
                        icon: Icons.color_lens,
                        items: ['Light', 'Dark', 'System'],
                        onChanged: (value) {
                          setState(() {
                            selectedTheme = value;
                          });
                        },
                      ),
                      _buildDropdownRow(
                        label: "Currency",
                        value: selectedCurrency,
                        icon: Icons.attach_money,
                        items: ['₹ INR', ' USD', '€ EUR', '£ GBP'],
                        onChanged: (value) {
                          setState(() {
                            selectedCurrency = value;
                          });
                        },
                      ),
                      _buildDropdownRow(
                        label: "Time Zone",
                        value: selectedTimeZone,
                        icon: Icons.access_time,
                        items: ['IST (UTC+5:30)', 'EST (UTC-5:00)', 'GMT (UTC+0:00)', 'PST (UTC-8:00)'],
                        onChanged: (value) {
                          setState(() {
                            selectedTimeZone = value;
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Academic Settings Card
                  _buildSettingsCard(
                    title: "Academic Settings",
                    icon: Icons.school,
                    children: [
                      _buildSettingRow(
                        label: "Academic Year",
                        value: academicYear,
                        icon: Icons.calendar_today,
                        onTap: () {
                          _showEditDialog(context, "Academic Year", academicYear, (value) {
                            setState(() {
                              academicYear = value;
                            });
                          });
                        },
                      ),
                      _buildSettingRow(
                        label: "Term Start Date",
                        value: "Jan 15, 2024",
                        icon: Icons.play_arrow,
                        onTap: () {},
                      ),
                      _buildSettingRow(
                        label: "Term End Date",
                        value: "Dec 20, 2024",
                        icon: Icons.stop,
                        onTap: () {},
                      ),
                      _buildSwitchRow(
                        label: "Enable Online Admissions",
                        value: true,
                        icon: Icons.how_to_reg,
                        onChanged: (value) {},
                      ),
                      _buildSwitchRow(
                        label: "Enable Exam Module",
                        value: true,
                        icon: Icons.assignment,
                        onChanged: (value) {},
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Notification Settings Card
                  _buildSettingsCard(
                    title: "Notification Settings",
                    icon: Icons.notifications,
                    children: [
                      _buildSwitchRow(
                        label: "Push Notifications",
                        subtitle: "Receive push notifications on mobile",
                        value: pushNotifications,
                        icon: Icons.notifications_active,
                        onChanged: (value) {
                          setState(() {
                            pushNotifications = value;
                          });
                        },
                      ),
                      _buildSwitchRow(
                        label: "Email Notifications",
                        subtitle: "Receive notifications via email",
                        value: emailNotifications,
                        icon: Icons.email,
                        onChanged: (value) {
                          setState(() {
                            emailNotifications = value;
                          });
                        },
                      ),
                      _buildSwitchRow(
                        label: "SMS Notifications",
                        subtitle: "Receive SMS alerts",
                        value: smsNotifications,
                        icon: Icons.sms,
                        onChanged: (value) {
                          setState(() {
                            smsNotifications = value;
                          });
                        },
                      ),
                      _buildSwitchRow(
                        label: "Attendance Alerts",
                        subtitle: "Get alerts for student attendance",
                        value: attendanceAlerts,
                        icon: Icons.check_circle,
                        onChanged: (value) {
                          setState(() {
                            attendanceAlerts = value;
                          });
                        },
                      ),
                      _buildSwitchRow(
                        label: "Exam Alerts",
                        subtitle: "Get notifications about exams",
                        value: examAlerts,
                        icon: Icons.grading,
                        onChanged: (value) {
                          setState(() {
                            examAlerts = value;
                          });
                        },
                      ),
                      _buildSwitchRow(
                        label: "Fee Reminders",
                        subtitle: "Get reminders for fee payments",
                        value: feeAlerts,
                        icon: Icons.attach_money,
                        onChanged: (value) {
                          setState(() {
                            feeAlerts = value;
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Security Settings Card
                  _buildSettingsCard(
                    title: "Security Settings",
                    icon: Icons.security,
                    children: [
                      _buildSettingRow(
                        label: "Two-Factor Authentication",
                        value: "Enabled",
                        icon: Icons.shield,
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {},
                          activeColor: Colors.blue[700],
                        ),
                        onTap: () {},
                      ),
                      _buildSettingRow(
                        label: "Last Password Change",
                        value: "30 days ago",
                        icon: Icons.lock,
                        onTap: () {},
                      ),
                      _buildSettingRow(
                        label: "Active Sessions",
                        value: "2 devices",
                        icon: Icons.devices,
                        onTap: () {},
                      ),
                      _buildSettingRow(
                        label: "Change Password",
                        value: "",
                        icon: Icons.password,
                        trailing: OutlinedButton(
                          onPressed: () {
                            _showChangePasswordDialog(context);
                          },
                          child: Text("Change", style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Data Management Card
                  _buildSettingsCard(
                    title: "Data Management",
                    icon: Icons.data_usage,
                    children: [
                      _buildDataActionRow(
                        icon: Icons.backup,
                        title: "Backup Data",
                        subtitle: "Create a backup of all school data",
                        buttonText: "Backup Now",
                        buttonColor: Colors.blue,
                        onTap: () {
                          _showSnackbar(context, "Backup started...", Colors.blue);
                        },
                      ),
                      _buildDataActionRow(
                        icon: Icons.restore,
                        title: "Restore Data",
                        subtitle: "Restore data from backup",
                        buttonText: "Restore",
                        buttonColor: Colors.orange,
                        onTap: () {
                          _showSnackbar(context, "Restore initiated...", Colors.orange);
                        },
                      ),
                      _buildDataActionRow(
                        icon: Icons.analytics,
                        title: "Export Reports",
                        subtitle: "Generate and export reports",
                        buttonText: "Export",
                        buttonColor: Colors.purple,
                        onTap: () {},
                      ),
                      _buildDataActionRow(
                        icon: Icons.clear_all,
                        title: "Clear Cache",
                        subtitle: "Clear temporary data",
                        buttonText: "Clear",
                        buttonColor: Colors.red,
                        onTap: () {
                          _showSnackbar(context, "Cache cleared", Colors.green);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Support Card
                  _buildSettingsCard(
                    title: "Support & About",
                    icon: Icons.support,
                    children: [
                      _buildSupportRow(
                        icon: Icons.help,
                        title: "Help Center",
                        subtitle: "Find answers to common questions",
                        onTap: () {},
                      ),
                      _buildSupportRow(
                        icon: Icons.feedback,
                        title: "Send Feedback",
                        subtitle: "Help us improve",
                        onTap: () {
                          _showFeedbackDialog(context);
                        },
                      ),
                      _buildSupportRow(
                        icon: Icons.info,
                        title: "About",
                        subtitle: "Version 1.0.0",
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "v1.0.0",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation Item
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? Border.all(color: Colors.blue[200]!) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.blue[700] : (color ?? Colors.grey[600]),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.blue[700] : (color ?? Colors.grey[700]),
          ),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }

  // Settings Card
  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: Colors.blue[700], size: 18),
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          // Card Body
          ...children,
        ],
      ),
    );
  }

  // Setting Row (Editable)
  Widget _buildSettingRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[100]!),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 18),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }

  // Dropdown Row
  Widget _buildDropdownRow({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: value,
              icon: Icon(Icons.arrow_drop_down, size: 18),
              underline: SizedBox(),
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Switch Row
  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[700],
          ),
        ],
      ),
    );
  }

  // Data Action Row
  Widget _buildDataActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: buttonColor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // Support Row
  Widget _buildSupportRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[100]!),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue[700], size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }

  // Edit Dialog
  void _showEditDialog(BuildContext context, String label, String initialValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $label", style: TextStyle(fontSize: 18)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              _showSnackbar(context, "$label updated successfully", Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: Text("Save", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Change Password Dialog
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Password", style: TextStyle(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm New Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar(context, "Password changed successfully", Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: Text("Update Password", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Feedback Dialog
  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Send Feedback", style: TextStyle(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar(context, "Feedback sent successfully", Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: Text("Send", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // About Dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("About", style: TextStyle(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 64, color: Colors.blue[700]),
            SizedBox(height: 12),
            Text(
              "School Management System",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Version 1.0.0",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "A comprehensive school management solution for administrators, teachers, and students.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "© 2024 School Management System",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 13)),
        backgroundColor: color,
        duration: Duration(seconds: 1),
      ),
    );
  }
}