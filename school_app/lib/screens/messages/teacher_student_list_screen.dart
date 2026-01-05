import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'teacher_chat_screen.dart';

class TeacherStudentListScreen extends StatefulWidget {
  const TeacherStudentListScreen({super.key});

  @override
  State<TeacherStudentListScreen> createState() =>
      _TeacherStudentListScreenState();
}

class _TeacherStudentListScreenState
    extends State<TeacherStudentListScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  List students = [];
  bool loading = true;

  late AnimationController _pageController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    fetchStudents();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchStudents() async {
    final response = await _api.get("/api/v1/messages/students");
    setState(() {
      students = response["data"];
      loading = false;
    });

    _pageController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // ================= HEADER =================
      appBar: AppBar(
        elevation: 0,
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
        title: const Text(
          "👨‍🎓 Student Doubts",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ================= BODY =================
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(
                  child: Text(
                    "💬 No student doubts yet",
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : FadeTransition(
                  opacity: _fade,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (_, i) {
                      final s = students[i];

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration:
                            Duration(milliseconds: 350 + i * 90),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),

                            // 👨‍🎓 AVATAR
                            leading: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(0xFF1A4DFF),
                              child: Text(
                                "👨‍🎓",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),

                            // 📛 NAME
                            title: Text(
                              s["name"],
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // 📚 ROLL
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(top: 4),
                              child: Text(
                                "📚 Roll No: ${s["roll_number"]}",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            // 💬 CHAT ICON
                            trailing: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1A4DFF),
                                    Color(0xFF3A6BFF),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.chat,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TeacherChatScreen(
                                    studentId: s["id"],
                                    studentName: s["name"],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
