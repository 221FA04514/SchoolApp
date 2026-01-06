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

  Future<void> submit() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
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
        const SnackBar(content: Text("Failed to create announcement")),
      );
    } finally {
      setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Announcement")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitting ? null : submit,
                child: submitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Publish"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
