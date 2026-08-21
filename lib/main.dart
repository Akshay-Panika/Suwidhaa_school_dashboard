// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'feature/auth/screen/splash_screen.dart';
import 'feature/student/controller/student_controller.dart';
import 'feature/teachers/controller/teacher_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialBinding: AppBindings(),
      home: const SplashScreen(),
    );
  }
}

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Register all controllers
    Get.put<TeacherController>(TeacherController(), permanent: true);
    Get.put<StudentController>(StudentController(), permanent: true);
    // Get.put<ClassController>(ClassController(), permanent: true);
    // Get.put<SubjectController>(SubjectController(), permanent: true);
  }
}