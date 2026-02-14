import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageSectionsScreen extends StatefulWidget {
  const ManageSectionsScreen({super.key});

  @override
  State<ManageSectionsScreen> createState() => _ManageSectionsScreenState();
}

class _ManageSectionsScreenState extends State<ManageSectionsScreen> {
  final ApiService _api = ApiService();
  List sections = [];
  bool isLoading = true;

  // Theme Color
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple

  @override
  void initState() {
    super.initState();
    fetchSections();
  }

  Future<void> fetchSections() async {
    try {
      final res = await _api.get("/api/v1/admin/sections");
      if (mounted) {
        setState(() {
          sections = res["data"] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
<<<<<<< HEAD
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildSectionList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSectionDialog,
        backgroundColor: const Color(0xFF1A4DFF),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Create Section",
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
          "Sections Hub 📁",
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

  Widget _buildSectionList() {
    if (sections.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            "No sections available",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final s = sections[index];
          return _buildSectionCard(s);
        }, childCount: sections.length),
      ),
    );
  }

  Widget _buildSectionCard(Map s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1A4DFF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF1A4DFF),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s["name"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E263E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Standard Academic Section",
                    style: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
              onPressed: () => _handleDeleteSection(s),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteSection(Map s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Section"),
        content: Text("Are you sure you want to delete section ${s["name"]}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final res = await _api.delete("/api/v1/admin/sections/${s["id"]}");
        if (res["success"]) {
          fetchSections();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
=======
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
    }
  }

  void _showAddSectionDialog() {
    final classController = TextEditingController();
    final sectionController = TextEditingController();

    showModalBottomSheet(
      context: context,
<<<<<<< HEAD
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
=======
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Create Section", style: TextStyle(color: primaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: classController,
              decoration: InputDecoration(
                labelText: "Class (e.g. 10)",
                labelStyle: TextStyle(color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: sectionController,
              decoration: InputDecoration(
                labelText: "Section (e.g. A)",
                labelStyle: TextStyle(color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create New Section",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                classController,
                "Class Number (e.g. 10)",
                Icons.school_outlined,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                sectionController,
                "Section Name (e.g. A)",
                Icons.grid_view_outlined,
                textCapitalization: TextCapitalization.characters,
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
                    if (classController.text.isEmpty ||
                        sectionController.text.isEmpty) {
                      return;
                    }
                    try {
                      final res = await _api.post("/api/v1/admin/sections", {
                        "class": classController.text,
                        "section": sectionController.text,
                      });
                      if (res["success"]) {
                        if (mounted) Navigator.pop(context);
                        fetchSections();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  child: const Text(
                    "Create Section",
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
<<<<<<< HEAD
        ),
=======
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (classController.text.isEmpty ||
                  sectionController.text.isEmpty)
                return;
              try {
                final res = await _api.post("/api/v1/admin/sections", {
                  "class": classController.text,
                  "section": sectionController.text,
                });
                if (res["success"]) {
                  if (mounted) Navigator.pop(context);
                  fetchSections();
                }
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Create", style: TextStyle(color: Colors.white)),
          ),
        ],
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
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
  @override
  Widget build(BuildContext context) {
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
                  color: primaryColor, // Solid
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Manage Sections",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : sections.isEmpty
                    ? const Center(
                        child: Text(
                          "No sections found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: sections.length,
                        itemBuilder: (context, index) {
                          final s = sections[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${s['class']}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              title: Text(
                                "Class ${s['class']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                "Section ${s['section']}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(s),
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
        onPressed: _showAddSectionDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Section", style: TextStyle(color: Colors.white)),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
      ),
    );
  }

  Future<void> _confirmDelete(Map s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Section"),
        content: const Text("Are you sure you want to delete this section?"),
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
        final res = await _api.delete("/api/v1/admin/sections/${s["id"]}");
        if (res["success"]) {
          fetchSections();
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
