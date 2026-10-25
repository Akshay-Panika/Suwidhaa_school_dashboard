// lib/feature/subjects/screen/subject_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main/controller/school_type_controller.dart';
import '../../main/widget/school_type_filter_widget.dart';
import '../controller/subject_controller.dart';
import '../model/subject_model.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubjectController>();
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
                          : controller.filteredSubjects.isEmpty
                          ? _buildEmptyState(controller)
                          : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: controller.filteredSubjects.length,
                        itemBuilder: (context, index) {
                          return _buildSubjectCard(controller, controller.filteredSubjects[index]);
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
                    : _buildViewPanel(controller))
                    : _buildEmptyRightPanel(controller),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ============ HEADER ============
  Widget _buildHeader(SubjectController controller, SchoolTypeController schoolController) {
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
                child: Icon(Icons.book, color: Colors.blue[700], size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Subjects Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${controller.filteredSubjects.length} subjects found', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
              if (!controller.showRightPanel.value || (!controller.isAddingNew.value && !controller.isEditing.value))
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
  Widget _buildSearchBar(SubjectController controller) {
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
            hintText: 'Search subjects...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }

  // ============ SUBJECT CARD ============
  Widget _buildSubjectCard(SubjectController controller, SubjectApiModel subject) {
    final isSelected = controller.selectedSubject.value?.id == subject.id;

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
            child: const Icon(Icons.book, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),

          // Info Clickable
          Expanded(
            child: InkWell(
              onTap: () => controller.selectSubject(subject),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.subjectName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildInfoText(Icons.school, subject.schoolName, color: Colors.blue),
                      if (subject.code != null && subject.code!.isNotEmpty)
                        _buildInfoText(Icons.tag, 'Code: ${subject.code}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons (Edit / Delete)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () => controller.startEditing(subject),
                  icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue[700]),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  onPressed: () => controller.deleteSubject(subject),
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          )
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
  Widget _buildFormPanel(SubjectController controller, SchoolTypeController schoolController) {
    final isEdit = controller.isEditing.value;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Icon(isEdit ? Icons.edit : Icons.add_box_outlined, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Text(
              isEdit ? 'Edit Subject' : 'Create New Subject',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('School: ${schoolController.selectedSchoolType.value?.schoolName ?? "Not Selected"}',
            style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // Name Field
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            labelText: 'Subject Name *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.book),
          ),
        ),
        const SizedBox(height: 16),

        // Code Field
        TextField(
          controller: controller.codeController,
          decoration: InputDecoration(
            labelText: 'Subject Code (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.tag),
          ),
        ),

        const SizedBox(height: 30),

        // Actions
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
                onPressed: isEdit ? controller.updateSubject : controller.addSubject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: Text(isEdit ? 'Update Subject' : 'Save Subject'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============ VIEW PANEL ============
  Widget _buildViewPanel(SubjectController controller) {
    final subject = controller.selectedSubject.value;
    if (subject == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.book, color: Colors.blue, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.subjectName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subject.schoolName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),

        _buildDetailRow('Subject Name', subject.subjectName),
        _buildDetailRow('Subject Code', subject.code ?? 'N/A'),
        _buildDetailRow('School', subject.schoolName, color: Colors.blue),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 8),

        // ✅ NEW: Teachers Section
        const Text('Assigned Teachers:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),

        if (subject.teachers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text('No teachers assigned to this subject yet.', style: TextStyle(color: Colors.grey))),
          )
        else
          ...subject.teachers.map((teacher) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue[50],
                  backgroundImage: teacher.teacherProfile != null ? NetworkImage(teacher.teacherProfile!) : null,
                  child: teacher.teacherProfile == null ? const Icon(Icons.person, color: Colors.blue) : null,
                ),
                const SizedBox(width: 12),

                // Name, ID, Subjects
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(teacher.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      if (teacher.teacherIdCard != null)
                        Text('ID: ${teacher.teacherIdCard}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      if (teacher.subjects != null && teacher.subjects!.isNotEmpty)
                        Text('Subjects: ${teacher.subjects!.join(', ')}', style: TextStyle(fontSize: 11, color: Colors.blue[700])),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: Colors.green[400], size: 20),
              ],
            ),
          )).toList(),

        const SizedBox(height: 24),

        // Bottom Action Buttons for Edit/Delete
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.startEditing(subject),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.deleteSubject(subject),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600]))),
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
          Text('Choose a school from the dropdown to load subjects', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildEmptyState(SubjectController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No Subjects Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.startAddNew,
            icon: const Icon(Icons.add),
            label: const Text('Add New Subject'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRightPanel(SubjectController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.blue[100]),
          const SizedBox(height: 16),
          Text('Select a subject to view details', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}