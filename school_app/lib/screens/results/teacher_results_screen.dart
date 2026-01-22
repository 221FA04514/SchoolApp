import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'teacher_marks_entry_screen.dart';

class TeacherResultsScreen extends StatefulWidget {
  const TeacherResultsScreen({super.key});

  @override
  State<TeacherResultsScreen> createState() => _TeacherResultsScreenState();
}

class _TeacherResultsScreenState extends State<TeacherResultsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _exams = [];
  List<dynamic> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      final response = await _api.get("/api/v1/results/sections");
      setState(() {
        _sections = response["data"] ?? [];
      });
    } catch (e) {}
  }

  Future<void> _loadExams() async {
    try {
      final response = await _api.get("/api/v1/results/list");
      setState(() {
        _exams = response["data"] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _togglePublish(int examId, bool currentStatus) async {
    try {
      await _api.post("/api/v1/results/toggle-publish", {
        "examId": examId,
        "isPublished": !currentStatus,
      });
      _loadExams();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Result ${!currentStatus ? 'published' : 'unpublished'}!",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Result Management"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A4DFF), Color(0xFF6A11CB)],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateExamDialog,
        icon: const Icon(Icons.add),
        label: const Text("Create Exam"),
        backgroundColor: const Color(0xFF1A4DFF),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
          ? const Center(child: Text("No exams recorded yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exams.length,
              itemBuilder: (context, index) {
                final exam = _exams[index];
                final isPublished =
                    exam["is_published"] == 1 || exam["is_published"] == true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEEF2FF),
                          child: Icon(
                            Icons.description_outlined,
                            color: Color(0xFF1A4DFF),
                          ),
                        ),
                        title: Text(exam["name"] ?? "Exam"),
                        subtitle: Text("Date: ${exam["exam_date"] ?? 'N/A'}"),
                        trailing: Switch(
                          value: isPublished,
                          activeColor: Colors.green,
                          onChanged: (val) =>
                              _togglePublish(exam["id"], isPublished),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Text(
                              isPublished ? "✅ PUBLIC" : "🔒 DRAFT",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isPublished ? Colors.green : Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TeacherMarksEntryScreen(
                                          examId: exam["id"],
                                          examName: exam["name"],
                                          sectionId:
                                              exam["section_id"] ??
                                              1, // Fallback
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text("Upload Marks"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showCreateExamDialog() {
    final nameController = TextEditingController();
    final classController = TextEditingController();
    final totalController = TextEditingController(text: "100");
    final passController = TextEditingController(text: "35");
    String? selectedSectionId;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Create New Exam"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Exam Name"),
                ),
                TextField(
                  controller: classController,
                  decoration: const InputDecoration(
                    labelText: "Class (Optional)",
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: selectedSectionId,
                  decoration: const InputDecoration(
                    labelText: "Target Section",
                  ),
                  items: _sections.map((s) {
                    return DropdownMenuItem<String>(
                      value: s["id"].toString(),
                      child: Text(s["name"]),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedSectionId = val),
                ),
                TextField(
                  controller: totalController,
                  decoration: const InputDecoration(labelText: "Total Marks"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: passController,
                  decoration: const InputDecoration(labelText: "Passing Marks"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text("Date: ${selectedDate.toString().split(' ')[0]}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null)
                      setDialogState(() => selectedDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedSectionId == null) return;
                try {
                  await _api.post("/api/v1/results/exam", {
                    "name": nameController.text,
                    "className": classController.text,
                    "section_id": int.tryParse(selectedSectionId!),
                    "total_marks": int.tryParse(totalController.text),
                    "passing_marks": int.tryParse(passController.text),
                    "exam_date": selectedDate.toIso8601String(),
                  });
                  Navigator.pop(context);
                  _loadExams();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}
