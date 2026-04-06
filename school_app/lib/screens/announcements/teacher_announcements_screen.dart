import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../models/announcement_model.dart';
import 'teacher_create_announcement_screen.dart';

class TeacherAnnouncementsScreen extends StatefulWidget {
  const TeacherAnnouncementsScreen({super.key});

  @override
  State<TeacherAnnouncementsScreen> createState() =>
      _TeacherAnnouncementsScreenState();
}
class _TeacherAnnouncementsScreenState
    extends State<TeacherAnnouncementsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();

  List<Announcement> announcements = [];
  bool loading = true;

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchAnnouncements() async {
    final res = await _api.get("/api/v1/announcements/teacher");

    setState(() {
      announcements = (res["data"] as List)
          .map((a) => Announcement.fromJson(a))
          .toList();
      loading = false;
    });

    _controller.forward(from: 0);
  }

  String _getEmoji(String title) {
    final t = title.toLowerCase();
    if (t.contains("exam")) return "📝";
    if (t.contains("holiday")) return "🏖️";
    if (t.contains("event")) return "🎉";
    if (t.contains("fee")) return "💰";
    return "📢";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          // Curved Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4A00E0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        "My Announcements",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : announcements.isEmpty
                          ? const Center(
                              child: Text(
                                "📭 No announcements yet",
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          : FadeTransition(
                              opacity: _fade,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: announcements.length,
                                itemBuilder: (_, i) {
                                  final a = announcements[i];

                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration:
                                        Duration(milliseconds: 400 + i * 120),
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
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF4A00E0)
                                                .withOpacity(0.06),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // EMOJI
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4A00E0)
                                                  .withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _getEmoji(a.title),
                                              style:
                                                  const TextStyle(fontSize: 24),
                                            ),
                                          ),
                                          const SizedBox(width: 16),

                                          // CONTENT
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  a.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  a.description,
                                                  style: const TextStyle(
                                                      color: Colors.black87),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.schedule,
                                                      size: 14,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "${a.createdAt.day}/${a.createdAt.month}/${a.createdAt.year}",
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fade,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF4A00E0),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () async {
            final created = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TeacherCreateAnnouncementScreen(),
              ),
            );

            if (created == true) {
              setState(() => loading = true);
              fetchAnnouncements();
            }
          },
        ),
      ),
    );
  }
}
