import 'package:material_ui/material_ui.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailUsernameController =
      TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color deepGreen = Color(0xFF344B3B);
  static const Color maroonButton = Color(0xFF7A2032);
  static const String fontFamily = 'Roboto';

  @override
  void dispose() {
    _emailUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO:
      // Connect this section to your Spring Boot authentication API.
      //
      // Send:
      // 1. email or username
      // 2. password
      //
      // The backend should return:
      // 1. authenticated user details
      // 2. user role
      // 3. access token
      //
      // Example:
      //
      // final authenticatedUser = await AuthApiService.login(
      //   usernameOrEmail: _emailUsernameController.text.trim(),
      //   password: _passwordController.text,
      // );
      //
      // _openDashboard(authenticatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Authentication API has not been connected yet.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleResetPassword() {
    Navigator.pushNamed(context, '/forgot-password');
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
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  width: double.infinity,
                  color: deepGreen,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: size.height * 0.04,
                  ),
                  child: Column(
                    children: [
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
                              color: deepGreen,
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  'assets/images/loggg.jpg',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.security,
                                    size: 40,
                                    color: Colors.white,
                                  ),
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
                          fontFamily: fontFamily,
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue to the\n'
                        'Prison Management System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: fontFamily,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Email / Username field
                      TextFormField(
                        controller: _emailUsernameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        cursorColor: deepGreen,
                        style: const TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Email / Username',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontFamily: fontFamily,
                            fontSize: 14,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: deepGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email or username';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        cursorColor: deepGreen,
                        style: const TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontFamily: fontFamily,
                            fontSize: 14,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: deepGreen,
                              width: 2,
                            ),
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

                          return null;
                        },
                        onFieldSubmitted: (_) => _handleSignIn(),
                      ),

                      SizedBox(height: size.height * 0.05),

                      // Sign In and Reset Password buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: maroonButton,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      maroonButton.withValues(
                                    alpha: 0.6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontFamily: fontFamily,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed:
                                    _isLoading ? null : _handleResetPassword,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: deepGreen,
                                  side: const BorderSide(
                                    color: deepGreen,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Reset Password',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

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
  bool shouldReclip(
    covariant CustomClipper<Path> oldClipper,
  ) =>
      false;
}
