// lib/feature/schedule/repository/event_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/event_model.dart';

class EventRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<SchoolEvent>> getEvents(int schoolId) async {
    try {
      final response = await _dio.get(ApiUrls.eventListBySchool(schoolId));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => SchoolEvent.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  Future<bool> createEvent({
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
    XFile? bannerImage, // Changed to XFile for Web Support
  }) async {
    try {
      Map<String, dynamic> data = {
        "title": title,
        "description": description,
        "category": category,
        "venue": venue,
        "start_date": startDate,
        "end_date": endDate,
        "start_time": startTime,
        "end_time": endTime,
        "audience": audience,
        "status": status,
        "is_pinned": isPinned,
      };

      if (bannerImage != null) {
        final bytes = await bannerImage.readAsBytes();
        data['banner'] = MultipartFile.fromBytes(bytes, filename: bannerImage.name);
      }

      final response = await _dio.post(
        ApiUrls.eventCreateBySchool(schoolId),
        data: FormData.fromMap(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create event: $e');
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
      Map<String, dynamic> data = {
        "title": title,
        "description": description,
        "category": category,
        "venue": venue,
        "start_date": startDate,
        "end_date": endDate,
        "start_time": startTime,
        "end_time": endTime,
        "audience": audience,
        "status": status,
        "is_pinned": isPinned,
      };

      if (bannerImage != null) {
        final bytes = await bannerImage.readAsBytes();
        data['banner'] = MultipartFile.fromBytes(bytes, filename: bannerImage.name);
      }

      final response = await _dio.put(
        ApiUrls.eventDetail(schoolId, eventId),
        data: FormData.fromMap(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<bool> deleteEvent({required int schoolId, required int eventId}) async {
    try {
      final response = await _dio.delete(ApiUrls.eventDetail(schoolId, eventId));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}