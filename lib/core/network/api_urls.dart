// lib/core/network/api_urls.dart
class ApiUrls {
  // School type endpoints
  static const String schoolTypeList   = 'v1/school/school-type/list/';
  static const String schoolTypeCreate = 'v1/school/school-type/create/';
  static const String schoolTypeDetail = 'v1/school/school-type/'; // + id/

  // Student endpoints
  static const String studentList = 'v1/school/student/list/';
  static const String studentCreate = 'v1/school/student/create/';
  static const String studentDetail = 'v1/school/student/';  // + id/
  static String studentBySchool(int schoolId) => 'v1/school/student/list/school/$schoolId/';

  // Student Attendance endpoints 
  static const String studentAttendanceCreate = 'v1/school/student-attendance/create/';
   static const String studentAttendanceList = 'v1/school/student-attendance/list/';
  static String studentAttendanceDetail(int studentId) => 'v1/school/student-attendance/list/$studentId/';
  static String studentAttendanceDelete(int studentId, String date) => 'v1/school/student-attendance/list/$studentId/$date/';
  static String studentAttendanceToday(int studentId) => 'v1/school/student-attendance/today/$studentId/';

  // Teacher Attendance endpoints
  static const String teacherAttendanceList = 'v1/school/teacher-attendance/list/';
  static const String teacherAttendanceCheckIn = 'v1/school/teacher-attendance/check-in/';
  static const String teacherAttendanceCheckOut = 'v1/school/teacher-attendance/check-out/';
  static const String teacherAttendanceHistory = 'v1/school/teacher-attendance/history/';
  static const String teacherAttendanceUpdate = 'v1/school/teacher-attendance/update/';
  static String teacherAttendanceDelete(int pk) => 'v1/school/teacher-attendance/delete/$pk/';

  // Teacher endpoints
  static const String teacherList = 'v1/school/teacher/list/';
  static const String teacherCreate = 'v1/school/teacher/create/';
  static const String teacherDetail = 'v1/school/teacher/';
  static String teacherBySchool(int schoolId) => 'v1/school/teacher/list/school/$schoolId/';

  // Class endpoints
  static const String classCreate = 'v1/school/class/create/';
  static String classListBySchool(int schoolId) => 'v1/school/class/list/school/$schoolId/';
  static String classAssignTeacher(int classId) => 'v1/school/class/$classId/assign-teacher/';

  // Subject endpoints
  static const String subjectList = 'v1/school/subject/list/';
  static const String subjectCreate = 'v1/school/subject/create/';
  static const String subjectDetail = 'v1/school/subject/';  // + id
  static String subjectBySchool(int schoolId) => 'v1/school/subject/list/school/$schoolId/';

  // Schedule endpoints
  static const String scheduleList = 'v1/school/schedule/list/';
  static const String scheduleCreate = 'v1/school/schedule/create/';
  static const String scheduleDetail = 'v1/school/schedule/';  // + id

  // Transport endpoints
  static const String transportCreate = 'v1/school/transport/create/';
  static const String transportList = 'v1/school/transport/list/';
  static String transportBySchool(int schoolId) => 'v1/school/transport/list/school/$schoolId/';
  static String transportDetail(int id) => 'v1/school/transport/$id/';
  static String transportAddStudent(int id) => 'v1/school/transport/$id/students/add/';
  static String transportRemoveStudent(int id, int studentId) => 'v1/school/transport/$id/students/$studentId/delete/';

  // Notice endpoints
  static const String noticeCreate = 'v1/school/notice/create/';
  static const String noticeList = 'v1/school/notice/list/';
  static String noticeListBySchool(int schoolId) => 'v1/school/notice/list/school/$schoolId/';
  static String noticeDetail(int pk) => 'v1/school/notice/$pk/';
  static String noticeTogglePin(int pk) => 'v1/school/notice/$pk/toggle-pin/';

  static const String eventCreate = 'v1/school/event/create/';
  static const String eventList = 'v1/school/event/list/';
  static String eventCreateBySchool(int schoolId) => 'v1/school/$schoolId/event/create/';
  static String eventListBySchool(int schoolId) => 'v1/school/$schoolId/event/list/';
  static String eventDetail(int schoolId, int pk) => 'v1/school/$schoolId/event/$pk/';
  static String eventTogglePin(int schoolId, int pk) => 'v1/school/$schoolId/event/$pk/toggle-pin/';

  // Meeting endpoints
  static String meetingCreate(int schoolId) => 'v1/school/$schoolId/meeting/create/';
  static String meetingList(int schoolId) => 'v1/school/$schoolId/meeting/list/';
  static String meetingDetail(int schoolId, int id) => 'v1/school/$schoolId/meeting/$id/';
  static String meetingDelete(int schoolId, int id) => 'v1/school/$schoolId/meeting/delete/$id/';

  // Exam endpoints
  static String examCreate(int schoolId) => 'v1/school/$schoolId/exam-timetables/create/';
  static String examList(int schoolId) => 'v1/school/$schoolId/exam-timetables/list/';
  static String examDetail(int schoolId, int pk) => 'v1/school/$schoolId/exam-timetables/$pk/';

}