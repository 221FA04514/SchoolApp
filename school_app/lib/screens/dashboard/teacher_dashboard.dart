import 'package:flutter/material.dart';
import 'dart:async';
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
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      dashboardFuture = TeacherDashboardService().fetchTeacherDashboard();
    });
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
      // Silent fail
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
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FA),
      body: FutureBuilder<TeacherDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A00E0)),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Error loading dashboard"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          return _getCurrentPage(data);
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4A00E0),
        unselectedItemColor: const Color(0xFF94A3B8),
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: 28),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_active_rounded, size: 28),
                if (unreadNotifications > 0)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        unreadNotifications.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: "Alerts",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 28),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _getCurrentPage(TeacherDashboardModel data) {
    switch (_selectedIndex) {
      case 0:
        return _HomeView(data: data, onRefresh: _refreshData);
      case 1:
        return const NotificationInboxScreen();
      case 2:
        return _ProfileView(data: data, parentContext: context);
      default:
        return _HomeView(data: data, onRefresh: _refreshData);
    }
  }
}

class _HomeView extends StatefulWidget {
  final TeacherDashboardModel data;
  final VoidCallback onRefresh;

  const _HomeView({required this.data, required this.onRefresh});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView>
    with SingleTickerProviderStateMixin {
  late Timer _quoteTimer;
  int _quoteIndex = 0;
  late AnimationController _animationController;
  late Animation<Color?> _headerColorAnimation;
  late Animation<double> _circleAnimation;

  final List<Color> _dynamicColors = [
    const Color(0xFF4A00E0),
    const Color(0xFF1E293B),
    const Color(0xFF2D31FA),
    const Color(0xFF6366F1),
    const Color(0xFF0F172A),
  ];

  final List<String> _quotes = [
    "Teaching is the profession that creates all other professions.",
    "The art of teaching is the art of assisting discovery.",
    "A good teacher can inspire hope, ignite the imagination, and instill a love of learning.",
    "Better than a thousand days of diligent study is one day with a great teacher.",
    "Education is the most powerful weapon which you can use to change the world.",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _headerColorAnimation = _animationController.drive(
      ColorTween(begin: _dynamicColors[0], end: _dynamicColors[2]),
    );

    _circleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _quoteTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _quotes.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _quoteTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _nav(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      color: const Color(0xFF4A00E0),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAnimatingShrinkHeader(data),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildStatsRow(data),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Quick Actions"),
                  const SizedBox(height: 15),
                  _buildQuickActionsGrid(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Today's Schedule"),
                  const SizedBox(height: 15),
                  _buildScheduleScroll(data),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Smart Insights"),
                  const SizedBox(height: 15),
                  _buildInsightsCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildStatsRow(TeacherDashboardModel data) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard(
            title: "Students",
            subtitle: "Total Enrolled",
            icon: Icons.people_rounded,
            value: data.totalStudents.toString(),
            color: Colors.blue.shade50,
            iconColor: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildSmallStatCard(
            title: "Doubts",
            subtitle: "Pending Now",
            icon: Icons.help_outline_rounded,
            value: data.pendingDoubts.toString(),
            color: Colors.orange.shade50,
            iconColor: Colors.orange.shade700,
            onTap: () => _nav(const TeacherStudentListScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color color,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPrimaryActionCard(
                title: "Attendance",
                subtitle: "Mark & Track",
                icon: Icons.how_to_reg_rounded,
                color: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF1976D2),
                onTap: () => _nav(const TeacherAttendanceScreen()),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildPrimaryActionCard(
                title: "Homework",
                subtitle: "Assign Tasks",
                icon: Icons.assignment_rounded,
                color: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF7B1FA2),
                onTap: () => _nav(const TeacherHomeworkScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildPrimaryActionCard(
                title: "Timetable",
                subtitle: "Class Schedule",
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFFE0F2F1),
                iconColor: const Color(0xFF00796B),
                onTap: () => _nav(const TeacherTimetableScreen()),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildPrimaryActionCard(
                title: "Doubts",
                subtitle: "Student Chats",
                icon: Icons.question_answer_rounded,
                color: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFF57C00),
                onTap: () => _nav(const TeacherStudentListScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _buildSectionTitle("Operations Hub"),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCompactActionCard("Results", Icons.assessment_rounded, Colors.amber.shade700, () => _nav(const TeacherResultsScreen())),
            _buildCompactActionCard("Announce", Icons.campaign_rounded, Colors.pink.shade600, () => _nav(const TeacherAnnouncementsScreen())),
            _buildCompactActionCard("Library", Icons.library_books_rounded, Colors.lightBlue.shade700, () => _nav(const TeacherResourceLibraryScreen())),
            _buildCompactActionCard("Leaves", Icons.event_note_rounded, Colors.indigo.shade600, () => _nav(const LeaveManagementScreen())),
            _buildCompactActionCard("Reports", Icons.show_chart_rounded, Colors.green.shade700, () => _nav(const TeacherPerformanceScreen())),
            _buildCompactActionCard("AI Suite", Icons.auto_awesome_rounded, Colors.deepPurple.shade600, () => _nav(const TeacherAiAssistantPortal())),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    final width = (MediaQuery.of(context).size.width - 64) / 3;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleScroll(TeacherDashboardModel data) {
    if (data.todaySchedule.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Text("No classes scheduled for today")),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: data.todaySchedule.length,
        itemBuilder: (context, index) {
          final slot = data.todaySchedule[index];
          return Container(
            width: 170,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A00E0),
                  const Color(0xFF4A00E0).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A00E0).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot["subject"] ?? "Class",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Period ${slot['period']}",
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      color: Colors.amber,
                      size: 12,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      slot["start_time"] ?? "N/A",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _InsightRow(
        title: "Attendance Warning",
        subtitle: "3 students fell below 75% threshold",
        color: Colors.red,
        icon: Icons.warning_amber_rounded,
        onTap: () {
          _nav(
            const TeacherInsightDetailScreen(
              type: "low_attendance",
              title: "Attendance Alerts",
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatingShrinkHeader(TeacherDashboardModel data) {
    const double maxHeight = 260.0;
    const double minHeight = 110.0;

    return SliverAppBar(
      expandedHeight: maxHeight,
      collapsedHeight: minHeight,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF1E293B),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final double currentHeight = constraints.biggest.height;
              final double t =
                  (maxHeight - currentHeight) / (maxHeight - minHeight);
              final double contentOpacity = (1.0 - (t * 3)).clamp(0.0, 1.0);
              final double quoteOpacity = (1.0 - (t * 6)).clamp(0.0, 1.0);
              final double scale = 1.0 - (t * 0.2).clamp(0.0, 0.2);
              final bool isShrunk = t > 0.5;

              return Container(
                decoration: BoxDecoration(
                  color: isShrunk
                      ? const Color(0xFF0F172A)
                      : _headerColorAnimation.value,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(t > 0.7 ? 0 : 30),
                    bottomRight: Radius.circular(t > 0.7 ? 0 : 30),
                  ),
                ),
                child: Stack(
                  children: [
                    ..._buildBackgroundCircles(t),

                    if (quoteOpacity > 0.01)
                      Positioned(
                        bottom: 25 + (t * 20),
                        left: 20,
                        right: 80,
                        child: Opacity(
                          opacity: quoteOpacity,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: KeyedSubtree(
                              key: ValueKey(_quoteIndex),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.psychology_rounded,
                                    color: Colors.white30,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _quotes[_quoteIndex],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      top: 55 + (t * -10),
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white24,
                                child: Text(
                                  data.name.isNotEmpty
                                      ? data.name[0].toUpperCase()
                                      : 'T',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t > 0.7
                                      ? "TEACHER CONSOLE"
                                      : (contentOpacity > 0.5
                                            ? "Welcome back,"
                                            : "Active Session"),
                                  style: TextStyle(
                                    color: t > 0.7
                                        ? Colors.amber
                                        : Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: t > 0.7 ? 2.5 : 0.5,
                                  ),
                                ),
                                Text(
                                  data.name.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18 + (t * -2),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (contentOpacity > 0.6)
                                  Text(
                                    data.subject.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _buildBadge(t),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildBackgroundCircles(double scrollT) {
    if (scrollT > 0.8) return [];
    return [
      _circle(
        top: -50 + (scrollT * 40),
        right: -50,
        size: 200,
        opacity: 0.1,
        mult: 1.0,
      ),
      _circle(bottom: -20, left: -30, size: 150, opacity: 0.08, mult: -0.5),
    ];
  }

  Widget _circle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
    required double mult,
  }) {
    return Positioned(
      top: top != null ? top + (_circleAnimation.value * 20 * mult) : null,
      bottom: bottom != null
          ? bottom + (_circleAnimation.value * 20 * mult)
          : null,
      left: left != null ? left + (_circleAnimation.value * 20 * mult) : null,
      right: right != null
          ? right + (_circleAnimation.value * 20 * mult)
          : null,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(double t) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8 + (t * -2)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: Colors.amber,
            size: 14 + (t * -2),
          ),
          if (t < 0.5) ...[
            const SizedBox(width: 6),
            const Text(
              "FACULTY",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
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

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.1), width: 1.5),
            ),
            child: Icon(icon, size: 28, color: color.withOpacity(0.8)),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey.shade900,
              letterSpacing: -0.2,
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
