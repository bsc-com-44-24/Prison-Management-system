import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme.dart';
import '../widgets/auth_header.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _id = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? 'Enter $label' : null;

  Future<void> _create() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);

    final db = DatabaseHelper.instance;
    final err = await db.registerUser(
      fullName: _name.text,
      email: _email.text,
      phone: _phone.text,
      officerId: _id.text,
      password: _pass.text,
    );
    if (!mounted) return;

    if (err != null) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    // Account created: sign the user in and go straight to home.
    final user = await db.login(_email.text, _pass.text);
    if (!mounted) return;
    if (user == null) {
      setState(() => _busy = false);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      (route) => false,
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    bool obscure = false,
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        TextFormField(
          controller: c,
          obscureText: obscure,
          keyboardType: type,
          validator: validator ?? (v) => _required(v, label.toLowerCase()),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          const AuthHeader(
            title: 'Create account',
            subtitle: 'Register to have access to the system',
            logoSize: 70,
            logoLeft: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _form,
              child: Column(children: [
                _field('Full Name', _name),
                _field(
                  'Email',
                  _email,
                  type: TextInputType.emailAddress,
                  validator: (v) => (v != null &&
                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(v.trim()))
                      ? null
                      : 'Enter a valid email',
                ),
                _field('Phone Number', _phone, type: TextInputType.phone),
                _field('ID Number', _id),
                _field(
                  'Password',
                  _pass,
                  obscure: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'At least 6 characters'
                      : null,
                ),
                _field(
                  'Confirm password',
                  _confirm,
                  obscure: true,
                  validator: (v) =>
                      v != _pass.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _create,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Create',
                            style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('Sign in',
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