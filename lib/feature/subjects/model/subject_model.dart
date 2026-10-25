// lib/feature/subjects/model/subject_model.dart
import '../../teachers/model/teacher_model.dart'; // ✅ Import TeacherModel

class SubjectListResponse {
  final bool success;
  final int? count;
  final List<SubjectApiModel> data;

  SubjectListResponse({
    required this.success,
    this.count,
    required this.data,
  });

  factory SubjectListResponse.fromJson(Map<String, dynamic> json) {
    return SubjectListResponse(
      success: json['success'] ?? false,
      count: json['count'],
      data: (json['data'] as List?)
          ?.map((e) => SubjectApiModel.fromJson(e))
          .toList() ?? [],
    );
  }
}

class SubjectApiModel {
  final int id;
  final String subjectName;
  final String? code;
  final int schoolId;
  final String schoolName;
  final List<TeacherModel> teachers; // ✅ Use TeacherModel
  final String createdAt;
  final String updatedAt;

  SubjectApiModel({
    required this.id,
    required this.subjectName,
    this.code,
    required this.schoolId,
    required this.schoolName,
    required this.teachers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubjectApiModel.fromJson(Map<String, dynamic> json) {
    return SubjectApiModel(
      id: json['id'] ?? 0,
      subjectName: json['name'] ?? '',
      code: json['code'],
      schoolId: json['school']?['id'] ?? 0,
      schoolName: json['school']?['school_name'] ?? 'No School',
      teachers: (json['teachers'] as List?) // ✅ Parse TeacherModel
          ?.map((e) => TeacherModel.fromJson(e))
          .toList() ?? [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': subjectName,
      'code': code,
      'school_id': schoolId,
    };
  }
}