// lib/feature/schedule/model/meeting_model.dart

class MeetingModel {
  final int id;
  final int? school;
  final String? schoolName;
  final String title;
  final String date;
  final String time;
  final String forMeeting;
  final String? className;
  final String? zoomUrl;
  final String createdAt;

  MeetingModel({
    required this.id,
    this.school,
    this.schoolName,
    required this.title,
    required this.date,
    required this.time,
    required this.forMeeting,
    this.className,
    this.zoomUrl,
    required this.createdAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] ?? 0,
      school: json['school'],
      schoolName: json['school_name'],
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      forMeeting: json['for_meeting'] ?? 'Student',
      className: json['class_name'],
      zoomUrl: json['zoom_url'],
      createdAt: json['created_at'] ?? '',
    );
  }
}