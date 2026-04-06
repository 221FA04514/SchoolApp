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
  bool isSubmitting = false;

  int? selectedTeacherId;
  int? selectedSectionId;
  String? selectedRole = 'Subject Teacher';
  final subjectController = TextEditingController();
  final yearController = TextEditingController(text: "2024-2025");

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

  Future<void> _createLink() async {
    if (selectedTeacherId == null ||
        selectedSectionId == null ||
        subjectController.text.isEmpty ||
        selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    String dbRole = 'subject_teacher';
    if (selectedRole == 'Class Teacher') dbRole = 'class_teacher';
    if (selectedRole == 'Mentor') dbRole = 'mentor';

    try {
      final res = await _api.post("/api/v2/admin/mappings", {
        "teacher_id": selectedTeacherId,
        "section_id": selectedSectionId,
        "subject_name": subjectController.text,
        "role": dbRole,
        "academic_year": yearController.text,
      });
      if (res["success"]) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🚀 Mapping established!")),
          );
          // clear fields
          setState(() {
            selectedTeacherId = null;
            selectedSectionId = null;
            subjectController.clear();
            selectedRole = 'Subject Teacher';
            yearController.text = "2024-2025";
          });
        }
        await _fetchInitialData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text(
          "Manage Mappings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLinkForm(),
                  const SizedBox(height: 24),
                  const Text(
                    "Existing Mappings",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF455A64),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMappingList(),
                ],
              ),
            ),
    );
  }

  Widget _buildLinkForm() {
    return Container(
      padding: const EdgeInsets.all(24.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, color: Color(0xFF673AB7)),
              const SizedBox(width: 8),
              const Text(
                "Link Subject to Teacher",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDropdown<int>(
            value: selectedTeacherId,
            hint: "Select Teacher",
            icon: Icons.person,
            items: teachers
                .map((t) => DropdownMenuItem<int>(
                    value: t["id"], child: Text(t["name"])))
                .toList(),
            onChanged: (val) => setState(() => selectedTeacherId = val),
          ),
          const SizedBox(height: 16),
          _buildDropdown<int>(
            value: selectedSectionId,
            hint: "Select Section",
            icon: Icons.book,
            items: sections
                .map((s) => DropdownMenuItem<int>(
                    value: s["id"],
                    child: Text(
                        "${s["class"]}-${s["section"] ?? s["section_name"] ?? ""}")))
                .toList(),
            onChanged: (val) => setState(() => selectedSectionId = val),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: subjectController,
                  hint: "Subject ...",
                  // No label parameter here so it shows placeholder style
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown<String>(
                  value: selectedRole,
                  hint: "Role",
                  label: "Role",
                  items: const [
                    DropdownMenuItem(
                        value: 'Subject Teacher',
                        child: Text("Subject Teacher")),
                    DropdownMenuItem(
                        value: 'Class Teacher', child: Text("Class Teacher")),
                    DropdownMenuItem(value: 'Mentor', child: Text("Mentor")),
                  ],
                  onChanged: (val) => setState(() => selectedRole = val),
                  hasIcon: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: yearController,
            label: "Academic Year",
            suffixIcon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: isSubmitting ? null : _createLink,
              icon: const Icon(Icons.link, color: Colors.white, size: 20),
              label: isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Create Link",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    IconData? icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? label,
    bool hasIcon = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF673AB7)),
        hintText: label == null ? hint : null,
        hintStyle: const TextStyle(color: Color(0xFF673AB7)),
        prefixIcon: hasIcon && icon != null
            ? Icon(icon, color: const Color(0xFF673AB7))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF673AB7), width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: label != null ? 12 : 16,
        ),
      ),
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      dropdownColor: Colors.white,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    String? label,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF673AB7)),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF673AB7)),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: const Color(0xFF673AB7))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF673AB7), width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildMappingList() {
    if (mappings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.link_off_rounded,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                "No mappings found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: mappings.length,
      itemBuilder: (context, index) {
        final m = mappings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5), // Light purple
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.book, // Matches screenshot's book icon
                  color: Color(0xFF673AB7),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${m["subject_name"]} - ${m["section_name"] ?? m["class"] ?? 'A'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Teacher: ${m["teacher_name"]}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "Role: ${m["role"]?.toString() ?? 'class_teacher'}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.deepOrange.shade400,
                  size: 24,
                ),
                onPressed: () => _confirmDelete(m),
              ),
            ],
          ),
        );
      },
    );
  }
}
