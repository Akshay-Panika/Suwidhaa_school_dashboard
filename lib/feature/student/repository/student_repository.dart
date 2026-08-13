// student_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../model/student_model.dart';

class StudentRepository {
  final Dio _dio = ApiClient.dio;

  // Get all students
  Future<List<StudentModel>> getAllStudents() async {
    try {
      final response = await _dio.get('/students/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('✅ Students found: ${data.length}');
        return data.map((json) => StudentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      if (e.response != null) {
        print('❌ Status: ${e.response?.statusCode}');
        print('❌ Data: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Add new student
  Future<StudentModel> addStudent(StudentModel student) async {
    try {
      final response = await _dio.post(
        '/students/',
        data: student.toJson(),
      );

      print('📤 POST Request URL: ${_dio.options.baseUrl}students/');
      print('📤 Request Data: ${student.toJson()}');
      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return StudentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to add student: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      if (e.response != null) {
        print('❌ Status: ${e.response?.statusCode}');
        print('❌ Response Data: ${e.response?.data}');
        throw Exception('Failed to add student: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Update student
  Future<StudentModel> updateStudent(int id, StudentModel student) async {
    try {
      final response = await _dio.put(
        '/students/$id/',
        data: student.toJson(),
      );

      print('📤 PUT Request URL: ${_dio.options.baseUrl}students/$id/');
      print('📤 Request Data: ${student.toJson()}');
      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return StudentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update student: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      if (e.response != null) {
        print('❌ Status: ${e.response?.statusCode}');
        print('❌ Response Data: ${e.response?.data}');
        throw Exception('Failed to update student: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Delete student
  Future<void> deleteStudent(int id) async {
    try {
      final response = await _dio.delete(
        '/students/$id/',
      );

      print('📤 DELETE Request URL: ${_dio.options.baseUrl}students/$id/');
      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete student: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      if (e.response != null) {
        print('❌ Status: ${e.response?.statusCode}');
        print('❌ Response Data: ${e.response?.data}');
        throw Exception('Failed to delete student: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Get single student by ID
  Future<StudentModel> getStudentById(int id) async {
    try {
      final response = await _dio.get(
        '/students/$id/',
      );

      print('📤 GET Request URL: ${_dio.options.baseUrl}students/$id/');
      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return StudentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load student: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      if (e.response != null) {
        print('❌ Status: ${e.response?.statusCode}');
        print('❌ Response Data: ${e.response?.data}');
        throw Exception('Failed to load student: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Search students by name or roll number
  Future<List<StudentModel>> searchStudents(String query) async {
    try {
      final response = await _dio.get(
        '/students/?search=$query',
      );

      print('📤 Search Request URL: ${_dio.options.baseUrl}students/?search=$query');
      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StudentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search students: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      if (e.response != null) {
        print('❌ Status: ${e.response?.statusCode}');
        print('❌ Response Data: ${e.response?.data}');
        throw Exception('Failed to search students: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}