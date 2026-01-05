import 'package:flutter/material.dart';
import '../../core/api/teacher_dashboard_service.dart';
import '../../models/teacher_dashboard_model.dart';
import '../messages/teacher_student_list_screen.dart';
import '../attendance/teacher_attendance_screen.dart';

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

  @override
  void initState() {
    super.initState();
    dashboardFuture =
        TeacherDashboardService().fetchTeacherDashboard();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOut),
    );

    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: FutureBuilder<TeacherDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return Column(
            children: [
              // ================= HEADER =================
              FadeTransition(
                opacity: _fade,
                child: Container(
                  height: size.height * 0.26,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A4DFF),
                        Color(0xFF3A6BFF),
                        Color(0xFF6A11CB),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white,
                          child: Text("👨‍🏫", style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome back 👋",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "📘 ${data.subject}",
                              style:
                                  const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= BODY =================
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // ================= STATS =================
                          Row(
                            children: [
                              _StatCard(
                                title: "Students",
                                value:
                                    data.totalStudents.toString(),
                                emoji: "👨‍🎓",
                                gradient: const [
                                  Color(0xFF43CEA2),
                                  Color(0xFF185A9D),
                                ],
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                title: "Pending Doubts",
                                value:
                                    data.pendingDoubts.toString(),
                                emoji: "❓",
                                gradient: const [
                                  Color(0xFFFF5F6D),
                                  Color(0xFFFFC371),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 26),

                          // ================= ROW 1 (3 ITEMS) =================
                          Row(
                            children: [
                              _ActionTile(
                                emoji: "👨‍🎓",
                                title: "Student\nDoubts",
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
                              const SizedBox(width: 10),
                              _ActionTile(
                                emoji: "📝",
                                title: "Mark\nAttendance",
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
                              const SizedBox(width: 10),
                              _ActionTile(
                                emoji: "📊",
                                title: "Results",
                                onTap: () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Results module coming soon"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ================= ROW 2 (2 ITEMS) =================
                          Row(
                            children: [
                              _WideActionTile(
                                emoji: "📢",
                                title: "Announcements",
                                onTap: () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Announcements coming soon"),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              _WideActionTile(
                                emoji: "💰",
                                title: "Fees Overview",
                                onTap: () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Fees overview coming soon"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ================= MOTIVATION =================
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient:
                                  const LinearGradient(colors: [
                                Color(0xFF6A11CB),
                                Color(0xFF2575FC),
                              ]),
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                            child: const Text(
                              "🌟 Teaching shapes the future.\nKeep inspiring minds every day 💙",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
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

// ================= SMALL ACTION TILE =================
class _ActionTile extends StatelessWidget {
  final String emoji;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.emoji,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= WIDE ACTION TILE =================
class _WideActionTile extends StatelessWidget {
  final String emoji;
  final String title;
  final VoidCallback onTap;

  const _WideActionTile({
    required this.emoji,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A4DFF), Color(0xFF3A6BFF)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= STAT CARD =================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String emoji;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.emoji,
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
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
