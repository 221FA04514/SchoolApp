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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // ================= HEADER =================
      body: Column(
        children: [
          SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Container(
                height: size.height * 0.22,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1A4DFF),
                      Color(0xFF3A6BFF),
                      Color(0xFF6A11CB),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: SafeArea(
                  child: Row(
                    children: const [
                      BackButton(color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "👨‍🏫 Select Teacher",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ================= LIST =================
          Expanded(
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
                            padding: const EdgeInsets.all(16),
                            itemCount: teachers.length,
                            itemBuilder: (context, index) {
                              final t = teachers[index];
                              final color =
                                  _subjectColor(t["subject"]);

                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(
                                    milliseconds: 400 + index * 120),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset:
                                          Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withOpacity(0.2),
                                        blurRadius: 14,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: const Text(
                                      "👨‍🏫",
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    title: Text(
                                      t["name"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "📘 ${t["subject"]}",
                                      style: TextStyle(color: color),
                                    ),
                                    trailing: Container(
                                      padding:
                                          const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            color,
                                            color.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline,
                                        color: Colors.white,
                                        size: 18,
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
