// lib/feature/classes/model/class_model.dart

class ClassListResponse {
  final bool success;
  final int? count;
  final List<ClassApiModel> data;

  ClassListResponse({
    required this.success,
    this.count,
    required this.data,
  });

  factory ClassListResponse.fromJson(Map<String, dynamic> json) {
    return ClassListResponse(
      success: json['success'] ?? false,
      count: json['count'],
      data: (json['data'] as List?)
          ?.map((e) => ClassApiModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ClassApiModel {
  final int id;
  final String className;
  final String schoolName;
  final List<String> sections;
  final bool checkBox;
  final ClassTeacherModel? classTeacher;
  final String createdAt;
  final String updatedAt;

  ClassApiModel({
    required this.id,
    required this.className,
    required this.schoolName,
    required this.sections,
    required this.checkBox,
    this.classTeacher,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassApiModel.fromJson(Map<String, dynamic> json) {
    return ClassApiModel(
      id: json['id'] ?? 0,
      className: json['class_name'] ?? '',
      schoolName: json['school']?['school_name'] ?? 'No School',
      sections: (json['sections'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      checkBox: json['check_box'] ?? false,
      classTeacher: json['class_teacher'] != null
          ? ClassTeacherModel.fromJson(json['class_teacher'])
          : null,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ClassTeacherModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? teacherIdCard;
  final String? gender;
  final String? phone;
  final String? email;
  final String? qualification;
  final List<String>? subjects;

  ClassTeacherModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.teacherIdCard,
    this.gender,
    this.phone,
    this.email,
    this.qualification,
    this.subjects,
  });

  factory ClassTeacherModel.fromJson(Map<String, dynamic> json) {
    return ClassTeacherModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profileImage: json['teacher_profile'],
      teacherIdCard: json['teacher_id_card'],
      gender: json['gender'],
      phone: json['phone'],
      email: json['email'],
      qualification: json['qualification'],
      subjects: json['subjects'] != null ? List<String>.from(json['subjects']) : null,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}