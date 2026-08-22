import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/class_model.dart';

class ClassRepository {
  final Dio dio = ApiClient.dio;

  Future<List<ClassApiModel>> getClasses() async {
    try {
      final response = await dio.get(ApiUrls.classList);
      print('📡 GET Classes Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = ClassListResponse.fromJson(response.data);
        return result.data;
      }
      return [];
    } catch (e) {
      print('❌ GET Classes Error: $e');
      return [];
    }
  }

  Future<ClassApiModel?> createClass(Map<String, dynamic> data) async {
    try {
      print('📡 POST Create Class Payload: $data');

      final response = await dio.post(
        ApiUrls.classCreate,
        data: data,
      );

      print('📡 POST Create Class Response: ${response.statusCode}');

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

  Future<ClassApiModel?> updateClass(int id, Map<String, dynamic> data) async {
    try {
      print('📡 PUT Update Class $id Payload: $data');

      final response = await dio.put(
        '${ApiUrls.classDetail}$id/',
        data: data,
      );

      print('📡 PUT Update Class Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        if (responseData != null) {
          return ClassApiModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('❌ PUT Update Class Error: $e');
      return null;
    }
  }

  Future<bool> deleteClass(int id) async {
    try {
      final response = await dio.delete('${ApiUrls.classDetail}$id/');
      print('📡 DELETE Class $id Response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ DELETE Class Error: $e');
      return false;
    }
  }
}