import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF344B3B), // Official Dark Green
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder / asset
            Image.asset(
              'assets/images/logo.png',
              width: 140,
              height: 140,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.shield_rounded,
                size: 100,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Prison Management System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}