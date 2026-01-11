import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../models/homework_model.dart';
import 'teacher_create_homework_screen.dart';

class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen>
    with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  bool loading = true;
  List homeworkList = [];

  late AnimationController _pageController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    fetchHomework();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchHomework() async {
    try {
      final res = await _api.get("/api/v1/homework/teacher");
      setState(() {
        homeworkList = res["data"] ?? [];
        loading = false;
      });
      _pageController.forward();
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          // ================= HEADER =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          // ================= CONTENT =================
          SafeArea(
            child: Column(
              children: [
                // APP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const BackButton(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "My Homework",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : FadeTransition(
                          opacity: _fade,
                          child: homeworkList.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No homework posted yet 📚",
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: homeworkList.length,
                                  itemBuilder: (context, index) {
                                    final h = homeworkList[index];
                                    return _buildHomeworkCard(h);
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TeacherCreateHomeworkScreen(),
            ),
          );

          if (created == true) {
            setState(() => loading = true);
            _pageController.reset();
            fetchHomework();
          }
        },
        backgroundColor: const Color(0xFF6A11CB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Create New",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHomeworkCard(dynamic h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF6A11CB).withOpacity(0.05),
              child: Row(
                children: [
                  const Icon(
                    Icons.class_rounded,
                    size: 16,
                    color: Color(0xFF6A11CB),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Section: ${h["section"] ?? 'N/A'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF6A11CB),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Due: ${h["due_date"] ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                h["title"] ?? "Untitled",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  h["description"] ?? "No description provided",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
