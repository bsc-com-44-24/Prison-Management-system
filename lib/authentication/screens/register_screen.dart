import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistering = false;

  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroonButton = Color(0xFF7A2032);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _idNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate() || _isRegistering) return;

    setState(() => _isRegistering = true);

    try {
      final Map<String, Object?> newUser = {
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'officer_id': _idNumberController.text.trim(),
        'phone': '',
      };

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(user: newUser),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: deepGreen,
        elevation: 0,
        // Standard back button returning to the previous screen (login)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Prison Management System',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        // Removed actions parameter to get rid of double arrows and dots on the top right
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipPath(
                clipper: RegisterHeaderClipper(),
                child: Container(
                  width: double.infinity,
                  color: deepGreen,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Centered Logo Container with asset check
                      Container(
                        height: 60,
                        width: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: deepGreen,
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Image.asset(
                              'assets/images/loggg.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.security,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Create account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Register to have access to the system',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      SizedBox(height: size.height * 0.05),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person_outline,
                        validatorMsg: 'Please enter your full name',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.trim().toLowerCase().endsWith(
                                '@prisons.gov.mw',
                              )) {
                            return 'Only @prisons.gov.mw emails are allowed';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _idNumberController,
                        label: 'ID Number',
                        prefixIcon: Icons.badge_outlined,
                        validatorMsg: 'Please enter your ID number',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.04),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isRegistering ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroonButton,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: maroonButton.withOpacity(
                              0.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: _isRegistering
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Create',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? validatorMsg,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: deepGreen,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: deepGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return validatorMsg ?? 'This field is required';
            }
            return null;
          },
    );
  }
}

class RegisterHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 15,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}