class StudentFeeModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? studentProfile;
  final String? studentIdCard;
  final String? schoolName;
  final String studentClass;
  final FeeSummary? feeSummary;

  StudentFeeModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.studentProfile,
    this.studentIdCard,
    this.schoolName,
    required this.studentClass,
    this.feeSummary,
  });

  factory StudentFeeModel.fromJson(Map<String, dynamic> json) {
    return StudentFeeModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      studentProfile: json['student_profile'],
      studentIdCard: json['student_id_card'],
      schoolName: json['school'] != null ? json['school']['school_name'] : null,
      studentClass: json['student_class'] ?? 'N/A',
      feeSummary: json['fee_summary'] != null
          ? FeeSummary.fromJson(json['fee_summary'])
          : null,
    );
  }
}

class FeeSummary {
  final double totalFee;
  final double totalPaid;
  final double pending;
  final String status;

  FeeSummary({
    required this.totalFee,
    required this.totalPaid,
    required this.pending,
    required this.status,
  });

  factory FeeSummary.fromJson(Map<String, dynamic> json) {
    return FeeSummary(
      totalFee: (json['total_fee'] ?? 0).toDouble(),
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      pending: (json['pending'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
    );
  }
}

class FeeHistoryModel {
  final int id;
  final String amountPaid;
  final String? remarks;
  final String paymentDate;

  FeeHistoryModel({
    required this.id,
    required this.amountPaid,
    this.remarks,
    required this.paymentDate,
  });

  factory FeeHistoryModel.fromJson(Map<String, dynamic> json) {
    return FeeHistoryModel(
      id: json['id'] ?? 0,
      amountPaid: json['amount_paid']?.toString() ?? '0.00',
      remarks: json['remarks'],
      paymentDate: json['payment_date'] ?? '',
    );
  }
}