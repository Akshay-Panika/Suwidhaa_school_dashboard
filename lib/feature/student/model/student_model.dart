// models/student_model.dart
class StudentModel {
  final int id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String dob;
  final String gender;
  final String fatherName;
  final String motherName;
  final String parentPhone;
  final String alternativePhone;
  final String studentClass;
  final String rollNumber;
  final String admissionNumber;
  final String email;
  final String address;
  final String casteCategory;
  final String adharNumber;
  final String sssmid;
  final String feeStatus;
  final String feeAmount;
  final String paidAmount;
  final bool checkBox;
  final String? profileImage;
  final String createdAt;

  StudentModel({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.fatherName,
    required this.motherName,
    required this.parentPhone,
    required this.alternativePhone,
    required this.studentClass,
    required this.rollNumber,
    required this.admissionNumber,
    required this.email,
    required this.address,
    required this.casteCategory,
    required this.adharNumber,
    required this.sssmid,
    required this.feeStatus,
    required this.feeAmount,
    required this.paidAmount,
    required this.checkBox,
    this.profileImage,
    required this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      fatherName: json['father_name'] ?? '',
      motherName: json['mother_name'] ?? '',
      parentPhone: json['parent_phone'] ?? '',
      alternativePhone: json['alternative_phone'] ?? '',
      studentClass: json['student_class'] ?? '',
      rollNumber: json['roll_number'] ?? '',
      admissionNumber: json['admission_number'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      casteCategory: json['caste_category'] ?? '',
      adharNumber: json['adhar_number'] ?? '',
      sssmid: json['SSSMID'] ?? '',
      feeStatus: json['fee_status'] ?? '',
      feeAmount: json['fee_amount'] ?? '',
      paidAmount: json['paid_amount'] ?? '',
      checkBox: json['check_box'] ?? false,
      profileImage: json['profile_image'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'dob': dob,
      'gender': gender,
      'father_name': fatherName,
      'mother_name': motherName,
      'parent_phone': parentPhone,
      'alternative_phone': alternativePhone,
      'student_class': studentClass,
      'roll_number': rollNumber,
      'admission_number': admissionNumber,
      'email': email,
      'address': address,
      'caste_category': casteCategory,
      'adhar_number': adharNumber,
      'SSSMID': sssmid,
      'fee_status': feeStatus,
      'fee_amount': feeAmount,
      'paid_amount': paidAmount,
      'check_box': checkBox,
      'profile_image': profileImage,
      'created_at': createdAt,
    };
  }

  StudentModel copyWith({
    int? id,
    String? firstName,
    String? middleName,
    String? lastName,
    String? dob,
    String? gender,
    String? fatherName,
    String? motherName,
    String? parentPhone,
    String? alternativePhone,
    String? studentClass,
    String? rollNumber,
    String? admissionNumber,
    String? email,
    String? address,
    String? casteCategory,
    String? adharNumber,
    String? sssmid,
    String? feeStatus,
    String? feeAmount,
    String? paidAmount,
    bool? checkBox,
    String? profileImage,
    String? createdAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      parentPhone: parentPhone ?? this.parentPhone,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      studentClass: studentClass ?? this.studentClass,
      rollNumber: rollNumber ?? this.rollNumber,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      casteCategory: casteCategory ?? this.casteCategory,
      adharNumber: adharNumber ?? this.adharNumber,
      sssmid: sssmid ?? this.sssmid,
      feeStatus: feeStatus ?? this.feeStatus,
      feeAmount: feeAmount ?? this.feeAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      checkBox: checkBox ?? this.checkBox,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}