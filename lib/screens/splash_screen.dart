import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF344B3B), // Dark Green (`#344B3B`)
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // True circular badge container with dark green background and soft shadow
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF344B3B), // Matches splash background
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Center(
                    child: Image.asset(
                      'assets/images/Prison logo.jpg',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      color: const Color(0xFF344B3B),
                      colorBlendMode: BlendMode.multiply, // Blends white background into dark green
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              // Main System Title
              const Text(
                'Prison Management\nSystem',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              // Subtitle
              const Text(
                'Operations . Administration . Oversight',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}