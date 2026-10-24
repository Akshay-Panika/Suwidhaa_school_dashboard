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

        // Details
        _buildDetailRow('Sections', classItem.sections.join(', ')),
        _buildDetailRow('Status', classItem.checkBox ? 'Active' : 'Inactive', color: classItem.checkBox ? Colors.green : Colors.red),

        const SizedBox(height: 20),
        const Text('Class Teacher Assignment:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),

        // Teacher Assignment UI
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              if (classItem.classTeacher != null) ...[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: classItem.classTeacher!.profileImage != null
                      ? NetworkImage(classItem.classTeacher!.profileImage!)
                      : null,
                  child: classItem.classTeacher!.profileImage == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(height: 8),
                Text(classItem.classTeacher!.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => controller.assignTeacher(classItem.id, null),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Remove Teacher'),
                ),
              ] else ...[
                const Text('No class teacher assigned yet.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAssignTeacherDialog(controller, classItem, schoolController),
                  icon: const Icon(Icons.person_add, color: Colors.white,),
                  label:  Text('Assign Teacher', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
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

    // ✅ FIX: Set the school and call getTeachers without parameters
    teacherController.selectedSchool.value = currentSchool;
    teacherController.getTeachers();

    Get.dialog(
      AlertDialog(
        title: const Text('Select Class Teacher'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Obx(() {
            if (teacherController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (teacherController.teachers.isEmpty) {
              return const Center(child: Text('No teachers found for this school.'));
            }

            return ListView.builder(
              itemCount: teacherController.teachers.length,
              itemBuilder: (context, index) {
                final teacher = teacherController.teachers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: teacher.teacherProfile != null
                        ? NetworkImage(teacher.teacherProfile!)
                        : null,
                    child: teacher.teacherProfile == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(teacher.fullName),
                  subtitle: Text(teacher.teacherIdCard ?? 'No ID'),
                  onTap: () {
                    Get.back(); // Close dialog
                    controller.assignTeacher(classItem.id, teacher.id);
                  },
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600]))),
          Expanded(child: Text(value, style: TextStyle(color: color ?? Colors.black87))),
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