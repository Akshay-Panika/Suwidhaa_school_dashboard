// lib/feature/school_type/repository/school_type_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/school_type_model.dart';

class SchoolTypeRepository {
  final Dio dio = ApiClient.dio;

  // ---------- GET ALL ----------
  Future<List<SchoolTypeModel>> getSchoolTypes() async {
    try {
      final response = await dio.get(ApiUrls.schoolTypeList);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          return list
              .map((json) => SchoolTypeModel.fromApiJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load school types: $e');
    }
  }

  // ---------- GET ONE ----------
  Future<SchoolTypeModel> getSchoolTypeById(int id) async {
    try {
      final response = await dio.get('${ApiUrls.schoolTypeDetail}$id/');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return SchoolTypeModel.fromApiJson(data['data']);
        }
        throw Exception('API returned error: ${data['message']}');
      }
      throw Exception('Failed to load school type: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ---------- CREATE ----------
  Future<SchoolTypeModel> createSchoolType(SchoolTypeModel school) async {
    try {
      final response = await dio.post(
        ApiUrls.schoolTypeCreate,
        data: school.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return SchoolTypeModel.fromApiJson(data['data']);
        }
        throw Exception('API returned error: ${data['message']}');
      }
      throw Exception('Failed to create school type: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ---------- UPDATE ----------
  Future<SchoolTypeModel> updateSchoolType({
    required int id,
    required SchoolTypeModel school,
  }) async {
    try {
      final response = await dio.put(
        '${ApiUrls.schoolTypeDetail}$id/',
        data: school.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return SchoolTypeModel.fromApiJson(data['data']);
        }
        throw Exception('API returned error: ${data['message']}');
      }
      throw Exception('Failed to update school type: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ---------- DELETE ----------
  Future<bool> deleteSchoolType(int id) async {
    try {
      final response = await dio.delete('${ApiUrls.schoolTypeDetail}$id/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}