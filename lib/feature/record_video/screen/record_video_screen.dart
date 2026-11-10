import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/widget/flutter_toast.dart';
import '../controller/record_video_controller.dart';
import '../model/record_class_model.dart';

class RecordVideoScreen extends StatelessWidget {
  const RecordVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecordVideoController());

    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            // ================= LEFT PANEL (Classes List) =================
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildHeader(controller),
                  _buildSearchBar(),
                  Expanded(
                    child: controller.isLoadingClasses.value
                        ? _buildShimmerList()
                        : controller.classes.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: controller.classes.length,
                      itemBuilder: (context, index) {
                        return _buildClassCard(controller, controller.classes[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ================= RIGHT PANEL =================
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
              child: controller.isAddingClass.value
                  ? _buildAddEditClassForm(controller)
                  : controller.selectedClass.value != null
                  ? _buildRightTabbedPanel(controller)
                  : _buildEmptyDetailPanel(),
            ),
          ],
        ),
      );
    });
  }

  // ============ LEFT PANEL: HEADER ============
  Widget _buildHeader(RecordVideoController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
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
                child: Icon(Icons.class_, color: Colors.blue[700], size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Classes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${controller.classes.length} classes',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: controller.openAddClassForm,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // ============ LEFT PANEL: SEARCH ============
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: TextField(
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

  // ============ LEFT PANEL: CLASS CARD (mirrors contact list item) ============
  Widget _buildClassCard(RecordVideoController controller, RecordClassModel classItem) {
    final isSelected = controller.selectedClass.value?.id == classItem.id;

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
        onTap: () => controller.selectClass(classItem),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.class_, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            classItem.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Class',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${classItem.subjectCount} Subjects • ${classItem.videoCount} Videos',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => controller.openEditClassForm(classItem),
                icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => _confirmDeleteClass(controller, classItem),
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ RIGHT PANEL: TABBED CLASS DETAIL ============
  Widget _buildRightTabbedPanel(RecordVideoController controller) {
    final classItem = controller.selectedClass.value!;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Header — mirrors MessageScreen detail panel header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.class_, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(classItem.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildViewStat(
                              Icons.book, '${classItem.subjectCount} Subjects', Colors.blue),
                          const SizedBox(width: 12),
                          _buildViewStat(Icons.video_library,
                              '${classItem.videoCount} Videos', Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => controller.selectedClass.value = null,
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // TabBar
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: 'Subjects', icon: Icon(Icons.book, size: 18)),
                Tab(text: 'Videos', icon: Icon(Icons.video_library, size: 18)),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildSubjectsTab(controller),
                _buildVideosTab(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewStat(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ============ TAB 1: SUBJECTS ============
  Widget _buildSubjectsTab(RecordVideoController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCard(
            title: controller.editingSubject.value != null
                ? 'Edit Subject'
                : 'Add New Subject',
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.subjectCtrl,
                    decoration: InputDecoration(
                      hintText: 'Enter Subject Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[50],
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: controller.isSavingSubject.value
                      ? null
                      : controller.saveSubject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.editingSubject.value != null
                        ? Colors.orange
                        : Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: controller.isSavingSubject.value
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : Text(controller.editingSubject.value != null
                      ? 'Update'
                      : 'Add'),
                ),
                if (controller.editingSubject.value != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: controller.cancelSubjectEdit,
                    icon: const Icon(Icons.cancel, color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            title: 'Subjects List',
            child: controller.subjects.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No subjects added yet.',
                  style: TextStyle(color: Colors.grey)),
            )
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.subjects.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final sub = controller.subjects[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.book, color: Colors.blue),
                  title: Text(sub.name,
                      style:
                      const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: Colors.orange),
                        onPressed: () => controller.editSubject(sub),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 18, color: Colors.red),
                        onPressed: () =>
                            _confirmDeleteSubject(controller, sub),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============ TAB 2: VIDEOS ============
  Widget _buildVideosTab(RecordVideoController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCard(
            title: controller.editingVideo.value != null
                ? 'Edit Video'
                : 'Add New Video',
            child: Column(
              children: [
                TextField(
                  controller: controller.vidTitleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Video Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: controller.formSubjectId.value == 0
                            ? null
                            : controller.formSubjectId.value,
                        items: controller.subjects
                            .map((s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)))
                            .toList(),
                        onChanged: (v) => controller.formSubjectId.value = v!,
                        decoration: InputDecoration(
                          labelText: 'Select Subject',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller.vidDurationCtrl,
                        decoration: InputDecoration(
                          labelText: 'Duration (e.g. 5 min)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: controller.vidUrlCtrl,
                        decoration: InputDecoration(
                          labelText: 'Video URL (YouTube or .mp4)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          hintText: 'https://youtube.com/...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller.vidRatingCtrl,
                        decoration: InputDecoration(
                          labelText: 'Rating',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                              image: _getThumbnailDecoration(controller),
                            ),
                            child: _getThumbnailDecoration(controller) == null
                                ? const Icon(Icons.image, color: Colors.grey)
                                : null,
                          ),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final res = await FilePicker.platform.pickFiles(
                                    type: FileType.image, withData: true);
                                if (res != null)
                                  controller.videoThumbnail.value =
                                      res.files.first;
                              },
                              icon: const Icon(Icons.upload_file),
                              label: Text(controller.videoThumbnail.value == null
                                  ? 'Upload Thumbnail'
                                  : 'Change Thumbnail'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: controller.isSavingVideo.value
                          ? null
                          : () => _validateAndSaveVideo(controller),
                      icon: const Icon(Icons.save),
                      label: Text(controller.editingVideo.value != null
                          ? 'Update'
                          : 'Save Video'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        controller.editingVideo.value != null
                            ? Colors.orange
                            : Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    if (controller.editingVideo.value != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: controller.clearVideoForm,
                        icon: const Icon(Icons.cancel, color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (controller.isLoadingVideos.value)
            _buildVideoShimmer()
          else if (controller.videos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No videos available for this class.',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: controller.videos.length,
              itemBuilder: (context, index) {
                final video = controller.videos[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(video.thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.movie,
                                        color: Colors.grey),
                                  )),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[700],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(video.subjectName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    _actionBtn(Icons.edit,
                                            () => controller.editVideo(video)),
                                    const SizedBox(width: 6),
                                    _actionBtn(
                                        Icons.delete,
                                            () => _confirmDeleteVideo(
                                            controller, video),
                                        isDanger: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(video.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(video.rating.toString(),
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 12)),
                                  ],
                                ),
                                Text(video.duration,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ============ RIGHT PANEL: ADD / EDIT FORM ============
  Widget _buildAddEditClassForm(RecordVideoController controller) {
    final isEdit = controller.editingClass.value != null;

    return Column(
      children: [
        // Header — mirrors MessageScreen detail panel header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(isEdit ? Icons.edit : Icons.add,
                    color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEdit ? 'Edit Class' : 'Create New Class',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.isAddingClass.value = false;
                  controller.editingClass.value = null;
                },
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller.classCtrl,
                  decoration: InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.saveClass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(isEdit ? 'Update Class' : 'Save Class'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============ RIGHT PANEL: EMPTY STATE ============
  Widget _buildEmptyDetailPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Select a Class',
              style: TextStyle(fontSize: 16, color: Colors.grey[500])),
          Text('Click on a class to view details',
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  // ============ HELPERS ============
  DecorationImage? _getThumbnailDecoration(RecordVideoController controller) {
    if (controller.videoThumbnail.value != null &&
        controller.videoThumbnail.value!.bytes != null) {
      return DecorationImage(
        image: MemoryImage(controller.videoThumbnail.value!.bytes!),
        fit: BoxFit.cover,
      );
    }
    if (controller.editingVideo.value != null &&
        controller.editingVideo.value!.thumbnail.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(controller.editingVideo.value!.thumbnail),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  bool _isValidVideoUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https'))
      return false;
    final lowerUrl = url.toLowerCase();
    final isYouTube =
        lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be');
    final isMp4 =
        lowerUrl.endsWith('.mp4') || lowerUrl.contains('.mp4?');
    return isYouTube || isMp4;
  }

  void _validateAndSaveVideo(RecordVideoController controller) {
    final url = controller.vidUrlCtrl.text.trim();
    if (url.isEmpty) {
      FlutterToast.error('Video URL is required');
      return;
    }
    if (!_isValidVideoUrl(url)) {
      FlutterToast.error('Please enter a valid YouTube link or MP4 URL');
      return;
    }
    controller.saveVideo();
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap, {bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 16, color: isDanger ? Colors.redAccent : Colors.black87),
      ),
    );
  }

  void _confirmDeleteSubject(RecordVideoController controller, dynamic sub) {
    Get.defaultDialog(
      title: 'Delete Subject?',
      middleText: 'Are you sure you want to delete "${sub.name}"?',
      confirm: TextButton(
        onPressed: () async {
          await controller.deleteSubject(sub.id);
          Get.back();
        },
        child: const Text('Delete', style: TextStyle(color: Colors.red)),
      ),
      cancel:
      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
    );
  }

  void _confirmDeleteClass(
      RecordVideoController controller, RecordClassModel cls) {
    Get.defaultDialog(
      title: 'Delete Class?',
      middleText: 'Are you sure you want to delete ${cls.name}?',
      confirm: TextButton(
        onPressed: () {
          controller.deleteClass(cls.id);
          Get.back();
        },
        child: const Text('Delete', style: TextStyle(color: Colors.red)),
      ),
      cancel:
      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
    );
  }

  void _confirmDeleteVideo(RecordVideoController controller, dynamic video) {
    Get.defaultDialog(
      title: 'Delete Video?',
      middleText: 'Are you sure you want to delete this video?',
      confirm: TextButton(
        onPressed: () async {
          await controller.deleteVideo(video.id);
          Get.back();
        },
        child: const Text('Delete', style: TextStyle(color: Colors.red)),
      ),
      cancel:
      TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildVideoShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.class_outlined, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text('No classes found',
            style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    ),
  );
}