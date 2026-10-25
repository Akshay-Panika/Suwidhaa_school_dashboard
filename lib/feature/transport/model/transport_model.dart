import '../../student/model/student_model.dart';
import '../../main/model/school_type_model.dart';

class TransportModel {
  final int id;
  final SchoolTypeModel? school;
  final String? transportType;
  final String vehicleNumber;
  final String driverName;
  final String driverNumber;
  final String? driverImage;
  final String? capacity;
  final String? routeName;
  final List<TransportStudentModel> students;
  final int studentCount;
  final String? createdAt;
  final String? updatedAt;

  TransportModel({
    required this.id,
    this.school,
    this.transportType,
    required this.vehicleNumber,
    required this.driverName,
    required this.driverNumber,
    this.driverImage,
    this.capacity,
    this.routeName,
    required this.students,
    required this.studentCount,
    this.createdAt,
    this.updatedAt,
  });

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      id: json['id'] ?? 0,
      school: json['school'] != null ? SchoolTypeModel.fromApiJson(json['school']) : null,
      transportType: json['transport_type'],
      vehicleNumber: json['vehicle_number'] ?? '',
      driverName: json['driver_name'] ?? '',
      driverNumber: json['driver_number'] ?? '',
      driverImage: json['driver_image'],
      capacity: json['capacity'],
      routeName: json['route_name'],
      students: (json['students'] as List?)
          ?.map((e) => TransportStudentModel.fromJson(e))
          .toList() ?? [],
      studentCount: json['student_count'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class TransportStudentModel {
  final int id;
  final StudentModel student;
  final String? address;
  final String? pickupTime;
  final String? dropTime;

  TransportStudentModel({
    required this.id,
    required this.student,
    this.address,
    this.pickupTime,
    this.dropTime,
  });

  factory TransportStudentModel.fromJson(Map<String, dynamic> json) {
    return TransportStudentModel(
      id: json['id'] ?? 0,
      student: StudentModel.fromApiJson(json['student']),
      address: json['address'],
      pickupTime: json['pickup_time'],
      dropTime: json['drop_time'],
    );
  }
}