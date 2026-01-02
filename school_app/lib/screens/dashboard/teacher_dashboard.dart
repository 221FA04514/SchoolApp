import 'package:flutter/material.dart';
import '../../core/api/teacher_dashboard_service.dart';
import '../../models/teacher_dashboard_model.dart';
import 'dashboard_button.dart';

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

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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

                // 🔘 Action Buttons (Navigation comes later)
                DashboardButton(
                  title: "Student Doubts",
                  icon: Icons.chat,
                  onTap: () {},
                ),
                DashboardButton(
                  title: "Attendance",
                  icon: Icons.calendar_today,
                  onTap: () {},
                ),
                DashboardButton(
                  title: "Results",
                  icon: Icons.assignment,
                  onTap: () {},
                ),
                DashboardButton(
                  title: "Announcements",
                  icon: Icons.announcement,
                  onTap: () {},
                ),
                DashboardButton(
                  title: "Fees Overview",
                  icon: Icons.payments,
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
