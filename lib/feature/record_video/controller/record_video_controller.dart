import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widget/flutter_toast.dart';
import '../model/record_class_model.dart';
import '../model/record_subject_model.dart';
import '../model/record_video_model.dart';
import '../repository/record_video_repository.dart';

class RecordVideoController extends GetxController {
  final RecordVideoRepository _repo = RecordVideoRepository();

  final RxList<RecordClassModel> classes = <RecordClassModel>[].obs;
  final RxList<RecordSubjectModel> subjects = <RecordSubjectModel>[].obs;
  final RxList<RecordVideoModel> videos = <RecordVideoModel>[].obs;

  final RxBool isLoadingClasses = false.obs;
  final RxBool isLoadingVideos = false.obs;
  final RxBool isSavingSubject = false.obs;
  final RxBool isSavingVideo = false.obs;

  final Rx<RecordClassModel?> selectedClass = Rx<RecordClassModel?>(null);
  final RxInt selectedSubjectId = 0.obs;

  final RxBool isAddingClass = false.obs;
  final Rx<RecordClassModel?> editingClass = Rx<RecordClassModel?>(null);
  final TextEditingController classCtrl = TextEditingController();

  final Rx<RecordSubjectModel?> editingSubject = Rx<RecordSubjectModel?>(null);
  final TextEditingController subjectCtrl = TextEditingController();

  final Rx<RecordVideoModel?> editingVideo = Rx<RecordVideoModel?>(null);
  final TextEditingController vidTitleCtrl = TextEditingController();
  final TextEditingController vidUrlCtrl = TextEditingController();
  final TextEditingController vidDurationCtrl = TextEditingController();
  final TextEditingController vidRatingCtrl = TextEditingController();
  final RxInt formSubjectId = 0.obs;
  final Rx<PlatformFile?> videoThumbnail = Rx<PlatformFile?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    isLoadingClasses.value = true;
    try {
      classes.value = await _repo.getClasses();
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoadingClasses.value = false;
    }
  }

  Future<void> fetchSubjects(int classId) async {
    try {
      subjects.value = await _repo.getSubjects(classId);
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> fetchVideos(int classId, {int? subjectId}) async {
    isLoadingVideos.value = true;
    try {
      videos.value = await _repo.getVideos(classId, subjectId: subjectId);
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoadingVideos.value = false;
    }
  }

  void selectClass(RecordClassModel? cls) {
    selectedClass.value = cls;
    isAddingClass.value = false;
    clearVideoForm();

    if (cls != null) {
      selectedSubjectId.value = 0;
      fetchSubjects(cls.id);
      fetchVideos(cls.id);
    } else {
      subjects.clear();
      videos.clear();
    }
  }

  void selectSubject(int? subjectId) {
    selectedSubjectId.value = subjectId ?? 0;
    if (selectedClass.value != null) {
      fetchVideos(selectedClass.value!.id, subjectId: subjectId == 0 ? null : subjectId);
    }
  }

  // ================= CLASS =================
  void openAddClassForm() {
    isAddingClass.value = true;
    editingClass.value = null;
    classCtrl.clear();
    selectedClass.value = null;
  }

  void openEditClassForm(RecordClassModel cls) {
    isAddingClass.value = true;
    editingClass.value = cls;
    classCtrl.text = cls.name;
    selectedClass.value = null;
  }

  Future<void> saveClass() async {
    final name = classCtrl.text.trim();
    if (name.isEmpty) return FlutterToast.error('Class name required');
    try {
      if (editingClass.value == null) {
        await _repo.createClass(name);
      } else {
        await _repo.updateClass(editingClass.value!.id, name);
      }
      isAddingClass.value = false;
      fetchClasses();
      FlutterToast.success('Class saved');
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> deleteClass(int id) async {
    try {
      await _repo.deleteClass(id);
      if (selectedClass.value?.id == id) selectedClass.value = null;
      fetchClasses();
      FlutterToast.success('Class deleted');
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ================= SUBJECT =================
  void editSubject(RecordSubjectModel sub) {
    editingSubject.value = sub;
    subjectCtrl.text = sub.name;
  }

  void cancelSubjectEdit() {
    editingSubject.value = null;
    subjectCtrl.clear();
  }

  Future<void> saveSubject() async {
    final name = subjectCtrl.text.trim();
    if (name.isEmpty) return FlutterToast.error('Subject name required');
    if (selectedClass.value == null) return FlutterToast.error('Class required');

    isSavingSubject.value = true;
    try {
      if (editingSubject.value == null) {
        await _repo.createSubject(selectedClass.value!.id, name);
        FlutterToast.success('Subject added');
      } else {
        await _repo.updateSubject(selectedClass.value!.id, editingSubject.value!.id, name);
        FlutterToast.success('Subject updated');
      }
      cancelSubjectEdit();
      fetchSubjects(selectedClass.value!.id);
      fetchClasses();
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSavingSubject.value = false;
    }
  }

  Future<void> deleteSubject(int id) async {
    if (selectedClass.value == null) return;
    try {
      await _repo.deleteSubject(selectedClass.value!.id, id);
      fetchSubjects(selectedClass.value!.id);
      fetchClasses();
      FlutterToast.success('Subject deleted');
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ================= VIDEO =================
  void editVideo(RecordVideoModel video) {
    editingVideo.value = video;
    vidTitleCtrl.text = video.title;
    vidUrlCtrl.text = video.videoUrl;
    vidDurationCtrl.text = video.duration;
    vidRatingCtrl.text = video.rating.toString();
    videoThumbnail.value = null;

    final sub = subjects.firstWhereOrNull((s) => s.name == video.subjectName);
    formSubjectId.value = sub?.id ?? (subjects.isNotEmpty ? subjects.first.id : 0);
  }

  void clearVideoForm() {
    editingVideo.value = null;
    vidTitleCtrl.clear();
    vidUrlCtrl.clear();
    vidDurationCtrl.clear();
    vidRatingCtrl.text = '5.0';
    videoThumbnail.value = null;
    formSubjectId.value = subjects.isNotEmpty ? subjects.first.id : 0;
  }

  Future<void> saveVideo() async {
    final title = vidTitleCtrl.text.trim();
    final url = vidUrlCtrl.text.trim();
    final duration = vidDurationCtrl.text.trim();
    final rating = double.tryParse(vidRatingCtrl.text) ?? 5.0;

    if (title.isEmpty) return FlutterToast.error('Title is required');
    if (url.isEmpty) return FlutterToast.error('Video URL is required');
    if (duration.isEmpty) return FlutterToast.error('Duration is required');
    if (formSubjectId.value == 0) return FlutterToast.error('Please select a subject');

    isSavingVideo.value = true;
    try {
      if (editingVideo.value == null) {
        await _repo.createVideo(
          selectedClass.value!.id,
          title: title,
          subjectId: formSubjectId.value,
          videoUrl: url,
          duration: duration,
          rating: rating,
          thumbnail: videoThumbnail.value,
        );
        FlutterToast.success('Video added successfully');
      } else {
        await _repo.updateVideo(
          selectedClass.value!.id,
          editingVideo.value!.id,
          title: title,
          subjectId: formSubjectId.value,
          videoUrl: url,
          duration: duration,
          rating: rating,
          thumbnail: videoThumbnail.value,
        );
        FlutterToast.success('Video updated successfully');
      }
      clearVideoForm();
      fetchVideos(selectedClass.value!.id);
      fetchClasses();
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSavingVideo.value = false;
    }
  }

  Future<void> deleteVideo(int videoId) async {
    if (selectedClass.value == null) return;
    try {
      await _repo.deleteVideo(selectedClass.value!.id, videoId);
      fetchVideos(selectedClass.value!.id);
      fetchClasses();
      FlutterToast.success('Video deleted');
    } catch (e) {
      FlutterToast.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}