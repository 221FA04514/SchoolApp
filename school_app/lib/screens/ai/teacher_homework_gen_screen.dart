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
  bool _allowCopy = false;

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

  void _generate({bool append = false}) async {
    if (_subjectController.text.isEmpty || _topicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter subject and topic")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      if (!append) _questions = [];
    });

    try {
      final questions = await TeacherAiService().generateHomework(
        subject: _subjectController.text,
        topic: _topicController.text,
        difficulty: _difficulty,
        count: _count,
      );

      setState(() {
        if (append) {
          _questions.addAll(questions);
        } else {
          _questions = questions;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _showManualQuestionDialog() {
    final qController = TextEditingController();
    final aController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Manual Question"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              decoration: const InputDecoration(
                labelText: "Question",
                hintText: "Enter the question here",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: aController,
              decoration: const InputDecoration(
                labelText: "Answer",
                hintText: "Enter the answer here",
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (qController.text.isNotEmpty && aController.text.isNotEmpty) {
                setState(() {
                  _questions.add({
                    "question": qController.text,
                    "answer": aController.text,
                    "options": [],
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  final _durationController = TextEditingController(text: "30");
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _endTime = DateTime.now().add(const Duration(hours: 3));

  void _editQuestion(int index) {
    final q = _questions[index];
    final questionController = TextEditingController(text: q["question"]);
    final answerController = TextEditingController(text: q["answer"]);
    String type = q["type"] ?? "mcq";
    List<String> options = List<String>.from(q["options"] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Question"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: "Type"),
                  items: const [
                    DropdownMenuItem(value: "mcq", child: Text("MCQ")),
                    DropdownMenuItem(
                      value: "fib",
                      child: Text("Fill in Blank"),
                    ),
                  ],
                  onChanged: (val) => setState(() => type = val!),
                ),
                TextField(
                  controller: questionController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Question"),
                ),
                if (type == "mcq") ...[
                  const SizedBox(height: 12),
                  const Text(
                    "Options:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...options.asMap().entries.map((entry) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (val) => options[entry.key] = val,
                            decoration: InputDecoration(
                              labelText: "Option ${entry.key + 1}",
                            ),
                            controller: TextEditingController(text: entry.value)
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: entry.value.length),
                              ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () =>
                              setState(() => options.removeAt(entry.key)),
                        ),
                      ],
                    );
                  }).toList(),
                  TextButton.icon(
                    onPressed: () => setState(() => options.add("")),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Option"),
                  ),
                ],
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: "Correct Answer",
                  ),
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
              onPressed: () {
                this.setState(() {
                  _questions[index] = {
                    "question": questionController.text,
                    "answer": answerController.text,
                    "type": type,
                    "options": type == "mcq" ? options : null,
                  };
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        "question": "New Question",
        "answer": "",
        "type": "mcq",
        "options": ["", "", "", ""],
      });
    });
    _editQuestion(_questions.length - 1);
  }

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
      await ApiService().post("/api/v1/online-exams/create", {
        "title": "${_subjectController.text}: ${_topicController.text}",
        "subject": _subjectController.text,
        "section_id": int.tryParse(_selectedSectionId!),
        "start_time": _startTime.toIso8601String(),
        "end_time": _endTime.toIso8601String(),
        "duration_mins": int.tryParse(_durationController.text) ?? 30,
<<<<<<< HEAD
        "total_marks": _questions.length,
=======
        "total_marks": _questions.length, // 1 mark per question for now
        "allow_copy": _allowCopy,
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        "questions": _questions
            .map(
              (q) => {
                "question_text": q["question"],
                "answer_text": q["answer"],
                "options_json": q["options"],
                "marks": 1,
              },
            )
            .toList(),
      });

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exam posted successfully!")),
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
          decoration: const BoxDecoration(color: const Color(0xFF4A00E0)),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: "Subject",
                hintText: "e.g. Mathematics",
                prefixIcon: Icon(Icons.book_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: "Topic",
                hintText: "e.g. Quadratic Equations",
                prefixIcon: Icon(Icons.topic_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSectionId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Select Section",
                prefixIcon: Icon(Icons.class_outlined),
              ),
              items: _sections.map((s) {
                return DropdownMenuItem<String>(
                  value: s["id"].toString(),
                  child: Text(
                    s["name"] ?? "Section ${s['id']}",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedSectionId = val),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duration (Minutes)",
                hintText: "e.g. 30",
                prefixIcon: Icon(Icons.timer_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Difficulty",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _diffChip("easy"),
                _diffChip("medium"),
                _diffChip("hard"),
              ],
            ),
<<<<<<< HEAD
            const SizedBox(height: 24),
=======
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text("Allow Text Copying"),
              subtitle: const Text("Students can select/copy question text"),
              value: _allowCopy,
              onChanged: (val) => setState(() => _allowCopy = val),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _generate(append: false),
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Generate Questions"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Review Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              tooltip: "Add Question",
            ),
          ],
        ),
        const SizedBox(height: 12),
<<<<<<< HEAD
        ..._questions.asMap().entries.map((entry) {
          final index = entry.key;
          final q = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              title: Text(
                "${index + 1}. ${q['question']}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    "Type: ${(q['type'] ?? 'mcq').toString().toUpperCase()}",
                    style: const TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                  Text(
                    "A: ${q['answer']}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
=======
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final q = _questions[index];
            return Card(
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "Q${index + 1}: ${q['question']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeQuestion(index),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      "A: ${q['answer']}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : () => _generate(append: true),
                icon: const Icon(Icons.refresh),
                label: const Text("Generate More"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF1A4DFF)),
                ),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editQuestion(index),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: () => setState(() => _questions.removeAt(index)),
                  ),
                ],
              ),
            ),
<<<<<<< HEAD
          );
        }),
=======
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showManualQuestionDialog,
                icon: const Icon(Icons.add),
                label: const Text("Manual Entry"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.green),
                  foregroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 80), // Space for FAB/BottomBar
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
      ],
    );
  }
}
