import 'package:flutter/material.dart';
import '../../core/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import '../auth/login_selection_screen.dart';
import '../admin/manage_teachers.dart';
import '../admin/manage_students.dart';
import '../admin/manage_timetable.dart';
import '../admin/manage_sections.dart';
import '../admin/manage_period_settings.dart';
import '../admin/manage_mappings.dart';
import '../admin/manage_substitutions.dart';
import '../admin/manage_notifications.dart';
import '../admin/manage_exams.dart';
import '../leaves/leave_management_screen.dart';
import '../../core/api/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  bool _showAllModules = false;
  late AnimationController _animationController;
  late Animation<Color?> _headerColorAnimation;
  late Animation<double> _circleAnimation;
  Map<String, dynamic> _stats = {
    "totalTeachers": 0,
    "totalStudents": 0,
    "totalSections": 0
  };
  bool _isLoadingStats = true;

  final List<Color> _dynamicColors = [
    const Color(0xFF673AB7),
    const Color(0xFF1E293B),
    const Color(0xFF512DA8),
    const Color(0xFF311B92),
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

    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await ApiService().get("/api/v1/admin/stats");
      if (mounted) {
        setState(() {
          _stats = response["data"];
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAnimatingShrinkHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  _buildStatsRow(),
                  const SizedBox(height: 30),
                  const Text(
                    "Control Center",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E263E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.95,
                    children: [
                      _buildPrimaryAdminCard("Teachers", "Manage Faculty", Icons.school_rounded, const Color(0xFFE3F2FD), const Color(0xFF1976D2), const ManageTeachersScreen()),
                      _buildPrimaryAdminCard("Students", "Enrollment Desk", Icons.people_alt_rounded, const Color(0xFFFFF3E0), const Color(0xFFF57C00), const ManageStudentsScreen()),
                      _buildPrimaryAdminCard("Timetable", "Class Scheduling", Icons.calendar_today_rounded, const Color(0xFFE0F2F1), const Color(0xFF00796B), const ManageTimetableScreen()),
                      _buildPrimaryAdminCard("Sections", "Class Segments", Icons.layers_rounded, const Color(0xFFF3E5F5), const Color(0xFF7B1FA2), const ManageSectionsScreen()),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "System Tools",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E263E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildCompactAdminCard("Time Mgmt", Icons.access_time_filled_rounded, Colors.indigo.shade600, const ManagePeriodSettingsScreen()),
                      _buildCompactAdminCard("Mappings", Icons.hub_rounded, Colors.deepOrange.shade600, const ManageMappingsScreen()),
                      _buildCompactAdminCard("Substitution", Icons.swap_calls_rounded, Colors.pink.shade600, const ManageSubstitutionsScreen()),
                      _buildCompactAdminCard("Notify Hub", Icons.campaign_rounded, Colors.red.shade700, const ManageNotificationsScreen()),
                      _buildCompactAdminCard("Exams", Icons.assessment_rounded, Colors.amber.shade700, const ManageExamsScreen()),
                      _buildCompactAdminCard("Leaves", Icons.event_note_rounded, Colors.green.shade700, const LeaveManagementScreen()),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "System Insights",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E263E),
                      letterSpacing: -0.5,
                    ),
                  ),
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard(
            title: "Teachers",
            value: _isLoadingStats ? "..." : _stats["totalTeachers"].toString(),
            icon: Icons.school_rounded,
            color: Colors.blue.shade50,
            iconColor: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildSmallStatCard(
            title: "Students",
            value: _isLoadingStats ? "..." : _stats["totalStudents"].toString(),
            icon: Icons.people_alt_rounded,
            color: Colors.orange.shade50,
            iconColor: Colors.orange.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: iconColor,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.purple.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "System Health Check",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E263E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Database and API services are running optimally. No critical failures detected.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatingShrinkHeader() {
    const double maxHeight = 240.0;
    const double minHeight = 110.0;

    return SliverAppBar(
      expandedHeight: maxHeight,
      collapsedHeight: minHeight,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF1E293B),
      actions: [
        IconButton(
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout_rounded, color: Colors.white70),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final double currentHeight = constraints.biggest.height;
              final double t =
                  (maxHeight - currentHeight) / (maxHeight - minHeight);
              final double contentOpacity = (1.0 - (t * 3)).clamp(0.0, 1.0);
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

                    Positioned(
                      top: 55 + (t * -15),
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white24,
                              ),
                              child: const CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 30,
                                  color: Color(0xFF673AB7),
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
                                      ? "SYSTEM CONTROL"
                                      : (contentOpacity > 0.5
                                            ? "System Operations,"
                                            : "Admin Terminal"),
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
                                  "ADMINISTRATOR",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22 + (t * -4),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (contentOpacity > 0.6)
                                  const Text(
                                    "School Management Suite",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
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
      _circle(
        top: -40 + (scrollT * 30),
        right: -30,
        size: 180,
        opacity: 0.1,
        mult: 1.0,
      ),
      _circle(bottom: -10, left: -20, size: 130, opacity: 0.08, mult: -0.6),
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

  Widget _buildPrimaryAdminCard(String title, String sub, IconData icon, Color color, Color iconColor, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(18),
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
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: Color(0xFF1E263E),
              ),
            ),
            Text(
              sub,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactAdminCard(String title, IconData icon, Color color, Widget screen) {
    final width = (MediaQuery.of(context).size.width - 64) / 3;
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(22),
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
}
