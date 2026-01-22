import 'package:flutter/material.dart';
import '../../core/api/teacher_ai_service.dart';
import '../../core/api/api_service.dart';

class TeacherHomeworkGenScreen extends StatefulWidget {
  const TeacherHomeworkGenScreen({super.key});

  @override
  State<TeacherHomeworkGenScreen> createState() =>
      _TeacherHomeworkGenScreenState();
}

class _TeacherHomeworkGenScreenState extends State<TeacherHomeworkGenScreen> {
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  List<dynamic> _sections = [];
  String? _selectedSectionId;
  String _difficulty = "medium";
  int _count = 5;
  List<Map<String, dynamic>> _questions = [];
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

  void _generate() async {
    if (_subjectController.text.isEmpty || _topicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter subject and topic")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _questions = [];
    });

    try {
      final questions = await TeacherAiService().generateHomework(
        subject: _subjectController.text,
        topic: _topicController.text,
        difficulty: _difficulty,
        count: _count,
      );

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  final _durationController = TextEditingController(text: "30");
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _endTime = DateTime.now().add(const Duration(hours: 3));

  void _saveHomework() async {
    if (_questions.isEmpty) return;
    if (_selectedSectionId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a section")));
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Create Online Exam instead of Homework
      await ApiService().post("/api/v1/online-exams/create", {
        "title": "${_subjectController.text}: ${_topicController.text}",
        "subject": _subjectController.text,
        "section_id": int.tryParse(_selectedSectionId!),
        "start_time": _startTime.toIso8601String(),
        "end_time": _endTime.toIso8601String(),
        "duration_mins": int.tryParse(_durationController.text) ?? 30,
        "total_marks": _questions.length, // 1 mark per question for now
        "questions": _questions
            .map(
              (q) => {
                "question_text": q["question"],
                "answer_text": q["answer"],
                "options_json": q["options"], // If the AI provided them
                "marks": 1,
              },
            )
            .toList(),
      });

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Smart Exam posted for your students!")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to post: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Exam Generator"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A4DFF), Color(0xFF6A11CB)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputSection(),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_questions.isNotEmpty)
              _buildQuestionsList(),
          ],
        ),
      ),
      bottomNavigationBar: _questions.isNotEmpty && !_isLoading
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _saveHomework,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A4DFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Post Exam to Class",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInputSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: "Subject",
                hintText: "e.g. Mathematics",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: "Topic",
                hintText: "e.g. Quadratic Equations",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSectionId,
              decoration: const InputDecoration(labelText: "Select Section"),
              items: _sections.map((s) {
                return DropdownMenuItem<String>(
                  value: s["id"].toString(),
                  child: Text(s["name"] ?? "Section ${s['id']}"),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedSectionId = val),
            ),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duration (Minutes)",
                hintText: "e.g. 30",
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Difficulty: "),
                const SizedBox(width: 8),
                _diffChip("easy"),
                _diffChip("medium"),
                _diffChip("hard"),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generate,
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Generate Questions"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _diffChip(String label) {
    bool selected = _difficulty == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
        selected: selected,
        onSelected: (val) => setState(() => _difficulty = label),
        selectedColor: const Color(0xFF1A4DFF),
      ),
    );
  }

  Widget _buildQuestionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Generated Preview",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._questions.map(
          (q) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Q: ${q['question']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  Text(
                    "A: ${q['answer']}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
