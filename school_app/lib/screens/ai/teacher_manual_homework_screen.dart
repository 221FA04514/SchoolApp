import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class TeacherManualHomeworkScreen extends StatefulWidget {
  const TeacherManualHomeworkScreen({super.key});

  @override
  State<TeacherManualHomeworkScreen> createState() =>
      _TeacherManualHomeworkScreenState();
}

class _TeacherManualHomeworkScreenState
    extends State<TeacherManualHomeworkScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subjectController = TextEditingController();
  List<dynamic> _sections = [];
  String? _selectedSectionId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 2));
  bool _isOffline = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      final response = await ApiService().get("/api/v1/results/sections");
      setState(() {
        _sections = response["data"] ?? [];
      });
    } catch (e) {
      print("Error loading sections: $e");
    }
  }

  void _save() async {
    if (_titleController.text.isEmpty || _selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Section are required")),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      await ApiService().post("/api/v1/homework", {
        "title": _titleController.text,
        "description": _descController.text,
        "subject": _subjectController.text,
        "section_id": int.tryParse(_selectedSectionId!),
        "due_date": _dueDate.toIso8601String(),
        "is_offline": _isOffline,
      });

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Homework created!")));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manual Homework")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Homework Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: "Subject"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Description / Instructions",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSectionId,
              decoration: const InputDecoration(labelText: "Select Section"),
              items: _sections
                  .map(
                    (s) => DropdownMenuItem(
                      value: s["id"].toString(),
                      child: Text(s["name"] ?? "S-${s['id']}"),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedSectionId = val),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text("Offline Mode (No file submission)"),
              subtitle: const Text("Use this for physical book work"),
              value: _isOffline,
              onChanged: (val) => setState(() => _isOffline = val),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Submit Homework"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
