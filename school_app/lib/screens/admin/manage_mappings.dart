import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageMappingsScreen extends StatefulWidget {
  const ManageMappingsScreen({super.key});

  @override
  State<ManageMappingsScreen> createState() => _ManageMappingsScreenState();
}

class _ManageMappingsScreenState extends State<ManageMappingsScreen> {
  final ApiService _api = ApiService();
<<<<<<< HEAD
  List mappings = [];
  List teachers = [];
  List sections = [];
  bool isLoading = true;
=======
  bool isLoading = true;
  List teachers = [];
  List sections = [];
  List mappings = [];

  // Form selections
  String? selectedTeacherId;
  String? selectedSectionId;
  final subjectController = TextEditingController();
  final yearController = TextEditingController(text: "2024-2025");
  String selectedRole = "Subject Teacher"; // Default

  // Theme Color
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final mRes = await _api.get("/api/v2/admin/mappings");
      final tRes = await _api.get("/api/v1/admin/teachers");
      final sRes = await _api.get("/api/v1/sections");

      if (mounted) {
        setState(() {
          mappings = mRes["data"] ?? [];
          teachers = tRes["data"] ?? [];
          sections = sRes["data"] ?? [];
=======
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final tRes = await _api.get("/api/v1/admin/teachers"); // Corrected route
      final sRes = await _api.get(
        "/api/v1/admin/sections",
      ); // Consistent admin route
      // final subRes = await _api.get("/api/v1/subjects"); // Keep v1 if valid

      // Mappings is now v2
      final mRes = await _api.get("/api/v2/admin/mappings");

      if (mounted) {
        setState(() {
          teachers = tRes["data"] ?? [];
          sections = sRes["data"] ?? [];
          mappings = mRes["data"] ?? [];
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
          isLoading = false;
        });
      }
    } catch (e) {
<<<<<<< HEAD
=======
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
      }
    }
  }

  Future<void> _createMapping() async {
    if (selectedTeacherId == null ||
        selectedSectionId == null ||
        subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields (Teacher, Section, Subject)"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true); // Show loading during request

    try {
      final res = await _api.post("/api/v2/admin/mappings", {
        "teacher_id": int.tryParse(selectedTeacherId!) ?? 0,
        "section_id": int.tryParse(selectedSectionId!) ?? 0,
        "subject_name": subjectController.text.trim(),
        "academic_year": "2024-2025", // Hardcoded for now
        "role": selectedRole,
      });

      if (res["success"]) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mapping created successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          subjectController.clear();
          // Keep academic year/teacher/section as they might want to add more for same
          await _fetchData(); // Refresh list and wait
        }
      } else {
        throw Exception(res["message"] ?? "Unknown error");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error creating mapping: ${e.toString().replaceAll('Exception:', '')}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
      if (mounted) setState(() => isLoading = false);
    }
  }

<<<<<<< HEAD
  void _showAddMappingDialog() {
    int? selectedTeacherId;
    int? selectedSectionId;
    String? selectedRole = 'subject_teacher';
    final subjectController = TextEditingController();
    final yearController = TextEditingController(text: "2024-25");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🤝 Create Mapping",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                decoration: _fieldDecoration(
                  "Select Teacher",
                  Icons.person_add_alt_1_rounded,
                ),
                items: teachers
                    .map<DropdownMenuItem<int>>(
                      (t) => DropdownMenuItem(
                        value: t["id"],
                        child: Text(t["name"]),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setDialogState(() => selectedTeacherId = val),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: _fieldDecoration(
                  "Select Section",
                  Icons.grid_view_rounded,
                ),
                items: sections
                    .map<DropdownMenuItem<int>>(
                      (s) => DropdownMenuItem(
                        value: s["id"],
                        child: Text("${s["class"]}-${s["section"]}"),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setDialogState(() => selectedSectionId = val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: _fieldDecoration(
                  "Subject Name",
                  Icons.book_rounded,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: _fieldDecoration(
                  "Assignment Role",
                  Icons.assignment_ind_rounded,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'subject_teacher',
                    child: Text("Subject Teacher"),
                  ),
                  DropdownMenuItem(
                    value: 'class_teacher',
                    child: Text("Class Teacher"),
                  ),
                  DropdownMenuItem(value: 'mentor', child: Text("Mentor")),
                ],
                onChanged: (val) => setDialogState(() => selectedRole = val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                decoration: _fieldDecoration(
                  "Academic Year",
                  Icons.event_note_rounded,
                ),
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
                  ),
                  onPressed: () async {
                    if (selectedTeacherId == null ||
                        selectedSectionId == null ||
                        subjectController.text.isEmpty)
                      return;
                    try {
                      final res = await _api.post("/api/v2/admin/mappings", {
                        "teacher_id": selectedTeacherId,
                        "section_id": selectedSectionId,
                        "subject_name": subjectController.text,
                        "role": selectedRole,
                        "academic_year": yearController.text,
                      });
                      if (res["success"]) {
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("🚀 Mapping established!"),
                            ),
                          );
                        }
                        _fetchInitialData();
                      }
                    } catch (e) {
                      if (mounted)
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                  child: const Text(
                    "Create Mapping",
                    style: TextStyle(
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
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey.shade300),
      filled: true,
      fillColor: const Color(0xFFF4F6FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
=======
  Future<void> _deleteMapping(String id) async {
    try {
      await _api.delete("/api/v2/admin/mappings/$id");
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error deleting mapping: $e")));
      }
    }
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _buildMappingList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMappingDialog,
        backgroundColor: const Color(0xFF1A4DFF),
        icon: const Icon(Icons.link_rounded, color: Colors.white),
        label: const Text(
          "New Mapping",
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
          "Teacher Mappings",
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
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMappingList() {
    if (mappings.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "No mappings found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const Text(
              "Tap '+' to link a teacher to a class.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildMappingCard(mappings[index]),
          childCount: mappings.length,
        ),
      ),
    );
  }

  Widget _buildMappingCard(Map m) {
    String emoji = "📜"; // Professional record symbol
    final sub = m["subject_name"].toString().toLowerCase();
    if (sub.contains("math")) emoji = "📐";
    if (sub.contains("science") || sub.contains("physics")) emoji = "🔬";
    if (sub.contains("english")) emoji = "📚";
    if (sub.contains("art")) emoji = "🎭";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1A4DFF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          m["teacher_name"],
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Color(0xFF1E263E),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 14,
                  color: Color(0xFF1A4DFF),
                ),
                const SizedBox(width: 4),
                Text(
                  "${m["subject_name"]} • Class ${m["class"]}-${m["section_name"]}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1A4DFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                m["role"].toString().replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A4DFF),
                ),
              ),
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.delete_sweep_rounded,
              color: Colors.red,
              size: 22,
            ),
            onPressed: () => _confirmDelete(m),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Map m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sever Mapping?"),
        content: Text(
          "Discard linking for '${m["teacher_name"]}' in '${m["subject_name"]}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep it"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sever", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.delete("/api/v2/admin/mappings/${m["id"]}");
        _fetchInitialData();
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
=======
    // Unique list for dropdown to prevent dup errors
    final uniqueTeachers = <String>{};
    final validTeachers = teachers.where((t) {
      final id = t["id"].toString();
      if (uniqueTeachers.contains(id)) return false;
      uniqueTeachers.add(id);
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Manage Mappings"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Create Mapping Form
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.link, color: primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                "Link Subject to Teacher",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Teacher Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedTeacherId,
                            decoration: InputDecoration(
                              labelText: "Select Teacher",
                              labelStyle: TextStyle(color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: primaryColor,
                              ),
                            ),
                            items: validTeachers.isEmpty
                                ? null
                                : validTeachers.map<DropdownMenuItem<String>>((
                                    t,
                                  ) {
                                    return DropdownMenuItem(
                                      value: t["id"].toString(),
                                      child: Text(t["name"] ?? "Unknown"),
                                    );
                                  }).toList(),
                            onChanged: (val) =>
                                setState(() => selectedTeacherId = val),
                            hint: validTeachers.isEmpty
                                ? const Text("No teachers found.")
                                : null,
                          ),
                          const SizedBox(height: 15),

                          // Section Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedSectionId,
                            decoration: InputDecoration(
                              labelText: "Select Section",
                              labelStyle: TextStyle(color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.class_,
                                color: primaryColor,
                              ),
                            ),
                            items: sections.isEmpty
                                ? null
                                : sections.map<DropdownMenuItem<String>>((s) {
                                    return DropdownMenuItem(
                                      value: s["id"].toString(),
                                      child: Text(s["name"] ?? "Unknown"),
                                    );
                                  }).toList(),
                            onChanged: (val) =>
                                setState(() => selectedSectionId = val),
                            hint: sections.isEmpty
                                ? const Text("No sections found.")
                                : null,
                          ),
                          const SizedBox(height: 15),

                          // Subject & Role Row
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: subjectController,
                                  decoration: InputDecoration(
                                    labelText: "Subject Name",
                                    labelStyle: TextStyle(color: primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: selectedRole,
                                  decoration: InputDecoration(
                                    labelText: "Role",
                                    labelStyle: TextStyle(color: primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  items: ["Class Teacher", "Subject Teacher"]
                                      .map(
                                        (r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(r),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => selectedRole = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Academic Year
                          TextField(
                            controller: yearController,
                            decoration: InputDecoration(
                              labelText: "Academic Year",
                              labelStyle: TextStyle(color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _createMapping,
                              icon: const Icon(Icons.link),
                              label: const Text(
                                "Create Link",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Existing Mappings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF455A64),
                    ),
                  ),
                  const SizedBox(height: 10),

                  mappings.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text("No mappings found.")),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: mappings.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final m = mappings[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  child: Icon(Icons.book, color: primaryColor),
                                ),
                                title: Text(
                                  "${m["subject_name"]} - ${m["section_name"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      const TextSpan(text: "Teacher: "),
                                      TextSpan(
                                        text: m["teacher_name"],
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const TextSpan(text: "\nRole: "),
                                      TextSpan(text: m["role"]),
                                    ],
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.deepOrangeAccent,
                                  ),
                                  onPressed: () =>
                                      _deleteMapping(m["id"].toString()),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
}
