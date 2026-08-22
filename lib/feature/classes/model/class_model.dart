// ============ ENUMS ============
enum ClassFilter {
  all,
  nursery,
  lkg,
  ukg,
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  seventh,
  eighth,
  ninth,
  tenth,
  eleventh,
  twelfth,
}

enum ClassStatus {
  active,
  inactive,
  completed,
}

enum SchoolFilter {
  all,
  schoolA,
  schoolB,
}

// ============ API MODELS ============
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
          .toList() ?? [],
    );
  }
}

class ClassApiModel {
  final int id;
  final String className;
  final String schoolName;
  final List<SectionApiModel> sections;
  final bool checkBox;
  final String createdAt;
  final String updatedAt;

  ClassApiModel({
    required this.id,
    required this.className,
    required this.schoolName,
    required this.sections,
    required this.checkBox,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassApiModel.fromJson(Map<String, dynamic> json) {
    return ClassApiModel(
      id: json['id'] ?? 0,
      className: json['class_name'] ?? '',
      schoolName: json['school_name'] ?? '',
      sections: (json['sections'] as List?)
          ?.map((e) => SectionApiModel.fromJson(e))
          .toList() ?? [],
      checkBox: json['check_box'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_name': className,
      'school_name': schoolName,
      'sections': sections.map((e) => e.toJson()).toList(),
      'check_box': checkBox,
    };
  }
}

class SectionApiModel {
  final String name;
  final String roomNumber;
  final List<String> subjectNames;
  final int totalStudent;
  final String classTeacherName;

  SectionApiModel({
    required this.name,
    required this.roomNumber,
    required this.subjectNames,
    required this.totalStudent,
    required this.classTeacherName,
  });

  factory SectionApiModel.fromJson(Map<String, dynamic> json) {
    return SectionApiModel(
      name: json['name'] ?? '',
      roomNumber: json['room_number'] ?? '',
      subjectNames: (json['subject_names'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      totalStudent: json['total_student'] ?? 0,
      classTeacherName: json['class_teacher_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'room_number': roomNumber,
      'subject_names': subjectNames,
      'total_student': totalStudent,
      'class_teacher_name': classTeacherName,
    };
  }
}