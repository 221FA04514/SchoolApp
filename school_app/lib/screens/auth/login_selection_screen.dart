import 'package:flutter/material.dart';
import 'student_login_screen.dart';
import 'teacher_login_screen.dart';
import 'admin_login_screen.dart';

class LoginSelectionScreen extends StatefulWidget {
  const LoginSelectionScreen({super.key});

  @override
  State<LoginSelectionScreen> createState() => _LoginSelectionScreenState();
}

class _LoginSelectionScreenState extends State<LoginSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _imageScale;
  late Animation<double> _imageFade;
  late Animation<Offset> _headerSlide;

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            /// 🔵 ORIGINAL BLUE WAVE HEADER
            SlideTransition(
              position: _headerSlide,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.36,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: const Color(0xFF673AB7), // Solid Violet
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 12),
                        Text(
                          'Welcome',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Select your role to continue',
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
              top: size.height * 0.16,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _imageFade,
                child: ScaleTransition(
                  scale: _imageScale,
                  child: Image.asset(
                    'assets/images/login_illustration.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            /// ⚪ CARDS CONTAINER
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
                  child: Column(
                    children: [
                      _buildRoleCard(
                        context,
                        "Student",
                        "Check results & attendance",
                        Icons.face,
                        Colors.green,
                        const StudentLoginScreen(),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        "Teacher",
                        "Manage classes & homework",
                        Icons.record_voice_over,
                        Colors.orange,
                        const TeacherLoginScreen(),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context,
                        "Administrator",
                        "Full school management",
                        Icons.admin_panel_settings,
                        const Color(0xFF673AB7), // Solid Violet
                        const AdminLoginScreen(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget target,
  ) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => target));
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
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
