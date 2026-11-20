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
import 'authentication/screens/dashboards/system_admin_dashboard.dart';
import 'splash/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure SQLite for Chrome.
  // Configure SQLite for Flutter Web.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Initialize Hive storage.
  await Hive.initFlutter();
  await Hive.openBox('inmates_box');
  await Hive.openBox('staff_shifts_box');
  await Hive.openBox('rehabilitation_box');

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
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ResetPasswordScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/home': (_) => DashboardScreen(
              user: const {
                'full_name': 'Test Officer',
                'email': 'officer@prisons.gov.mw',
                'officer_id': 'TEST001',
                'phone': '',
              },
            ),
        '/inmates': (_) =>
            const InmateListScreen(currentUserRole: 'Record Officer'),
        '/visitors': (_) => const VisitorListScreen(),
        '/tracking': (_) => const TrackingScreen(),
        '/rehabilitation': (_) => const RehabilitationScreen(),
        '/releases': (_) => const ReleaseManagementScreen(),
        '/staff': (_) => const StaffRosterScreen(),
      },
    );
  }
}
