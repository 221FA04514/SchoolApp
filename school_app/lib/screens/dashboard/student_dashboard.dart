import 'package:flutter/material.dart';
import '../../core/api/dashboard_service.dart';
import '../../models/student_dashboard_model.dart';

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

  late AnimationController _headerController;
  late AnimationController _tileController;

  late Animation<double> _fade;
  late Animation<double> _avatarScale;

  @override
  void initState() {
    super.initState();

    dashboardFuture = DashboardService().fetchStudentDashboard();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _tileController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _avatarScale = Tween<double>(begin: 1, end: 0.85).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeInOut,
      ),
    );

    _headerController.forward();

    // 🔽 AUTO SHRINK HEADER TO 20%
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => isCollapsed = true);
    });

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _tileController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _tileController.dispose();
    super.dispose();
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
              // ================= SHRINKABLE HEADER =================
              AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                height:
                    isCollapsed ? size.height * 0.20 : size.height * 0.36,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A4DFF), Color(0xFF3A6BFF)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _avatarScale,
                        child: const CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.school_rounded,
                            size: 40,
                            color: Color(0xFF1A4DFF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FadeTransition(
                        opacity: _fade,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome 👋",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                              "Class ${data.className}-${data.section} | Roll ${data.roll}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= BODY =================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// 📊 STATS
                      Row(
                        children: [
                          _StatCard(
                            title: "Attendance",
                            value: "${data.attendancePercentage}%",
                            icon: Icons.event_available_rounded,
                            gradient: const [
                              Color(0xFF43CEA2),
                              Color(0xFF185A9D),
                            ],
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            title: "Fees Due",
                            value: "₹${data.feesDue}",
                            icon: Icons.account_balance_wallet_rounded,
                            gradient: const [
                              Color(0xFFFF5F6D),
                              Color(0xFFFFC371),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      /// 🧩 MENU
                      AnimatedBuilder(
                        animation: _tileController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _tileController.value,
                            child: Transform.translate(
                              offset: Offset(
                                  0, 40 * (1 - _tileController.value)),
                              child: child,
                            ),
                          );
                        },
                        child: GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _MenuTile(
                              icon: Icons.event_available_rounded,
                              label: "Attendance",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AttendanceScreen(),
                                ),
                              ),
                            ),
                            _MenuTile(
                              icon: Icons.account_balance_wallet_rounded,
                              label: "Fees",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FeesScreen(),
                                ),
                              ),
                            ),
                            _MenuTile(
                              icon: Icons.assignment_rounded,
                              label: "Results",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ResultsScreen(),
                                ),
                              ),
                            ),
                            _MenuTile(
                              icon: Icons.chat_rounded,
                              label: "Ask Doubt",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TeacherListScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// 📢 ANNOUNCEMENTS
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Latest Announcements",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...data.announcements.map(
                        (a) => _AnnouncementCard(
                          title: a["title"],
                          description: a["description"],
                        ),
                      ),
                    ],
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

/// ================= STAT CARD =================
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
            Text(title, style: const TextStyle(color: Colors.white70)),
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

/// ================= MENU TILE =================
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
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF1A4DFF)),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// ================= ANNOUNCEMENT CARD =================
class _AnnouncementCard extends StatelessWidget {
  final String title;
  final String description;

  const _AnnouncementCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded,
              color: Color(0xFF1A4DFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
