import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/teacher_salary_model.dart';

class TeacherSalaryRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<TeacherSalaryModel>> getSalaryList({int? schoolId}) async {
    final url = schoolId != null
        ? ApiUrls.teacherSalaryListBySchool(schoolId)
        : ApiUrls.teacherSalaryList;

    final response = await _dio.get(url);
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => TeacherSalaryModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to load salary list');
  }

  Future<List<SalaryHistoryModel>> getTransactionHistory(int teacherId) async {
    final url = ApiUrls.teacherSalaryTransactionHistory(teacherId);
    final response = await _dio.get(url);

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => SalaryHistoryModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to load history');
  }

  Future<void> createTransaction({
    required int teacherId,
    required double amountPaid,
    required int month,
    required int year,
    String? remarks,
  }) async {
    final url = ApiUrls.teacherSalaryTransactionCreate;
    final response = await _dio.post(url, data: {
      'teacher_id': teacherId,
      'amount_paid': amountPaid,
      'month': month,
      'year': year,
      'remarks': remarks ?? '',
    });

    if (response.statusCode != 201 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to create transaction');
    }
  }

  Future<void> deleteTransaction(int teacherId, int transactionId) async {
    final url = ApiUrls.teacherSalaryTransactionDetail(teacherId, transactionId);
    final response = await _dio.delete(url);

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete transaction');
    }
  }
}