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
  final TextEditingController searchController = TextEditingController();

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

<<<<<<< HEAD
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
=======
  Future<void> fetchStudents() async {
    try {
      final res = await _api.get("/api/v1/admin/students");
      if (mounted) {
        setState(() {
          students = res["data"] ?? [];
        });
      }
    } catch (e) {}
  }

  List get filteredStudents {
    List temp = students;

    // Filter by Section
    if (selectedSection != null && selectedSection != "All") {
      temp = temp.where((s) => s["section_name"] == selectedSection).toList();
    }

    // Filter by Search
    final query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      temp = temp.where((s) {
        final name = (s["name"] ?? "").toLowerCase();
        final roll = (s["roll_number"] ?? "").toString().toLowerCase();
        return name.contains(query) || roll.contains(query);
      }).toList();
    }

    return temp;
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
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
<<<<<<< HEAD
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
=======
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Edit Student", style: TextStyle(color: primaryColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, "Full Name", Icons.person),
                const SizedBox(height: 10),
                _buildTextField(emailController, "Email", Icons.email),
                const SizedBox(height: 10),
                _buildTextField(
                  passwordController,
                  "New Password",
                  Icons.lock,
                  isObscure: true,
                ),
                const SizedBox(height: 10),
                _buildTextField(classController, "Class", Icons.class_),
                const SizedBox(height: 10),
                _buildTextField(sectionController, "Section", Icons.grid_view),
                const SizedBox(height: 10),
                _buildTextField(
                  rollController,
                  "Roll Number",
                  Icons.confirmation_number,
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
                ),
              ],
            ),
            _buildField(
              controllers[5],
              "Roll Number",
              Icons.format_list_numbered_rounded,
            ),
<<<<<<< HEAD
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
=======
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                try {
                  final res = await _api
                      .put("/api/v1/admin/users/${s["user_id"]}", {
                        "role": "student",
                        "name": nameController.text,
                        "email": emailController.text,
                        "password": passwordController.text,
                        "class": classController.text,
                        "section": sectionController.text,
                        "roll_number": rollController.text,
                      });
                  if (res["success"]) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Student updated!")),
                      );
                      fetchStudents();
                    }
                  }
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final classController = TextEditingController();
    final sectionController = TextEditingController();
    final rollController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Register Student",
            style: TextStyle(color: primaryColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, "Full Name", Icons.person),
                const SizedBox(height: 10),
                _buildTextField(emailController, "Email", Icons.email),
                const SizedBox(height: 10),
                _buildTextField(
                  passwordController,
                  "Password",
                  Icons.lock,
                  isObscure: true,
                ),
                const SizedBox(height: 10),
                _buildTextField(classController, "Class", Icons.class_),
                const SizedBox(height: 10),
                _buildTextField(sectionController, "Section", Icons.grid_view),
                const SizedBox(height: 10),
                _buildTextField(
                  rollController,
                  "Roll Number",
                  Icons.confirmation_number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                try {
                  final res = await _api.post("/api/v1/admin/register", {
                    "role": "student",
                    "name": nameController.text,
                    "email": emailController.text,
                    "password": passwordController.text,
                    "class": classController.text,
                    "section": sectionController.text,
                    "roll_number": rollController.text,
                  });
                  if (res["success"]) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Student registered!")),
                      );
                      fetchStudents();
                    }
                  }
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text(
                "Register",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Map s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Student"),
        content: Text("Are you sure you want to delete ${s['name']}?"),
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
        await _api.delete("/api/v1/admin/users/${s['user_id']}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Student deleted successfully")),
          );
          fetchStudents();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error deleting student: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayStudents = filteredStudents;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
<<<<<<< HEAD
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
=======
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Manage Students",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${displayStudents.length} Students Active",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Add Student Icon Button in Header
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _showAddStudentDialog,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Search
                    TextField(
                      controller: searchController,
                      onChanged: (val) => setState(() {}),
                      cursorColor: primaryColor,
                      decoration: InputDecoration(
                        hintText: "Search Name or Roll Number...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip("All"),
                    ...sections.map((s) => _buildFilterChip(s["name"])),
                  ],
                ),
              ),

              // List
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : displayStudents.isEmpty
                    ? const Center(
                        child: Text(
                          "No students found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: displayStudents.length,
                        itemBuilder: (context, index) {
                          final s = displayStudents[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        (s["name"] ?? "S")[0].toUpperCase(),
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s["name"] ?? "Unnamed",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "Roll: ${s["roll_number"]}",
                                                style: TextStyle(
                                                  color: Colors.blue[700],
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Class ${s["class"]} - ${s["section"]}",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Actions
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _showEditStudentDialog(s),
                                        icon: Icon(
                                          Icons.edit_rounded,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: primaryColor
                                              .withOpacity(0.1),
                                          padding: const EdgeInsets.all(8),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () => _confirmDelete(s),
                                        icon: const Icon(
                                          Icons.delete_rounded,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.red
                                              .withOpacity(0.1),
                                          padding: const EdgeInsets.all(8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Student", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedSection == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (val) setState(() => selectedSection = label);
        },
        selectedColor: primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
      ),
    );
  }
}
