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

  // School Settings
  String schoolName = 'Sunrise School';
  String schoolEmail = 'info@sunriseschool.com';
  String schoolPhone = '+91 98765 43210';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 20),

            // Row 1: General + Notifications
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSettingsCard(
                    title: "General",
                    icon: Icons.settings,
                    children: [
                      _buildSettingRow(
                        label: "School Name",
                        value: schoolName,
                        icon: Icons.school,
                        onTap: () => _showEditDialog(context, "School Name", schoolName, (value) {
                          setState(() => schoolName = value);
                        }),
                      ),
                      _buildSettingRow(
                        label: "School Email",
                        value: schoolEmail,
                        icon: Icons.email,
                        onTap: () => _showEditDialog(context, "School Email", schoolEmail, (value) {
                          setState(() => schoolEmail = value);
                        }),
                      ),
                      _buildSettingRow(
                        label: "School Phone",
                        value: schoolPhone,
                        icon: Icons.phone,
                        onTap: () => _showEditDialog(context, "School Phone", schoolPhone, (value) {
                          setState(() => schoolPhone = value);
                        }),
                      ),
                      _buildDropdownRow(
                        label: "Language",
                        value: selectedLanguage,
                        icon: Icons.language,
                        items: ['English', 'Hindi', 'Spanish', 'French'],
                        onChanged: (value) => setState(() => selectedLanguage = value),
                      ),
                      _buildDropdownRow(
                        label: "Theme",
                        value: selectedTheme,
                        icon: Icons.color_lens,
                        items: ['Light', 'Dark', 'System'],
                        onChanged: (value) => setState(() => selectedTheme = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSettingsCard(
                    title: "Notifications",
                    icon: Icons.notifications,
                    children: [
                      _buildSwitchRow(
                        label: "Push Notifications",
                        value: pushNotifications,
                        icon: Icons.notifications_active,
                        onChanged: (value) => setState(() => pushNotifications = value),
                      ),
                      _buildSwitchRow(
                        label: "Email Notifications",
                        value: emailNotifications,
                        icon: Icons.email,
                        onChanged: (value) => setState(() => emailNotifications = value),
                      ),
                      _buildSwitchRow(
                        label: "SMS Notifications",
                        value: smsNotifications,
                        icon: Icons.sms,
                        onChanged: (value) => setState(() => smsNotifications = value),
                      ),
                      _buildSwitchRow(
                        label: "Attendance Alerts",
                        value: attendanceAlerts,
                        icon: Icons.check_circle,
                        onChanged: (value) => setState(() => attendanceAlerts = value),
                      ),
                      _buildSwitchRow(
                        label: "Exam Alerts",
                        value: examAlerts,
                        icon: Icons.grading,
                        onChanged: (value) => setState(() => examAlerts = value),
                      ),
                      _buildSwitchRow(
                        label: "Fee Reminders",
                        value: feeAlerts,
                        icon: Icons.attach_money,
                        onChanged: (value) => setState(() => feeAlerts = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Row 2: Security + Data Management
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSettingsCard(
                    title: "Security",
                    icon: Icons.security,
                    children: [
                      _buildSwitchRow(
                        label: "Two-Factor Auth",
                        value: true,
                        icon: Icons.shield,
                        onChanged: (value) {},
                      ),
                      _buildSettingRow(
                        label: "Change Password",
                        value: "********",
                        icon: Icons.password,
                        trailing: _buildActionButton("Change", Colors.blue, () {
                          _showChangePasswordDialog(context);
                        }),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSettingsCard(
                    title: "Data Management",
                    icon: Icons.data_usage,
                    children: [
                      _buildActionRow(
                        icon: Icons.backup,
                        title: "Backup Data",
                        buttonText: "Backup",
                        color: Colors.blue,
                        onTap: () => _showSnackbar(context, "Backup started...", Colors.blue),
                      ),
                      _buildActionRow(
                        icon: Icons.restore,
                        title: "Restore Data",
                        buttonText: "Restore",
                        color: Colors.orange,
                        onTap: () => _showSnackbar(context, "Restore initiated...", Colors.orange),
                      ),
                      _buildActionRow(
                        icon: Icons.clear_all,
                        title: "Clear Cache",
                        buttonText: "Clear",
                        color: Colors.red,
                        onTap: () => _showSnackbar(context, "Cache cleared", Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Support Card (Full Width)
            _buildSettingsCard(
              title: "Support",
              icon: Icons.support,
              children: [
                _buildSupportRow(
                  icon: Icons.help,
                  title: "Help Center",
                  onTap: () => _showSnackbar(context, "Opening Help Center...", Colors.blue),
                ),
                _buildSupportRow(
                  icon: Icons.feedback,
                  title: "Send Feedback",
                  onTap: () => _showFeedbackDialog(context),
                ),
                _buildSupportRow(
                  icon: Icons.info,
                  title: "About",
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============ BUILDERS ============

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Manage your preferences",
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
              onPressed: () => _showSnackbar(context, "Settings saved successfully!", Colors.green),
              icon: const Icon(Icons.save, size: 18),
              label: const Text("Save"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Reset"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: Colors.blue[700], size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[100]!),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 16),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 16),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              underline: const SizedBox(),
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) onChanged(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[700],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String buttonText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildActionButton(buttonText, color, onTap),
        ],
      ),
    );
  }

  Widget _buildSupportRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[100]!),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.blue[700], size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        minimumSize: const Size(50, 28),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ============ DIALOGS ============

  void _showEditDialog(BuildContext context, String label, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: (value) {
            onSave(value);
            Navigator.pop(context);
            _showSnackbar(context, "$label updated", Colors.green);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              _showSnackbar(context, "$label updated", Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
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
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPassController.text.isEmpty || confirmPassController.text.isEmpty) {
                _showSnackbar(context, "Please fill all fields", Colors.red);
                return;
              }
              if (newPassController.text != confirmPassController.text) {
                _showSnackbar(context, "Passwords don't match", Colors.red);
                return;
              }
              Navigator.pop(context);
              _showSnackbar(context, "Password changed successfully!", Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send Feedback"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: messageController,
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
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (subjectController.text.isEmpty || messageController.text.isEmpty) {
                _showSnackbar(context, "Please fill all fields", Colors.red);
                return;
              }
              Navigator.pop(context);
              _showSnackbar(context, "Feedback sent successfully!", Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("About"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 64, color: Colors.blue[700]),
            const SizedBox(height: 12),
            const Text(
              "School Management System",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Version 1.0.0",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
             Text(
              "A comprehensive school management solution.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
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
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset All Settings"),
        content: const Text("Are you sure you want to reset all settings to default?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Reset to defaults
                pushNotifications = true;
                emailNotifications = false;
                smsNotifications = true;
                attendanceAlerts = true;
                examAlerts = true;
                feeAlerts = false;
                selectedTheme = 'Light';
                selectedLanguage = 'English';
                schoolName = 'Sunrise School';
                schoolEmail = 'info@sunriseschool.com';
                schoolPhone = '+91 98765 43210';
              });
              Navigator.pop(context);
              _showSnackbar(context, "All settings reset to default", Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Reset All"),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}