// lib/models/teacher_model.dart
class TeacherModel {
  final int? id;
  final String? teacherProfile;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? dob;
  final String? phone;
  final String? altPhone;
  final String? email;
  final String? teacherIdCard;
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
  String get idString => teacherIdCard ?? 'N/A';
  String get status => checkBox ? 'Active' : 'Inactive';
  String get school => schoolType ?? 'A';
  String get experienceStr => experience != null ? '$experience Years' : '0 Years';

  TeacherModel({
    this.id,
    this.teacherProfile,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.dob,
    this.phone,
    this.altPhone,
    this.email,
    this.teacherIdCard,
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
      id: json['id'] as int?,
      teacherProfile: json['teacher_profile'] as String?,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      phone: json['phone']?.toString(),
      altPhone: json['alt_phone']?.toString(),
      email: json['email']?.toString(),
      teacherIdCard: json['teacher_id_card']?.toString(),
      address: json['address']?.toString(),
      qualification: json['qualification']?.toString(),
      experience: json['experience'] as int?,
      salary: json['salary']?.toString(),
      joinDate: json['join_date']?.toString(),
      checkBox: json['check_box'] ?? false,
      subjects: json['subjects'] != null
          ? List<String>.from(json['subjects'])
          : null,
      schoolType: json['school_type']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      if (gender != null && gender!.isNotEmpty) 'gender': gender,
      if (dob != null && dob!.isNotEmpty) 'dob': dob,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (altPhone != null && altPhone!.isNotEmpty) 'alt_phone': altPhone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (teacherIdCard != null && teacherIdCard!.isNotEmpty) 'teacher_id_card': teacherIdCard,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (qualification != null && qualification!.isNotEmpty) 'qualification': qualification,
      if (experience != null) 'experience': experience,
      if (salary != null && salary!.isNotEmpty) 'salary': double.tryParse(salary!),
      if (joinDate != null && joinDate!.isNotEmpty) 'join_date': joinDate,
      'check_box': checkBox,
      if (subjects != null && subjects!.isNotEmpty) 'subjects': subjects,
      if (schoolType != null && schoolType!.isNotEmpty) 'school_type': schoolType,
    };
  }

  TeacherModel copyWith({
    int? id,
    String? teacherProfile,
    String? firstName,
    String? lastName,
    String? gender,
    String? dob,
    String? phone,
    String? altPhone,
    String? email,
    String? teacherIdCard,
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
      teacherProfile: teacherProfile ?? this.teacherProfile,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      email: email ?? this.email,
      teacherIdCard: teacherIdCard ?? this.teacherIdCard,
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
      count: json['count'] as int?,
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
      message: json['message'] as String?,
      errors: json['errors'] as Map<String, dynamic>?,
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
      message: json['message'] as String?,
      data: json['data'] != null ? TeacherModel.fromJson(json['data']) : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}