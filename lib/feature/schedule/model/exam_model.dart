// lib/feature/schedule/model/exam_model.dart

class SubjectScheduleModel {
  final int? id;
  final String subject;
  final String date;
  final String startTime;
  final String endTime;
  final int? invigilatorId;
  final String? invigilatorName;
  final String room;

  SubjectScheduleModel({
    this.id,
    required this.subject,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.invigilatorId,
    this.invigilatorName,
    required this.room,
  });

  factory SubjectScheduleModel.fromJson(Map<String, dynamic> json) {
    String? invName;
    if (json['invigilator_details'] != null) {
      invName = "${json['invigilator_details']['first_name']} ${json['invigilator_details']['last_name']}";
    }

    return SubjectScheduleModel(
      id: json['id'],
      subject: json['subject'] ?? '',
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      invigilatorId: json['invigilator'],
      invigilatorName: invName,
      room: json['room'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'invigilator': invigilatorId,
      'room': room,
    };
  }
}

class ExamTimetableModel {
  final int id;
  final int? school;
  final String schoolName;
  final String className;
  final String examType;
  final String examTypeLabel;
  final String fromDate;
  final String toDate;
  final List<SubjectScheduleModel> schedules;
  final String createdAt;

  ExamTimetableModel({
    required this.id,
    this.school,
    required this.schoolName,
    required this.className,
    required this.examType,
    required this.examTypeLabel,
    required this.fromDate,
    required this.toDate,
    required this.schedules,
    required this.createdAt,
  });

  factory ExamTimetableModel.fromJson(Map<String, dynamic> json) {
    return ExamTimetableModel(
      id: json['id'] ?? 0,
      school: json['school'],
      schoolName: json['school_name'] ?? '',
      className: json['class_name'] ?? '',
      examType: json['exam_type'] ?? '',
      examTypeLabel: json['exam_type_label'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
      schedules: json['schedules'] != null
          ? List<SubjectScheduleModel>.from(json['schedules'].map((x) => SubjectScheduleModel.fromJson(x)))
          : [],
      createdAt: json['created_at'] ?? '',
    );
  }
}