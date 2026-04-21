import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class TeacherMarksEntryScreen extends StatefulWidget {
  final int examId;
  final String examName;
  final int sectionId;

  const TeacherMarksEntryScreen({
    super.key,
    required this.examId,
    required this.examName,
    required this.sectionId,
  });

  @override
  State<TeacherMarksEntryScreen> createState() =>
      _TeacherMarksEntryScreenState();
}

class _TeacherMarksEntryScreenState extends State<TeacherMarksEntryScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _students = [];
  bool _isLoading = true;
  String? _selectedSubject;
  List<String> _availableSubjects = [];
  final Map<int, TextEditingController> _marksControllers = {};
  final Map<int, TextEditingController> _remarksControllers = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final res = await _api.get("/api/v1/results/teacher-subjects/${widget.sectionId}");
      setState(() {
        _availableSubjects = List<String>.from(res["data"] ?? []);
        if (_availableSubjects.isNotEmpty) {
          _selectedSubject = _availableSubjects.first;
        }
      });
    } catch (e) {
      debugPrint("Error loading subjects: $e");
    }
  }

  Future<void> _loadStudents() async {
    try {
      final response = await _api.get(
        "/api/v1/results/exam-marks/${widget.examId}/${widget.sectionId}",
      );
      setState(() {
        _students = response["data"] ?? [];
        for (var s in _students) {
          _marksControllers[s["id"]] = TextEditingController(
            text: s["marks"]?.toString() ?? "",
          );
          _remarksControllers[s["id"]] = TextEditingController(
            text: s["remarks"] ?? "",
          );
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

  void _submitMarks() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> marksList = [];
      _marksControllers.forEach((studentId, controller) {
        if (controller.text.isNotEmpty) {
          marksList.add({
            "student_id": studentId,
            "marks": double.tryParse(controller.text) ?? 0,
            "remarks": _remarksControllers[studentId]?.text ?? "",
            "grade": _calculateGrade(double.tryParse(controller.text) ?? 0),
          });
        }
      });

      if (marksList.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      if (_selectedSubject == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a subject first")));
        return;
      }

      await _api.post("/api/v1/results/bulk-marks", {
        "exam_id": widget.examId,
        "subject": _selectedSubject,
        "marks_list": marksList,
      });

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marks uploaded successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
  }

  String _calculateGrade(double marks) {
    if (marks >= 90) return "A+";
    if (marks >= 80) return "A";
    if (marks >= 70) return "B";
    if (marks >= 60) return "C";
    if (marks >= 50) return "D";
    return "F";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marking: ${widget.examName}"),
        actions: [
          IconButton(onPressed: _submitMarks, icon: const Icon(Icons.save)),
        ],
      ),
      body: Column(
        children: [
          if (_availableSubjects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  labelText: "Subject",
                  prefixIcon: const Icon(Icons.book_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _availableSubjects.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSubject = val),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text("No students found in this section"))
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                final student = _students[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${student['roll_no'] ?? index + 1}. ${student['name']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _marksControllers[student["id"]],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Marks",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _remarksControllers[student["id"]],
                                decoration: const InputDecoration(
                                  labelText: "Remarks",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
