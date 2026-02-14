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
<<<<<<< HEAD
import '../notifications/notification_inbox_screen.dart';
import '../../core/api/api_service.dart';
import '../../core/socket/socket_service.dart';
import '../resources/teacher_resource_library_screen.dart';
import '../leaves/leave_management_screen.dart';
=======
import '../alerts/student_alerts_screen.dart';
import '../leaves/teacher_leaves_screen.dart';
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  late Future<TeacherDashboardModel> dashboardFuture;
<<<<<<< HEAD

  late AnimationController _pageController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool minimized = false;
  int unreadNotifications = 0;
=======
  int _selectedIndex = 0;
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)

  @override
  void initState() {
    super.initState();
    dashboardFuture = TeacherDashboardService().fetchTeacherDashboard();
<<<<<<< HEAD
    _fetchUnreadCount();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));

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

  void _showProfileDialog(TeacherDashboardModel data) {
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
              child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              data.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(data.subject, style: const TextStyle(color: Colors.grey)),
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      body: FutureBuilder<TeacherDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error loading dashboard"));
          }

          final data = snapshot.data!;
<<<<<<< HEAD
          _pageController.forward();

          return Stack(
            children: [
              // ================= BODY =================
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
                top: minimized ? minimizedHeight : expandedHeight,
                left: 0,
                right: 0,
                bottom: 0,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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

                          // ================= SMART INSIGHTS =================
                          const Text(
                            "🎯 Smart Insights",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _insightRow(
                                  "Attendance Alert",
                                  "3 students below 75%",
                                  Colors.red,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TeacherInsightDetailScreen(
                                              type: "low_attendance",
                                              title: "Attendance Alerts",
                                            ),
                                      ),
                                    );
                                  },
                                  icon: Icons.warning_amber_rounded,
                                ),
                                const Divider(height: 24),
                                _insightRow(
                                  "Grading Queue",
                                  "5 homework pending",
                                  Colors.orange,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TeacherInsightDetailScreen(
                                              type: "ungraded_homework",
                                              title: "Grading Queue",
                                            ),
                                      ),
                                    );
                                  },
                                  icon: Icons.assignment_rounded,
                                ),
                              ],
                            ),
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
                              ),
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
                                title: "🗓 Timetable",
                                icon: Icons.schedule,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherTimetableScreen(),
                                    ),
                                  );
                                },
                              ),

                              DashboardButton(
                                title: "📊 Results",
                                icon: Icons.bar_chart,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherResultsScreen(),
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
                                title: "🤖 AI Assistant",
                                icon: Icons.auto_awesome,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherAiAssistantPortal(),
                                    ),
                                  );
                                },
                              ),
                              DashboardButton(
                                title: "📏 Monitor",
                                icon: Icons.fact_check_outlined,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherResultsScreen(),
                                    ),
                                  );
                                },
                              ),
                              DashboardButton(
                                title: "📖 Library",
                                icon: Icons.library_books,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherResourceLibraryScreen(),
                                    ),
                                  );
                                },
                              ),
                              DashboardButton(
                                title: "🤒 Leaves",
                                icon: Icons.sick_outlined,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const LeaveManagementScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ================= MOTIVATION CARD =================
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Text(
                              "🌟 Shaping minds, building futures.\nKeep inspiring! 🍎✨",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ================= HEADER =================
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
                top: 0,
                left: 0,
                right: 0,
                height: minimized ? minimizedHeight : expandedHeight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1A4DFF),
                        Color(0xFF3A6BFF),
                        Color(0xFF6A11CB),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // PROFILE PIC
                        AnimatedScale(
                          scale: minimized ? 0.85 : 1.2,
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutBack,
                          child: GestureDetector(
                            onTap: () => _showProfileDialog(data),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    radius: 36,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 40,
                                      color: Color(0xFF1A4DFF),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.logout,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                  _fetchUnreadCount();
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
                    ),
                  ),
                ),
              ),
            ],
          );
=======
          return _getCurrentPage(data);
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
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

  Widget _getCurrentPage(TeacherDashboardModel data) {
    switch (_selectedIndex) {
      case 0:
        return _HomeView(data: data, parentContext: context);
      case 1:
        return const StudentAlertsScreen();
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
          // Background Color for Header
          Container(
            height: 280,
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

                // Grid Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Quick Actions",
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
                            title: "Doubts",
                            subtitle: "Resolve",
                            icon: Icons.chat_bubble_outline,
                            color: Colors.blue.shade50,
                            iconColor: Colors.blue,
                            onTap: () => _nav(const TeacherStudentListScreen()),
                          ),
                          _DashboardCard(
                            title: "Attendance",
                            subtitle: "Mark",
                            icon: Icons.event_available,
                            color: Colors.green.shade50,
                            iconColor: Colors.green,
                            onTap: () => _nav(const TeacherAttendanceScreen()),
                          ),
                          _DashboardCard(
                            title: "Homework",
                            subtitle: "Assign",
                            icon: Icons.menu_book,
                            color: Colors.orange.shade50,
                            iconColor: Colors.orange,
                            onTap: () => _nav(const TeacherHomeworkScreen()),
                          ),
                          _DashboardCard(
                            title: "Timetable",
                            subtitle: "Schedule",
                            icon: Icons.schedule,
                            color: Colors.purple.shade50,
                            iconColor: Colors.purple,
                            onTap: () => _nav(const TeacherTimetableScreen()),
                          ),
                          _DashboardCard(
                            title: "Leaves",
                            subtitle: "Request",
                            icon: Icons.holiday_village,
                            color: Colors.red.shade50,
                            iconColor: Colors.red,
                            onTap: () => _nav(const TeacherLeavesScreen()),
                          ),
                          _DashboardCard(
                            title: "Results",
                            subtitle: "Published",
                            icon: Icons.bar_chart,
                            color: Colors.teal.shade50,
                            iconColor: Colors.teal,
                            onTap: () => _nav(const TeacherResultsScreen()),
                          ),
                          _DashboardCard(
                            title: "Announce",
                            subtitle: "Broadcast",
                            icon: Icons.campaign,
                            color: Colors.amber.shade50,
                            iconColor: Colors.amber,
                            onTap: () =>
                                _nav(const TeacherAnnouncementsScreen()),
                          ),
                          _DashboardCard(
                            title: "AI Asst",
                            subtitle: "Tools",
                            icon: Icons.auto_awesome,
                            color: Colors.indigo.shade50,
                            iconColor: Colors.indigo,
                            onTap: () => _nav(const TeacherAiAssistantPortal()),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Smart Insights Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Smart Insights",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                            const Divider(height: 24),
                            _InsightRow(
                              title: "Grading Queue",
                              subtitle: "5 homework pending",
                              color: Colors.orange,
                              icon: Icons.assignment_rounded,
                              onTap: () {
                                Navigator.push(
                                  parentContext,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TeacherInsightDetailScreen(
                                          type: "ungraded_homework",
                                          title: "Grading Queue",
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
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashboardCard({
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
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12, // Slightly smaller for 3-column
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
