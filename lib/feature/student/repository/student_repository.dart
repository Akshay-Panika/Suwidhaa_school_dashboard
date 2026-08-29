// lib/repositories/student_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import '../../../core/network/api_client.dart';
import '../model/student_model.dart';

class StudentRepository {
  final Dio dio = ApiClient.dio;

  // Get all students
  Future<List<StudentModel>> getStudents() async {
    try {
      final response = await dio.get('v1/school/student/list/');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> studentData = data['data'] ?? [];
          return studentData.map((json) => StudentModel.fromApiJson(json)).toList();
        }
      }
      return [];
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
      FormData formData = FormData.fromMap({
        'first_name': student.firstName,
        'middle_name': student.middleName,
        'last_name': student.lastName,
        'dob': student.dob,
        'gender': student.gender,
        'father_name': student.fatherName,
        'mother_name': student.motherName,
        'parent_phone': student.parentPhone,
        'alternative_phone': student.alternativePhone ?? '',
        'adhar_number': student.adharNumber,
        'SSSMID': student.sssmid,
        'student_class': student.studentClass,
        'roll_number': student.rollNumber,
        'address': student.address,
        'caste_category': student.casteCategory,
        'fee_status': student.feeStatus,
        'fee_amount': student.feeAmount,
        'paid_amount': student.paidAmount,
        'check_box': student.checkBox,
        'school_type': student.schoolType ?? '',
        'student_id_card': student.studentIdCard ?? '',
      });

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
        'v1/school/student/create/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
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
      FormData formData = FormData.fromMap({
        'first_name': student.firstName,
        'middle_name': student.middleName,
        'last_name': student.lastName,
        'dob': student.dob,
        'gender': student.gender,
        'father_name': student.fatherName,
        'mother_name': student.motherName,
        'parent_phone': student.parentPhone,
        'alternative_phone': student.alternativePhone ?? '',
        'adhar_number': student.adharNumber,
        'SSSMID': student.sssmid,
        'student_class': student.studentClass,
        'roll_number': student.rollNumber,
        'address': student.address,
        'caste_category': student.casteCategory,
        'fee_status': student.feeStatus,
        'fee_amount': student.feeAmount,
        'paid_amount': student.paidAmount,
        'check_box': student.checkBox,
        'school_type': student.schoolType ?? '',
        'student_id_card': student.studentIdCard ?? '',
      });

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

      final response = await dio.put(
        'v1/school/student/$id/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
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
      final response = await dio.delete('v1/school/student/$id/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}