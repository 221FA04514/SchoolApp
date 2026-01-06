import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class TeacherCreateHomeworkScreen extends StatefulWidget {
  const TeacherCreateHomeworkScreen({super.key});

  @override
  State<TeacherCreateHomeworkScreen> createState() =>
      _TeacherCreateHomeworkScreenState();
}

class _TeacherCreateHomeworkScreenState
    extends State<TeacherCreateHomeworkScreen> {
  final ApiService _api = ApiService();

  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _subject = TextEditingController();
  final _sectionId = TextEditingController();
  final _dueDate = TextEditingController();

  bool loading = false;

  Future<void> submit() async {
    if (_title.text.isEmpty ||
        _desc.text.isEmpty ||
        _subject.text.isEmpty ||
        _sectionId.text.isEmpty ||
        _dueDate.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields required")),
      );
      return;
    }

    setState(() => loading = true);

    await _api.post("/api/v1/homework", {
      "title": _title.text,
      "description": _desc.text,
      "subject": _subject.text,
      "section_id": int.parse(_sectionId.text),
      "due_date": _dueDate.text,
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Homework")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: _subject, decoration: const InputDecoration(labelText: "Subject")),
            TextField(controller: _sectionId, decoration: const InputDecoration(labelText: "Section ID")),
            TextField(controller: _dueDate, decoration: const InputDecoration(labelText: "Due Date (YYYY-MM-DD)")),
            TextField(
              controller: _desc,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Publish Homework"),
            ),
          ],
        ),
      ),
    );
  }
}
