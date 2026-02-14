import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../auth/login_selection_screen.dart';
import '../../models/student_dashboard_model.dart';

class StudentProfileScreen extends StatelessWidget {
  final StudentDashboardModel? studentData;

  const StudentProfileScreen({super.key, this.studentData});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no data is passed (e.g. initial load), show placeholders or loading state
    // In a real app, you might want to fetch profile specifically or use a state management store.
    // For now, we assume data is passed from Dashboard or we use safe defaults.
    final name = studentData?.name ?? "Test Student";
    // Assuming we can derive class/section from data or it's static for now as per model
    final className = "Class 10-A";
    final rollNumber = "01";
    final section = "10 - A";
    final term = "2023-24";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Image
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A00E0).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF4A00E0),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            // Name & Role
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Student • $className",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Details Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ProfileCard(
                    icon: Icons.badge_outlined,
                    label: "Roll Number",
                    value: rollNumber,
                  ),
                  const SizedBox(height: 15),
                  const Divider(height: 1),
                  const SizedBox(height: 15),
                  _ProfileCard(
                    icon: Icons.class_outlined,
                    label: "Section",
                    value: section,
                  ),
                  const SizedBox(height: 15),
                  const Divider(height: 1),
                  const SizedBox(height: 15),
                  _ProfileCard(
                    icon: Icons.school_outlined,
                    label: "Current Term",
                    value: term,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEB),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Logout Session",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4A00E0)),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
