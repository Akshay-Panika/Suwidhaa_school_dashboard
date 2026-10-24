import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/student_attendance_model.dart';

class StudentAttendanceRepository {
  final Dio _dio = ApiClient.dio;

  Future<StudentAttendanceHistoryResponse> getHistory(int studentId) async {
    final response = await _dio.get(ApiUrls.studentAttendanceDetail(studentId));
    return StudentAttendanceHistoryResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> saveAttendance({
    required int studentId,
    required String date,
    required String status,
    required String remarks,
  }) async {
    final response = await _dio.post(
      ApiUrls.studentAttendanceCreate,
      data: {
        'students': [
          {
            'student_id': studentId,
            'date': date,
            'attendance_status': status,
            'remarks': remarks,
          }
        ]
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteAttendance({
    required int studentId,
    required String date,
  }) async {
    final response = await _dio.delete(
      ApiUrls.studentAttendanceDelete(studentId, date),
    );
    return response.data as Map<String, dynamic>;
  }
}