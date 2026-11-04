import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme.dart';
import '../widgets/auth_header.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true, _remember = false, _busy = false;

  final _light = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );

  @override
  void initState() {
    super.initState();
    final saved = DatabaseHelper.instance.rememberedUser;
    if (saved != null) {
      _user.text = saved;
      _remember = true;
    }
  }

  Future<void> _signIn() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);

    final user = await DatabaseHelper.instance.login(_user.text, _pass.text);

    await DatabaseHelper.instance
        .setRememberedUser(_remember ? _user.text.trim() : null);

    if (!mounted) return;
    setState(() => _busy = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          const AuthHeader(
            title: 'Welcome back',
            subtitle: 'Sign in to continue to the\nPrison Management System',
            serifSubtitle: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _form,
              child: Column(children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _user,
                  decoration: InputDecoration(
                    hintText: 'username',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: _light,
                    enabledBorder: _light,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter username' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _pass,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    hintText: 'password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: _light,
                    enabledBorder: _light,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _hide ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter password' : null,
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v ?? false),
                  ),
                  const Text('Remember me'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: const Text('Forgot password?',
                        style: TextStyle(color: Colors.black87)),
                  ),
                ]),
                const SizedBox(height: 8),
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _signIn,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('sign in',
                            style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('Sign up',
                        style: TextStyle(color: kGreen, fontSize: 16)),
                  ),
                ]),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
