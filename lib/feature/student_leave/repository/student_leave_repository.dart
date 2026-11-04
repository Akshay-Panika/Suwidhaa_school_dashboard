// lib/feature/school/student_leave/repository/student_leave_repository.dart

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_urls.dart';
import '../model/student_leave_list_model.dart';

class StudentLeaveRepository {
  final Dio _dio = ApiClient.dio;

  // ─── GET ALL ───
  Future<StudentLeaveListModel> getStudentLeaveList() async {
    try {
      final r = await _dio.get(ApiUrls.studentLeaveList);
      return StudentLeaveListModel.fromJson(r.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  // ─── GET BY CLASS ───
  Future<StudentLeaveListModel> getStudentLeaveByClass(String className) async {
    try {
      final r = await _dio.get(ApiUrls.studentLeaveByClass(className));
      return StudentLeaveListModel.fromJson(r.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  // ─── GET BY CARD ───
  Future<StudentLeaveListModel> getStudentLeaveByCardId(String card) async {
    try {
      final r = await _dio.get('${ApiUrls.studentLeaveByIdCard}$card/');
      return StudentLeaveListModel.fromJson(r.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  // ─── GET DETAIL ───
  Future<StudentLeaveDetailResponse> getLeaveById(int leaveId) async {
    try {
      final r = await _dio.get('${ApiUrls.studentLeaveDetail}$leaveId/');
      return StudentLeaveDetailResponse.fromJson(r.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  // ─── CREATE (only student_id_card needed — backend auto-fills name, class, school) ───
  // ─── CREATE ───
  Future<StudentLeaveCreateResponse> createLeave({
    required String studentIdCard,
    required String reasonMsg,
    required String startDate,
    required String endDate,
    String? imagePath,
  }) async {
    try {
      // ✅ explicit <String, dynamic>
      final Map<String, dynamic> map = {
        'student_id_card': studentIdCard,
        'reason_msg': reasonMsg,
        'start_date': startDate,
        'end_date': endDate,
      };
      if (imagePath != null && imagePath.isNotEmpty) {
        map['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
      }
      final r = await _dio.post(
        ApiUrls.studentLeaveCreate,
        data: FormData.fromMap(map),
      );
      return StudentLeaveCreateResponse.fromJson(r.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  // ─── UPDATE ───
  Future<StudentLeaveCreateResponse> updateLeave({
    required int leaveId,
    required String studentIdCard,
    required String reasonMsg,
    required String startDate,
    required String endDate,
    String? imagePath,
    bool removeOldImage = false,
  }) async {
    try {
      // ✅ explicit <String, dynamic>
      final Map<String, dynamic> map = {
        'student_id_card': studentIdCard,
        'reason_msg': reasonMsg,
        'start_date': startDate,
        'end_date': endDate,
      };
      if (imagePath != null && imagePath.isNotEmpty) {
        map['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
      } else if (removeOldImage) {
        map['image'] = '';
      }
      final r = await _dio.put(
        '${ApiUrls.studentLeaveDetail}$leaveId/',
        data: FormData.fromMap(map),
      );
      return StudentLeaveCreateResponse.fromJson(r.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  // ─── DELETE ───
  Future<StudentLeaveDeleteResponse> deleteLeave(int leaveId) async {
    try {
      final r = await _dio.delete('${ApiUrls.studentLeaveDetail}$leaveId/');
      if (r.data == null || r.data is! Map) {
        return StudentLeaveDeleteResponse(
          status: true,
          message: 'Leave deleted successfully',
        );
      }
      return StudentLeaveDeleteResponse.fromJson(r.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  // ─── APPROVAL ───
  Future<StudentLeaveApprovalResponse> updateLeaveApproval({
    required int leaveId,
    required String status,
    String? teacherCardId,
    String? teacherName,
  }) async {
    try {
      final r = await _dio.patch(
        '${ApiUrls.studentLeaveApproval}$leaveId/',
        data: {
          'leave_status': status.toLowerCase(),
          if (teacherCardId != null) 'teacher_card_id': teacherCardId,
          if (teacherName != null) 'teacher_name': teacherName,
        },
      );
      return StudentLeaveApprovalResponse.fromJson(r.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  // ─── ERROR HANDLER ───
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map && data['message'] != null) return data['message'];
        if (data is Map && data['errors'] != null) {
          final errs = data['errors'];
          if (errs is Map && errs.isNotEmpty) {
            final first = errs.values.first;
            return first is List ? first.first.toString() : first.toString();
          }
        }
        return 'Server error (${e.response?.statusCode})';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}