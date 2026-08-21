import 'package:dio/dio.dart';
import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/teacher_model.dart';

class TeacherRepository {
  final Dio _dio = ApiClient.dio;

  // Create Teacher
  Future<TeacherCreateResponse> createTeacher({
    required String firstName,
    required String lastName,
    String? teacherId,
    File? teacherProfile,
    String? gender,
    String? dob,
    String? phone,
    String? altPhone,
    String? email,
    String? address,
    String? qualification,
    int? experience,
    double? salary,
    String? joinDate,
    bool? checkBox,
    List<String>? subjects,
    String? schoolType,
  }) async {
    try {
      if (teacherProfile != null) {
        FormData formData = FormData.fromMap({
          'first_name': firstName,
          'last_name': lastName,
          if (teacherId != null && teacherId.isNotEmpty) 'teacher_id': teacherId,
          if (gender != null && gender.isNotEmpty) 'gender': gender,
          if (dob != null && dob.isNotEmpty) 'dob': dob,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (altPhone != null && altPhone.isNotEmpty) 'alt_phone': altPhone,
          if (email != null && email.isNotEmpty) 'email': email,
          if (address != null && address.isNotEmpty) 'address': address,
          if (qualification != null && qualification.isNotEmpty) 'qualification': qualification,
          if (experience != null) 'experience': experience,
          if (salary != null) 'salary': salary,
          if (joinDate != null && joinDate.isNotEmpty) 'join_date': joinDate,
          if (checkBox != null) 'check_box': checkBox,
          if (subjects != null && subjects.isNotEmpty) 'subjects': subjects,
          if (schoolType != null && schoolType.isNotEmpty) 'school_type': schoolType,
          'teacher_profile': await MultipartFile.fromFile(
            teacherProfile.path,
            filename: teacherProfile.path.split('/').last,
          ),
        });

        final response = await _dio.post(
          ApiUrls.teacherCreate,
          data: formData,
          options: Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        );

        if (response.statusCode == 201) {
          return TeacherCreateResponse.fromJson(response.data);
        } else {
          return TeacherCreateResponse(
            success: false,
            message: 'Failed to create teacher',
            errors: response.data['errors'],
          );
        }
      } else {
        final data = {
          'first_name': firstName,
          'last_name': lastName,
          if (teacherId != null && teacherId.isNotEmpty) 'teacher_id': teacherId,
          if (gender != null && gender.isNotEmpty) 'gender': gender,
          if (dob != null && dob.isNotEmpty) 'dob': dob,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (altPhone != null && altPhone.isNotEmpty) 'alt_phone': altPhone,
          if (email != null && email.isNotEmpty) 'email': email,
          if (address != null && address.isNotEmpty) 'address': address,
          if (qualification != null && qualification.isNotEmpty) 'qualification': qualification,
          if (experience != null) 'experience': experience,
          if (salary != null) 'salary': salary,
          if (joinDate != null && joinDate.isNotEmpty) 'join_date': joinDate,
          if (checkBox != null) 'check_box': checkBox,
          if (subjects != null && subjects.isNotEmpty) 'subjects': subjects,
          if (schoolType != null && schoolType.isNotEmpty) 'school_type': schoolType,
        };

        final response = await _dio.post(
          ApiUrls.teacherCreate,
          data: data,
        );

        if (response.statusCode == 201) {
          return TeacherCreateResponse.fromJson(response.data);
        } else {
          return TeacherCreateResponse(
            success: false,
            message: 'Failed to create teacher',
            errors: response.data['errors'],
          );
        }
      }
    } on DioException catch (e) {
      return TeacherCreateResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message,
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return TeacherCreateResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Get All Teachers
  Future<TeacherListResponse> getTeachers() async {
    try {
      final response = await _dio.get(ApiUrls.teacherList);

      if (response.statusCode == 200) {
        return TeacherListResponse.fromJson(response.data);
      } else {
        return TeacherListResponse(
          success: false,
          data: [],
        );
      }
    } on DioException catch (e) {
      return TeacherListResponse(
        success: false,
        data: [],
        count: 0,
      );
    } catch (e) {
      return TeacherListResponse(
        success: false,
        data: [],
        count: 0,
      );
    }
  }

  // Get Teacher by ID
  Future<TeacherSingleResponse> getTeacherById(int id) async {
    try {
      final response = await _dio.get('${ApiUrls.teacherDetail}$id/');

      if (response.statusCode == 200) {
        return TeacherSingleResponse.fromJson(response.data);
      } else {
        return TeacherSingleResponse(
          success: false,
          message: 'Teacher not found',
        );
      }
    } on DioException catch (e) {
      return TeacherSingleResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message,
      );
    } catch (e) {
      return TeacherSingleResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Update Teacher - FIXED: Only send teacher_profile if file is provided
  Future<TeacherSingleResponse> updateTeacher({
    required int id,
    required String firstName,
    required String lastName,
    String? teacherId,
    String? gender,
    String? dob,
    String? phone,
    String? altPhone,
    String? email,
    String? address,
    String? qualification,
    int? experience,
    double? salary,
    String? joinDate,
    bool? checkBox,
    List<String>? subjects,
    String? schoolType,
    File? teacherProfile,
  }) async {
    try {
      Map<String, dynamic> data = {
        'first_name': firstName,
        'last_name': lastName,
        if (teacherId != null && teacherId.isNotEmpty) 'teacher_id': teacherId,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (dob != null && dob.isNotEmpty) 'dob': dob,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (altPhone != null && altPhone.isNotEmpty) 'alt_phone': altPhone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (address != null && address.isNotEmpty) 'address': address,
        if (qualification != null && qualification.isNotEmpty) 'qualification': qualification,
        if (experience != null) 'experience': experience,
        if (salary != null) 'salary': salary,
        if (joinDate != null && joinDate.isNotEmpty) 'join_date': joinDate,
        if (checkBox != null) 'check_box': checkBox,
        if (subjects != null && subjects.isNotEmpty) 'subjects': subjects,
        if (schoolType != null && schoolType.isNotEmpty) 'school_type': schoolType,
      };

      // If a new profile image is provided, use multipart/form-data
      if (teacherProfile != null) {
        FormData formData = FormData.fromMap({
          ...data,
          'teacher_profile': await MultipartFile.fromFile(
            teacherProfile.path,
            filename: teacherProfile.path.split('/').last,
          ),
        });

        final response = await _dio.put(
          '${ApiUrls.teacherDetail}$id/',
          data: formData,
          options: Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        );

        if (response.statusCode == 200) {
          return TeacherSingleResponse.fromJson(response.data);
        } else {
          return TeacherSingleResponse(
            success: false,
            message: 'Failed to update teacher',
            errors: response.data['errors'],
          );
        }
      } else {
        // If no new image, use JSON request without teacher_profile field
        final response = await _dio.put(
          '${ApiUrls.teacherDetail}$id/',
          data: data,
        );

        if (response.statusCode == 200) {
          return TeacherSingleResponse.fromJson(response.data);
        } else {
          return TeacherSingleResponse(
            success: false,
            message: 'Failed to update teacher',
            errors: response.data['errors'],
          );
        }
      }
    } on DioException catch (e) {
      return TeacherSingleResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message,
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      return TeacherSingleResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Delete Teacher
  Future<Map<String, dynamic>> deleteTeacher(int id) async {
    try {
      final response = await _dio.delete('${ApiUrls.teacherDetail}$id/');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Teacher deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to delete teacher',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}