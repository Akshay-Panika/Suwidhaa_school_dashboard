// lib/feature/schedule/controller/event_controller.dart
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../model/event_model.dart';
import '../repository/event_repository.dart';

class EventController extends GetxController {
  final EventRepository _repository = EventRepository();

  var isLoading = false.obs;
  var events = <SchoolEvent>[].obs;

  Future<void> fetchEvents(int schoolId) async {
    try {
      isLoading.value = true;
      final result = await _repository.getEvents(schoolId);
      events.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addEvent({
    required int schoolId,
    required String title,
    required String description,
    required String category,
    required String venue,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required String audience,
    required String status,
    required bool isPinned,
    XFile? bannerImage,
  }) async {
    try {
      isLoading.value = true;
      bool success = await _repository.createEvent(
        schoolId: schoolId,
        title: title,
        description: description,
        category: category,
        venue: venue,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        audience: audience,
        status: status,
        isPinned: isPinned,
        bannerImage: bannerImage,
      );

      if (success) {
        await fetchEvents(schoolId);
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

  Future<bool> updateEvent({
    required int schoolId,
    required int eventId,
    required String title,
    required String description,
    required String category,
    required String venue,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required String audience,
    required String status,
    required bool isPinned,
    XFile? bannerImage,
  }) async {
    try {
      isLoading.value = true;
      bool success = await _repository.updateEvent(
        schoolId: schoolId,
        eventId: eventId,
        title: title,
        description: description,
        category: category,
        venue: venue,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        audience: audience,
        status: status,
        isPinned: isPinned,
        bannerImage: bannerImage,
      );

      if (success) {
        await fetchEvents(schoolId);
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

  Future<bool> deleteEvent({required int schoolId, required int eventId}) async {
    try {
      isLoading.value = true;
      bool success = await _repository.deleteEvent(schoolId: schoolId, eventId: eventId);
      if (success) {
        await fetchEvents(schoolId);
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