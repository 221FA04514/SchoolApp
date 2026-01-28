import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageMappingsScreen extends StatefulWidget {
  const ManageMappingsScreen({super.key});

  @override
  State<ManageMappingsScreen> createState() => _ManageMappingsScreenState();
}

class _ManageMappingsScreenState extends State<ManageMappingsScreen> {
  final ApiService _api = ApiService();
  List mappings = [];
  List teachers = [];
  List sections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
  }

  @override
  Widget build(BuildContext context) {
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
}
