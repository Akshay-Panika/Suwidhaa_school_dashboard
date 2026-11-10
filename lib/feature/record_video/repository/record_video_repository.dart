import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_urls.dart';
import '../model/record_class_model.dart';
import '../model/record_subject_model.dart';
import '../model/record_video_model.dart';

class RecordVideoRepository {
  final Dio _dio = ApiClient.dio;

  // ================= CLASS CRUD =================
  Future<List<RecordClassModel>> getClasses() async {
    final res = await _dio.get(ApiUrls.recordVideoClasses);
    if (res.data['status'] == true) {
      return (res.data['data'] as List).map((e) => RecordClassModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<RecordClassModel> createClass(String name) async {
    final res = await _dio.post(ApiUrls.recordVideoClasses, data: {'name': name});
    return RecordClassModel.fromJson(res.data['data']);
  }

  Future<RecordClassModel> updateClass(int id, String name) async {
    final res = await _dio.put(ApiUrls.recordVideoClassDetail(id), data: {'name': name});
    return RecordClassModel.fromJson(res.data['data']);
  }

  Future<void> deleteClass(int id) async {
    await _dio.delete(ApiUrls.recordVideoClassDetail(id));
  }

  // ================= SUBJECT CRUD =================
  Future<List<RecordSubjectModel>> getSubjects(int classId) async {
    final res = await _dio.get(ApiUrls.recordVideoSubjects(classId));
    if (res.data['status'] == true) {
      return (res.data['data'] as List).map((e) => RecordSubjectModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<RecordSubjectModel> createSubject(int classId, String name) async {
    final res = await _dio.post(ApiUrls.recordVideoSubjects(classId), data: {'name': name});
    return RecordSubjectModel.fromJson(res.data['data']);
  }

  Future<RecordSubjectModel> updateSubject(int classId, int subjectId, String name) async {
    final res = await _dio.put(ApiUrls.recordVideoSubjectDetail(classId, subjectId), data: {'name': name});
    return RecordSubjectModel.fromJson(res.data['data']);
  }

  Future<void> deleteSubject(int classId, int subjectId) async {
    await _dio.delete(ApiUrls.recordVideoSubjectDetail(classId, subjectId));
  }

  // ================= VIDEO CRUD =================
  Future<List<RecordVideoModel>> getVideos(int classId, {int? subjectId}) async {
    final url = ApiUrls.recordVideoList(classId, subjectId: subjectId);
    final res = await _dio.get(url);
    if (res.data['status'] == true) {
      return (res.data['data'] as List).map((e) => RecordVideoModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> createVideo(int classId, {
    required String title,
    required int subjectId,
    required String videoUrl,
    required String duration,
    double rating = 5.0,
    PlatformFile? thumbnail,
  }) async {
    try {
      final map = <String, dynamic>{
        'title': title,
        'subject': subjectId,
        'video_url': videoUrl,
        'duration': duration,
        'rating': rating.toString(),
      };
      if (thumbnail != null) map['thumbnail'] = await _toMultipart(thumbnail);

      await _dio.post(ApiUrls.recordVideoList(classId), data: FormData.fromMap(map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> updateVideo(int classId, int videoId, {
    required String title,
    required int subjectId,
    required String videoUrl,
    required String duration,
    double rating = 5.0,
    PlatformFile? thumbnail,
  }) async {
    try {
      final map = <String, dynamic>{
        'title': title,
        'subject': subjectId,
        'video_url': videoUrl,
        'duration': duration,
        'rating': rating.toString(),
      };
      if (thumbnail != null) map['thumbnail'] = await _toMultipart(thumbnail);

      await _dio.put(ApiUrls.recordVideoDetail(classId, videoId), data: FormData.fromMap(map));
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> deleteVideo(int classId, int videoId) async {
    await _dio.delete(ApiUrls.recordVideoDetail(classId, videoId));
  }

  Future<MultipartFile?> _toMultipart(PlatformFile? file) async {
    if (file == null) return null;
    if (file.bytes != null) return MultipartFile.fromBytes(file.bytes!, filename: file.name);
    if (file.path != null) return MultipartFile.fromFile(file.path!, filename: file.name);
    return null;
  }

  // ✅ EXACT ERROR EXTRACTION FROM BACKEND
  String _handleError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data;
      if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map) {
          final firstKey = errors.keys.first;
          final firstError = errors[firstKey];
          if (firstError is List) {
            return '$firstKey: ${firstError.first}';
          }
          return '$firstKey: $firstError';
        }
      }
      if (data['error'] != null) return data['error'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout) return 'Connection timeout';
    if (e.type == DioExceptionType.connectionError) return 'No internet connection';
    return 'Something went wrong. Check console for details.';
  }
}