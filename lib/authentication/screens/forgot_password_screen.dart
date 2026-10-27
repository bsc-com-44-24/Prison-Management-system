import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _id = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  Future<void> _reset() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);

    final ok = await DatabaseHelper.instance
        .resetPassword(_email.text, _id.text, _pass.text);

    if (!mounted) return;
    setState(() => _busy = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Password updated. Please sign in.'
          : 'Email and ID number do not match any account'),
    ));
    if (ok) Navigator.pop(context);
  }

  String? _req(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? 'Enter $label' : null;

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
          validator: validator ?? (v) => _req(v, label.toLowerCase()),
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
            title: 'Reset password',
            subtitle: 'Confirm your identity, then choose\na new password',
            logoSize: 70,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _form,
              child: Column(children: [
                _field('Email', _email, type: TextInputType.emailAddress),
                _field('ID Number', _id),
                _field(
                  'New password',
                  _pass,
                  obscure: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'At least 6 characters'
                      : null,
                ),
                _field(
                  'Confirm new password',
                  _confirm,
                  obscure: true,
                  validator: (v) =>
                      v != _pass.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _reset,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Reset password',
                            style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to sign in',
                      style: TextStyle(color: kGreen, fontSize: 16)),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
