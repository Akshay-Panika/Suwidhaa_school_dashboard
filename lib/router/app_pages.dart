import 'package:get/get.dart';
import '../feature/auth/screen/auth_screen.dart';
import '../feature/auth/screen/splash_screen.dart';
import '../feature/main/screen/main_screen.dart';
import '../feature/student/binding/student_binding.dart';
import '../feature/student/screen/student_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.students,
      page: () => const StudentScreen(),
      binding: StudentBinding(), // <-- Add this
      transition: Transition.rightToLeft,
    ),
  ];
}