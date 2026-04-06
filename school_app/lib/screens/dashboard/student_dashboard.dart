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

import '../../core/socket/socket_service.dart';
import '../notifications/notification_inbox_screen.dart';
import '../../core/api/api_service.dart';
import '../announcements/student_announcements_screen.dart';
import '../messages/teacher_list_screen.dart';
import '../performance/student_performance_screen.dart';
import '../ai/student_online_exam_list.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late Future<StudentDashboardModel> dashboardFuture;
  bool minimized = false;
  int unreadNotifications = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshData(); // Fetch initial data

    _fetchUnreadCount();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => minimized = true);
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      dashboardFuture = DashboardService().fetchStudentDashboard();
    });
    await dashboardFuture;
    await _fetchUnreadCount();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        return _HomeView(
          data: data,
          parentContext: context,
          unreadNotifications: unreadNotifications,
          onRefreshNotifications: _fetchUnreadCount,
          onRefresh: _refreshData,
        );
      case 1:
        return const StudentAlertsScreen();
      case 2:
        return StudentProfileScreen(studentData: data);
      default:
        return _HomeView(
          data: data,
          parentContext: context,
          unreadNotifications: unreadNotifications,
          onRefreshNotifications: _fetchUnreadCount,
          onRefresh: _refreshData,
        );
    }
  }
}

class _HomeView extends StatefulWidget {
  final StudentDashboardModel data;
  final BuildContext parentContext;
  final int unreadNotifications;
  final VoidCallback onRefreshNotifications;
  final RefreshCallback onRefresh;

  const _HomeView({
    required this.data,
    required this.parentContext,
    required this.unreadNotifications,
    required this.onRefreshNotifications,
    required this.onRefresh,
  });

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  bool _showAll = false;

  Future<void> _logout() async {
    await widget.parentContext.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      widget.parentContext,
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (route) => false,
    );
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.push(
      widget.parentContext,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final unreadNotifications = widget.unreadNotifications;
    final onRefreshNotifications = widget.onRefreshNotifications;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      displacement: 60,
      color: const Color(0xFF4A00E0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatItem(
                                  icon: Icons.assignment_outlined,
                                  label: "Homework",
                                  value: "${data.pendingHomework}",
                                  color: Colors.orange,
                                ),
                              ),
                              const _VerticalDivider(),
                              Expanded(
                                child: _StatItem(
                                  icon: Icons.event_busy_outlined,
                                  label: "Leave %",
                                  value: "${data.leavePercentage}%",
                                  color: Colors.redAccent,
                                ),
                              ),
                              const _VerticalDivider(),
                              Expanded(
                                child: _StatItem(
                                  icon: Icons.check_circle_outline,
                                  label: "Attendance",
                                  value: "${data.attendancePercentage}%",
                                  color: const Color(0xFF4A00E0),
                                ),
                              ),
                            ],
                          ),
                          // Notification Icon at top right of the card
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Consumer<SocketService>(
                              builder: (context, socket, child) => Stack(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.notifications_active_outlined,
                                      color: Color(0xFF4A00E0),
                                      size: 22,
                                    ),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const NotificationInboxScreen(),
                                        ),
                                      );
                                      onRefreshNotifications();
                                    },
                                  ),
                                  if (unreadNotifications > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          unreadNotifications.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  else if (socket.isConnected)
                                    Positioned(
                                      right: 2,
                                      top: 2,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      Builder(
                        builder: (context) {
                          final List<Widget> modules = [
                            _DashboardCard(
                              title: "Attendance",
                              subtitle: "View",
                              imagePath: "assets/3d_icons/attendance.png",
                              onTap: () => _go(context, const AttendanceScreen()),
                            ),
                            _DashboardCard(
                              title: "Doubts",
                              subtitle: "Ask Teacher",
                              imagePath: "assets/3d_icons/doubts.png",
                              onTap: () => _go(context, const TeacherListScreen()),
                            ),
                            _DashboardCard(
                              title: "Homework",
                              subtitle: "View",
                              imagePath: "assets/3d_icons/homework.png",
                              onTap: () => _go(context, const StudentHomeworkScreen()),
                            ),
                            _DashboardCard(
                              title: "Results",
                              subtitle: "View",
                              imagePath: "assets/3d_icons/results.png",
                              onTap: () => _go(context, const ResultsScreen()),
                            ),
                            _DashboardCard(
                              title: "Fees",
                              subtitle: "Pay",
                              imagePath: "assets/3d_icons/fees.png",
                              onTap: () => _go(context, const FeesScreen()),
                            ),
                            _DashboardCard(
                              title: "Time Table",
                              subtitle: "Schedule",
                              imagePath: "assets/3d_icons/timetable.png",
                              onTap: () => _go(context, const StudentTimetableScreen()),
                            ),
                            _DashboardCard(
                              title: "AI Hub",
                              subtitle: "Ask AI",
                              iconData: Icons.auto_awesome_rounded,
                              onTap: () => _go(context, const AiHubScreen()),
                            ),
                            _DashboardCard(
                              title: "Resources",
                              subtitle: "Library",
                              imagePath: "assets/3d_icons/resources.png",
                              onTap: () => _go(context, const ResourceLibraryScreen()),
                            ),
                            _DashboardCard(
                              title: "Class Notice",
                              subtitle: "Updates",
                              imagePath: "assets/3d_icons/notice.png",
                              onTap: () => _go(context, const StudentAnnouncementsScreen()),
                            ),
                            _DashboardCard(
                              title: "Leaves",
                              subtitle: "Apply",
                              imagePath: "assets/3d_icons/leaves.png",
                              onTap: () => _go(context, const LeaveManagementScreen()),
                            ),
                            _DashboardCard(
                              title: "Performance",
                              subtitle: "View",
                              imagePath: "assets/3d_icons/performance.png",
                              onTap: () => _go(context, const StudentPerformanceScreen()),
                            ),
                            _DashboardCard(
                              title: "Online Exam",
                              subtitle: "Tests",
                              imagePath: "assets/3d_icons/exam.png",
                              onTap: () => _go(context, const StudentOnlineExamListScreen()),
                            ),
                          ];

                          final displayModules = _showAll ? modules : modules.take(9).toList();

                          return Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 25,
                                childAspectRatio: 0.85,
                                children: displayModules,
                              ),
                              const SizedBox(height: 20),
                              if (modules.length > 9)
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showAll = !_showAll;
                                    });
                                  },
                                  icon: Icon(
                                    _showAll ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: const Color(0xFF4A00E0),
                                  ),
                                  label: Text(
                                    _showAll ? "Show Less" : "Show More",
                                    style: const TextStyle(
                                      color: Color(0xFF4A00E0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.transparent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    backgroundColor: Colors.white,
                                    elevation: 2,
                                  ),
                                ),
                            ],
                          );
                        },
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
    ),
  );
}

  Widget _buildHeader(StudentDashboardModel data) {
    // Deprecated
    return Container();
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({super.key});

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
  final String? imagePath;
  final IconData? iconData;
  final VoidCallback onTap;

  const _DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 65,
            height: 65,
            child: iconData != null
                ? ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Icon(
                      iconData,
                      size: 50,
                      color: Colors.white,
                    ),
                  )
                : Image.asset(
                    imagePath!,
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
