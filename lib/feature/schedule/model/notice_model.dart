class SchoolModel {
  final int id;
  final String schoolName;
  final String schoolCode;

  SchoolModel({
    required this.id,
    required this.schoolName,
    required this.schoolCode,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] ?? 0,
      schoolName: json['school_name'] ?? '',
      schoolCode: json['school_code'] ?? '',
    );
  }
}

class NoticeModel {
  final int id;
  final SchoolModel? school;
  final String title;
  final String description;
  final String priority;
  final String audience;
  final String assignedClass;
  final String? attachmentUrl;
  final bool isPinned;
  final String createdBy;
  final String displayDate;

  NoticeModel({
    required this.id,
    this.school,
    required this.title,
    required this.description,
    required this.priority,
    required this.audience,
    required this.assignedClass,
    this.attachmentUrl,
    required this.isPinned,
    required this.createdBy,
    required this.displayDate,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] ?? 0,
      school: json['school'] != null ? SchoolModel.fromJson(json['school']) : null,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Normal',
      audience: json['audience'] ?? 'Students',
      assignedClass: json['assigned_class'] ?? 'All Classes',
      attachmentUrl: json['attachment_url'],
      isPinned: json['is_pinned'] ?? false,
      createdBy: json['created_by'] ?? '',
      displayDate: json['display_date'] ?? '',
    );
  }
}