import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'chat_screen.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  bool loading = true;
  List teachers = [];

  late AnimationController _pageController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    fetchTeachers();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchTeachers() async {
    try {
      final response = await _api.get("/api/v1/messages/teachers");
      setState(() {
        teachers = response["data"];
        loading = false;
      });
      _pageController.forward();
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Color _subjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains("math")) return Colors.blue;
    if (s.contains("science")) return Colors.green;
    if (s.contains("english")) return Colors.purple;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
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
                    const Text(
                      "Select Teacher",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Search or descriptive text could go here
                Text(
                  "Choose a teacher to resolve doubts",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // ================= LIST =================
          Padding(
            padding: const EdgeInsets.only(top: 130),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : teachers.isEmpty
                ? const Center(
                    child: Text(
                      "😔 No teachers available",
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        itemCount: teachers.length,
                        itemBuilder: (context, index) {
                          final t = teachers[index];
                          final color = _subjectColor(t["subject"]);

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 400 + index * 120),
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
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "👨‍🏫",
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                title: Text(
                                  t["name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  "📘 ${t["subject"]}",
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F6FB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Color(0xFF4A00E0),
                                    size: 20,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        teacherId: t["id"],
                                        teacherName: t["name"],
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
                  ),
          ),
        ],
      ),
    );
  }
}
