// lib/repositories/teacher_repository.dart
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/teacher_model.dart';

class TeacherRepository {
  final Dio _dio = ApiClient.dio;

  // Create Teacher - FIXED
  Future<TeacherCreateResponse> createTeacher({
    required String firstName,
    required String lastName,
    String? gender,
    String? dob,
    String? phone,
    String? altPhone,
    String? email,
    String? teacherIdCard,
    String? address,
    String? qualification,
    int? experience,
    double? salary,
    String? joinDate,
    bool? checkBox,
    List<String>? subjects,
    String? schoolType,
    File? teacherProfile,
    Uint8List? teacherProfileBytes,
  }) async {
    try {
      // Build data map - ONLY include fields that have values
      Map<String, dynamic> data = {};

      // Required fields
      data['first_name'] = firstName;
      data['last_name'] = lastName;

      // Optional fields - only add if they have values
      if (gender != null && gender.isNotEmpty) data['gender'] = gender;
      if (dob != null && dob.isNotEmpty) data['dob'] = dob;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (altPhone != null && altPhone.isNotEmpty) data['alt_phone'] = altPhone;
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (teacherIdCard != null && teacherIdCard.isNotEmpty) data['teacher_id_card'] = teacherIdCard;
      if (address != null && address.isNotEmpty) data['address'] = address;
      if (qualification != null && qualification.isNotEmpty) data['qualification'] = qualification;
      if (experience != null) data['experience'] = experience;
      if (salary != null) data['salary'] = salary;
      if (joinDate != null && joinDate.isNotEmpty) data['join_date'] = joinDate;
      if (checkBox != null) data['check_box'] = checkBox;
      if (schoolType != null && schoolType.isNotEmpty) data['school_type'] = schoolType;

      // CRITICAL: Subjects must be a List<String>, NOT a String
      if (subjects != null && subjects.isNotEmpty) {
        data['subjects'] = subjects;
      }

      // Debug log
      print('📤 Sending Teacher Data:');
      print('   firstName: $firstName');
      print('   lastName: $lastName');
      print('   subjects: $subjects (${subjects?.runtimeType})');
      print('   schoolType: $schoolType');

      // Handle file upload
      if (kIsWeb) {
        if (teacherProfileBytes != null && teacherProfileBytes.isNotEmpty) {
          FormData formData = FormData.fromMap(data);
          final multipartFile = MultipartFile.fromBytes(
            teacherProfileBytes,
            filename: 'profile.jpg',
            contentType: DioMediaType.parse('image/jpeg'),
          );
          formData.files.add(MapEntry('teacher_profile', multipartFile));

          final response = await _dio.post(
            ApiUrls.teacherCreate,
            data: formData,
            options: Options(
              headers: {'Content-Type': 'multipart/form-data'},
              validateStatus: (status) => status! < 500,
            ),
          );

          print('📥 Response Status: ${response.statusCode}');
          print('📥 Response Data: ${response.data}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            return TeacherCreateResponse.fromJson(response.data);
          } else {
            return TeacherCreateResponse(
              success: false,
              message: response.data?['message'] ?? 'Failed to create teacher',
              errors: response.data?['errors'],
            );
          }
        } else {
          final response = await _dio.post(
            ApiUrls.teacherCreate,
            data: data,
            options: Options(
              validateStatus: (status) => status! < 500,
            ),
          );

          print('📥 Response Status: ${response.statusCode}');
          print('📥 Response Data: ${response.data}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            return TeacherCreateResponse.fromJson(response.data);
          } else {
            return TeacherCreateResponse(
              success: false,
              message: response.data?['message'] ?? 'Failed to create teacher',
              errors: response.data?['errors'],
            );
          }
        }
      } else {
        if (teacherProfile != null) {
          FormData formData = FormData.fromMap(data);
          final multipartFile = await MultipartFile.fromFile(
            teacherProfile.path,
            filename: teacherProfile.path.split('/').last,
          );
          formData.files.add(MapEntry('teacher_profile', multipartFile));

          final response = await _dio.post(
            ApiUrls.teacherCreate,
            data: formData,
            options: Options(
              headers: {'Content-Type': 'multipart/form-data'},
              validateStatus: (status) => status! < 500,
            ),
          );

          print('📥 Response Status: ${response.statusCode}');
          print('📥 Response Data: ${response.data}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            return TeacherCreateResponse.fromJson(response.data);
          } else {
            return TeacherCreateResponse(
              success: false,
              message: response.data?['message'] ?? 'Failed to create teacher',
              errors: response.data?['errors'],
            );
          }
        } else {
          final response = await _dio.post(
            ApiUrls.teacherCreate,
            data: data,
            options: Options(
              validateStatus: (status) => status! < 500,
            ),
          );

          print('📥 Response Status: ${response.statusCode}');
          print('📥 Response Data: ${response.data}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            return TeacherCreateResponse.fromJson(response.data);
          } else {
            return TeacherCreateResponse(
              success: false,
              message: response.data?['message'] ?? 'Failed to create teacher',
              errors: response.data?['errors'],
            );
          }
        }
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.data}');
      return TeacherCreateResponse(
        success: false,
        message: e.response?.data['message'] ?? e.message,
        errors: e.response?.data['errors'],
      );
    } catch (e) {
      print('❌ Error: $e');
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

  // Update Teacher
  Future<TeacherSingleResponse> updateTeacher({
    required int id,
    required String firstName,
    required String lastName,
    String? gender,
    String? dob,
    String? phone,
    String? altPhone,
    String? email,
    String? teacherIdCard,
    String? address,
    String? qualification,
    int? experience,
    double? salary,
    String? joinDate,
    bool? checkBox,
    List<String>? subjects,
    String? schoolType,
    File? teacherProfile,
    Uint8List? teacherProfileBytes,
  }) async {
    try {
      Map<String, dynamic> data = {};

      data['first_name'] = firstName;
      data['last_name'] = lastName;

      if (gender != null && gender.isNotEmpty) data['gender'] = gender;
      if (dob != null && dob.isNotEmpty) data['dob'] = dob;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (altPhone != null && altPhone.isNotEmpty) data['alt_phone'] = altPhone;
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (teacherIdCard != null && teacherIdCard.isNotEmpty) data['teacher_id_card'] = teacherIdCard;
      if (address != null && address.isNotEmpty) data['address'] = address;
      if (qualification != null && qualification.isNotEmpty) data['qualification'] = qualification;
      if (experience != null) data['experience'] = experience;
      if (salary != null) data['salary'] = salary;
      if (joinDate != null && joinDate.isNotEmpty) data['join_date'] = joinDate;
      if (checkBox != null) data['check_box'] = checkBox;

      if (subjects != null && subjects.isNotEmpty) {
        data['subjects'] = subjects;
      }

      if (schoolType != null && schoolType.isNotEmpty) data['school_type'] = schoolType;

      // Handle file upload
      if (kIsWeb) {
        if (teacherProfileBytes != null && teacherProfileBytes.isNotEmpty) {
          FormData formData = FormData.fromMap({
            ...data,
            'teacher_profile': MultipartFile.fromBytes(
              teacherProfileBytes,
              filename: 'profile.jpg',
              contentType: DioMediaType.parse('image/jpeg'),
            ),
          });

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
        } else {
          final response = await _dio.put(
            '${ApiUrls.teacherDetail}$id/',
            data: data,
            options: Options(
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
        }
      } else {
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
        } else {
          final response = await _dio.put(
            '${ApiUrls.teacherDetail}$id/',
            data: data,
            options: Options(
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