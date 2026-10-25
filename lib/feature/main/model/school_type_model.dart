// lib/feature/school_type/model/transport_model.dart
class SchoolTypeModel {
  final int? id;
  final String schoolName;
  final String schoolCode;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? phone;
  final String? email;
  final String? website;
  final String? board;
  final String? schoolType;
  final String? createdAt;
  final String? updatedAt;

  SchoolTypeModel({
    this.id,
    required this.schoolName,
    required this.schoolCode,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.phone,
    this.email,
    this.website,
    this.board,
    this.schoolType,
    this.createdAt,
    this.updatedAt,
  });

  // ---------- From API ----------
  factory SchoolTypeModel.fromApiJson(Map<String, dynamic> json) {
    return SchoolTypeModel(
      id: json['id'] as int?,
      schoolName: json['school_name']?.toString() ?? '',
      schoolCode: json['school_code']?.toString() ?? '',
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      board: json['board']?.toString(),
      schoolType: json['school_type']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  // ---------- To JSON (for create/update) ----------
  Map<String, dynamic> toJson() {
    return {
      'school_name': schoolName,
      'school_code': schoolCode,
      'address': address ?? '',
      'city': city ?? '',
      'state': state ?? '',
      'pincode': pincode ?? '',
      'phone': phone ?? '',
      'email': email ?? '',
      'website': website ?? '',
      'board': board ?? '',
      'school_type': schoolType ?? '',
    };
  }

  // ---------- CopyWith ----------
  SchoolTypeModel copyWith({
    int? id,
    String? schoolName,
    String? schoolCode,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? phone,
    String? email,
    String? website,
    String? board,
    String? schoolType,
    String? createdAt,
    String? updatedAt,
  }) {
    return SchoolTypeModel(
      id: id ?? this.id,
      schoolName: schoolName ?? this.schoolName,
      schoolCode: schoolCode ?? this.schoolCode,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      board: board ?? this.board,
      schoolType: schoolType ?? this.schoolType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Useful for DropdownButton / equality checks
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SchoolTypeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}