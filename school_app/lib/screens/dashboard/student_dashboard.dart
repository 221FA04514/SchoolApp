import 'package:flutter/material.dart';

import '../../core/api/dashboard_service.dart';
import '../../models/student_dashboard_model.dart';

// Widgets
import 'dashboard_button.dart';

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

class _StudentDashboardState extends State<StudentDashboard> {
  late Future<StudentDashboardModel> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = DashboardService().fetchStudentDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: FutureBuilder<StudentDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Failed to load dashboard"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ================= HEADER =================
                Container(
                  height: size.height * 0.28,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A4DFF), Color(0xFF3A6BFF)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome 👋",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Class ${data.className}-${data.section} | Roll ${data.roll}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= BODY =================
                Padding(
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
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            title: "Fees Due",
                            value: "₹${data.feesDue}",
                            icon: Icons.payments,
                            color: Colors.red,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // ================= QUICK ACTIONS =================
                      Row(
                        children: [
                          Expanded(
                            child: DashboardButton(
                              title: "Attendance",
                              icon: Icons.calendar_today,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AttendanceScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: DashboardButton(
                              title: "Fees",
                              icon: Icons.currency_rupee,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FeesScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: DashboardButton(
                              title: "Results",
                              icon: Icons.assignment,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ResultsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      DashboardButton(
                        title: "Ask Doubt",
                        icon: Icons.chat,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TeacherListScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // ================= ANNOUNCEMENTS =================
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

                      const SizedBox(height: 10),

                      if (data.announcements.isEmpty)
                        const Text("No announcements"),

                      ...data.announcements.map(
                        (a) => Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.announcement,
                              color: Color(0xFF1A4DFF),
                            ),
                            title: Text(a["title"]),
                            subtitle: Text(a["description"]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}