import 'package:flutter/material.dart';

import '../../core/api/dashboard_service.dart';
import '../../models/student_dashboard_model.dart';

// Screens
import '../attendance/attendance_screen.dart';
import '../fees/fees_screen.dart';
import '../results/results_screen.dart';
import '../messages/teacher_list_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with TickerProviderStateMixin {
  late Future<StudentDashboardModel> dashboardFuture;

  bool isCollapsed = false;
  bool collapsedOnce = false;

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    dashboardFuture = DashboardService().fetchStudentDashboard();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _contentFade =
        CurvedAnimation(parent: _contentController, curve: Curves.easeOut);

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void autoCollapseHeader() {
    if (!collapsedOnce) {
      setState(() {
        isCollapsed = true;
        collapsedOnce = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: FutureBuilder<StudentDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return Column(
            children: [
              // ================= PROFILE HEADER =================
              AnimatedContainer(
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeInOutCubic,
                height:
                    isCollapsed ? size.height * 0.20 : size.height * 0.40,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A4DFF), Color(0xFF3A6BFF)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      AnimatedScale(
                        scale: isCollapsed ? 0.75 : 1.15,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: isCollapsed ? 28 : 46,
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.school_rounded,
                              size: 38,
                              color: Color(0xFF1A4DFF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      /// NAME SHOULD ALWAYS BE VISIBLE
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedOpacity(
                            opacity: isCollapsed ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: const Text(
                              "Welcome back 👋",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Class ${data.className}-${data.section}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ================= DASHBOARD BODY =================
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: autoCollapseHeader,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // ================= STATS =================
                            Row(
                              children: [
                                _StatCard(
                                  title: "Attendance",
                                  value: "${data.attendancePercentage}%",
                                  icon: Icons.event_available,
                                  gradient: const [
                                    Color(0xFF43CEA2),
                                    Color(0xFF185A9D),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                _StatCard(
                                  title: "Fees Due",
                                  value: "₹${data.feesDue}",
                                  icon:
                                      Icons.account_balance_wallet_rounded,
                                  gradient: const [
                                    Color(0xFFFF5F6D),
                                    Color(0xFFFFC371),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // ================= GRID =================
                            GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: [
                                _MenuTile(
                                  icon: Icons.calendar_today,
                                  label: "Attendance",
                                  onTap: () {
                                    autoCollapseHeader();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AttendanceScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _MenuTile(
                                  icon: Icons.currency_rupee,
                                  label: "Fees",
                                  onTap: () {
                                    autoCollapseHeader();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const FeesScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _MenuTile(
                                  icon: Icons.assignment,
                                  label: "Results",
                                  onTap: () {
                                    autoCollapseHeader();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ResultsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _MenuTile(
                                  icon: Icons.chat,
                                  label: "Chat",
                                  onTap: () {
                                    autoCollapseHeader();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TeacherListScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _MenuTile(
                                  icon: Icons.support_agent,
                                  label: "Ask Doubt",
                                  onTap: () {
                                    autoCollapseHeader();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TeacherListScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ================= MOTIVATION =================
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6A11CB),
                                    Color(0xFF2575FC),
                                  ],
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================= STAT CARD =================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
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
            Text(title,
                style: const TextStyle(color: Colors.white70)),
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
