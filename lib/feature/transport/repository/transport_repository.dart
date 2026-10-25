import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/transport_model.dart';

class TransportRepository {
  final Dio dio = ApiClient.dio;

  Future<List<TransportModel>> getTransports({int? schoolId}) async {
    try {
      // ✅ School-wise custom URL use karein
      final url = schoolId != null
          ? ApiUrls.transportBySchool(schoolId)
          : ApiUrls.transportList;

      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => TransportModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ GET Transport Error: $e');
      return [];
    }
  }

  Future<TransportModel?> createTransport(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiUrls.transportCreate, data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return TransportModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('❌ POST Transport Error: $e');
      return null;
    }
  }

  Future<TransportModel?> updateTransport(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(ApiUrls.transportDetail(id), data: data);
      if (response.statusCode == 200) {
        return TransportModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('❌ PUT Transport Error: $e');
      return null;
    }
  }

  Future<bool> deleteTransport(int id) async {
    try {
      final response = await dio.delete(ApiUrls.transportDetail(id));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ DELETE Transport Error: $e');
      return false;
    }
  }

  Future<bool> addStudent(
      int transportId,
      int studentId, {
        String? address,
        String? pickupTime,
        String? dropTime,
      }) async {
    try {
      final Map<String, dynamic> data = {
        'student_id': studentId,
      };

      if (address != null && address.trim().isNotEmpty) data['address'] = address.trim();
      if (pickupTime != null && pickupTime.trim().isNotEmpty) data['pickup_time'] = pickupTime.trim();
      if (dropTime != null && dropTime.trim().isNotEmpty) data['drop_time'] = dropTime.trim();

      final response = await dio.post(ApiUrls.transportAddStudent(transportId), data: data);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('❌ Add Student Error: $e');
      return false;
    }
  }

  Future<bool> removeStudent(int transportId, int studentId) async {
    try {
      final response = await dio.delete(ApiUrls.transportRemoveStudent(transportId, studentId));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Remove Student Error: $e');
      return false;
    }
  }
}