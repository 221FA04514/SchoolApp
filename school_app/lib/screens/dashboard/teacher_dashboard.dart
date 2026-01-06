import 'package:flutter/material.dart';
import '../../core/api/teacher_dashboard_service.dart';
import '../../models/teacher_dashboard_model.dart';
import 'dashboard_button.dart';
import '../messages/teacher_student_list_screen.dart';
import '../attendance/teacher_attendance_screen.dart';
import '../announcements/teacher_announcements_screen.dart';
import '../homework/teacher_homework_screen.dart'; // 🔥 ADD


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

    dashboardFuture = TeacherDashboardService().fetchTeacherDashboard();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOut),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // ================= HEADER =================
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("👨‍🏫 Teacher Dashboard"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A4DFF),
                Color(0xFF3A6BFF),
                Color(0xFF6A11CB),
              ],
            ),
          ),
        ),
      ),

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

          return FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ================= TEACHER CARD =================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: Color(0xFF1A4DFF),
                            child: Text("👨‍🏫", style: TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "📘 ${data.subject}",
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

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
                        ),                      // 🔥 NEW HOMEWORK BUTTON
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
                          title: "📊 Results",
                          icon: Icons.bar_chart,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("📊 Results module coming next"),
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
                                content:
                                    Text("💰 Fees overview coming next"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12), // ✅ no bottom gap
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= STAT CARD =================
  Widget _statCard(
    String title,
    String value,
    Color bg,
    Color valueColor,
  ) {
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
