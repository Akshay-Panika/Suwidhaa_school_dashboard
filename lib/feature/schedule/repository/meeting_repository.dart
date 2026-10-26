// lib/feature/schedule/repository/meeting_repository.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/meeting_model.dart';

class MeetingRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<MeetingModel>> getMeetings(int schoolId) async {
    try {
      final response = await _dio.get(ApiUrls.meetingList(schoolId));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MeetingModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("GET MEETING ERROR: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'Failed to load meetings');
    }
  }

  Future<bool> createMeeting({
    required int schoolId,
    required String title,
    required String date,
    required String time,
    required String forMeeting,
    String? className,
    String? zoomUrl,
  }) async {
    try {
      Map<String, dynamic> data = {
        "title": title,
        "date": date,
        "time": time,
        "for_meeting": forMeeting,
      };

      if (className != null && className.isNotEmpty) data['class_name'] = className;
      if (zoomUrl != null && zoomUrl.isNotEmpty) data['zoom_url'] = zoomUrl;

      // Debug print to see what we are sending
      print("SENDING MEETING DATA: $data");

      final response = await _dio.post(
        ApiUrls.meetingCreate(schoolId),
        data: FormData.fromMap(data),
      );
      return response.statusCode == 201;
    } on DioException catch (e) {
      // 👇 This will print the EXACT error from Django in your terminal
      print("CREATE MEETING ERROR: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'Failed to create meeting');
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
      Map<String, dynamic> data = {
        "title": title,
        "date": date,
        "time": time,
        "for_meeting": forMeeting,
      };

      if (className != null && className.isNotEmpty) data['class_name'] = className;
      if (zoomUrl != null && zoomUrl.isNotEmpty) data['zoom_url'] = zoomUrl;

      final response = await _dio.put(
        ApiUrls.meetingDetail(schoolId, id),
        data: FormData.fromMap(data),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("UPDATE MEETING ERROR: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'Failed to update meeting');
    }
  }

  Future<bool> deleteMeeting({required int schoolId, required int id}) async {
    try {
      final response = await _dio.delete(ApiUrls.meetingDelete(schoolId, id));
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("DELETE MEETING ERROR: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'Failed to delete meeting');
    }
  }
}