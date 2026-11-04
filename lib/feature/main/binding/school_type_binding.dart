// lib/feature/teacher_salary/binding/teacher_salary_binding.dart

import 'package:get/get.dart';

import '../controller/school_type_controller.dart';

class SchoolTypeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SchoolTypeController>(() => SchoolTypeController());
  }
}