// lib/feature/auth/screen/splash_screen.dart
import 'package:flutter/material.dart';
import '../service/auth_pref.dart';
import 'auth_screen.dart';
import '../../main/screen/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Show splash for a minimum of 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is logged in
    bool isLoggedIn = await AuthPref.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // Go directly to MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Go to AuthScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Suwidhaa',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black26,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Tagline Here',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}