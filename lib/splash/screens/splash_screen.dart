import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});

@override
State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
@override
void initState() {
super.initState();

Future.delayed(const Duration(seconds: 5), () {
  if (!mounted) return;

  Navigator.pushReplacementNamed(context, '/login');
});


}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFF344B3B),
body: Center(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24.0),
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Container(
width: 160,
height: 160,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: const Color(0xFF344B3B),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.3),
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
colorBlendMode: BlendMode.multiply,
),
),
),
),
const SizedBox(height: 36),
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
