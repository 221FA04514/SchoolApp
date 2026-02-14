import 'package:flutter/material.dart';
import '../../core/auth/auth_provider.dart';
import '../dashboard/admin_dashboard.dart';
import 'package:provider/provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _imageScale;
  late Animation<double> _imageFade;
  late Animation<Offset> _headerSlide;

  bool _requiresOtp = false;
  int? _userId;
  bool _isLoading = false;
  bool _obscurePassword = true;

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
    otpController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      debugPrint("ADMIN LOGIN: Email=$email");
      final Map? res = await context.read<AuthProvider>().login(
        email,
        password,
      );

<<<<<<< HEAD
      if (res != null && res["requiresOtp"] == true) {
        setState(() {
          _requiresOtp = true;
          _userId = res["userId"];
          _maskedPhone = res["phone"];
          _isLoading = false;
        });
      } else if (res != null) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
            (route) => false,
          );
=======
      debugPrint("ADMIN LOGIN RES: $res");

      if (res != null) {
        debugPrint("Check RequiresOTP: ${res["requiresOtp"]}");

        if (res["requiresOtp"] == true) {
          debugPrint("OTP REQUIRED. Setting state...");

          final userId = res["userId"];

          if (userId == null) {
            throw Exception("User ID missing in response");
          }

          setState(() {
            _requiresOtp = true;
            _userId = userId;
            _isLoading = false;
            otpController.text = "00000";
          });
        } else {
          debugPrint("Direct Login. Navigating...");
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          }
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        }
      } else {
        throw Exception("Login response is null");
      }
    } catch (e) {
      debugPrint("LOGIN EXCEPTION: $e");
      setState(() => _isLoading = false);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleVerifyOtp() async {
    FocusScope.of(context).unfocus(); // ⌨️ Close keyboard first
    await Future.delayed(const Duration(milliseconds: 300)); // ⏳ Let UI settle

    final code = otpController.text.trim();
    if (_userId == null) return;
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the verification code")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().verifyOtp(_userId!, code);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _handleResendOtp() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().resendOtp(_userId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Resent Successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to resend: $e")));
      }
    } finally {
      setState(() => _isLoading = false);
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
<<<<<<< HEAD
              child: RepaintBoundary(
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    width: double.infinity,
                    height: size.height * 0.36,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A4DFF), Color(0xFF3A6BFF)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 12),
                          Text(
                            'Admin Portal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
=======
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
                          'Admin Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Authorized access only',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// 🖼 CENTER ILLUSTRATION
            Positioned(
              top: size.height * 0.22,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _imageFade,
                child: ScaleTransition(
                  scale: _imageScale,
                  child: RepaintBoundary(
                    child: Image.asset(
                      'assets/images/secure_admin_no_bg.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _requiresOtp ? _buildOtpView() : _buildLoginView(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return Container(
      key: const ValueKey("login_view"),
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
          const Icon(Icons.admin_panel_settings, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          _InputField(
            controller: emailController,
            hint: 'Email or Mobile', // Updated Hint
            icon: Icons.admin_panel_settings_outlined,
          ),
          const SizedBox(height: 18),
          _InputField(
            controller: passwordController,
            hint: 'Password',
            icon: Icons.lock,
            obscure: _obscurePassword,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Next Step  →',
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
    );
  }

  Widget _buildOtpView() {
    return Container(
      key: const ValueKey("otp_view"),
      padding: const EdgeInsets.all(24),
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
          // 🛡️ Shield Icon
          const Icon(Icons.security_rounded, size: 60, color: Colors.red),
          const SizedBox(height: 16),

          const Text(
            "Verification",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          const Text(
            "Enter Admin Security Code",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 16),
          ),
          const SizedBox(height: 30),

          // 🔢 OTP Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 12,
              ),
              decoration: const InputDecoration(
                counterText: "",
                hintText: "000000",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black26, letterSpacing: 12),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 🔴 Verify Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30), // Red color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _handleVerifyOtp,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Verify & Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
<<<<<<< HEAD
          TextButton(
            onPressed: _isLoading ? null : _handleResendOtp,
            child: const Text(
              "Resend Code",
              style: TextStyle(color: Colors.red),
            ),
=======

          const SizedBox(height: 16),

          // Resend Code Removed
          const SizedBox(height: 20),
          const Text(
            "Use default OTP: 00000",
            style: TextStyle(color: Colors.grey),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
          ),
        ],
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
