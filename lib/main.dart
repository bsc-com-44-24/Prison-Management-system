import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'authentication/db/database_helper.dart';
import 'authentication/theme.dart';
import 'authentication/screens/login_screen.dart';
import 'authentication/screens/reset_password.dart';
import 'authentication/screens/auth_services/auth_service.dart';
import 'authentication/screens/dashboards/role_dashboard_factory.dart';
import 'authentication/screens/dashboards/commissioner_workflow_screens.dart';
import 'authentication/screens/manage_prisons_screen.dart';
import 'authentication/screens/manage_users_screen.dart';
import 'authentication/screens/profile_and_settings_screen.dart';
import 'Inmate_management/screens/inmate_list_screen.dart';
import 'visitor_management/screens/visitor_list_screen.dart';
import 'tracking/screens/api_tracking_screen.dart';
import 'rehabilitation/screens/rehabilitation_screen.dart';
import 'release_management/screens/api_release_screen.dart';
import 'staff_roster/screens/duty_roster_screen.dart';
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
      },
      onGenerateRoute: _generateAuthenticatedRoute,
    );
  }
}

Route<dynamic>? _generateAuthenticatedRoute(RouteSettings settings) {
  final user = AuthService.currentUser;
  final role = RoleDashboardFactory.normalizeRole(user?['role']);
  final isAdmin = role == 'super admin' ||
      role == 'admin' ||
      role == 'system admin' ||
      role == 'system administrator';

  if (settings.name == '/home') {
    if (user == null) {
      return MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      );
    }
    return MaterialPageRoute<void>(
      builder: (_) => RoleDashboardFactory.build(
        Map<String, Object?>.from(user),
      ),
    );
  }

  final requiredRoles = switch (settings.name) {
    '/manage-users' || '/manage-prisons' => <String>{'__admin__'},
    '/commissioner-transfers' || '/commissioner-notifications' => {
        'commissioner',
        'prison commissioner'
      },
    '/profile' => {
        'commissioner',
        'prison commissioner',
        'records officer',
        'record officer',
        'duty officer',
        'prison officer',
        'program facilitator',
      },
    '/inmates' => {'records officer', 'record officer', 'commissioner', 'prison commissioner'},
    '/visitors' => {'records officer', 'record officer', 'commissioner', 'prison commissioner'},
    '/tracking' => {'records officer', 'record officer', 'commissioner', 'prison commissioner'},
    '/rehabilitation' => {'program facilitator', 'commissioner', 'prison commissioner'},
    '/releases' => {'duty officer', 'prison officer', 'commissioner', 'prison commissioner'},
    '/staff' => {'duty officer', 'prison officer', 'commissioner', 'prison commissioner'},
    _ => null,
  };

  if (requiredRoles == null) return null;

  if (user == null) {
    return MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(),
    );
  }

  if (!isAdmin &&
      !(requiredRoles.contains(role) ||
          (requiredRoles.contains('__admin__') && isAdmin))) {
    return MaterialPageRoute<void>(
      builder: (_) => const _AccessDeniedScreen(),
    );
  }

  return MaterialPageRoute<void>(
    builder: (_) {
      switch (settings.name) {
        case '/manage-users':
          return const ManageUsersScreen();
        case '/manage-prisons':
          return const ManagePrisonsScreen();
        case '/commissioner-transfers':
          return const CommissionerTransfersScreen(pendingOnly: true);
        case '/commissioner-notifications':
          return const CommissionerNotificationsScreen();
        case '/profile':
          return ProfileSettingsScreen(user: user);
        case '/inmates':
          return InmateListScreen(currentUserRole: role);
        case '/visitors':
          return VisitorListScreen(
            readOnly: role == 'commissioner' || role == 'prison commissioner',
          );
        case '/tracking':
          return const ApiTrackingScreen();
        case '/rehabilitation':
          return RehabilitationScreen(
            user: Map<String, Object?>.from(user),
          );
        case '/releases':
          return const ApiReleaseScreen();
        case '/staff':
          return DutyRosterScreen(
            readOnly: role == 'commissioner' || role == 'prison commissioner',
          );
        default:
          return const _AccessDeniedScreen();
      }
    },
  );
}

class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access restricted')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Your account does not have access to this section.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
