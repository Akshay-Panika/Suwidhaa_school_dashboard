// lib/feature/schedule/repository/notice_repository.dart
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/notice_model.dart';

class NoticeRepository {
  Future<List<NoticeModel>> getAllNotices() async {
    try {
      final response = await ApiClient.dio.get(ApiUrls.noticeList);
      if (response.statusCode == 200) {
        final List list = response.data['data'];
        return list.map((e) => NoticeModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load notices');
    }
  }

  Future<List<NoticeModel>> getNoticesBySchool(int schoolId) async {
    try {
      final response = await ApiClient.dio.get(ApiUrls.noticeListBySchool(schoolId));
      if (response.statusCode == 200) {
        final List list = response.data['data'];
        return list.map((e) => NoticeModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load notices');
    }
  }

  Future<bool> createNotice({
    int? schoolId,
    required String title,
    required String description,
    required String priority,
    required String audience,
    required String assignedClass,
    XFile? attachmentImage,
  }) async {
    try {
      Map<String, dynamic> data = {
        if (schoolId != null) "school_id": schoolId,
        "title": title,
        "description": description,
        "priority": priority,
        "audience": audience,
        "assigned_class": assignedClass,
      };

      if (attachmentImage != null) {
        final bytes = await attachmentImage.readAsBytes();
        data['attachment'] = MultipartFile.fromBytes(bytes, filename: attachmentImage.name);
      }

      final response = await ApiClient.dio.post(
        ApiUrls.noticeCreate,
        data: FormData.fromMap(data),
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create notice');
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
      Map<String, dynamic> data = {
        "title": title,
        "description": description,
        "priority": priority,
        "audience": audience,
        "assigned_class": assignedClass,
      };

      if (attachmentImage != null) {
        final bytes = await attachmentImage.readAsBytes();
        data['attachment'] = MultipartFile.fromBytes(bytes, filename: attachmentImage.name);
      }

      final response = await ApiClient.dio.put(
        ApiUrls.noticeDetail(id),
        data: FormData.fromMap(data),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update notice');
    }
  }

  Future<bool> deleteNotice(int id) async {
    try {
      final response = await ApiClient.dio.delete(ApiUrls.noticeDetail(id));
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete notice');
    }
  }
}