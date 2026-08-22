import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/subject_model.dart';

class SubjectRepository {
  final Dio dio = ApiClient.dio;

  // GET all subjects
  Future<List<SubjectApiModel>> getSubjects() async {
    try {
      final response = await dio.get(ApiUrls.subjectList);
      print('📡 GET Subjects Response: ${response.statusCode}');
      print('📡 GET Subjects Data: ${response.data}');

      if (response.statusCode == 200) {
        final result = SubjectListResponse.fromJson(response.data);
        return result.data;
      }
      return [];
    } catch (e) {
      print('❌ GET Subjects Error: $e');
      return [];
    }
  }

  // GET single subject
  Future<SubjectApiModel?> getSubject(int id) async {
    try {
      final response = await dio.get('${ApiUrls.subjectDetail}$id/');
      print('📡 GET Subject $id Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          return SubjectApiModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('❌ GET Subject Error: $e');
      return null;
    }
  }

  // POST create subject
  Future<SubjectApiModel?> createSubject(Map<String, dynamic> data) async {
    try {
      print('📡 POST Create Subject Payload: $data');

      final response = await dio.post(
        ApiUrls.subjectCreate,
        data: data,
      );

      print('📡 POST Create Subject Response: ${response.statusCode}');
      print('📡 POST Create Subject Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data['data'];
        if (responseData != null) {
          return SubjectApiModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('❌ POST Create Subject Error: $e');
      if (e is DioException && e.response != null) {
        print('❌ Response Data: ${e.response?.data}');
      }
      return null;
    }
  }

  // PUT update subject
  Future<SubjectApiModel?> updateSubject(int id, Map<String, dynamic> data) async {
    try {
      print('📡 PUT Update Subject $id Payload: $data');

      final response = await dio.put(
        '${ApiUrls.subjectDetail}$id/',
        data: data,
      );

      print('📡 PUT Update Subject Response: ${response.statusCode}');
      print('📡 PUT Update Subject Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        if (responseData != null) {
          return SubjectApiModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('❌ PUT Update Subject Error: $e');
      if (e is DioException && e.response != null) {
        print('❌ Response Data: ${e.response?.data}');
      }
      return null;
    }
  }

  // DELETE subject
  Future<bool> deleteSubject(int id) async {
    try {
      final response = await dio.delete('${ApiUrls.subjectDetail}$id/');
      print('📡 DELETE Subject $id Response: ${response.statusCode}');
      print('📡 DELETE Subject Data: ${response.data}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ DELETE Subject Error: $e');
      if (e is DioException && e.response != null) {
        print('❌ Response Data: ${e.response?.data}');
      }
      return false;
    }
  }
}