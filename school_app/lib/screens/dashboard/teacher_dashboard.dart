import 'package:flutter/material.dart';
import '../../core/api/teacher_dashboard_service.dart';
import '../../models/teacher_dashboard_model.dart';
import 'dashboard_button.dart';
import '../messages/teacher_student_list_screen.dart';
import '../attendance/teacher_attendance_screen.dart';


class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  late Future<TeacherDashboardModel> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = TeacherDashboardService().fetchTeacherDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        centerTitle: true,
      ),
      body: FutureBuilder<TeacherDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("TEACHER DASHBOARD ERROR: ${snapshot.error}");
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView( // ✅ FIX OVERFLOW
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // 👤 Teacher Info
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(data.subject),
                  ),
                ),

                const SizedBox(height: 20),

                // 📊 Stats
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: const Text("Students"),
                          trailing: Text(
                            data.totalStudents.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: const Text("Pending Doubts"),
                          trailing: Text(
                            data.pendingDoubts.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // 🔘 Action Buttons

                DashboardButton(
                  title: "Student Doubts",
                  icon: Icons.chat,
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
                  title: "Mark Attendance",
                  icon: Icons.chat,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TeacherAttendanceScreen(),
                      ),
                    );
                  },
                ),
                DashboardButton(
                  title: "Results",
                  icon: Icons.assignment,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Results module coming next"),
                      ),
                    );
                  },
                ),

                DashboardButton(
                  title: "Announcements",
                  icon: Icons.announcement,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Announcements module coming next"),
                      ),
                    );
                  },
                ),

                DashboardButton(
                  title: "Fees Overview",
                  icon: Icons.payments,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Fees overview coming next"),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20), // extra bottom space
              ],
            ),
          );
        },
      ),
    );
  }
}
