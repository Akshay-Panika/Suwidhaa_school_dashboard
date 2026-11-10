class RecordSubjectModel {
  final int id;
  final String name;
  final int classId;
  final String className;

  RecordSubjectModel({
    required this.id,
    required this.name,
    required this.classId,
    required this.className,
  });

  factory RecordSubjectModel.fromJson(Map<String, dynamic> json) {
    return RecordSubjectModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      classId: json['school_class'] ?? 0,
      className: json['class_name'] ?? '',
    );
  }
}