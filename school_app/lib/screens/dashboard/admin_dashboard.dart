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
<<<<<<< HEAD
import '../admin/notification_center.dart';
import '../leaves/leave_management_screen.dart';
=======
import '../admin/manage_notifications.dart';
import '../admin/manage_leaves.dart';
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  // Theme Color
  final Color primaryColor = const Color(0xFF673AB7); // Solid Violet

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool minimized = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => minimized = true);
    });
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
    final size = MediaQuery.of(context).size;
    final double expandedHeight = size.height * 0.32;
    final double minimizedHeight = size.height * 0.18;

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          // ================= BODY =================
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            top: minimized ? minimizedHeight : expandedHeight,
            left: 0,
            right: 0,
            bottom: 0,
=======
      backgroundColor: const Color(0xFFF5F6FA), // Light grey background
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            decoration: BoxDecoration(
              color: primaryColor, // Solid Violet
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: primaryColor,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Administrator",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginSelectionScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
<<<<<<< HEAD
                  const Text(
                    "💎 Control Center",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E263E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
=======
                  Row(
                    children: [
                      Icon(Icons.grid_view_rounded, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        "Control Center",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
<<<<<<< HEAD
                      _buildHubTile(
                        context,
                        "Teachers",
                        Icons.supervisor_account_rounded,
                        Colors.blue,
                        const ManageTeachersScreen(),
                      ),
                      _buildHubTile(
                        context,
                        "Students",
                        Icons.school_rounded,
                        Colors.teal,
                        const ManageStudentsScreen(),
                      ),
                      _buildHubTile(
                        context,
                        "Timetable",
                        Icons.calendar_today_rounded,
                        Colors.indigo,
                        const ManageTimetableScreen(),
                      ),
                      _buildHubTile(
                        context,
                        "Sections",
                        Icons.grid_view_rounded,
                        Colors.orange,
                        const ManageSectionsScreen(),
                      ),
                      _buildHubTile(
                        context,
                        "Time Mgmt",
                        Icons.timer_rounded,
                        Colors.pink,
                        const ManagePeriodSettingsScreen(),
                      ),
                      _buildHubTile(
                        context,
                        "Mappings",
                        Icons.join_inner_rounded,
                        Colors.cyan,
                        const ManageMappingsScreen(),
                      ),
                      _buildHubTile(
                        context,
                        "Substitution",
                        Icons.cached_rounded,
                        Colors.purple,
                        const ManageSubstitutionsScreen(),
                      ),
                      _buildHubTile(
                        context,
                        "Notify Hub",
                        Icons.notifications_active_rounded,
                        Colors.deepOrange,
                        const NotificationCenterScreen(),
                      ),
                      _buildHubTile(
                        context,
                        "Leaves",
                        Icons.sick_rounded,
                        Colors.redAccent,
                        const LeaveManagementScreen(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
=======
                      _buildModuleCard(
                        context,
                        "Teachers",
                        Icons.people,
                        const ManageTeachersScreen(),
                      ),
                      _buildModuleCard(
                        context,
                        "Students",
                        Icons.school,
                        const ManageStudentsScreen(),
                      ),
                      _buildModuleCard(
                        context,
                        "Timetable",
                        Icons.calendar_today,
                        const ManageTimetableScreen(),
                      ),
                      _buildModuleCard(
                        context,
                        "Sections",
                        Icons.grid_view,
                        const ManageSectionsScreen(),
                      ),
                      _buildModuleCard(
                        context,
                        "Time Mgmt",
                        Icons.timer,
                        const ManagePeriodSettingsScreen(),
                      ),
                      _buildModuleCard(
                        context,
                        "Mappings",
                        Icons.link,
                        const ManageMappingsScreen(),
                      ),
                      _buildModuleCard(
                        context,
                        "Substitution",
                        Icons.sync_alt,
                        const ManageSubstitutionsScreen(),
                      ),
                      _buildModuleCard(
                        context,
                        "Notify Hub",
                        Icons.notifications_active,
                        const ManageNotificationsScreen(),
                      ),
                      _buildModuleCard(
                        context,
                        "Leaves",
                        Icons.exit_to_app,
                        const ManageLeavesScreen(),
                      ),
                    ],
                  ),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
                ],
              ),
            ),
          ),
<<<<<<< HEAD

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
                  colors: [Color(0xFF1A4DFF), Color(0xFF0031D1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: minimized ? 26 : 40,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 36,
                        color: Color(0xFF1A4DFF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedOpacity(
                          opacity: minimized ? 0 : 1,
                          duration: const Duration(milliseconds: 300),
                          child: const Text(
                            "System Control ⚙️",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Text(
                          "Administrator",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _logout(context),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
=======
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildHubTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Color(0xFF1E263E),
              ),
            ),
          ],
=======
  Widget _buildModuleCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget target,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => target));
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        ),
      ),
    );
  }
}
