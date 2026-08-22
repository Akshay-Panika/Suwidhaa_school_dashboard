// ============ ENUMS ============
enum SubjectFilter {
  all,
  active,
  inactive,
  upcoming,
  completed,
  withTeacher,
  withoutTeacher,
  withSchedule,
  withoutSchedule,
}

enum SubjectStatus {
  active,
  inactive,
  upcoming,
  completed,
}

// ============ API MODELS ============
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
  final String schoolType;
  final List<AsignApiModel> asign;  // Note: "asign" NOT "assign"
  final bool checkBox;
  final String createdAt;
  final String updatedAt;

  SubjectApiModel({
    required this.id,
    required this.subjectName,
    required this.schoolType,
    required this.asign,
    required this.checkBox,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubjectApiModel.fromJson(Map<String, dynamic> json) {
    return SubjectApiModel(
      id: json['id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
      schoolType: json['school_type'] ?? '',
      asign: (json['asign'] as List?)
          ?.map((e) => AsignApiModel.fromJson(e))
          .toList() ?? [],
      checkBox: json['check_box'] ?? true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_name': subjectName,
      'school_type': schoolType,
      'asign': asign.map((e) => e.toJson()).toList(),  // Use "asign" for request
      'check_box': checkBox,
    };
  }
}

class AsignApiModel {
  final String? slotTime;
  final String className;
  final String? roomNumber;
  final String sectionName;
  final String teacherName;

  AsignApiModel({
    this.slotTime,
    required this.className,
    this.roomNumber,
    required this.sectionName,
    required this.teacherName,
  });

  factory AsignApiModel.fromJson(Map<String, dynamic> json) {
    return AsignApiModel(
      slotTime: json['slot_time'],
      className: json['class_name'] ?? '',
      roomNumber: json['room_number'],
      sectionName: json['section_name'] ?? '',
      teacherName: json['teacher_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slot_time': slotTime,
      'class_name': className,
      'room_number': roomNumber,
      'section_name': sectionName,
      'teacher_name': teacherName,
    };
  }
}

// ============ UI HELPER CLASS ============
class SubjectUIModel {
  final String id;
  final String name;
  final String code;
  final List<String> teachers;
  final bool isActive;
  final List<Map<String, dynamic>> asign;
  final String school;

  SubjectUIModel({
    required this.id,
    required this.name,
    required this.code,
    required this.teachers,
    required this.isActive,
    required this.asign,
    required this.school,
  });

  factory SubjectUIModel.fromApi(SubjectApiModel api) {
    return SubjectUIModel(
      id: api.id.toString(),
      name: api.subjectName,
      code: api.subjectName.substring(0, 3).toUpperCase(),
      teachers: api.asign.map((a) => a.teacherName).toList(),
      isActive: api.checkBox,
      asign: api.asign.map((a) => ({
        'slotTime': a.slotTime,
        'classLevel': a.className,
        'room': a.roomNumber,
        'section': a.sectionName,
        'teacher': a.teacherName,
      })).toList(),
      school: api.schoolType == 'a' ? 'School A' : 'School B',
    );
  }

  int get teacherCount => teachers.length;
  int get scheduleCount => asign.length;
  bool get hasTeacher => teachers.isNotEmpty;
  bool get hasSchedule => asign.any((a) => a['slotTime'] != null);
}