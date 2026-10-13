import 'package:flutter/material.dart';
import 'staff_roster/screens/staff_roster_screen.dart';

void main() {
  runApp(const PrisonManagementApp());
}

class PrisonManagementApp extends StatelessWidget {
  const PrisonManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prison Management System',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const StaffRosterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}