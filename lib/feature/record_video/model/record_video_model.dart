class RecordVideoModel {
  final int id;
  final String title;
  final String thumbnail;
  final String videoUrl;
  final String duration;
  final double rating;
  final String subjectName;
  final String className;

  RecordVideoModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.videoUrl,
    required this.duration,
    required this.rating,
    required this.subjectName,
    required this.className,
  });

  factory RecordVideoModel.fromJson(Map<String, dynamic> json) {
    return RecordVideoModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      videoUrl: json['video_url'] ?? '',
      duration: json['duration'] ?? '',
      rating: (json['rating'] != null) ? double.tryParse(json['rating'].toString()) ?? 5.0 : 5.0,
      subjectName: json['subject_name'] ?? '',
      className: json['class_name'] ?? '',
    );
  }
}