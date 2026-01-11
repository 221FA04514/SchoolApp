import 'package:flutter/material.dart';
import '../../core/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../admin/manage_teachers.dart';
import '../admin/manage_students.dart';
import '../admin/manage_timetable.dart';
import '../admin/manage_sections.dart';
import '../admin/manage_period_settings.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Management",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  "Teachers",
                  Icons.person,
                  Colors.blue,
                  const ManageTeachersScreen(),
                ),
                _buildStatCard(
                  context,
                  "Students",
                  Icons.school,
                  Colors.green,
                  const ManageStudentsScreen(),
                ),
                _buildStatCard(
                  context,
                  "Timetable",
                  Icons.calendar_today,
                  Colors.purple,
                  const ManageTimetableScreen(),
                ),
                _buildStatCard(
                  context,
                  "Sections",
                  Icons.class_,
                  Colors.orange,
                  const ManageSectionsScreen(),
                ),
                _buildStatCard(
                  context,
                  "Time Mgmt",
                  Icons.access_time,
                  Colors.pink,
                  const ManagePeriodSettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget target,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => target));
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
