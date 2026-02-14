import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'teacher_chat_screen.dart';

class TeacherStudentListScreen extends StatefulWidget {
  const TeacherStudentListScreen({super.key});

  @override
  State<TeacherStudentListScreen> createState() =>
      _TeacherStudentListScreenState();
}

class _TeacherStudentListScreenState extends State<TeacherStudentListScreen>
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

    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchStudents() async {
    try {
      final response = await _api.get("/api/v1/messages/students");
      if (mounted) {
        setState(() {
          students = response["data"] ?? [];
          loading = false;
        });
        _pageController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // ================= HEADER =================
                Container(
                  padding: const EdgeInsets.only(
                    top: 50,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4A00E0),
                        const Color(0xFF4A00E0).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A00E0).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Student Doubts",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${students.length} Students Pending",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ================= LIST =================
                Padding(
                  padding: const EdgeInsets.only(top: 120),
                  child: students.isEmpty
                      ? const Center(
                          child: Text(
                            "No students found",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : FadeTransition(
                          opacity: _fade,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            itemCount: students.length,
                            itemBuilder: (_, i) {
                              final s = students[i];
                              return _buildStudentCard(s, i);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStudentCard(Map s, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 90),
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
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
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A00E0).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (s["name"]?[0] ?? "S").toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF4A00E0),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s["name"] ?? "Unknown",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Roll: ${s["roll_number"] ?? "-"}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Icon
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A00E0).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF4A00E0),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
