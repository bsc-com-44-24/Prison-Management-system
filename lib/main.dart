import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'authentication/db/database_helper.dart';
import 'authentication/theme.dart';

import 'authentication/screens/login_screen.dart';
import 'authentication/screens/reset_password.dart';
import 'Inmate_management/screens/inmate_list_screen.dart';
import 'visitor_management/screens/visitor_list_screen.dart';
import 'tracking/screens/tracking_screen.dart';
import 'rehabilitation/screens/rehabilitation_screen.dart';
import 'release_management/screens/release_management_screen.dart';
import 'staff_roster/screens/staff_roster_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure SQLite for Flutter Web.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Initialize Hive.
  await Hive.initFlutter();

  await Hive.openBox('inmates_box');
  await Hive.openBox('staff_shifts_box');

  // Initialize local database.
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
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ResetPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/inmates': (context) => const InmateListScreen(),
        '/visitors': (context) => const VisitorListScreen(),
        '/tracking': (context) => const TrackingScreen(),
        '/rehabilitation': (context) => const RehabilitationScreen(),
        '/releases': (context) => const ReleaseManagementScreen(),
        '/staff': (context) => const StaffRosterScreen(),
      },
    );
  }
}
