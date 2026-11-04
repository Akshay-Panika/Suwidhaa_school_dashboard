// lib/feature/school/student_leave/model/student_leave_list_model.dart

// ==================== LIST WRAPPER ====================
class StudentLeaveListModel {
  final bool status;
  final List<StudentLeaveData> data;
  final String? message;

  StudentLeaveListModel({
    required this.status,
    required this.data,
    this.message,
  });

  factory StudentLeaveListModel.fromJson(Map<String, dynamic> json) {
    return StudentLeaveListModel(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => StudentLeaveData.fromJson(e))
          .toList() ??
          [],
      message: json['message'],
    );
  }
}

// ==================== SCHOOL ====================
class LeaveSchoolInfo {
  final int id;
  final String schoolName;
  final String? schoolCode;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? phone;
  final String? email;
  final String? website;
  final String? board;
  final String? schoolType;

  LeaveSchoolInfo({
    required this.id,
    required this.schoolName,
    this.schoolCode,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.phone,
    this.email,
    this.website,
    this.board,
    this.schoolType,
  });

  factory LeaveSchoolInfo.fromJson(Map<String, dynamic> json) {
    return LeaveSchoolInfo(
      id: json['id'] ?? 0,
      schoolName: json['school_name'] ?? '',
      schoolCode: json['school_code'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      board: json['board'],
      schoolType: json['school_type'],
    );
  }
}

// ==================== STUDENT ====================
class LeaveStudentInfo {
  final int id;
  final String studentIdCard;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? studentProfile;
  final String? studentClass;
  final String? rollNumber;
  final String? dob;
  final String? gender;
  final String? parentPhone;
  final String? fatherName;
  final String? motherName;
  final String? address;
  final LeaveSchoolInfo? school;

  LeaveStudentInfo({
    required this.id,
    required this.studentIdCard,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.studentProfile,
    this.studentClass,
    this.rollNumber,
    this.dob,
    this.gender,
    this.parentPhone,
    this.fatherName,
    this.motherName,
    this.address,
    this.school,
  });

  factory LeaveStudentInfo.fromJson(Map<String, dynamic> json) {
    return LeaveStudentInfo(
      id: json['id'] ?? 0,
      studentIdCard: json['student_id_card'] ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
      studentProfile: json['student_profile'],
      studentClass: json['student_class'],
      rollNumber: json['roll_number'],
      dob: json['dob'],
      gender: json['gender'],
      parentPhone: json['parent_phone'],
      fatherName: json['father_name'],
      motherName: json['mother_name'],
      address: json['address'],
      school: json['school'] != null
          ? LeaveSchoolInfo.fromJson(json['school'])
          : null,
    );
  }

  String get fullName => [firstName, middleName, lastName]
      .where((e) => e != null && e!.trim().isNotEmpty)
      .join(' ')
      .trim();

  bool get hasProfile =>
      studentProfile != null && studentProfile!.trim().isNotEmpty;
}

// ==================== TEACHER ====================
class LeaveTeacherInfo {
  final int id;
  final String teacherIdCard;
  final String firstName;
  final String lastName;
  final String? teacherProfile;
  final String? phone;
  final String? email;
  final String? gender;
  final String? qualification;
  final int? experience;
  final LeaveSchoolInfo? school;

  LeaveTeacherInfo({
    required this.id,
    required this.teacherIdCard,
    required this.firstName,
    required this.lastName,
    this.teacherProfile,
    this.phone,
    this.email,
    this.gender,
    this.qualification,
    this.experience,
    this.school,
  });

  factory LeaveTeacherInfo.fromJson(Map<String, dynamic> json) {
    return LeaveTeacherInfo(
      id: json['id'] ?? 0,
      teacherIdCard: json['teacher_id_card'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      teacherProfile: json['teacher_profile'],
      phone: json['phone'],
      email: json['email'],
      gender: json['gender'],
      qualification: json['qualification'],
      experience: json['experience'],
      school: json['school'] != null
          ? LeaveSchoolInfo.fromJson(json['school'])
          : null,
    );
  }

  String get fullName => "$firstName $lastName".trim();

  bool get hasProfile =>
      teacherProfile != null && teacherProfile!.trim().isNotEmpty;
}

// ==================== MAIN ====================
class StudentLeaveData {
  final int id;
  final String reasonMsg;
  final String startDate;
  final String endDate;
  final String? image;
  final String leaveStatus;
  final String createdDate;
  final LeaveStudentInfo? student;
  final LeaveTeacherInfo? teacher;
  final LeaveSchoolInfo? school;

  StudentLeaveData({
    required this.id,
    required this.reasonMsg,
    required this.startDate,
    required this.endDate,
    this.image,
    required this.leaveStatus,
    required this.createdDate,
    this.student,
    this.teacher,
    this.school,
  });

  factory StudentLeaveData.fromJson(Map<String, dynamic> json) {
    return StudentLeaveData(
      id: json['id'] ?? 0,
      reasonMsg: json['reason_msg'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      image: json['image'],
      leaveStatus: json['leave_status'] ?? 'pending',
      createdDate: json['created_date'] ?? '',
      student: json['student'] != null
          ? LeaveStudentInfo.fromJson(json['student'])
          : null,
      teacher: json['teacher'] != null
          ? LeaveTeacherInfo.fromJson(json['teacher'])
          : null,
      school: json['school'] != null
          ? LeaveSchoolInfo.fromJson(json['school'])
          : null,
    );
  }

  StudentLeaveData copyWith({
    String? leaveStatus,
    LeaveTeacherInfo? teacher,
  }) {
    return StudentLeaveData(
      id: id,
      reasonMsg: reasonMsg,
      startDate: startDate,
      endDate: endDate,
      image: image,
      leaveStatus: leaveStatus ?? this.leaveStatus,
      createdDate: createdDate,
      student: student,
      teacher: teacher ?? this.teacher,
      school: school,
    );
  }

  // ─── Derived getters (backward compatible) ───
  String get studentIdCard => student?.studentIdCard ?? '';
  String get studentName =>
      (student?.fullName.isNotEmpty ?? false) ? student!.fullName : studentIdCard;
  String get studentClass => student?.studentClass ?? '';
  String? get studentProfileImage => student?.studentProfile;

  String? get teacherCardId => teacher?.teacherIdCard;
  String get teacherName => teacher?.fullName ?? '';
  String? get teacherProfileImage => teacher?.teacherProfile;

  LeaveSchoolInfo? get schoolInfo =>
      school ?? student?.school ?? teacher?.school;
  String get schoolName => schoolInfo?.schoolName ?? '';

  // ─── Date formatters ───
  String get formattedStartDate => _formatDate(startDate);
  String get formattedEndDate => _formatDate(endDate);
  String get formattedCreatedDate => _formatDateTime(createdDate);

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    } catch (_) {
      return date;
    }
  }

  String _formatDateTime(String date) {
    try {
      final dt = DateTime.parse(date);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    } catch (_) {
      return date;
    }
  }

  String get displayStatus {
    switch (leaveStatus.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      default:
        return leaveStatus;
    }
  }

  bool get isPending => leaveStatus.toLowerCase() == 'pending';
  bool get hasImage => image != null && image!.trim().isNotEmpty;
  bool get hasStudentProfile => student?.hasProfile ?? false;
  bool get hasTeacherProfile => teacher?.hasProfile ?? false;
  bool get hasTeacher => teacher != null;
}

// ==================== RESPONSE WRAPPERS ====================

class StudentLeaveApprovalResponse {
  final bool status;
  final String? message;
  final StudentLeaveData? data;

  StudentLeaveApprovalResponse({required this.status, this.message, this.data});

  factory StudentLeaveApprovalResponse.fromJson(Map<String, dynamic> json) {
    return StudentLeaveApprovalResponse(
      status: json['status'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? StudentLeaveData.fromJson(json['data'])
          : null,
    );
  }
}

class StudentLeaveCreateResponse {
  final bool status;
  final String? message;
  final StudentLeaveData? data;

  StudentLeaveCreateResponse({required this.status, this.message, this.data});

  factory StudentLeaveCreateResponse.fromJson(Map<String, dynamic> json) {
    return StudentLeaveCreateResponse(
      status: json['status'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? StudentLeaveData.fromJson(json['data'])
          : null,
    );
  }
}

class StudentLeaveDetailResponse {
  final bool status;
  final String? message;
  final StudentLeaveData? data;

  StudentLeaveDetailResponse({required this.status, this.message, this.data});

  factory StudentLeaveDetailResponse.fromJson(Map<String, dynamic> json) {
    return StudentLeaveDetailResponse(
      status: json['status'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? StudentLeaveData.fromJson(json['data'])
          : null,
    );
  }
}

class StudentLeaveDeleteResponse {
  final bool status;
  final String? message;

  StudentLeaveDeleteResponse({required this.status, this.message});

  factory StudentLeaveDeleteResponse.fromJson(Map<String, dynamic> json) {
    return StudentLeaveDeleteResponse(
      status: json['status'] ?? false,
      message: json['message'],
    );
  }
}