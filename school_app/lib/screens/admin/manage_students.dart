import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final ApiService _api = ApiService();
  List students = [];
  List filteredStudentsList = [];
  List sections = [];
  String? selectedSection = "All";
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

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
        backgroundColor: const Color(0xFF1A4DFF),
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
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A4DFF),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          "Manage Students",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A4DFF), Color(0xFF0031D1)],
                ),
              ),
            ),
            Positioned(
              right: -40,
              top: -40,
              child: CircleAvatar(
                radius: 80,
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
          color: isSelected ? const Color(0xFF1A4DFF) : Colors.white,
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

  Widget _buildStudentCard(Map s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEditStudentDialog(s),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("🎓", style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E263E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      Icons.school_outlined,
                      "Class ${s["class"]} ${s["section"]} | Roll: ${s["roll_number"]}",
                    ),
                    const SizedBox(height: 2),
                    _buildInfoRow(Icons.email_outlined, s["email"]),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.blueGrey.shade300),
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
                  backgroundColor: const Color(0xFF1A4DFF),
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
        ),
      ),
    );
  }
}
