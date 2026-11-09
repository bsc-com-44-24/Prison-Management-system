
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'authentication/db/database_helper.dart';
import 'authentication/theme.dart';
import 'authentication/screens/login_screen.dart';
import 'authentication/screens/register_screen.dart';
import 'authentication/screens/forgot_password_screen.dart';
import 'authentication/screens/dashboard_screen.dart';

import 'splash/screens/splash_screen.dart';
import 'Inmate_management/screens/inmate_list_screen.dart';
import 'visitor_management/screens/visitor_list_screen.dart';
import 'release_management/screens/release_management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? startupError;

  try {
    // Initialize Hive storage.
    await Hive.initFlutter();
    await Hive.openBox('inmates_box');
    await Hive.openBox('staff_shifts_box');

    // Initialize authentication database.
    await DatabaseHelper.instance.init();
  } catch (error, stackTrace) {
    startupError = error;

    debugPrint('STARTUP ERROR: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(PrisonApp(startupError: startupError));
}

class PrisonApp extends StatelessWidget {
  final Object? startupError;

  const PrisonApp({
    super.key,
    this.startupError,
  });

  @override
  Widget build(BuildContext context) {
    if (startupError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: StartupErrorScreen(
          error: startupError.toString(),
        ),
      );
    }

    return MaterialApp(
      title: 'Prison Management System',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/login',

      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),

        '/home': (_) => DashboardScreen(
              user: const {
                'full_name': 'Test Officer',
                'email': 'officer@prisons.gov.mw',
                'officer_id': 'TEST001',
                'phone': '',
              },
            ),

        '/inmates': (_) => const InmateListScreen(),
        '/visitors': (_) => const VisitorListScreen(),
        '/release-test': (_) => const ReleaseManagementScreen(),
      },
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  final String error;

  const StartupErrorScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Application Startup Failed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'The application could not initialize its local storage.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SelectableText(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
