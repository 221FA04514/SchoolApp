import 'package:flutter/material.dart';
import '../../core/auth/auth_provider.dart';
import '../dashboard/teacher_dashboard.dart';
import 'package:provider/provider.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _imageScale;
  late Animation<double> _imageFade;
  late Animation<Offset> _headerSlide;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _imageScale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _imageFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      final res = await context.read<AuthProvider>().login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      setState(() => _isLoading = false);
      if (res != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            /// 🔵 WAVE HEADER
            SlideTransition(
              position: _headerSlide,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.36,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: const Color(0xFF4A00E0),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 12),
                        Text(
                          'Teacher Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Access your teacher account',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// 🖼 CENTER ILLUSTRATION
            Positioned(
              top: size.height * 0.24,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _imageFade,
                child: ScaleTransition(
                  scale: _imageScale,
                  child: Image.asset(
                    'assets/images/class.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            /// ⚪ LOGIN CARD
            Container(
              margin: EdgeInsets.only(
                top: size.height * 0.48,
                left: 16,
                right: 16,
                bottom: 24,
              ),
              child: SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _fade,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 25,
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.record_voice_over,
                          size: 50,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 20),
                        _InputField(
                          controller: emailController,
                          hint: 'Employee Email',
                          icon: Icons.badge,
                        ),
                        const SizedBox(height: 18),
                        _InputField(
                          controller: passwordController,
                          hint: 'Password',
                          icon: Icons.lock,
                          obscure: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Login Now  →',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF2F4F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
