import 'package:flutter/material.dart';

import 'inmate_module/screens/inmate_list_screen.dart';

void main() {
  runApp(const PrisonManagementApp());
}

class PrisonManagementApp extends StatelessWidget {
  const PrisonManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prison Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const InmateListScreen(),
    );
  }
}
