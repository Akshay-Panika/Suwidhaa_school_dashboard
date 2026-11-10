class RecordClassModel {
  final int id;
  final String name;
  final int videoCount;
  final int subjectCount; // ✅ Added

  RecordClassModel({
    required this.id,
    required this.name,
    required this.videoCount,
    required this.subjectCount, // ✅ Added
  });

  factory RecordClassModel.fromJson(Map<String, dynamic> json) {
    return RecordClassModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      videoCount: json['video_count'] ?? 0,
      subjectCount: json['subject_count'] ?? 0, // ✅ Added
    );
  }
}