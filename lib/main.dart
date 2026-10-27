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
    );
  }
}
