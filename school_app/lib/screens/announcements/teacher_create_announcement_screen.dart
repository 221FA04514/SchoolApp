import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class TeacherCreateAnnouncementScreen extends StatefulWidget {
  const TeacherCreateAnnouncementScreen({super.key});

  @override
  State<TeacherCreateAnnouncementScreen> createState() =>
      _TeacherCreateAnnouncementScreenState();
}

class _TeacherCreateAnnouncementScreenState
    extends State<TeacherCreateAnnouncementScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  bool submitting = false;

  late AnimationController _pageController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOut),
    );

    _pageController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _pageController.dispose();
    super.dispose();
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
      await _api.post("/api/v1/announcements", {
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("❌ Failed to create announcement")),
      );
    } finally {
      setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // ================= HEADER =================
      appBar: AppBar(
        elevation: 0,
        title: const Text("📢 Create Announcement"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A4DFF),
                Color(0xFF3A6BFF),
                Color(0xFF6A11CB),
              ],
            ),
          ),
        ),
      ),

      // ================= BODY =================
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ================= TITLE FIELD =================
                Container(
                  decoration: _cardDecoration(),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.title),
                      hintText: "📌 Announcement Title",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ================= DESCRIPTION FIELD =================
                Container(
                  decoration: _cardDecoration(),
                  child: TextField(
                    controller: _descController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.description),
                      hintText: "📝 Write announcement details...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ================= PUBLISH BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: submitting ? null : submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: const Color(0xFF1A4DFF),
                    ),
                    child: submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "🚀 Publish Announcement",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= CARD DECORATION =================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
