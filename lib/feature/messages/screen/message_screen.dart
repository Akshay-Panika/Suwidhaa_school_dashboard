// lib/feature/message/screen/message_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main/controller/school_type_controller.dart';
import '../../main/widget/school_type_filter_widget.dart';
import '../../teachers/controller/teacher_controller.dart';
import '../../student/controller/student_controller.dart';
import '../../transport/controller/transport_controller.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final SchoolTypeController schoolController = Get.find<SchoolTypeController>();
  final TeacherController teacherController = Get.find<TeacherController>();
  final StudentController studentController = Get.find<StudentController>();
  final TransportController transportController = Get.find<TransportController>();

  // Current Tab: 'Teachers', 'Students', or 'Transport'
  String selectedTab = 'Teachers';

  // Selected Contact (Full Data Map)
  Map<String, dynamic>? selectedContact;

  // Search Query for the current tab
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAllData() {
    final school = schoolController.selectedSchoolType.value;
    final schoolId = school?.id;

    teacherController.setSelectedSchool(school);
    studentController.setSelectedSchool(school);
    transportController.loadTransports(schoolId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<Map<String, dynamic>> currentList = [];

      if (selectedTab == 'Teachers') {
        currentList = teacherController.teachers.map((t) => {
          'id': 'T${t.id}',
          'name': t.fullName,
          'role': 'Teacher',
          'phone': t.phone ?? 'N/A',
          'email': t.email ?? 'N/A',
          'idCard': t.teacherIdCard ?? 'N/A',
          'profile': t.teacherProfile,
          'school': t.schoolName ?? 'N/A',
          'gender': t.gender ?? 'N/A',
          'dob': t.dob ?? 'N/A',
          'altPhone': t.altPhone ?? 'N/A',
          'address': t.address ?? 'N/A',
          'qualification': t.qualification ?? 'N/A',
          'experience': t.experienceStr,
          'salary': t.salary ?? 'N/A',
          'joinDate': t.joinDate ?? 'N/A',
          'subjects': t.subjects?.join(', ') ?? 'N/A',
          'status': t.status,
        }).toList();
      } else if (selectedTab == 'Students') {
        currentList = studentController.students.map((s) => {
          'id': 'S${s.id}',
          'name': '${s.firstName} ${s.middleName} ${s.lastName}',
          'role': 'Student',
          'phone': s.parentPhone,
          'email': 'N/A',
          'idCard': s.studentIdCard ?? 'N/A',
          'profile': s.studentProfile,
          'school': s.schoolName ?? 'N/A',
          'className': s.studentClass,
          'rollNumber': s.rollNumber,
          'dob': s.dob,
          'gender': s.gender,
          'fatherName': s.fatherName,
          'motherName': s.motherName,
          'altPhone': s.alternativePhone ?? 'N/A',
          'aadhar': s.adharNumber,
          'sssmid': s.sssmid,
          'caste': s.casteCategory,
          'address': s.address,
          'feeStatus': s.feeStatus,
          'feeAmount': '₹${s.feeAmount}',
          'paidAmount': '₹${s.paidAmount}',
        }).toList();
      } else if (selectedTab == 'Transport') {
        currentList = transportController.transports.map((tr) => {
          'id': 'D${tr.id}',
          'name': tr.driverName,
          'role': 'Driver',
          'phone': tr.driverNumber,
          'email': 'N/A',
          'idCard': tr.vehicleNumber,
          'profile': tr.driverImage,
          'school': tr.school?.schoolName ?? 'N/A',
          'route': tr.routeName ?? 'N/A',
          'capacity': tr.capacity ?? 'N/A',
          'transportType': tr.transportType ?? 'N/A',
          'totalStudents': tr.studentCount.toString(),
        }).toList();
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        currentList = currentList.where((c) {
          final q = _searchQuery.toLowerCase();
          return c['name'].toString().toLowerCase().contains(q) ||
              c['idCard'].toString().toLowerCase().contains(q) ||
              c['phone'].toString().toLowerCase().contains(q);
        }).toList();
      }

      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            // Left Panel
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Header
                  Container(
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
                              child: Icon(Icons.contacts, color: Colors.blue[700], size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Contact Directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Manage all contacts', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        SchoolTypeFilterWidget(
                          compact: true,
                          value: schoolController.selectedSchoolType.value,
                          onChanged: (school) {
                            schoolController.selectedSchoolType.value = school;
                            _loadAllData();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        _buildTabChip('Teachers', teacherController.teachers.length, Colors.blue),
                        const SizedBox(width: 8),
                        _buildTabChip('Students', studentController.students.length, Colors.green),
                        const SizedBox(width: 8),
                        _buildTabChip('Transport', transportController.transports.length, Colors.orange),
                      ],
                    ),
                  ),

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search by name, ID, or phone...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                          prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Contact List
                  Expanded(
                    child: (teacherController.isLoading.value || studentController.isLoading.value || transportController.isLoading.value)
                        ? const Center(child: CircularProgressIndicator())
                        : currentList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        return _buildContactListItem(currentList[index]);
                      },
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
                borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                border: Border(left: BorderSide(color: Colors.grey[200]!, width: 1)),
              ),
              child: selectedContact != null
                  ? _buildDetailPanel(selectedContact!)
                  : _buildEmptyDetailPanel(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabChip(String title, int count, Color color) {
    final isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = title;
            selectedContact = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? color : Colors.grey[600])),
              const SizedBox(height: 2),
              Text('$count', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey[800])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactListItem(Map<String, dynamic> contact) {
    final isSelected = selectedContact != null && selectedContact!['id'] == contact['id'];
    final roleColor = _getRoleColor(contact['role']);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedContact = contact;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: roleColor.withOpacity(0.1),
                backgroundImage: (contact['profile'] != null && contact['profile'].toString().isNotEmpty)
                    ? NetworkImage(contact['profile'])
                    : null,
                child: (contact['profile'] == null || contact['profile'].toString().isEmpty)
                    ? Text(
                  _getInitials(contact['name']),
                  style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 14),
                )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(contact['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(contact['role'], style: TextStyle(fontSize: 8, color: roleColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Text('ID: ${contact['idCard']}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
              if (contact['phone'] != 'N/A' && contact['phone'] != null)
                IconButton(
                  onPressed: () => _makePhoneCall(contact['phone']),
                  icon: const Icon(Icons.phone, color: Colors.green, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 👇 UPDATED: Full Data Detail Panel
  Widget _buildDetailPanel(Map<String, dynamic> contact) {
    final roleColor = _getRoleColor(contact['role']);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: roleColor.withOpacity(0.1),
                backgroundImage: (contact['profile'] != null && contact['profile'].toString().isNotEmpty)
                    ? NetworkImage(contact['profile'])
                    : null,
                child: (contact['profile'] == null || contact['profile'].toString().isEmpty)
                    ? Text(
                  _getInitials(contact['name']),
                  style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18),
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(contact['role'], style: TextStyle(fontSize: 12, color: roleColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => selectedContact = null),
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        // Scrollable Details
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Basic Information', roleColor),
              _buildDetailRow('School', contact['school']),
              if (contact['className'] != null) _buildDetailRow('Class', contact['className']),
              if (contact['idCard'] != null) _buildDetailRow('ID / Vehicle', contact['idCard']),

              if (contact['role'] == 'Student') ...[
                _buildSectionTitle('Personal Info', Colors.green),
                _buildDetailRow('Date of Birth', contact['dob']),
                _buildDetailRow('Gender', contact['gender']),
                _buildDetailRow('Roll Number', contact['rollNumber']),
                _buildDetailRow('Father Name', contact['fatherName']),
                _buildDetailRow('Mother Name', contact['motherName']),
                _buildDetailRow('Aadhar Number', contact['aadhar']),
                _buildDetailRow('SSSMID', contact['sssmid']),
                _buildDetailRow('Caste Category', contact['caste']),
                _buildDetailRow('Address', contact['address']),
                _buildSectionTitle('Fee Info', Colors.red),
                _buildDetailRow('Fee Amount', contact['feeAmount']),
                _buildDetailRow('Paid Amount', contact['paidAmount']),
                _buildDetailRow('Fee Status', contact['feeStatus']),
              ],

              if (contact['role'] == 'Teacher') ...[
                _buildSectionTitle('Professional Info', Colors.blue),
                _buildDetailRow('Qualification', contact['qualification']),
                _buildDetailRow('Experience', contact['experience']),
                _buildDetailRow('Salary', contact['salary']),
                _buildDetailRow('Join Date', contact['joinDate']),
                _buildDetailRow('Subjects', contact['subjects']),
                _buildDetailRow('Status', contact['status']),
                _buildDetailRow('Date of Birth', contact['dob']),
                _buildDetailRow('Gender', contact['gender']),
                _buildDetailRow('Address', contact['address']),
              ],

              if (contact['role'] == 'Driver') ...[
                _buildSectionTitle('Transport Info', Colors.orange),
                _buildDetailRow('Vehicle Number', contact['idCard']),
                _buildDetailRow('Route Name', contact['route']),
                _buildDetailRow('Capacity', contact['capacity']),
                _buildDetailRow('Transport Type', contact['transportType']),
                _buildDetailRow('Total Students', contact['totalStudents']),
              ],

              const SizedBox(height: 16),
              _buildSectionTitle('Contact Info', Colors.purple),
              _buildDetailRow('Phone', contact['phone']),
              _buildDetailRow('Alt Phone', contact['altPhone'] ?? 'N/A'),
              _buildDetailRow('Email', contact['email']),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(contact['phone']),
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text("Call Now"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDetailPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contact_page, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text("Select a Contact", style: TextStyle(fontSize: 16, color: Colors.grey[500])),
          Text("Click on a contact to view full details", style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text("No contacts found", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Teacher':
        return Colors.blue;
      case 'Student':
        return Colors.green;
      case 'Driver':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  Future<void> _makePhoneCall(String phone) async {
    if (phone == 'N/A' || phone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar('Error', 'Could not launch phone dialer');
    }
  }
}