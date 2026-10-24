// lib/feature/classes/repository/class_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/class_model.dart';

class ClassRepository {
  final Dio dio = ApiClient.dio;

  // ✅ Get Classes by School ID
  Future<List<ClassApiModel>> getClassesBySchool(int schoolId) async {
    try {
      final response = await dio.get(ApiUrls.classListBySchool(schoolId));
      if (response.statusCode == 200) {
        final result = ClassListResponse.fromJson(response.data);
        return result.data;
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return []; // No classes found
      print('❌ GET Classes Error: $e');
      return [];
    } catch (e) {
      print('❌ GET Classes Error: $e');
      return [];
    }
  }

  // ✅ Create Class
  Future<ClassApiModel?> createClass(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiUrls.classCreate, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data['data'];
        if (responseData != null) {
          return ClassApiModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('❌ POST Create Class Error: $e');
      return null;
    }
  }

  // ✅ Assign Teacher to Class
  Future<bool> assignClassTeacher(int classId, int? teacherId) async {
    try {
      final response = await dio.post(
        ApiUrls.classAssignTeacher(classId),
        data: {'teacher_id': teacherId}, // Send null to unassign
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('❌ Assign Teacher Error: $e');
      return false;
    }
  }
}