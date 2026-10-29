import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  // Primary Theme Color (#344B3B - Deep Green)
  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroonButton = Color(0xFF7A2032); // Maroon button[cite: 1]

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signing in...'),
          backgroundColor: deepGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Deep Green background
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  width: double.infinity,
                  color: deepGreen,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: size.height * 0.04,
                  ),
                  child: Column(
                    children: [
                      // Responsive Logo Container
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double logoSize = constraints.maxWidth * 0.22;
                          if (logoSize > 90) logoSize = 90;
                          if (logoSize < 60) logoSize = 60;

                          return Container(
                            height: logoSize,
                            width: logoSize,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  'assets/logo.png', // Replace with your logo path
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.security,
                                      size: 40,
                                      color: deepGreen,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue to the\nPrison Management System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: size.height * 0.06),
                    ],
                  ),
                ),
              ),

              // Form Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Email Field with Strict @prisons.gov.mw Validation
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: deepGreen,
                        decoration: InputDecoration(
                          hintText: 'email',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: deepGreen, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          // Only allow @prisons.gov.mw emails
                          if (!value.trim().toLowerCase().endsWith('@prisons.gov.mw')) {
                            return 'Only @prisons.gov.mw emails are allowed';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        cursorColor: deepGreen,
                        decoration: InputDecoration(
                          hintText: 'password',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: deepGreen, width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: deepGreen,
                                  onChanged: (val) {
                                    setState(() {
                                      _rememberMe = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.05),

                      // Sign In Button (Maroon)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroonButton,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'sign in',
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
}

// Curved bottom Clipper for top header
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 35);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 15,
      size.width,
      size.height - 35,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}