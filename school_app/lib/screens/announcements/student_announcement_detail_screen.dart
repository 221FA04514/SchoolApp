import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class StudentAnnouncementDetailScreen extends StatefulWidget {
  final int announcementId;

  const StudentAnnouncementDetailScreen({
    super.key,
    required this.announcementId,
  });

  @override
  State<StudentAnnouncementDetailScreen> createState() =>
      _StudentAnnouncementDetailScreenState();
}

class _StudentAnnouncementDetailScreenState
    extends State<StudentAnnouncementDetailScreen> {
  final ApiService _api = ApiService();
  Map announcement = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAnnouncement();
  }

  Future<void> fetchAnnouncement() async {
    try {
      final res = await _api.get(
        "/api/v1/announcements/${widget.announcementId}",
      );

      setState(() {
        announcement = res["data"];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load announcement")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Announcement")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement["title"],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    announcement["description"],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Posted on: ${announcement["created_at"].toString().split("T")[0]}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
