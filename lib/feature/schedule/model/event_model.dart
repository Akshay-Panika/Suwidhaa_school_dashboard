// lib/feature/schedule/model/event_model.dart

class SchoolEvent {
  final int id;
  final int? school;
  final String? schoolName;
  final String? schoolCode;
  final String title;
  final String description;
  final String category;
  final String venue;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String? organizer;
  final String audience;
  final String status;
  final String? bannerUrl;
  final bool isPinned;
  final String displayDate;

  SchoolEvent({
    required this.id,
    this.school,
    this.schoolName,
    this.schoolCode,
    required this.title,
    required this.description,
    required this.category,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    this.organizer,
    required this.audience,
    required this.status,
    this.bannerUrl,
    required this.isPinned,
    required this.displayDate,
  });

  factory SchoolEvent.fromJson(Map<String, dynamic> json) {
    return SchoolEvent(
      id: json['id'],
      school: json['school'],
      schoolName: json['school_name'],
      schoolCode: json['school_code'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Sports',
      venue: json['venue'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      organizer: json['organizer'],
      audience: json['audience'] ?? 'Both',
      status: json['status'] ?? 'Upcoming',
      bannerUrl: json['banner_url'],
      isPinned: json['is_pinned'] ?? false,
      displayDate: json['display_date'] ?? '',
    );
  }
}