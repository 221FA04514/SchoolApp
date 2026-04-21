import 'package:flutter/material.dart';
import 'dart:async';
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
import '../../core/api/api_service.dart';
import '../announcements/student_announcements_screen.dart';
import '../messages/teacher_list_screen.dart';
import '../performance/student_performance_screen.dart';
import '../ai/student_online_exam_list.dart';
import '../timetable/timetable_model.dart';
import 'bus_tracking_screen.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late Future<StudentDashboardModel> dashboardFuture;
  List<TimetableItem> todaySchedule = [];
  int unreadNotifications = 0;
  int _selectedIndex = 0;
  bool _isLoadingSchedule = true;

  // Real-time Attendance
  int realAttendancePercentage = 0;
  bool _isLoadingAttendance = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      dashboardFuture = DashboardService().fetchStudentDashboard();
      _isLoadingSchedule = true;
      _isLoadingAttendance = true;
    });

    // 1. Fetch Timetable for Today's Schedule
    try {
      final res = await ApiService().get("/api/v1/timetable/my");
      final String today = DateFormat('EEEE').format(DateTime.now());
      List<TimetableItem> allItems = (res["data"] as List)
          .map((e) => TimetableItem.fromJson(e))
          .toList();

      if (mounted) {
        setState(() {
          todaySchedule = allItems
              .where((item) => item.day.toLowerCase() == today.toLowerCase())
              .toList();
          _isLoadingSchedule = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSchedule = false);
    }

    // 2. Fetch Real-time Attendance Summary
    try {
      final now = DateTime.now();
      final summaryRes = await ApiService().get(
        "/api/v1/attendance/summary?month=${now.month}&year=${now.year}",
      );
      if (mounted) {
        setState(() {
          realAttendancePercentage = (summaryRes["data"]?["percentage"] ?? 0)
              .toInt();
          _isLoadingAttendance = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAttendance = false);
    }

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FA),
      body: FutureBuilder<StudentDashboardModel>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0056D2)),
            );
          }
          final data =
              snapshot.data ??
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
        selectedItemColor: const Color(0xFF0056D2),
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

  Widget _getCurrentPage(StudentDashboardModel data) {
    switch (_selectedIndex) {
      case 0:
        return _HomeView(
          data: data,
          unreadNotifications: unreadNotifications,
          todaySchedule: todaySchedule,
          isLoadingSchedule: _isLoadingSchedule,
          realAttendance: realAttendancePercentage,
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
          todaySchedule: todaySchedule,
          isLoadingSchedule: _isLoadingSchedule,
          realAttendance: realAttendancePercentage,
          onRefresh: _refreshData,
        );
    }
  }
}

class _HomeView extends StatefulWidget {
  final StudentDashboardModel data;
  final int unreadNotifications;
  final List<TimetableItem> todaySchedule;
  final bool isLoadingSchedule;
  final int realAttendance;
  final RefreshCallback onRefresh;

  const _HomeView({
    required this.data,
    required this.unreadNotifications,
    required this.todaySchedule,
    required this.isLoadingSchedule,
    required this.realAttendance,
    required this.onRefresh,
  });

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
    const Color(0xFF0056D2),
    const Color(0xFF6366F1),
    const Color(0xFF0F172A),
  ];

  final List<String> _quotes = [
    "The best way to predict your future is to create it.",
    "Success is the sum of small efforts repeated daily.",
    "Strive for progress, not perfection. Keep going!",
    "Your education is a dress rehearsal for a life that is yours.",
    "Don't let what you cannot do interfere with what you can do.",
    "Believe you can and you're halfway there.",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _headerColorAnimation = _animationController.drive(
      ColorTween(
        begin: _dynamicColors[0],
        end: _dynamicColors[2],
      ),
    );

    _circleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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

  void _go(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: const Color(0xFF0056D2),
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
                  GestureDetector(
                    onTap: () => _go(context, const AttendanceScreen()),
                    child: _buildAttendanceCard(widget.realAttendance),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallStatCard(
                          title: "Homework",
                          subtitle: "Complete it",
                          icon: Icons.edit_document,
                          color: Colors.blue.shade50,
                          iconColor: Colors.blue.shade700,
                          onTap: () =>
                              _go(context, const StudentHomeworkScreen()),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildSmallStatCard(
                          title: "Time Table",
                          subtitle: "Check Today",
                          icon: Icons.calendar_today_rounded,
                          color: Colors.blue.shade50,
                          iconColor: Colors.blue.shade700,
                          onTap: () =>
                              _go(context, const StudentTimetableScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Academic Hub"),
                  const SizedBox(height: 15),
                  _buildAcademicHub(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Today's Schedule", trailing: "Full View"),
                  const SizedBox(height: 15),
                  _buildScheduleList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: () => _go(context, const StudentTimetableScreen()),
            child: Text(
              trailing,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0056D2),
              ),
            ),
          ),
      ],
    );
  }

  // --- NEW ADVANCED SHRINKING HEADER ---
  Widget _buildAnimatingShrinkHeader(StudentDashboardModel data) {
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
              final double t = (maxHeight - currentHeight) / (maxHeight - minHeight);
              final double contentOpacity = (1.0 - (t * 3)).clamp(0.0, 1.0);
              final double quoteOpacity = (1.0 - (t * 6)).clamp(0.0, 1.0);
              final double scale = 1.0 - (t * 0.2).clamp(0.0, 0.2);
              final bool isShrunk = t > 0.5;

              return Container(
                decoration: BoxDecoration(
                  color: isShrunk ? const Color(0xFF0F172A) : _headerColorAnimation.value,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(t > 0.7 ? 0 : 30),
                    bottomRight: Radius.circular(t > 0.7 ? 0 : 30),
                  ),
                  boxShadow: isShrunk
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    // Live Circle Designs
                    ..._buildBackgroundCircles(t),

                    // Expanded Only Content: Quote (Fades out extremely fast)
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
                                    Icons.tips_and_updates_rounded,
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

                    // Header Top Row (Adjusts position based on scroll)
                    Positioned(
                      top: 55 + (t * -10),
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          // Animated Profile Picture
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white24,
                                child: Text(
                                  data.name.isNotEmpty
                                      ? data.name[0].toUpperCase()
                                      : 'S',
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
                                      ? "STUDENT PORTAL"
                                      : (contentOpacity > 0.5
                                            ? "Welcome back,"
                                            : "Active Board"),
                                  style: TextStyle(
                                    color: t > 0.7 ? Colors.amber : Colors.white70,
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
                                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Small interesting badge shifts up
                          Transform.translate(
                            offset: Offset(0, t * -5),
                            child: _buildBadge(t),
                          ),
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
      _buildCircle(
        top: -50 + (scrollT * 40),
        right: -50,
        size: 200,
        opacity: 0.1,
        offsetMultiplier: 1.0,
      ),
      _buildCircle(
        bottom: -20,
        left: -30,
        size: 150,
        opacity: 0.08,
        offsetMultiplier: -0.5,
      ),
      _buildCircle(
        top: 40,
        left: 100,
        size: 80,
        opacity: 0.05,
        offsetMultiplier: 0.8,
      ),
    ];
  }

  Widget _buildCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
    required double offsetMultiplier,
  }) {
    return Positioned(
      top: top != null ? top + (_circleAnimation.value * 20 * offsetMultiplier) : null,
      bottom: bottom != null ? bottom + (_circleAnimation.value * 20 * offsetMultiplier) : null,
      left: left != null ? left + (_circleAnimation.value * 20 * offsetMultiplier) : null,
      right: right != null ? right + (_circleAnimation.value * 20 * offsetMultiplier) : null,
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
          Icon(Icons.auto_awesome, color: Colors.amber, size: 14 + (t * -2)),
          if (t < 0.5) ...[
            const SizedBox(width: 6),
            const Text(
              "PRO",
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

  Widget _buildAttendanceCard(int percentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0056D2).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 65,
            width: 65,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100.0,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade50,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2DC4B6)),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  "$percentage%",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Attendance Summary",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${DateFormat('MMMM').format(DateTime.now())} Monthly Report",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    String? badge,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicHub() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildRhythmicCard(
                title: "Notices",
                sub: "School Feed",
                icon: Icons.campaign_rounded,
                color: const Color(0xFFE1F5FE),
                iconColor: const Color(0xFF0288D1),
                onTap: () => _go(context, const StudentAnnouncementsScreen()),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildRhythmicCard(
                title: "Performance",
                sub: "Analytics",
                icon: Icons.analytics_rounded,
                color: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF2E7D32),
                onTap: () => _go(context, const StudentPerformanceScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildRhythmicCard(
                title: "Exams",
                sub: "View Marks",
                icon: Icons.assignment_rounded,
                color: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFF57C00),
                onTap: () => _go(context, const StudentOnlineExamListScreen()),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildRhythmicCard(
                title: "Results",
                sub: "Report Card",
                icon: Icons.auto_graph_rounded,
                color: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF7B1FA2),
                onTap: () => _go(context, const ResultsScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCompactCard(
              title: "Fees",
              icon: Icons.payments_rounded,
              color: Colors.amber.shade700,
              onTap: () => _go(context, const FeesScreen()),
            ),
            _buildCompactCard(
              title: "Library",
              icon: Icons.local_library_rounded,
              color: Colors.purple.shade600,
              onTap: () => _go(context, const ResourceLibraryScreen()),
            ),
            _buildCompactCard(
              title: "AI Help",
              icon: Icons.auto_awesome_rounded,
              color: Colors.cyan.shade600,
              onTap: () => _go(context, const AiHubScreen()),
            ),
            _buildCompactCard(
              title: "Leaves",
              icon: Icons.time_to_leave_rounded,
              color: Colors.pink.shade600,
              onTap: () => _go(context, const LeaveManagementScreen()),
            ),
            _buildCompactCard(
              title: "Bus Map",
              icon: Icons.directions_bus_rounded,
              color: Colors.indigo.shade600,
              onTap: () => _go(context, const BusTrackingScreen()),
            ),
            _buildCompactCard(
              title: "Doubts",
              icon: Icons.chat_bubble_rounded,
              color: Colors.brown.shade600,
              onTap: () => _go(context, const TeacherListScreen()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRhythmicCard({
    required String title,
    required String sub,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              sub,
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

  Widget _buildCompactCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
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

  Widget _buildScheduleList() {
    if (widget.isLoadingSchedule)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    if (widget.todaySchedule.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 40,
              color: Colors.grey.shade100,
            ),
            const SizedBox(height: 12),
            const Text(
              "No classes today",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Column(
      children: widget.todaySchedule.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF0056D2),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      item.teacherName,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.startTime,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
