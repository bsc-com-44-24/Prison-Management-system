import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'staff_roster/screens/staff_roster_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for Flutter local storage
  await Hive.initFlutter();
  
  // Open a local box for staff shifts
  await Hive.openBox('staff_shifts_box');

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