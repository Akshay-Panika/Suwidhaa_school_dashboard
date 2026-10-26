// lib/feature/schedule/controller/notice_controller.dart
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widget/flutter_toast.dart';
import '../../main/controller/school_type_controller.dart';
import '../model/notice_model.dart';
import '../repository/notice_repository.dart';

class NoticeController extends GetxController {
  final NoticeRepository _repository = NoticeRepository();
  final SchoolTypeController schoolController = Get.find<SchoolTypeController>();

  var notices = <NoticeModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(schoolController.selectedSchoolType, (_) => fetchNotices());
  }

  Future<void> fetchNotices() async {
    final schoolId = schoolController.selectedSchoolType.value?.id;
    try {
      isLoading.value = true;
      if (schoolId != null) {
        final data = await _repository.getNoticesBySchool(schoolId);
        notices.assignAll(data);
      } else {
        final data = await _repository.getAllNotices();
        notices.assignAll(data);
      }
    } catch (e) {
      FlutterToast.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addNotice({
    required String title,
    required String description,
    required String priority,
    required String audience,
    required String assignedClass,
    XFile? attachmentImage,
  }) async {
    final schoolId = schoolController.selectedSchoolType.value?.id;

    try {
      final success = await _repository.createNotice(
        schoolId: schoolId,
        title: title,
        description: description,
        priority: priority,
        audience: audience,
        assignedClass: assignedClass,
        attachmentImage: attachmentImage,
      );

      if (success) fetchNotices();
      return success;
    } catch (e) {
      FlutterToast.error(e.toString());
      return false;
    }
  }

  // 👇 ADDED UPDATE NOTICE
  Future<bool> updateNotice({
    required int id,
    required String title,
    required String description,
    required String priority,
    required String audience,
    required String assignedClass,
    XFile? attachmentImage,
  }) async {
    try {
      final success = await _repository.updateNotice(
        id: id,
        title: title,
        description: description,
        priority: priority,
        audience: audience,
        assignedClass: assignedClass,
        attachmentImage: attachmentImage,
      );

      if (success) fetchNotices();
      return success;
    } catch (e) {
      FlutterToast.error(e.toString());
      return false;
    }
  }

  Future<bool> deleteNotice(int id) async {
    try {
      final success = await _repository.deleteNotice(id);
      if (success) fetchNotices();
      return success;
    } catch (e) {
      FlutterToast.error(e.toString());
      return false;
    }
  }
}