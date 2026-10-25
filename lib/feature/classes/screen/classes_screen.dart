// lib/feature/classes/screen/classes_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main/controller/school_type_controller.dart';
import '../../main/widget/school_type_filter_widget.dart';
import '../../teachers/controller/teacher_controller.dart'; // ✅ Import TeacherController
import '../controller/class_controller.dart';
import '../model/class_model.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClassController>();
    final schoolController = Get.find<SchoolTypeController>();

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
                          : schoolController.selectedSchoolType.value == null
                          ? _buildSelectSchoolState()
                          : controller.filteredClasses.isEmpty
                          ? _buildEmptyState(controller)
                          : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: controller.filteredClasses.length,
                        itemBuilder: (context, index) {
                          return _buildClassCard(controller, controller.filteredClasses[index]);
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
                    ? (controller.isAddingNew.value
                    ? _buildAddPanel(controller, schoolController)
                    : _buildViewPanel(controller, schoolController))
                    : _buildEmptyRightPanel(controller),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ============ HEADER ============
  Widget _buildHeader(ClassController controller, SchoolTypeController schoolController) {
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
                child: Icon(Icons.class_, color: Colors.blue[700], size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Classes Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${controller.filteredClasses.length} classes found', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                },
              ),
              const SizedBox(width: 8),
              if (!controller.showRightPanel.value || !controller.isAddingNew.value)
                ElevatedButton.icon(
                  onPressed: controller.startAddNew,
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
                  onPressed: controller.closeRightPanel,
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ SEARCH ============
  Widget _buildSearchBar(ClassController controller) {
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
            hintText: 'Search classes...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }

  // ============ CLASS CARD ============
  Widget _buildClassCard(ClassController controller, ClassApiModel classItem) {
    final isSelected = controller.selectedClass.value?.id == classItem.id;

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
            child: const Icon(Icons.class_, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => controller.selectClass(classItem),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classItem.className,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildInfoText(Icons.school, classItem.schoolName, color: Colors.blue),
                      _buildInfoText(Icons.view_list, '${classItem.sections.length} Sections'),
                      _buildInfoText(
                          Icons.person,
                          classItem.classTeacher?.fullName ?? 'No Teacher',
                          color: classItem.classTeacher != null ? Colors.green : Colors.red
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => controller.selectClass(classItem),
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

  // ============ ADD PANEL ============
  Widget _buildAddPanel(ClassController controller, SchoolTypeController schoolController) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_box_outlined, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              const Text('Create New Class', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('School: ${schoolController.selectedSchoolType.value?.schoolName ?? "Not Selected"}',
              style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Class Name Field
          TextField(
            onChanged: (val) => controller.newClassName.value = val,
            decoration: InputDecoration(
              labelText: 'Class Name (e.g., 6A)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.text_fields),
            ),
          ),
          const SizedBox(height: 20),

          // Sections List
          const Text('Sections:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => Wrap(
            spacing: 8,
            children: controller.newClassSections.map((sec) => Chip(
              label: Text('Section $sec'),
              onDeleted: () => controller.removeSectionFromForm(sec),
              deleteIcon: const Icon(Icons.close, size: 16),
            )).toList(),
          )),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: controller.addSectionToForm,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Section'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[50],
              foregroundColor: Colors.green[700],
              elevation: 0,
            ),
          ),

          const SizedBox(height: 30),

          // Action Buttons
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
                  onPressed: controller.addClass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Class'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ VIEW PANEL ============
  Widget _buildViewPanel(ClassController controller, SchoolTypeController schoolController) {
    final classItem = controller.selectedClass.value;
    if (classItem == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ---- CLASS HEADER ----
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.class_, color: Colors.blue, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${classItem.className} Class', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(classItem.schoolName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),

        // ---- CLASS DETAILS ----
        _buildDetailRow('Sections', classItem.sections.join(', ')),
        _buildDetailRow('Status', classItem.checkBox ? 'Active' : 'Inactive', color: classItem.checkBox ? Colors.green : Colors.red),

        const SizedBox(height: 20),
        const Text('Class Teacher Assignment:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),

        // ---- TEACHER PROFILE CARD ----
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
          ),
          child: Column(
            children: [
              if (classItem.classTeacher != null) ...[
                // 1. Profile Image + Name & ID
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.blue[50],
                      backgroundImage: classItem.classTeacher!.profileImage != null
                          ? NetworkImage(classItem.classTeacher!.profileImage!)
                          : null,
                      child: classItem.classTeacher!.profileImage == null
                          ? const Icon(Icons.person, size: 35, color: Colors.blue)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classItem.classTeacher!.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  'ID: ${classItem.classTeacher!.teacherIdCard ?? "N/A"}',
                                  style: TextStyle(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                classItem.classTeacher!.gender ?? '',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Qualification: ${classItem.classTeacher!.qualification ?? "N/A"}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          if (classItem.classTeacher!.subjects != null && classItem.classTeacher!.subjects!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Subjects: ${classItem.classTeacher!.subjects!.join(', ')}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),

                // 2. Contact Details
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(classItem.classTeacher!.phone ?? 'N/A', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.email, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              classItem.classTeacher!.email ?? 'N/A',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 3. Remove Button
                OutlinedButton.icon(
                  onPressed: () => controller.assignTeacher(classItem.id, null),
                  icon: const Icon(Icons.person_remove, size: 18),
                  label: const Text('Remove Teacher'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else ...[
                // ---- NO TEACHER ASSIGNED ----
                const SizedBox(height: 10),
                Icon(Icons.person_search, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                const Text('No class teacher assigned yet.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAssignTeacherDialog(controller, classItem, schoolController),
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text('Assign Teacher', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
              ]
            ],
          ),
        ),
      ],
    );
  }

  void _showAssignTeacherDialog(
      ClassController controller,
      ClassApiModel classItem,
      SchoolTypeController schoolController
      ) {
    final teacherController = Get.find<TeacherController>();
    final currentSchool = schoolController.selectedSchoolType.value;

    if (currentSchool == null) {
      Get.snackbar("Error", "Please select a school first");
      return;
    }

    teacherController.selectedSchool.value = currentSchool;
    teacherController.getTeachers();

    // Local search query variable
    final RxString searchQuery = ''.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 500,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // --- HEADER ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_search, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assign Class Teacher',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'For ${classItem.className} Class',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),

              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    onChanged: (val) => searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search teacher by name or ID...',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // --- TEACHER LIST ---
              Expanded(
                child: Obx(() {
                  if (teacherController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filter logic
                  final allTeachers = teacherController.teachers;
                  final filteredTeachers = allTeachers.where((t) {
                    final query = searchQuery.value.toLowerCase();
                    return t.fullName.toLowerCase().contains(query) ||
                        (t.teacherIdCard?.toLowerCase().contains(query) ?? false);
                  }).toList();

                  if (filteredTeachers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_outlined, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            allTeachers.isEmpty
                                ? 'No teachers found for this school.'
                                : 'No teacher matched your search.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredTeachers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final teacher = filteredTeachers[index];

                      return InkWell(
                        onTap: () {
                          Get.back(); // Close dialog
                          controller.assignTeacher(classItem.id, teacher.id);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blue[50],
                                backgroundImage: teacher.teacherProfile != null
                                    ? NetworkImage(teacher.teacherProfile!)
                                    : null,
                                child: teacher.teacherProfile == null
                                    ? Icon(Icons.person, color: Colors.blue[700], size: 24)
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      teacher.fullName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.badge_outlined, size: 12, color: Colors.grey[500]),
                                        const SizedBox(width: 4),
                                        Text(
                                          teacher.teacherIdCard ?? 'No ID',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 8),
                                        if (teacher.subjects != null && teacher.subjects!.isNotEmpty) ...[
                                          Icon(Icons.book_outlined, size: 12, color: Colors.grey[500]),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              teacher.subjects!.join(', '),
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow Icon
                              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              // --- FOOTER ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(dynamic label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label is String) ...[
            SizedBox(
              width: 100,
              child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[600])),
            ),
          ] else if (label is IconData) ...[
            Icon(label, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: color ?? Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ============ EMPTY PANELS ============
  Widget _buildSelectSchoolState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Please select a school', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text('Choose a school from the dropdown to load classes', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ClassController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No Classes Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.startAddNew,
            icon: const Icon(Icons.add),
            label: const Text('Add New Class'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRightPanel(ClassController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 80, color: Colors.blue[100]),
          const SizedBox(height: 16),
          Text('Select a class to view details', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}