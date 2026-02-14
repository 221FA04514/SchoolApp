import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For context.read
import 'dart:ui'; // For ImageFilter
import '../../core/auth/auth_provider.dart';
import '../auth/login_selection_screen.dart'; // For Logout navigation
import '../../core/api/dashboard_service.dart';
import '../../models/student_dashboard_model.dart';
import '../alerts/student_alerts_screen.dart';
import '../profile/student_profile_screen.dart';

// Screens for Grid
import '../attendance/attendance_screen.dart';
import '../fees/fees_screen.dart';
import '../results/results_screen.dart';
import '../homework/student_homework_screen.dart';
import '../timetable/student_timetable_screen.dart';
import '../ai/ai_hub_screen.dart';
import '../resources/resource_library_screen.dart';

import '../leaves/leave_management_screen.dart';
import '../ai/student_online_exam_list.dart';
<<<<<<< HEAD
import '../../core/socket/socket_service.dart';
import '../notifications/notification_inbox_screen.dart';
import '../../core/api/api_service.dart';
=======
import '../announcements/student_announcements_screen.dart';
import '../messages/teacher_list_screen.dart';
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late Future<StudentDashboardModel> dashboardFuture;
<<<<<<< HEAD
  bool minimized = false;
  int unreadNotifications = 0;
=======
  int _selectedIndex = 0;
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)

  @override
  void initState() {
    super.initState();
    dashboardFuture = DashboardService().fetchStudentDashboard();
<<<<<<< HEAD
    _fetchUnreadCount();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => minimized = true);
    });
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
    } catch (e) {}
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (route) => false,
    );
  }

  void _showProfileDialog(StudentDashboardModel data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1A4DFF),
              child: Icon(Icons.school_rounded, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              data.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Class ${data.className}-${data.section}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }

=======
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: FutureBuilder<StudentDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _getCurrentPage(
              StudentDashboardModel(
                name: "Student",
                className: "N/A",
                section: "N/A",
                roll: "N/A",
                attendancePercentage: 0,
                feesDue: 0,
                announcements: [],
              ),
            );
          }

          final data = snapshot.hasData
              ? snapshot.data!
              : StudentDashboardModel(
                  name: "Student",
                  className: "N/A",
                  section: "N/A",
                  roll: "N/A",
                  attendancePercentage: 0,
                  feesDue: 0,
                  announcements: [],
                );

          return _getCurrentPage(data);
        },
      ),
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
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Alerts",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentPage(StudentDashboardModel data) {
    switch (_selectedIndex) {
      case 0:
        return _HomeView(data: data, parentContext: context);
      case 1:
        return const StudentAlertsScreen();
      case 2:
        return StudentProfileScreen(studentData: data);
      default:
        return _HomeView(data: data, parentContext: context);
    }
  }
}

class _HomeView extends StatelessWidget {
  final StudentDashboardModel data;
  final BuildContext parentContext;

  const _HomeView({required this.data, required this.parentContext});

  Future<void> _logout() async {
    await parentContext.read<AuthProvider>().logout();
    if (!parentContext.mounted) return;
    Navigator.pushAndRemoveUntil(
      parentContext,
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (route) => false,
    );
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.push(parentContext, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          // Background Color for Header
          Container(
            height: 280, // Height of the purple background
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
                // Header Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
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
                          const Text(
                            "STUDENT",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _logout,
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Stats Card
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              icon: Icons.check_circle,
                              label: "Attendance (Month)",
                              value: "${data.attendancePercentage}%",
                              color: const Color(0xFF4A00E0),
                            ),
                            _VerticalDivider(),
                            _StatItem(
                              icon: Icons.assignment_turned_in,
                              label: "Recent Result",
                              value: data.recentResult ?? "Pending",
                              color: Colors.orange,
                            ),
                          ],
                        ),
<<<<<<< HEAD
                        const Spacer(),
                        Consumer<SocketService>(
                          builder: (context, socket, child) => Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_none,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotificationInboxScreen(),
                                    ),
                                  );
                                  _fetchUnreadCount(); // Refresh badge count after returning
                                },
                              ),
                              if (unreadNotifications > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 14,
                                      minHeight: 14,
                                    ),
                                    child: Text(
                                      unreadNotifications.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              else if (socket.isConnected)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
=======
                      ),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Grid Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "All Modules",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.1,
                        children: [
                          _DashboardCard(
                            title: "Attendance",
                            subtitle: "View",
                            icon: Icons.calendar_today_outlined,
                            color: Colors.blue.shade50,
                            iconColor: Colors.blue,
                            onTap: () => _go(context, const AttendanceScreen()),
                          ),
                          _DashboardCard(
                            title: "Doubts",
                            subtitle: "Ask Teacher",
                            icon: Icons.chat_bubble_outline,
                            color: Colors.deepPurple.shade50,
                            iconColor: Colors.deepPurple,
                            onTap: () =>
                                _go(context, const TeacherListScreen()),
                          ),
                          _DashboardCard(
                            title: "Homework",
                            subtitle: "View",
                            icon: Icons.edit_outlined,
                            color: Colors.orange.shade50,
                            iconColor: Colors.orange,
                            onTap: () =>
                                _go(context, const StudentHomeworkScreen()),
                          ),
                          _DashboardCard(
                            title: "Results",
                            subtitle: "View",
                            icon: Icons.assignment_outlined,
                            color: Colors.purple.shade50,
                            iconColor: Colors.purple,
                            onTap: () => _go(context, const ResultsScreen()),
                          ),
                          _DashboardCard(
                            title: "Fees",
                            subtitle: "Pay",
                            icon: Icons.payment,
                            color: Colors.green.shade50,
                            iconColor: Colors.green,
                            onTap: () => _go(context, const FeesScreen()),
                          ),
                          _DashboardCard(
                            title: "Time Table",
                            subtitle: "Schedule",
                            icon: Icons.schedule,
                            color: Colors.teal.shade50,
                            iconColor: Colors.teal,
                            onTap: () =>
                                _go(context, const StudentTimetableScreen()),
                          ),
                          _DashboardCard(
                            title: "AI Hub",
                            subtitle: "Ask AI",
                            icon: Icons.auto_awesome,
                            color: Colors.indigo.shade50,
                            iconColor: Colors.indigo,
                            onTap: () => _go(context, const AiHubScreen()),
                          ),
                          _DashboardCard(
                            title: "Resources",
                            subtitle: "Library",
                            icon: Icons.menu_book_rounded,
                            color: Colors.pink.shade50,
                            iconColor: Colors.pink,
                            onTap: () =>
                                _go(context, const ResourceLibraryScreen()),
                          ),

                          _DashboardCard(
                            title: "Online Exam",
                            subtitle: "Tests",
                            icon: Icons.computer,
                            color: Colors.cyan.shade50,
                            iconColor: Colors.cyan,
                            onTap: () => _go(
                              context,
                              const StudentOnlineExamListScreen(),
                            ),
                          ),
                          _DashboardCard(
                            title: "Class Notice",
                            subtitle: "Updates",
                            icon: Icons.campaign_outlined,
                            color: Colors.amber.shade50,
                            iconColor: Colors.amber.shade800,
                            onTap: () => _go(
                              context,
                              const StudentAnnouncementsScreen(),
                            ),
                          ),
                          _DashboardCard(
                            title: "Leaves",
                            subtitle: "Apply",
                            icon: Icons.time_to_leave,
                            color: Colors.red.shade50,
                            iconColor: Colors.red,
                            onTap: () =>
                                _go(context, const LeaveManagementScreen()),
                          ),
                        ],
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

  Widget _buildHeader(StudentDashboardModel data) {
    // Deprecated
    return Container();
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    super.key,
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
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
<<<<<<< HEAD
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
=======
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    var secondControlPoint = Offset(
      size.width - (size.width / 3.25),
      size.height - 80,
    );
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
