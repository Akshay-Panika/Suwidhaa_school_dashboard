// lib/feature/student/repository/student_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/student_model.dart';

class StudentRepository {
  final Dio dio = ApiClient.dio;

  // Get all students OR filter by school
  Future<List<StudentModel>> getStudents({int? schoolId}) async {
    try {
      // Use specific URL if schoolId is provided, otherwise fetch all
      final url = schoolId != null
          ? ApiUrls.studentBySchool(schoolId)
          : ApiUrls.studentList;

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> studentData = data['data'] ?? [];
          return studentData.map((json) => StudentModel.fromApiJson(json)).toList();
        }
      }
      return [];
    }  on DioException catch (e) {
      // ✅ Handle 400 Bad Request (e.g., "No students found for school id")
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        return []; // Return empty list instead of throwing an error
      }
      throw Exception('Failed to load students: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }


  // Create student with file upload
  Future<StudentModel> createStudent({
    required StudentModel student,
    File? studentProfile,
    Uint8List? studentProfileBytes,
  }) async {
    try {
      final mapData = student.toJson();

      // Clean up map for FormData (remove nulls to avoid "null" string issues)
      mapData.removeWhere((key, value) => value == null);

      FormData formData = FormData.fromMap(mapData);

      // Handle file upload based on platform
      if (kIsWeb) {
        if (studentProfileBytes != null && studentProfileBytes.isNotEmpty) {
          final multipartFile = MultipartFile.fromBytes(
            studentProfileBytes,
            filename: 'profile.jpg',
            contentType: DioMediaType.parse('image/jpeg'),
          );
          formData.files.add(MapEntry('student_profile', multipartFile));
        }
      } else {
        if (studentProfile != null) {
          final multipartFile = await MultipartFile.fromFile(
            studentProfile.path,
            filename: studentProfile.path.split('/').last,
            contentType: DioMediaType.parse('image/jpeg'),
          );
          formData.files.add(MapEntry('student_profile', multipartFile));
        }
      }

      final response = await dio.post(
        ApiUrls.studentCreate,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return StudentModel.fromApiJson(data['data']);
        }
        throw Exception('API returned error: ${data['message']}');
      }
      throw Exception('Failed to create student: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update student
  Future<StudentModel> updateStudent({
    required int id,
    required StudentModel student,
    File? studentProfile,
    Uint8List? studentProfileBytes,
  }) async {
    try {
      final mapData = student.toJson();
      mapData.removeWhere((key, value) => value == null);

      FormData formData = FormData.fromMap(mapData);

      if (kIsWeb) {
        if (studentProfileBytes != null && studentProfileBytes.isNotEmpty) {
          final multipartFile = MultipartFile.fromBytes(
            studentProfileBytes,
            filename: 'profile.jpg',
            contentType: DioMediaType.parse('image/jpeg'),
          );
          formData.files.add(MapEntry('student_profile', multipartFile));
        }
      } else {
        if (studentProfile != null) {
          final multipartFile = await MultipartFile.fromFile(
            studentProfile.path,
            filename: studentProfile.path.split('/').last,
            contentType: DioMediaType.parse('image/jpeg'),
          );
          formData.files.add(MapEntry('student_profile', multipartFile));
        }
      }

      final response = await dio.put(
        '${ApiUrls.studentDetail}$id/',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return StudentModel.fromApiJson(data['data']);
        }
        throw Exception('API returned error: ${data['message']}');
      }
      throw Exception('Failed to update student: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete student
  Future<bool> deleteStudent(int id) async {
    try {
      final response = await dio.delete('${ApiUrls.studentDetail}$id/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}