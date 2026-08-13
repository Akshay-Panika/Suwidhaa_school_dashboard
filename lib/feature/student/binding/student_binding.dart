// lib/feature/student/binding/student_binding.dart
import 'package:get/get.dart';
import '../controller/student_controller.dart';

class StudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentController>(() => StudentController());
  }
}