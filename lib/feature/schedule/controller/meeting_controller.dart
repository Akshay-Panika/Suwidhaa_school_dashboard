// lib/feature/schedule/controller/meeting_controller.dart

import 'package:get/get.dart';
import '../model/meeting_model.dart';
import '../repository/meeting_repository.dart';

class MeetingController extends GetxController {
  final MeetingRepository _repository = MeetingRepository();

  var isLoading = false.obs;
  var meetings = <MeetingModel>[].obs;

  Future<void> fetchMeetings(int schoolId) async {
    try {
      isLoading.value = true;
      final result = await _repository.getMeetings(schoolId);
      meetings.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addMeeting({
    required int schoolId,
    required String title,
    required String date,
    required String time,
    required String forMeeting,
    String? className,
    String? zoomUrl,
  }) async {
    try {
      isLoading.value = true;
      bool success = await _repository.createMeeting(
        schoolId: schoolId,
        title: title,
        date: date,
        time: time,
        forMeeting: forMeeting,
        className: className,
        zoomUrl: zoomUrl,
      );

      if (success) {
        await fetchMeetings(schoolId);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMeeting({
    required int schoolId,
    required int id,
    required String title,
    required String date,
    required String time,
    required String forMeeting,
    String? className,
    String? zoomUrl,
  }) async {
    try {
      isLoading.value = true;
      bool success = await _repository.updateMeeting(
        schoolId: schoolId,
        id: id,
        title: title,
        date: date,
        time: time,
        forMeeting: forMeeting,
        className: className,
        zoomUrl: zoomUrl,
      );

      if (success) {
        await fetchMeetings(schoolId);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteMeeting({required int schoolId, required int id}) async {
    try {
      isLoading.value = true;
      bool success = await _repository.deleteMeeting(schoolId: schoolId, id: id);
      if (success) {
        await fetchMeetings(schoolId);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}