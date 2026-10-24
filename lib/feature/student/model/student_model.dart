// lib/feature/student/model/student_model.dart
class StudentModel {
  final int? id;
  final String? studentProfile;
  final int? schoolId; // ✅ Added to track school ID
  final String? schoolName; // ✅ Added to display school name
  final String firstName;
  final String middleName;
  final String lastName;
  final String dob;
  final String gender;
  final String fatherName;
  final String motherName;
  final String parentPhone;
  final String? alternativePhone;
  final String adharNumber;
  final String sssmid;
  final String studentClass;
  final String rollNumber;
  final String address;
  final String casteCategory;
  final String feeStatus;
  final String feeAmount;
  final String paidAmount;
  final bool checkBox;
  final String? studentIdCard;
  final String? createdAt;
  final String? updatedAt;

  StudentModel({
    this.id,
    this.studentProfile,
    this.schoolId,
    this.schoolName,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.fatherName,
    required this.motherName,
    required this.parentPhone,
    this.alternativePhone,
    required this.adharNumber,
    required this.sssmid,
    required this.studentClass,
    required this.rollNumber,
    required this.address,
    required this.casteCategory,
    required this.feeStatus,
    required this.feeAmount,
    required this.paidAmount,
    this.checkBox = false,
    this.studentIdCard,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from API response
  factory StudentModel.fromApiJson(Map<String, dynamic> json) {
    // Safely parse nested school object
    int? parsedSchoolId;
    String? parsedSchoolName;
    if (json['school'] != null && json['school'] is Map) {
      parsedSchoolId = json['school']['id'] as int?;
      parsedSchoolName = json['school']['school_name']?.toString();
    }

    return StudentModel(
      id: json['id'] as int?,
      studentProfile: json['student_profile'] as String?,
      schoolId: parsedSchoolId,
      schoolName: parsedSchoolName,
      firstName: json['first_name']?.toString() ?? '',
      middleName: json['middle_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      fatherName: json['father_name']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? '',
      parentPhone: json['parent_phone']?.toString() ?? '',
      alternativePhone: json['alternative_phone']?.toString(),
      adharNumber: json['adhar_number']?.toString() ?? '',
      sssmid: json['SSSMID']?.toString() ?? '',
      studentClass: json['student_class']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      casteCategory: json['caste_category']?.toString() ?? '',
      feeStatus: json['fee_status']?.toString() ?? '',
      feeAmount: json['fee_amount']?.toString() ?? '0.00',
      paidAmount: json['paid_amount']?.toString() ?? '0.00',
      checkBox: json['check_box'] ?? false,
      studentIdCard: json['student_id_card'] as String?,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  // Convert to JSON for API requests (Used for both FormData & JSON)
  Map<String, dynamic> toJson() {
    return {
      'school_id': schoolId, // ✅ Crucial for linking student to school
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'dob': dob,
      'gender': gender,
      'father_name': fatherName,
      'mother_name': motherName,
      'parent_phone': parentPhone,
      'alternative_phone': alternativePhone ?? '',
      'adhar_number': adharNumber,
      'SSSMID': sssmid,
      'student_class': studentClass,
      'roll_number': rollNumber,
      'address': address,
      'caste_category': casteCategory,
      'fee_status': feeStatus,
      'fee_amount': feeAmount,
      'paid_amount': paidAmount,
      'check_box': checkBox,
      'student_id_card': studentIdCard ?? '',
    };
  }
}