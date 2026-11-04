import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/student_fee_model.dart';

class StudentFeeRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<StudentFeeModel>> getFeeList({int? schoolId}) async {
    final url = schoolId != null
        ? ApiUrls.studentFeeListBySchool(schoolId)
        : ApiUrls.studentFeeList;
    final response = await _dio.get(url);
    if (response.statusCode == 200) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => StudentFeeModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load list');
  }

  Future<List<FeeHistoryModel>> getHistory(int studentId) async {
    final url = ApiUrls.studentFeeTransactionHistory(studentId);
    final response = await _dio.get(url);
    if (response.statusCode == 200) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => FeeHistoryModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load history');
  }

  Future<void> createTransaction(int studentId, double amount, String? remarks) async {
    final url = ApiUrls.studentFeeTransactionCreate;
    final response = await _dio.post(url, data: {
      'student_id': studentId,
      'amount_paid': amount,
      'remarks': remarks ?? '',
    });
    if (response.statusCode != 201) throw Exception('Failed to create');
  }

  Future<void> deleteTransaction(int studentId, int transactionId) async {
    final url = ApiUrls.studentFeeTransactionDetail(studentId, transactionId);
    final response = await _dio.delete(url);
    if (response.statusCode != 200) throw Exception('Failed to delete');
  }
}