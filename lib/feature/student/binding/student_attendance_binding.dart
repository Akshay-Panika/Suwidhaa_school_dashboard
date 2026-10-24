// lib/feature/student_attendance/binding/student_attendance_binding.dart
import 'package:get/get.dart';

import '../controller/student_attendance_controller.dart';

class StudentAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentAttendanceController>(
          () => StudentAttendanceController(),
      fenix: true,
    );
  }
}