import 'package:flutter/material.dart';
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
import '../notifications/notification_inbox_screen.dart';
import '../../core/api/api_service.dart';
import '../announcements/student_announcements_screen.dart';
import '../messages/teacher_list_screen.dart';
import '../performance/student_performance_screen.dart';
import '../ai/student_online_exam_list.dart';
import 'bus_tracking_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late Future<StudentDashboardModel> dashboardFuture;
  int unreadNotifications = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _fetchUnreadCount();
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
              .where((n) =>
                  n["receipt_status"] == 'pending' ||
                  n["receipt_status"] == 'delivered')
              .length;
        });
      }
    } catch (e) {}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Soft Grayish Blue
      body: FutureBuilder<StudentDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
          }
          final data = snapshot.data ??
              StudentDashboardModel(
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
      bottomNavigationBar: _buildSafeFooter(),
    );
  }

  Widget _buildSafeFooter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF4F46E5), // Indigo
            unselectedItemColor: const Color(0xFF94A3B8),
            backgroundColor: Colors.white,
            elevation: 0,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.notification_important_rounded), label: "Alerts"),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCurrentPage(StudentDashboardModel data) {
    switch (_selectedIndex) {
      case 0:
        return _HomeView(
          data: data,
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
          unreadNotifications: unreadNotifications,
          onRefreshNotifications: _fetchUnreadCount,
          onRefresh: _refreshData,
        );
    }
  }
}

class _HomeView extends StatefulWidget {
  final StudentDashboardModel data;
  final int unreadNotifications;
  final VoidCallback onRefreshNotifications;
  final RefreshCallback onRefresh;

  const _HomeView({
    required this.data,
    required this.unreadNotifications,
    required this.onRefreshNotifications,
    required this.onRefresh,
  });

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  void _go(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: const Color(0xFF4F46E5),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          _buildHeader(data),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildFixedStats(data),
                const SizedBox(height: 30),
                const Text(
                  "Learning Modules",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 15),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _buildVerticalModules(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeader(StudentDashboardModel data) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
       automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF4F46E5),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Good Day,", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(
                          data.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _NotificationBadge(
                    unreadCount: widget.unreadNotifications,
                    onRefresh: widget.onRefreshNotifications,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedStats(StudentDashboardModel data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _FixedStatItem(
            label: "Attendance",
            value: "${data.attendancePercentage}%",
            icon: Icons.calendar_month_rounded,
            color: Colors.blue,
            onTap: () => _go(context, const AttendanceScreen()),
          ),
          _FixedStatItem(
            label: "Homework",
            value: "${data.homeworkCompletionPercentage}%",
            icon: Icons.assignment_turned_in_rounded,
            color: const Color(0xFF10B981),
            onTap: () => _go(context, const StudentHomeworkScreen()),
          ),
          _FixedStatItem(
            label: "Leave Request",
            value: data.recentLeaveStatus,
            icon: Icons.exit_to_app_rounded,
            color: Colors.orange,
            onTap: () => _go(context, const LeaveManagementScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalModules() {
    final modules = [
       _ModuleButton(title: "Attendance", icon: "assets/3d_icons/attendance.png", onTap: () => _go(context, const AttendanceScreen())),
       _ModuleButton(title: "Homework", icon: "assets/3d_icons/homework.png", onTap: () => _go(context, const StudentHomeworkScreen())),
       _ModuleButton(title: "Time Table", icon: "assets/3d_icons/timetable.png", onTap: () => _go(context, const StudentTimetableScreen())),
       _ModuleButton(title: "Notice", icon: "assets/3d_icons/notice.png", onTap: () => _go(context, const StudentAnnouncementsScreen())),
       _ModuleButton(title: "Exams", icon: "assets/3d_icons/exam.png", onTap: () => _go(context, const StudentOnlineExamListScreen())),
       _ModuleButton(title: "Results", icon: "assets/3d_icons/results.png", onTap: () => _go(context, const ResultsScreen())),
       _ModuleButton(title: "Library", icon: "assets/3d_icons/resources.png", onTap: () => _go(context, const ResourceLibraryScreen())),
       _ModuleButton(title: "Fees", icon: "assets/3d_icons/fees.png", onTap: () => _go(context, const FeesScreen())),
       _ModuleButton(title: "AI Helper", iconData: Icons.auto_awesome_rounded, onTap: () => _go(context, const AiHubScreen())),
       _ModuleButton(title: "Leaves", icon: "assets/3d_icons/leaves.png", onTap: () => _go(context, const LeaveManagementScreen())),
       _ModuleButton(title: "Tracking", iconData: Icons.directions_bus_rounded, onTap: () => _go(context, const BusTrackingScreen())),
       _ModuleButton(title: "Analytics", icon: "assets/3d_icons/performance.png", onTap: () => _go(context, const StudentPerformanceScreen())),
       _ModuleButton(title: "Messages", iconData: Icons.forum_rounded, onTap: () => _go(context, const TeacherListScreen())),
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => modules[index],
        childCount: modules.length,
      ),
    );
  }
}

class _FixedStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FixedStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ModuleButton extends StatelessWidget {
  final String title;
  final String? icon;
  final IconData? iconData;
  final VoidCallback onTap;

  const _ModuleButton({
    required this.title,
    this.icon,
    this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
               Image.asset(icon!, height: 40, width: 40)
            else
               Icon(iconData, color: const Color(0xFF4F46E5), size: 35),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onRefresh;

  const _NotificationBadge({required this.unreadCount, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationInboxScreen()));
        onRefresh();
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
