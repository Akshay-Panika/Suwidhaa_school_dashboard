

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../feature/classes/controller/class_controller.dart';
import '../feature/main/controller/school_type_controller.dart';
import '../feature/schedule/controller/schedule_controller.dart';
import '../feature/student/controller/student_attendance_controller.dart';
import '../feature/student/controller/student_controller.dart';
import '../feature/subjects/controller/subject_controller.dart';
import '../feature/teachers/controller/teacher_attendance_controller.dart';
import '../feature/teachers/controller/teacher_controller.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Register all controllers
    Get.put<TeacherController>(TeacherController(), permanent: true);
    Get.put<StudentController>(StudentController(), permanent: true);
    Get.put<StudentAttendanceController>(StudentAttendanceController(), permanent: true);
    Get.put<ClassController>(ClassController(), permanent: true);
    Get.put<SubjectController>(SubjectController(), permanent: true);
    Get.put<ScheduleController>(ScheduleController(), permanent: true);
    Get.put<SchoolTypeController>(SchoolTypeController(), permanent: true);
    Get.put<TeacherAttendanceController>(TeacherAttendanceController(), permanent: true);


  }
}