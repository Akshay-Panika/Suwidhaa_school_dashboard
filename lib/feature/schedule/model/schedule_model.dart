// ============ ENUMS ============
import 'dart:ui';

import 'package:flutter/material.dart';

enum ScheduleType {
  event,
  exam,
  other,
}

enum ScheduleFilter {
  all,
  event,
  exam,
  other,
}

// ============ API MODELS ============
class ScheduleListResponse {
  final bool success;
  final int? count;
  final List<ScheduleApiModel> data;

  ScheduleListResponse({
    required this.success,
    this.count,
    required this.data,
  });

  factory ScheduleListResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleListResponse(
      success: json['success'] ?? false,
      count: json['count'],
      data: (json['data'] as List?)
          ?.map((e) => ScheduleApiModel.fromJson(e))
          .toList() ?? [],
    );
  }
}

class ScheduleApiModel {
  final int id;
  final String? bannerImage;
  final String? pdfFile;
  final String title;
  final String description;
  final String type;
  final String startDate;
  final String endDate;
  final String schoolType;
  final String time;
  final String location;
  final String status;
  final List<String> assignedClasses;
  final List<String> assignedTeachers;
  final EventDetails? eventDetails;
  final bool checkBox;
  final String createdAt;
  final String updatedAt;

  ScheduleApiModel({
    required this.id,
    this.bannerImage,
    this.pdfFile,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.schoolType,
    required this.time,
    required this.location,
    required this.status,
    required this.assignedClasses,
    required this.assignedTeachers,
    this.eventDetails,
    required this.checkBox,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleApiModel.fromJson(Map<String, dynamic> json) {
    return ScheduleApiModel(
      id: json['id'] ?? 0,
      bannerImage: json['banner_image'],
      pdfFile: json['pdf_file'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'Event',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      schoolType: json['school_type'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'Upcoming',
      assignedClasses: (json['assigned_classes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      assignedTeachers: (json['assigned_teachers'] as List?)?.map((e) => e.toString()).toList() ?? [],
      eventDetails: json['event_details'] != null ? EventDetails.fromJson(json['event_details']) : null,
      checkBox: json['check_box'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'start_date': startDate,
      'end_date': endDate,
      'school_type': schoolType,
      'time': time,
      'location': location,
      'status': status,
      'assigned_classes': assignedClasses,
      'assigned_teachers': assignedTeachers,
      'event_details': eventDetails?.toJson(),
      'check_box': checkBox,
    };
  }
}

class EventDetails {
  final String? eventType;
  final String? guestSpeaker;
  final String? eventDescription;
  final String? expectedAttendees;

  EventDetails({
    this.eventType,
    this.guestSpeaker,
    this.eventDescription,
    this.expectedAttendees,
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      eventType: json['event_type'],
      guestSpeaker: json['guest_speaker'],
      eventDescription: json['event_description'],
      expectedAttendees: json['expected_attendees'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_type': eventType,
      'guest_speaker': guestSpeaker,
      'event_description': eventDescription,
      'expected_attendees': expectedAttendees,
    };
  }
}

// ============ UI MODEL ============
class ScheduleUIModel {
  final String id;
  final String? bannerImage;
  final String? pdfFile;
  final String title;
  final String description;
  final String type;
  final String startDate;
  final String endDate;
  final String schoolType;
  final String time;
  final String location;
  final String status;
  final List<String> assignedClasses;
  final List<String> assignedTeachers;
  final EventDetails? eventDetails;
  final bool checkBox;

  ScheduleUIModel({
    required this.id,
    this.bannerImage,
    this.pdfFile,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.schoolType,
    required this.time,
    required this.location,
    required this.status,
    required this.assignedClasses,
    required this.assignedTeachers,
    this.eventDetails,
    required this.checkBox,
  });

  factory ScheduleUIModel.fromApi(ScheduleApiModel api) {
    return ScheduleUIModel(
      id: api.id.toString(),
      bannerImage: api.bannerImage,
      pdfFile: api.pdfFile,
      title: api.title,
      description: api.description,
      type: api.type,
      startDate: api.startDate,
      endDate: api.endDate,
      schoolType: api.schoolType,
      time: api.time,
      location: api.location,
      status: api.status,
      assignedClasses: api.assignedClasses,
      assignedTeachers: api.assignedTeachers,
      eventDetails: api.eventDetails,
      checkBox: api.checkBox,
    );
  }

  ScheduleApiModel toApiModel() {
    return ScheduleApiModel(
      id: int.tryParse(id) ?? 0,
      bannerImage: bannerImage,
      pdfFile: pdfFile,
      title: title,
      description: description,
      type: type,
      startDate: startDate,
      endDate: endDate,
      schoolType: schoolType,
      time: time,
      location: location,
      status: status,
      assignedClasses: assignedClasses,
      assignedTeachers: assignedTeachers,
      eventDetails: eventDetails,
      checkBox: checkBox,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  String get schoolDisplay => schoolType.toUpperCase() == 'A' ? 'School A' : 'School B';
  Color get schoolColor => schoolType.toUpperCase() == 'A' ? Colors.blue : Colors.green;

  bool get isUpcoming => status.toLowerCase() == 'upcoming';
  bool get isOngoing => status.toLowerCase() == 'ongoing';
  bool get isCompleted => status.toLowerCase() == 'completed';

  Color get statusColor {
    if (isUpcoming) return Colors.green;
    if (isOngoing) return Colors.orange;
    return Colors.grey;
  }

  String get statusDisplay => status.isNotEmpty ? status : 'Upcoming';
}