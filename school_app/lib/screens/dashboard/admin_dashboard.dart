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
import '../leaves/leave_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  // Theme Color
  final Color primaryColor = const Color(0xFF673AB7); // Solid Violet

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool minimized = false;
  bool _showAllModules = false;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Builder(
                    builder: (context) {
                      final List<Widget> modules = [
                        _buildHubTile(
                          context,
                          "Teachers",
                          "assets/3d_icons/teachers.png",
                          const ManageTeachersScreen(),
                        ),
                        _buildHubTile(
                          context,
                          "Students",
                          "assets/3d_icons/students_admin.png",
                          const ManageStudentsScreen(),
                        ),
                        _buildHubTile(
                          context,
                          "Timetable",
                          "assets/3d_icons/timetable.png",
                          const ManageTimetableScreen(),
                        ),
                        _buildHubTile(
                          context,
                          "Sections",
                          "assets/3d_icons/sections.png",
                          const ManageSectionsScreen(),
                        ),
                        _buildHubTile(
                          context,
                          "Time Mgmt",
                          "assets/3d_icons/time_mgmt.png",
                          const ManagePeriodSettingsScreen(),
                        ),
                        _buildHubTile(
                          context,
                          "Mappings",
                          "assets/3d_icons/mappings.png",
                          const ManageMappingsScreen(),
                        ),
                        _buildHubTile(
                          context,
                          "Substitution",
                          "assets/3d_icons/substitution.png",
                          const ManageSubstitutionsScreen(),
                        ),
                        _buildHubTile(
                          context,
                          "Notify Hub",
                          "assets/3d_icons/notice.png",
                          const ManageNotificationsScreen(),
                        ),
                        _buildHubTile(
                          context,
                          "Leaves",
                          "assets/3d_icons/leaves.png",
                          const LeaveManagementScreen(),
                        ),
                      ];

                      final displayModules = _showAllModules
                          ? modules
                          : modules.take(9).toList();

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
                                  _showAllModules = !_showAllModules;
                                });
                              },
                              icon: Icon(
                                _showAllModules
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: const Color(0xFF673AB7),
                              ),
                              label: Text(
                                _showAllModules ? "Show Less" : "Show More",
                                style: const TextStyle(
                                  color: Color(0xFF673AB7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.transparent,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.white,
                                elevation: 2,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
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
                  colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
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
                        color: Color(0xFF673AB7),
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
        ],
      ),
    );
  }

  Widget _buildHubTile(
    BuildContext context,
    String title,
    String imagePath,
    Widget screen,
  ) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
