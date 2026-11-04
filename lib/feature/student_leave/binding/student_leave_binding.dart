// lib/feature/school/student_leave/binding/student_leave_binding.dart

import 'package:get/get.dart';
import '../controller/student_leave_controller.dart';

class StudentLeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentLeaveController>(
          () => StudentLeaveController(),
      fenix: true,
    );
  }
}