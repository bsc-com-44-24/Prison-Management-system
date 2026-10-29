import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'authentication/db/database_helper.dart';
import 'authentication/theme.dart';
import 'authentication/screens/login_screen.dart';
import 'authentication/screens/register_screen.dart';
import 'authentication/screens/forgot_password_screen.dart';
import 'authentication/screens/home_screen.dart';
import 'splash/screens/splash_screen.dart';
import 'Inmate_management/screens/inmate_list_screen.dart';
import 'visitor_management/screens/visitor_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure SQLite for Chrome.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Initialize Hive storage.
  await Hive.initFlutter();
  await Hive.openBox('inmates_box');
  await Hive.openBox('staff_shifts_box');

  // Initialize the authentication database.
  await DatabaseHelper.instance.init();

  runApp(const PrisonApp());
}

class PrisonApp extends StatelessWidget {
  const PrisonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prison Management System',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/home': (_) => const HomeScreen(user: {}),
        '/inmates': (_) => const InmateListScreen(),
        '/visitors': (_) => const VisitorListScreen(),
      },
    );
  }
}