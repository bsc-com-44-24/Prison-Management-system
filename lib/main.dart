import 'package:flutter/foundation.dart'; // 1. Added for kIsWeb check
import 'package:flutter/material.dart';
import 'authentication/db/database_helper.dart';
import 'authentication/theme.dart';
import 'authentication/screens/login_screen.dart';
import 'authentication/screens/register_screen.dart';
import 'authentication/screens/forgot_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.init();
  runApp(const PrisonApp());
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

import 'package:hive_flutter/hive_flutter.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Open local box for staff shifts
  await Hive.openBox('staff_shifts_box');
  
  runApp(const MyApp());
}

class PrisonApp extends StatelessWidget {
  const PrisonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prison Management System',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
      },
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF344B3B), // Official Dark Green
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      ),
      home: const SplashScreen(),
    );
  }
}
