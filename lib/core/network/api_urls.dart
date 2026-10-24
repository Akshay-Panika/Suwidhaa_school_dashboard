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
  static const String classList = 'v1/school/class/list/';
  static const String classCreate = 'v1/school/class/create/';
  static const String classDetail = 'v1/school/class/';  // + id

  // Subject endpoints
  static const String subjectList = 'v1/school/subject/list/';
  static const String subjectCreate = 'v1/school/subject/create/';
  static const String subjectDetail = 'v1/school/subject/';  // + id

  // Schedule endpoints
  static const String scheduleList = 'v1/school/schedule/list/';
  static const String scheduleCreate = 'v1/school/schedule/create/';
  static const String scheduleDetail = 'v1/school/schedule/';  // + id

}