// lib/feature/schedule/repository/exam_repository.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/exam_model.dart';

class ExamRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<ExamTimetableModel>> getExams(int schoolId) async {
    try {
      final response = await _dio.get(ApiUrls.examList(schoolId));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ExamTimetableModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("GET EXAMS ERROR: ${e.response?.data}");
      throw Exception('Failed to load exams');
    }
  }

  Future<bool> createExam({
    required int schoolId,
    required String className,
    required String examType,
    required String fromDate,
    required String toDate,
    required List<SubjectScheduleModel> schedules,
  }) async {
    try {
      Map<String, dynamic> data = {
        "class_name": className,
        "exam_type": examType,
        "from_date": fromDate,
        "to_date": toDate,
        "schedules": schedules.map((s) => s.toJson()).toList(),
      };

      final response = await _dio.post(
        ApiUrls.examCreate(schoolId),
        data: data,
      );
      return response.statusCode == 201;
    } on DioException catch (e) {
      print("CREATE EXAM ERROR: ${e.response?.data}");
      throw Exception('Failed to create exam');
    }
  }

  // 👇 ADDED UPDATE EXAM
  Future<bool> updateExam({
    required int schoolId,
    required int id,
    required String className,
    required String examType,
    required String fromDate,
    required String toDate,
    required List<SubjectScheduleModel> schedules,
  }) async {
    try {
      Map<String, dynamic> data = {
        "class_name": className,
        "exam_type": examType,
        "from_date": fromDate,
        "to_date": toDate,
        "schedules": schedules.map((s) => s.toJson()).toList(),
      };

      final response = await _dio.put(
        ApiUrls.examDetail(schoolId, id),
        data: data,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("UPDATE EXAM ERROR: ${e.response?.data}");
      throw Exception('Failed to update exam');
    }
  }

  Future<bool> deleteExam({required int schoolId, required int id}) async {
    try {
      final response = await _dio.delete(ApiUrls.examDetail(schoolId, id));
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Failed to delete exam');
    }
  }
}