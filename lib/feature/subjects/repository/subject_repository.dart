// lib/feature/subjects/repository/subject_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/subject_model.dart';

class SubjectRepository {
  final Dio dio = ApiClient.dio;

  Future<List<SubjectApiModel>> getSubjects(int schoolId) async {
    try {
      final response = await dio.get(ApiUrls.subjectBySchool(schoolId));
      if (response.statusCode == 200) {
        final result = SubjectListResponse.fromJson(response.data);
        return result.data;
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      print('❌ GET Subjects Error: $e');
      return [];
    } catch (e) {
      print('❌ GET Subjects Error: $e');
      return [];
    }
  }

  Future<SubjectApiModel?> createSubject(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiUrls.subjectCreate, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data['data'];
        if (responseData != null) {
          return SubjectApiModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('❌ POST Create Subject Error: $e');
      return null;
    }
  }

  // ✅ NEW: Update
  Future<SubjectApiModel?> updateSubject(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put('${ApiUrls.subjectDetail}$id/', data: data);
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        if (responseData != null) {
          return SubjectApiModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('❌ PUT Update Subject Error: $e');
      return null;
    }
  }

  // ✅ NEW: Delete
  Future<bool> deleteSubject(int id) async {
    try {
      final response = await dio.delete('${ApiUrls.subjectDetail}$id/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ DELETE Subject Error: $e');
      return false;
    }
  }
}