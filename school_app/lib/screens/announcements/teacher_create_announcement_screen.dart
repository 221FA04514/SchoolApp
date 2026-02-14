import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class TeacherCreateAnnouncementScreen extends StatefulWidget {
  const TeacherCreateAnnouncementScreen({super.key});

  @override
  State<TeacherCreateAnnouncementScreen> createState() =>
      _TeacherCreateAnnouncementScreenState();
}

class _TeacherCreateAnnouncementScreenState
    extends State<TeacherCreateAnnouncementScreen> {
  final ApiService _api = ApiService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool submitting = false;

  List<dynamic> sections = [];
  int? selectedSectionId;

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _fetchSections();
=======

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));

    _pageController.forward();
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
  }

  Future<void> _fetchSections() async {
    try {
      final res = await _api.get("/api/v1/sections");
      if (mounted) {
        setState(() {
          sections = res["data"] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching sections: $e");
    }
  }

  Future<void> submit() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ All fields are required")),
      );
      return;
    }

    setState(() => submitting = true);

    try {
      final res = await _api.post("/api/v1/announcements", {
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "section_id": selectedSectionId,
      });

      if (res["success"]) {
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚀 Announcement published successfully!"),
          ),
        );
      }
    } catch (e) {
<<<<<<< HEAD
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to create announcement")),
        );
      }
=======
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to create announcement")),
      );
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                    "📝 Compose Studio",
                    "Draft your message for students",
                  ),
                  const SizedBox(height: 16),
                  _buildSectionSelector(),
                  const SizedBox(height: 16),
                  _buildEditorCard(),
                  const SizedBox(height: 32),
                  _buildPublishButton(),
                ],
              ),
            ),
          ),
        ],
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
          "Create Announcement",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
=======
      backgroundColor: const Color(0xFFF4F6FB),

      // ================= HEADER =================
      appBar: AppBar(
        elevation: 0,
        title: const Text("📢 Create Announcement"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: const Color(0xFF4A00E0)),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E263E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEditorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              hintText: "Headline (e.g. 📢 School Holiday)",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              border: InputBorder.none,
              prefixIcon: const Icon(
                Icons.title_rounded,
                color: Color(0xFF1A4DFF),
              ),
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          TextField(
            controller: _descController,
            maxLines: 8,
            style: const TextStyle(fontSize: 15, height: 1.5),
            decoration: InputDecoration(
              hintText: "📌 Write notice content here...",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A4DFF).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A4DFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: submitting ? null : submit,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (submitting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else ...[
              const Icon(Icons.rocket_launch_rounded),
              const SizedBox(width: 12),
              const Text(
                "Publish Now",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedSectionId,
          hint: const Text("Select Targeted Section (Required)"),
          isExpanded: true,
          items: sections.map((s) {
            return DropdownMenuItem<int>(
              value: s["id"],
              child: Text("Section ${s["name"]}"),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => selectedSectionId = val);
          },
        ),
      ),
    );
  }
}
