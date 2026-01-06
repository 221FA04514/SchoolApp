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
    extends State<TeacherAnnouncementsScreen> {
  final ApiService _api = ApiService();
  List<Announcement> announcements = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    final res = await _api.get("/api/v1/announcements/teacher");

    setState(() {
      announcements = (res["data"] as List)
          .map((a) => Announcement.fromJson(a))
          .toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Announcements")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : announcements.isEmpty
              ? const Center(child: Text("No announcements yet"))
              : ListView.builder(
                  itemCount: announcements.length,
                  itemBuilder: (_, i) {
                    final a = announcements[i];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          a.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          a.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          "${a.createdAt.day}/${a.createdAt.month}/${a.createdAt.year}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
