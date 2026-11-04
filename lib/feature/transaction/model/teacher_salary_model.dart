class TeacherSalaryModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? teacherProfile;
  final String? teacherIdCard;
  final String? schoolName;
  final String salary;
  final TransactionSummary? transaction;

  TeacherSalaryModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.teacherProfile,
    this.teacherIdCard,
    this.schoolName,
    required this.salary,
    this.transaction,
  });

  factory TeacherSalaryModel.fromJson(Map<String, dynamic> json) {
    return TeacherSalaryModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      teacherProfile: json['teacher_profile'],
      teacherIdCard: json['teacher_id_card'],
      schoolName: json['school'] != null ? json['school']['school_name'] : null,
      salary: json['salary']?.toString() ?? '0.00',
      transaction: json['transaction'] != null
          ? TransactionSummary.fromJson(json['transaction'])
          : null,
    );
  }
}

class TransactionSummary {
  final int year;
  final int month;
  final double baseSalary;
  final double totalPaid;
  final double pending;
  final String status;

  TransactionSummary({
    required this.year,
    required this.month,
    required this.baseSalary,
    required this.totalPaid,
    required this.pending,
    required this.status,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      baseSalary: (json['base_salary'] ?? 0).toDouble(),
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      pending: (json['pending'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
    );
  }
}

class SalaryHistoryModel {
  final int id;
  final String amountPaid;
  final int month;
  final int year;
  final String? remarks;
  final String paymentDate;

  SalaryHistoryModel({
    required this.id,
    required this.amountPaid,
    required this.month,
    required this.year,
    this.remarks,
    required this.paymentDate,
  });

  factory SalaryHistoryModel.fromJson(Map<String, dynamic> json) {
    return SalaryHistoryModel(
      id: json['id'] ?? 0,
      amountPaid: json['amount_paid']?.toString() ?? '0.00',
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      remarks: json['remarks'],
      paymentDate: json['payment_date'] ?? '',
    );
  }
}