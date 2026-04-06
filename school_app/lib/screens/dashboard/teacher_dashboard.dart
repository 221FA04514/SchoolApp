import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/teacher_dashboard_service.dart';
import '../../models/teacher_dashboard_model.dart';
import '../messages/teacher_student_list_screen.dart';
import '../attendance/teacher_attendance_screen.dart';
import '../announcements/teacher_announcements_screen.dart';
import '../homework/teacher_homework_screen.dart';
import '../timetable/teacher_timetable_screen.dart';
import '../auth/login_selection_screen.dart';
import '../ai/teacher_ai_portal.dart';
import './teacher_insight_detail.dart';
import '../results/teacher_results_screen.dart';
import '../notifications/notification_inbox_screen.dart';
import '../../core/api/api_service.dart';

import '../resources/teacher_resource_library_screen.dart';
import '../leaves/leave_management_screen.dart';
import '../performance/teacher_performance_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  late Future<TeacherDashboardModel> dashboardFuture;
  int _selectedIndex = 0;
  int unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    dashboardFuture = TeacherDashboardService().fetchTeacherDashboard();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final res = await ApiService().get("/api/v2/admin/notifications/my");
      final list = res["data"] as List;
      if (mounted) {
        setState(() {
          unreadNotifications = list
              .where(
                (n) =>
                    n["receipt_status"] == 'pending' ||
                    n["receipt_status"] == 'delivered',
              )
              .length;
        });
      }
    } catch (e) {
      // Slient fail
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      _fetchUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TeacherDashboardModel>(
      future: dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Error loading dashboard"),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        dashboardFuture = TeacherDashboardService()
                            .fetchTeacherDashboard();
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FB),
          body: _getCurrentPage(data),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: const Color(0xFF4A00E0),
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications),
                      if (unreadNotifications > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '$unreadNotifications',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: "Alerts",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getCurrentPage(TeacherDashboardModel data) {
    switch (_selectedIndex) {
      case 0:
        return _HomeView(data: data, parentContext: context);
      case 1:
        return const NotificationInboxScreen();
      case 2:
        return _ProfileView(data: data, parentContext: context);
      default:
        return _HomeView(data: data, parentContext: context);
    }
  }
}

class _HomeView extends StatelessWidget {
  final TeacherDashboardModel data;
  final BuildContext parentContext;

  const _HomeView({required this.data, required this.parentContext});

  void _nav(Widget screen) {
    Navigator.push(parentContext, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            height: 240,
            decoration: const BoxDecoration(
              color: Color(0xFF4A00E0),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back,",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            data.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            data.subject.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A00E0).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          icon: Icons.people,
                          label: "Students",
                          value: data.totalStudents.toString(),
                          color: const Color(0xFF4A00E0),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        _StatItem(
                          icon: Icons.help_outline,
                          label: "Pending Doubts",
                          value: data.pendingDoubts.toString(),
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildSchedule(),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Quick Actions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                        children: [
                          _DashboardCard(
                            title: "Doubts",
                            subtitle: "Resolve",
                            imagePath: "assets/3d_icons/teacher_doubts_v3.png",
                            onTap: () => _nav(const TeacherStudentListScreen()),
                          ),
                          _DashboardCard(
                            title: "Attendance",
                            subtitle: "Mark",
                            imagePath:
                                "assets/3d_icons/teacher_attendance_v3.png",
                            onTap: () => _nav(const TeacherAttendanceScreen()),
                          ),
                          _DashboardCard(
                            title: "Homework",
                            subtitle: "Assign",
                            imagePath:
                                "assets/3d_icons/teacher_homework_v3.png",
                            onTap: () => _nav(const TeacherHomeworkScreen()),
                          ),
                          _DashboardCard(
                            title: "Timetable",
                            subtitle: "Schedule",
                            imagePath: "assets/3d_icons/timetable.png",
                            onTap: () => _nav(const TeacherTimetableScreen()),
                          ),
                          _DashboardCard(
                            title: "Leaves",
                            subtitle: "Request",
                            imagePath: "assets/3d_icons/leaves.png",
                            onTap: () => _nav(const LeaveManagementScreen()),
                          ),
                          _DashboardCard(
                            title: "Results",
                            subtitle: "Published",
                            imagePath: "assets/3d_icons/results.png",
                            onTap: () => _nav(const TeacherResultsScreen()),
                          ),
                          _DashboardCard(
                            title: "Announce",
                            subtitle: "Broadcast",
                            imagePath: "assets/3d_icons/notice_v3.png",
                            onTap: () =>
                                _nav(const TeacherAnnouncementsScreen()),
                          ),
                          _DashboardCard(
                            title: "AI Asst",
                            subtitle: "Tools",
                            imagePath: "assets/3d_icons/ai_hub_v3.png",
                            onTap: () => _nav(const TeacherAiAssistantPortal()),
                          ),
                          _DashboardCard(
                            title: "Library",
                            subtitle: "Resources",
                            imagePath: "assets/3d_icons/library_v3.png",
                            onTap: () =>
                                _nav(const TeacherResourceLibraryScreen()),
                          ),
                          _DashboardCard(
                            title: "Performance",
                            subtitle: "Evaluate",
                            imagePath: "assets/3d_icons/performance.png",
                            onTap: () => _nav(const TeacherPerformanceScreen()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Smart Insights",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: Column(
                          children: [
                            _InsightRow(
                              title: "Attendance Alert",
                              subtitle: "3 students below 75%",
                              color: Colors.red,
                              icon: Icons.warning_amber_rounded,
                              onTap: () {
                                Navigator.push(
                                  parentContext,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TeacherInsightDetailScreen(
                                          type: "low_attendance",
                                          title: "Attendance Alerts",
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    if (data.todaySchedule.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Today's Schedule",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: data.todaySchedule.length,
            itemBuilder: (context, index) {
              final slot = data.todaySchedule[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A00E0), Color(0xFF6A11CB)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A00E0).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      slot["subject"] ?? "Class",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Period ${slot['period']}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          slot["start_time"] ?? "N/A",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProfileView extends StatelessWidget {
  final TeacherDashboardModel data;
  final BuildContext parentContext;

  const _ProfileView({required this.data, required this.parentContext});

  Future<void> _logout() async {
    await parentContext.read<AuthProvider>().logout();
    if (!parentContext.mounted) return;
    Navigator.pushAndRemoveUntil(
      parentContext,
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF4A00E0),
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            data.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            data.subject,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const _DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 65,
            height: 65,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _InsightRow({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
