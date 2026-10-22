import 'package:flutter/foundation.dart'; // 1. Added for kIsWeb check
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // 2. Added for databaseFactory
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // 3. Added for Web SQLite support
import 'features/visitor_management/screens/visitor_list_screen.dart'; 

void main() async { // 4. Added 'async' here
  // 5. Ensures Flutter framework hooks are fully loaded before database starts
  WidgetsFlutterBinding.ensureInitialized();

  // 6. Automatically setup the correct database engine if running in Chrome
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prison Management System',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E4F32), 
          primary: const Color(0xFF2E4F32),
        ),
        useMaterial3: true,
      ),
      home: const VisitorListScreen(), 
    );
  }
}
