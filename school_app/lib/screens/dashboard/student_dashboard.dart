import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';

import '../../core/api/dashboard_service.dart';
import '../../models/student_dashboard_model.dart';

// Screens
import '../attendance/attendance_screen.dart';
import '../fees/fees_screen.dart';
import '../results/results_screen.dart';
import '../messages/teacher_list_screen.dart';
import '../announcements/student_announcements_screen.dart';
import '../homework/student_homework_screen.dart';
import '../timetable/student_timetable_screen.dart';
import '../auth/login_selection_screen.dart';
import '../ai/ai_hub_screen.dart';
import '../resources/resource_library_screen.dart';
import '../quizzes/quiz_list_screen.dart';
import '../leaves/leave_management_screen.dart';
import '../../core/socket/socket_service.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late Future<StudentDashboardModel> dashboardFuture;
  bool minimized = false;

  @override
  void initState() {
    super.initState();
    dashboardFuture = DashboardService().fetchStudentDashboard();

    /// Auto-minimize header after load
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => minimized = true);
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (route) => false,
    );
  }

  void _showProfileDialog(StudentDashboardModel data) {
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
              child: Icon(Icons.school_rounded, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              data.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Class ${data.className}-${data.section}",
              style: const TextStyle(color: Colors.grey),
            ),
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double expandedHeight = size.height * 0.40;
    final double minimizedHeight = size.height * 0.20;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: FutureBuilder<StudentDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// ===== STATS =====
                      Row(
                        children: [
                          _StatCard(
                            title: "Attendance",
                            value: "${data.attendancePercentage}%",
                            gradient: const [
                              Color(0xFF43CEA2),
                              Color(0xFF185A9D),
                            ],
                            icon: Icons.event_available,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            title: "Fees Due",
                            value: "₹${data.feesDue}",
                            gradient: const [
                              Color(0xFFFF5F6D),
                              Color(0xFFFFC371),
                            ],
                            icon: Icons.account_balance_wallet,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          _MenuTile(
                            icon: Icons.calendar_today,
                            label: "Attnd",
                            onTap: () => _go(context, const AttendanceScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.schedule,
                            label: "TimeT",
                            onTap: () =>
                                _go(context, const StudentTimetableScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.book,
                            label: "HW",
                            onTap: () =>
                                _go(context, const StudentHomeworkScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.currency_rupee,
                            label: "Fees",
                            onTap: () => _go(context, const FeesScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.assignment,
                            label: "Results",
                            onTap: () => _go(context, const ResultsScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.campaign,
                            label: "Announce",
                            onTap: () => _go(
                              context,
                              const StudentAnnouncementsScreen(),
                            ),
                          ),
                          _MenuTile(
                            icon: Icons.library_books,
                            label: "Library",
                            onTap: () =>
                                _go(context, const ResourceLibraryScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.quiz,
                            label: "Quizzes",
                            onTap: () => _go(context, const QuizListScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.sick,
                            label: "Leaves",
                            onTap: () =>
                                _go(context, const LeaveManagementScreen()),
                          ),
                          _MenuTile(
                            icon: Icons.chat,
                            label: "Chat",
                            onTap: () =>
                                _go(context, const TeacherListScreen()),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// ===== SMART AI HUB CARD =====
                      InkWell(
                        onTap: () => _go(context, const AiHubScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: Color(0xFF6A11CB),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Smart AI Learning Hub",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Homework Help • Doubt Solver • Planner",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// ===== MOTIVATION CARD =====
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          "🚀 Believe in yourself!\nEvery day is a chance to learn & grow 📚✨",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
                      children: [
                        AnimatedScale(
                          scale: minimized ? 0.85 : 1.2,
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutBack,
                          child: GestureDetector(
                            onTap: () => _showProfileDialog(data),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: minimized ? 26 : 44,
                                  backgroundColor: Colors.white,
                                  child: const Icon(
                                    Icons.school_rounded,
                                    size: 38,
                                    color: Color(0xFF1A4DFF),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.logout,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedOpacity(
                              opacity: minimized ? 0 : 1,
                              duration: const Duration(milliseconds: 300),
                              child: const Text(
                                "Welcome 👋",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            Text(
                              data.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Class ${data.className}-${data.section}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Consumer<SocketService>(
                          builder: (context, socket, child) => Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_none,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // Show notification notification history
                                },
                              ),
                              if (socket.isConnected)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
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

  void _go(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ================= STAT CARD =================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final List<Color> gradient;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= MENU TILE =================
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1A4DFF),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
