import 'package:flutter/material.dart';
import '../../core/api/teacher_dashboard_service.dart';
import '../../models/teacher_dashboard_model.dart';
import 'dashboard_button.dart';
import '../messages/teacher_student_list_screen.dart';
import '../attendance/teacher_attendance_screen.dart';
import '../announcements/teacher_announcements_screen.dart';
import '../homework/teacher_homework_screen.dart';
import '../timetable/teacher_timetable_screen.dart';
import '../auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with TickerProviderStateMixin {
  late Future<TeacherDashboardModel> dashboardFuture;

  late AnimationController _pageController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool minimized = false;

  @override
  void initState() {
    super.initState();

    dashboardFuture = TeacherDashboardService().fetchTeacherDashboard();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));

    /// Auto-minimize header after load
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => minimized = true);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showProfileDialog(TeacherDashboardModel data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1A4DFF),
              child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              data.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(data.subject, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double expandedHeight = size.height * 0.35;
    final double minimizedHeight = size.height * 0.18;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: FutureBuilder<TeacherDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data"));
          }

          final data = snapshot.data!;
          _pageController.forward();

          return Stack(
            children: [
              // ================= BODY =================
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
                top: minimized ? minimizedHeight : expandedHeight,
                left: 0,
                right: 0,
                bottom: 0,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ================= STATS =================
                          Row(
                            children: [
                              _statCard(
                                "👨‍🎓 Students",
                                data.totalStudents.toString(),
                                const Color(0xFFE3F2FD),
                                Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              _statCard(
                                "❓ Pending Doubts",
                                data.pendingDoubts.toString(),
                                const Color(0xFFFFF3E0),
                                Colors.orange,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ================= ACTION GRID =================
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1,
                                ),
                            children: [
                              DashboardButton(
                                title: "💬 Doubts",
                                icon: Icons.chat_bubble_outline,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherStudentListScreen(),
                                    ),
                                  );
                                },
                              ),
                              DashboardButton(
                                title: "📋 Attendance",
                                icon: Icons.event_available,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherAttendanceScreen(),
                                    ),
                                  );
                                },
                              ),
                              DashboardButton(
                                title: "📚 Homework",
                                icon: Icons.menu_book,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TeacherHomeworkScreen(),
                                  ),
                                ),
                              ),
                              DashboardButton(
                                title: "🗓 Timetable",
                                icon: Icons.schedule,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherTimetableScreen(),
                                    ),
                                  );
                                },
                              ),

                              DashboardButton(
                                title: "📊 Results",
                                icon: Icons.bar_chart,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "📊 Results module coming next",
                                      ),
                                    ),
                                  );
                                },
                              ),
                              DashboardButton(
                                title: "📢 Announce",
                                icon: Icons.campaign,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherAnnouncementsScreen(),
                                    ),
                                  );
                                },
                              ),
                              DashboardButton(
                                title: "💰 Fees",
                                icon: Icons.account_balance_wallet,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "💰 Fees overview coming next",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ================= MOTIVATION CARD =================
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Text(
                              "🌟 Shaping minds, building futures.\nKeep inspiring! 🍎✨",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ================= HEADER =================
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
                top: 0,
                left: 0,
                right: 0,
                height: minimized ? minimizedHeight : expandedHeight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A4DFF),
                        Color(0xFF3A6BFF),
                        Color(0xFF6A11CB),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // PROFILE PIC
                        AnimatedScale(
                          scale: minimized ? 0.85 : 1.2,
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutBack,
                          child: GestureDetector(
                            onTap: () => _showProfileDialog(data),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: Color(0xFF1A4DFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        /// NAME & SUBJECT
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Collapsible "Welcome Back"
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: minimized ? 0 : 20,
                                  curve: Curves.easeInOut,
                                  child: AnimatedOpacity(
                                    opacity: minimized ? 0 : 1,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Text(
                                      "Welcome Back 👋",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ),
                                SizedBox(height: minimized ? 0 : 4),

                                Text(
                                  data.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Subject: ${data.subject}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= STAT CARD =================
  Widget _statCard(String title, String value, Color bg, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
