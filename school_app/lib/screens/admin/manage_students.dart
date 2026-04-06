import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final ApiService _api = ApiService();
  final searchController = TextEditingController();
  List students = [];
  List filteredStudentsList = [];
  List sections = [];
  String? selectedSection = "All";
  bool isLoading = true;

  // Theme Color
  final Color primaryColor = const Color(0xFF4A00E0); // Modern Violet

  @override
  void initState() {
    super.initState();
    fetchData();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> fetchData() async {
    try {
      final sRes = await _api.get("/api/v1/admin/students");
      final secRes = await _api.get("/api/v1/admin/sections");
      setState(() {
        students = sRes["data"] ?? [];
        sections = secRes["data"] ?? [];
        isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredStudentsList = students.where((s) {
        final matchesSection =
            selectedSection == "All" || s["section_name"] == selectedSection;
        final name = s["name"].toString().toLowerCase();
        final email = s["email"].toString().toLowerCase();
        final search = searchController.text.toLowerCase();
        final matchesSearch = name.contains(search) || email.contains(search);
        return matchesSection && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildFilterSection()),
          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildGroupedStudentList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        backgroundColor: const Color(0xFF673AB7),
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text(
          "Add Student",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: const Text(
          "Manage Students",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search students...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.blueGrey.shade300,
                  size: 22,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
        // Section Pills
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSectionPill("All"),
              ...sections
                  .map((sec) => _buildSectionPill(sec["name"].toString()))
                  .toList(),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionPill(String label) {
    bool isSelected = selectedSection == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSection = label;
          _applyFilters();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF673AB7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            label == "All" ? "All Sections" : "Section $label",
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.blueGrey.shade700,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedStudentList() {
    final grouped = <String, List>{};
    for (var s in filteredStudentsList) {
      final sec = s["section_name"] ?? "Unassigned";
      grouped.putIfAbsent(sec, () => []).add(s);
    }

    final sortedSections = grouped.keys.toList()..sort();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          // Flatten the list with headers
          int currentCount = 0;
          for (var sec in sortedSections) {
            if (index == currentCount) {
              return _buildSectionHeader(sec);
            }
            currentCount++;
            if (index < currentCount + grouped[sec]!.length) {
              return _buildStudentCard(grouped[sec]![index - currentCount]);
            }
            currentCount += grouped[sec]!.length;
          }
          return null;
        }, childCount: sortedSections.length + filteredStudentsList.length),
      ),
    );
  }

  Widget _buildSectionHeader(String sectionName) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12, left: 4),
      child: Text(
        "Section $sectionName",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.blueGrey.shade800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _deleteStudent(Map s) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Student?"),
        content: Text("Are you sure you want to remove ${s["name"]}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.delete("/api/v1/admin/users/${s["user_id"]}");
        fetchData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  Widget _buildStudentCard(Map s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Styled Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF673AB7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.school, color: Color(0xFF673AB7), size: 28),
              ),
            ),
            const SizedBox(width: 16),
            // Main Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s["name"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    Icons.class_outlined,
                    "Class ${s["class"]} ${s["section"]} | Roll No: ${s["roll_number"]}",
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.email_outlined, s["email"]),
                ],
              ),
            ),
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF673AB7),
                    size: 22,
                  ),
                  onPressed: () => _showEditStudentDialog(s),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 22,
                  ),
                  onPressed: () => _deleteStudent(s),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF673AB7)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final classController = TextEditingController();
    final sectionController = TextEditingController();
    final rollController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildStudentForm(
        title: "New Student",
        controllers: [
          nameController,
          emailController,
          passwordController,
          classController,
          sectionController,
          rollController,
        ],
        btnLabel: "Register Student",
        onSave: () async {
          await _api.post("/api/v1/admin/register", {
            "role": "student",
            "name": nameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "class": classController.text,
            "section": sectionController.text,
            "roll_number": rollController.text,
          });
          fetchData();
        },
      ),
    );
  }

  void _showEditStudentDialog(Map s) {
    final nameController = TextEditingController(text: s["name"]);
    final emailController = TextEditingController(text: s["email"]);
    final passwordController = TextEditingController();
    final classController = TextEditingController(text: s["class"].toString());
    final sectionController = TextEditingController(text: s["section"]);
    final rollController = TextEditingController(
      text: s["roll_number"].toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildStudentForm(
        title: "Edit Student",
        controllers: [
          nameController,
          emailController,
          passwordController,
          classController,
          sectionController,
          rollController,
        ],
        btnLabel: "Update Details",
        onSave: () async {
          await _api.put("/api/v1/admin/users/${s["user_id"]}", {
            "role": "student",
            "name": nameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "class": classController.text,
            "section": sectionController.text,
            "roll_number": rollController.text,
          });
          fetchData();
        },
      ),
    );
  }

  Widget _buildStudentForm({
    required String title,
    required List<TextEditingController> controllers,
    required String btnLabel,
    required Future<void> Function() onSave,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildField(controllers[0], "Full Name", Icons.person_outlined),
            _buildField(controllers[1], "Email ID", Icons.email_outlined),
            _buildField(
              controllers[2],
              "Password",
              Icons.lock_outlined,
              obscure: true,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controllers[3],
                    "Class",
                    Icons.class_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    controllers[4],
                    "Section",
                    Icons.grid_view_rounded,
                  ),
                ),
              ],
            ),
            _buildField(
              controllers[5],
              "Roll Number",
              Icons.format_list_numbered_rounded,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  try {
                    await onSave();
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: Text(
                  btnLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey.shade300),
          filled: true,
          fillColor: const Color(0xFFF4F6FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF673AB7), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
