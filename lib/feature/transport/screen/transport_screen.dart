import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../main/controller/school_type_controller.dart';
import '../../main/widget/school_type_filter_widget.dart';
import '../../student/controller/student_controller.dart';
import '../../student/model/student_model.dart';
import '../controller/transport_controller.dart';
import '../model/transport_model.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  // ✅ State to track if "Add Student" list is expanded
  bool _isAddingStudent = false;

  // ✅ State to track which student is selected for the inline form
  StudentModel? _selectedStudentForAdd;

  // ✅ Search query for filtering students in Add Student list
  String _studentSearchQuery = '';
  final TextEditingController _studentSearchController = TextEditingController();

  // ✅ Controllers for inline form (Date, Address, Times)
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _pickupTimeController = TextEditingController();
  final TextEditingController _dropTimeController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _dateController.dispose();
    _pickupTimeController.dispose();
    _dropTimeController.dispose();
    _studentSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransportController>();
    final schoolController = Get.find<SchoolTypeController>();
    final studentController = Get.find<StudentController>();

    return Obx(() {
      return Scaffold(
        body: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              // Left Panel
              Expanded(
                flex: controller.showRightPanel.value ? 5 : 8,
                child: Column(
                  children: [
                    _buildHeader(controller, schoolController),
                    _buildSearchBar(controller),
                    Expanded(
                      child: controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : controller.filteredTransports.isEmpty
                          ? _buildEmptyState(controller)
                          : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: controller.filteredTransports.length,
                        itemBuilder: (context, index) {
                          return _buildTransportCard(controller, controller.filteredTransports[index]);
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
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(left: BorderSide(color: Colors.grey[200]!, width: 1)),
                ),
                child: controller.showRightPanel.value
                    ? (controller.isAddingNew.value || controller.isEditing.value
                    ? _buildFormPanel(controller, schoolController)
                    : _buildViewPanel(controller, studentController))
                    : _buildEmptyRightPanel(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ============ HEADER ============
  Widget _buildHeader(TransportController controller, SchoolTypeController schoolController) {
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
                child: Icon(Icons.directions_bus, color: Colors.blue[700], size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transport Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${controller.filteredTransports.length} transports found', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                  controller.closeRightPanel();
                  setState(() {
                    _isAddingStudent = false;
                    _selectedStudentForAdd = null;
                    _studentSearchQuery = '';
                    _studentSearchController.clear();
                  });
                },
              ),
              const SizedBox(width: 8),
              if (!controller.showRightPanel.value || (!controller.isAddingNew.value && !controller.isEditing.value))
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isAddingStudent = false;
                      _selectedStudentForAdd = null;
                      _studentSearchQuery = '';
                      _studentSearchController.clear();
                    });
                    controller.startAddNew();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              if (controller.showRightPanel.value)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingStudent = false;
                      _selectedStudentForAdd = null;
                      _studentSearchQuery = '';
                      _studentSearchController.clear();
                    });
                    controller.closeRightPanel();
                  },
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ SEARCH (Main List) ============
  Widget _buildSearchBar(TransportController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: TextField(
          onChanged: controller.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search by vehicle or driver...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }

  // ============ TRANSPORT CARD ============
  Widget _buildTransportCard(TransportController controller, TransportModel transport) {
    final isSelected = controller.selectedTransport.value?.id == transport.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? Colors.blue[300]! : Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.directions_bus, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isAddingStudent = false;
                  _selectedStudentForAdd = null;
                  _studentSearchQuery = '';
                  _studentSearchController.clear();
                });
                controller.selectTransport(transport);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle: ${transport.vehicleNumber}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildInfoText(Icons.school, transport.school?.schoolName ?? 'No School', color: Colors.blue),
                      _buildInfoText(Icons.person, 'Driver: ${transport.driverName}'),
                      _buildInfoText(Icons.people, '${transport.studentCount} Students', color: Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isAddingStudent = false;
                _selectedStudentForAdd = null;
                _studentSearchQuery = '';
                _studentSearchController.clear();
              });
              controller.selectTransport(transport);
            },
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
        Text(text, style: TextStyle(fontSize: 10, color: color ?? Colors.grey[600])),
      ],
    );
  }

  // ============ ADD / EDIT PANEL ============
  Widget _buildFormPanel(TransportController controller, SchoolTypeController schoolController) {
    final isEdit = controller.isEditing.value;
    final schoolName = schoolController.selectedSchoolType.value?.schoolName ?? "All Schools Selected";

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Icon(isEdit ? Icons.edit : Icons.add_box_outlined, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Text(isEdit ? 'Edit Transport' : 'Add New Transport', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text('School: $schoolName',
            style: TextStyle(fontSize: 12, color: schoolName == "All Schools Selected" ? Colors.red : Colors.blue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        TextField(
          controller: controller.vehicleNumberController,
          decoration: const InputDecoration(
            labelText: 'Vehicle Number *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.confirmation_number),
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.driverNameController,
          decoration: const InputDecoration(
            labelText: 'Driver Name *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.driverNumberController,
          decoration: const InputDecoration(
            labelText: 'Driver Phone',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextField(controller: controller.capacityController, decoration: const InputDecoration(labelText: 'Capacity', border: OutlineInputBorder(), isDense: true))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: controller.routeNameController, decoration: const InputDecoration(labelText: 'Route Name', border: OutlineInputBorder(), isDense: true))),
          ],
        ),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.closeRightPanel,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.saveTransport,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
                child: Text(isEdit ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============ VIEW PANEL ============
  Widget _buildViewPanel(TransportController controller, StudentController studentController) {
    final transport = controller.selectedTransport.value;
    if (transport == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.directions_bus, color: Colors.blue, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vehicle: ${transport.vehicleNumber}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(transport.school?.schoolName ?? 'No School', style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),

        _buildDetailRow('Driver Name', transport.driverName),
        _buildDetailRow('Phone', transport.driverNumber),
        _buildDetailRow('Capacity', transport.capacity ?? 'N/A'),
        _buildDetailRow('Route', transport.routeName ?? 'N/A'),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Assigned Students:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isAddingStudent = !_isAddingStudent;
                  _selectedStudentForAdd = null; // Reset selected student
                  _studentSearchQuery = '';
                  _studentSearchController.clear();
                });

                if (_isAddingStudent && transport.school?.id != null) {
                  studentController.setSelectedSchool(transport.school);
                }
              },
              icon: Icon(_isAddingStudent ? Icons.close : Icons.add, size: 16, color: Colors.blue,),
              label: Text(_isAddingStudent ? 'Close List' : 'Add Student', style: TextStyle(color: Colors.blue,fontSize: 14),),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ✅ Inline Add Student List with Search
        if (_isAddingStudent)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Student to Add:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                const SizedBox(height: 8),

                // ✅ Search Bar for Students
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: TextField(
                    controller: _studentSearchController,
                    onChanged: (val) => setState(() => _studentSearchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search by Student ID or Name...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                      prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Obx(() {
                  if (studentController.isLoading.value) {
                    return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
                  }
                  if (studentController.students.isEmpty) {
                    return const Text('No students found for this school.', style: TextStyle(fontSize: 12, color: Colors.grey));
                  }

                  // ✅ Filter Students based on search
                  final filteredStudents = studentController.students.where((s) {
                    final query = _studentSearchQuery.toLowerCase();
                    final idCard = (s.studentIdCard ?? '').toLowerCase();
                    final name = '${s.firstName} ${s.lastName}'.toLowerCase();
                    return idCard.contains(query) || name.contains(query);
                  }).toList();

                  if (filteredStudents.isEmpty) {
                    return const Text('No matching students found.', style: TextStyle(fontSize: 12, color: Colors.grey));
                  }

                  // ✅ Dynamic height based on filtered list length
                  double listHeight = (filteredStudents.length * 60.0).clamp(60.0, 250.0);

                  return SizedBox(
                    height: listHeight,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        final isAlreadyAssigned = transport.students.any((s) => s.student.id == student.id);

                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundImage: student.studentProfile != null ? NetworkImage(student.studentProfile!) : null,
                            child: student.studentProfile == null ? const Icon(Icons.person, size: 16) : null,
                          ),
                          title: Text('${student.firstName} ${student.lastName}', style: const TextStyle(fontSize: 13)),
                          subtitle: Text('ID: ${student.studentIdCard ?? "N/A"} | Class: ${student.studentClass}', style: const TextStyle(fontSize: 11)),
                          trailing: isAlreadyAssigned
                              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                              : IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedStudentForAdd = student;
                                _addressController.text = student.address ?? '';
                                _dateController.clear();
                                _pickupTimeController.clear();
                                _dropTimeController.clear();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  );
                }),

                // ✅ Inline Form (Shows when a student is selected)
                if (_selectedStudentForAdd != null) ...[
                  const Divider(thickness: 1, height: 20),
                  Text('Add Details for ${_selectedStudentForAdd!.firstName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                  const SizedBox(height: 12),

                  // Address Field
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              _pickupTimeController.text = picked.format(context);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _pickupTimeController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Pickup Time',
                                labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                isDense: true,
                                fillColor: Colors.white,
                                filled: true,
                                suffixIcon: const Icon(Icons.access_time, size: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              _dropTimeController.text = picked.format(context);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _dropTimeController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Drop Time',
                                labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                isDense: true,
                                fillColor: Colors.white,
                                filled: true,
                                suffixIcon: const Icon(Icons.access_time, size: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Confirm Add Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.addStudentToTransport(
                          transportId: transport.id,
                          studentId: _selectedStudentForAdd!.id!,
                          address: _addressController.text.trim(),
                          pickupTime: _pickupTimeController.text.trim(),
                          dropTime: _dropTimeController.text.trim(),
                        );
                        setState(() {
                          _selectedStudentForAdd = null; // Form close karo
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Confirm & Add Student'),
                    ),
                  ),
                ],
              ],
            ),
          ),

        // Assigned Students List
        if (transport.students.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text('No students assigned to this bus.', style: TextStyle(color: Colors.grey))),
          )
        else
          ...transport.students.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[50],
                  backgroundImage: s.student.studentProfile != null ? NetworkImage(s.student.studentProfile!) : null,
                  child: s.student.studentProfile == null ? const Icon(Icons.person, color: Colors.blue) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s.student.firstName} ${s.student.lastName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Class: ${s.student.studentClass} | ID: ${s.student.studentIdCard}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      if (s.address != null && s.address!.isNotEmpty)
                        Text('Address: ${s.address}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      if (s.pickupTime != null && s.pickupTime!.isNotEmpty)
                        Text('Pickup: ${s.pickupTime} | Drop: ${s.dropTime ?? "N/A"}', style: TextStyle(fontSize: 11, color: Colors.orange[700])),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => controller.removeStudentFromTransport(transport.id, s.student.id!),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                )
              ],
            ),
          )).toList(),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.startEditing(transport),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.deleteTransport(transport),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600], foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600]))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ============ EMPTY PANELS ============
  Widget _buildEmptyState(TransportController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus_outlined, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No Transports Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isAddingStudent = false;
                _selectedStudentForAdd = null;
              });
              controller.startAddNew();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Transport'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRightPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus_outlined, size: 80, color: Colors.blue[100]),
          const SizedBox(height: 16),
          Text('Select a transport to view details', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}