// lib/feature/teachers/repository/teacher_repository.dart

import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert'; // ✅ Import jsonEncode
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/teacher_model.dart';

class TeacherRepository {
  final Dio _dio = ApiClient.dio;

  Future<TeacherListResponse> getTeachers({int? schoolId}) async {
    try {
      final url = schoolId != null
          ? ApiUrls.teacherBySchool(schoolId)
          : ApiUrls.teacherList;

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return TeacherListResponse.fromJson(response.data);
      } else {
        return TeacherListResponse(success: false, data: []);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        return TeacherListResponse(success: true, data: []);
      }
      return TeacherListResponse(success: false, data: []);
    } catch (e) {
      return TeacherListResponse(success: false, data: []);
    }
  }

  // ✅ Helper to build FormData correctly for Web
  FormData _buildFormData(TeacherModel teacher) {
    final mapData = teacher.toJson();
    mapData.removeWhere((key, value) => value == null);

    final formData = FormData();

    mapData.forEach((key, value) {
      if (key == 'subjects' && value is List) {
        // ✅ Encode list to JSON array string so backend parses it correctly.
        // Postman me bhi aise hi JSON string bheja gaya tha.
        formData.fields.add(MapEntry(key, jsonEncode(value)));
      } else if (key == 'check_box' && value is bool) {
        formData.fields.add(MapEntry(key, value ? 'true' : 'false'));
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    return formData;
  }

  // Create Teacher
  Future<TeacherCreateResponse> createTeacher({
    required TeacherModel teacher,
    File? teacherProfile,
    Uint8List? teacherProfileBytes,
  }) async {
    try {
      FormData formData = _buildFormData(teacher);

      if (kIsWeb) {
        if (teacherProfileBytes != null && teacherProfileBytes.isNotEmpty) {
          formData.files.add(MapEntry('teacher_profile', MultipartFile.fromBytes(
            teacherProfileBytes, filename: 'profile.jpg', contentType: DioMediaType.parse('image/jpeg'),
          )));
        }
      } else {
        if (teacherProfile != null) {
          formData.files.add(MapEntry('teacher_profile', await MultipartFile.fromFile(
            teacherProfile.path, filename: teacherProfile.path.split('/').last,
          )));
        }
      }

      final response = await _dio.post(
        ApiUrls.teacherCreate,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TeacherCreateResponse.fromJson(response.data);
      } else {
        return TeacherCreateResponse(
          success: false,
          message: response.data?['message'] ?? 'Failed to create teacher',
          errors: response.data?['errors'],
        );
      }
    } on DioException catch (e) {
      return TeacherCreateResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message,
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return TeacherCreateResponse(success: false, message: 'Error: ${e.toString()}');
    }
  }

  // Update Teacher
  Future<TeacherSingleResponse> updateTeacher({
    required int id,
    required TeacherModel teacher,
    File? teacherProfile,
    Uint8List? teacherProfileBytes,
  }) async {
    try {
      FormData formData = _buildFormData(teacher);

      if (kIsWeb) {
        if (teacherProfileBytes != null && teacherProfileBytes.isNotEmpty) {
          formData.files.add(MapEntry('teacher_profile', MultipartFile.fromBytes(
            teacherProfileBytes, filename: 'profile.jpg', contentType: DioMediaType.parse('image/jpeg'),
          )));
        }
      } else {
        if (teacherProfile != null) {
          formData.files.add(MapEntry('teacher_profile', await MultipartFile.fromFile(
            teacherProfile.path, filename: teacherProfile.path.split('/').last,
          )));
        }
      }

      final response = await _dio.put(
        '${ApiUrls.teacherDetail}$id/',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return TeacherSingleResponse.fromJson(response.data);
      } else {
        return TeacherSingleResponse(
          success: false,
          message: response.data?['message'] ?? 'Failed to update teacher',
          errors: response.data?['errors'],
        );
      }
    } on DioException catch (e) {
      return TeacherSingleResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message,
        errors: e.response?.data?['errors'],
      );
    } catch (e) {
      return TeacherSingleResponse(success: false, message: 'Error: ${e.toString()}');
    }
  }

  // Delete Teacher
  Future<Map<String, dynamic>> deleteTeacher(int id) async {
    try {
      final response = await _dio.delete('${ApiUrls.teacherDetail}$id/');
      if (response.statusCode == 200) {
        return {'success': true, 'message': response.data['message'] ?? 'Deleted'};
      } else {
        return {'success': false, 'message': response.data['message'] ?? 'Failed to delete'};
      }
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? e.message};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}