import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/teacher_attendance_model.dart';

class TeacherAttendanceRepository {
  Future<TeacherAttendanceHistoryResponse> getHistory(int teacherId) async {
    try {
      final response = await ApiClient.dio.get(
        ApiUrls.teacherAttendanceHistory,
        queryParameters: {'teacher_id': teacherId},
      );
      if (response.statusCode == 200) {
        return TeacherAttendanceHistoryResponse.fromJson(response.data);
      }
      throw Exception('Failed to load history');
    } catch (e) {
      throw Exception('Error fetching teacher attendance: $e');
    }
  }

  Future<List<TeacherListModel>> getAllTeachersList() async {
    try {
      final response = await ApiClient.dio.get(ApiUrls.teacherAttendanceList);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => TeacherListModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load teacher list');
    } catch (e) {
      throw Exception('Error fetching teacher list: $e');
    }
  }

  Future<TeacherListModel?> getSingleTeacherStatus(int teacherId) async {
    try {
      final response = await ApiClient.dio.get(
        ApiUrls.teacherAttendanceList,
        queryParameters: {'teacher_id': teacherId},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        if (data.isNotEmpty) {
          return TeacherListModel.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching teacher status: $e');
    }
  }

  Future<bool> updateTeacherStatus({
    required int teacherId,
    required String date,
    required String status,
    String? remarks,
  }) async {
    try {
      final response = await ApiClient.dio.patch(
        ApiUrls.teacherAttendanceUpdate,
        data: {
          'teacher_id': teacherId,
          'date': date,
          'status': status,
          if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
        },
      );
      return response.data['success'] ?? false;
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  Future<bool> deleteTeacherAttendance(int id) async {
    try {
      final response = await ApiClient.dio.delete(
        ApiUrls.teacherAttendanceDelete(id),
      );
      return response.data['success'] ?? false;
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }
}