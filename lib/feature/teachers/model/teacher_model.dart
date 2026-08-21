class TeacherModel {
  final int id;
  final String? teacherId;
  final String? teacherProfile;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? dob;
  final String? phone;
  final String? altPhone;
  final String? email;
  final String? address;
  final String? qualification;
  final int? experience;
  final String? salary;
  final String? joinDate;
  final bool checkBox;
  final List<String>? subjects;
  final String? schoolType;
  final String? createdAt;
  final String? updatedAt;

  // Computed properties for UI
  String get fullName => '$firstName $lastName'.trim();
  String get idString => teacherId ?? 'N/A';
  String get status => checkBox ? 'Active' : 'Inactive';
  String get school => schoolType ?? 'School A';
  String get experienceStr => '$experience Years';

  TeacherModel({
    required this.id,
    this.teacherId,
    this.teacherProfile,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.dob,
    this.phone,
    this.altPhone,
    this.email,
    this.address,
    this.qualification,
    this.experience,
    this.salary,
    this.joinDate,
    this.checkBox = false,
    this.subjects,
    this.schoolType,
    this.createdAt,
    this.updatedAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? 0,
      teacherId: json['teacher_id'],
      teacherProfile: json['teacher_profile'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'],
      dob: json['dob'],
      phone: json['phone'],
      altPhone: json['alt_phone'],
      email: json['email'],
      address: json['address'],
      qualification: json['qualification'],
      experience: json['experience'],
      salary: json['salary']?.toString(),
      joinDate: json['join_date'],
      checkBox: json['check_box'] ?? false,
      subjects: json['subjects'] != null
          ? List<String>.from(json['subjects'])
          : null,
      schoolType: json['school_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'dob': dob,
      'phone': phone,
      'alt_phone': altPhone,
      'email': email,
      'address': address,
      'qualification': qualification,
      'experience': experience,
      'salary': salary != null ? double.tryParse(salary!) : null,
      'join_date': joinDate,
      'check_box': checkBox,
      'subjects': subjects,
      'school_type': schoolType,
    };
  }

  TeacherModel copyWith({
    int? id,
    String? teacherId,
    String? teacherProfile,
    String? firstName,
    String? lastName,
    String? gender,
    String? dob,
    String? phone,
    String? altPhone,
    String? email,
    String? address,
    String? qualification,
    int? experience,
    String? salary,
    String? joinDate,
    bool? checkBox,
    List<String>? subjects,
    String? schoolType,
    String? createdAt,
    String? updatedAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      teacherProfile: teacherProfile ?? this.teacherProfile,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      email: email ?? this.email,
      address: address ?? this.address,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      salary: salary ?? this.salary,
      joinDate: joinDate ?? this.joinDate,
      checkBox: checkBox ?? this.checkBox,
      subjects: subjects ?? this.subjects,
      schoolType: schoolType ?? this.schoolType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TeacherListResponse {
  final bool success;
  final int? count;
  final List<TeacherModel> data;

  TeacherListResponse({
    required this.success,
    this.count,
    required this.data,
  });

  factory TeacherListResponse.fromJson(Map<String, dynamic> json) {
    return TeacherListResponse(
      success: json['success'] ?? false,
      count: json['count'],
      data: json['data'] != null
          ? List<TeacherModel>.from(json['data'].map((x) => TeacherModel.fromJson(x)))
          : [],
    );
  }
}

class TeacherSingleResponse {
  final bool success;
  final TeacherModel? data;
  final String? message;
  final Map<String, dynamic>? errors;

  TeacherSingleResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  factory TeacherSingleResponse.fromJson(Map<String, dynamic> json) {
    return TeacherSingleResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? TeacherModel.fromJson(json['data']) : null,
      message: json['message'],
      errors: json['errors'],
    );
  }
}

class TeacherCreateResponse {
  final bool success;
  final String? message;
  final TeacherModel? data;
  final Map<String, dynamic>? errors;

  TeacherCreateResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory TeacherCreateResponse.fromJson(Map<String, dynamic> json) {
    return TeacherCreateResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? TeacherModel.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }
}