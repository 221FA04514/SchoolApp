import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'student_exam_portal_screen.dart';
import 'student_exam_review_screen.dart';

class StudentOnlineExamListScreen extends StatefulWidget {
  const StudentOnlineExamListScreen({super.key});

  @override
  State<StudentOnlineExamListScreen> createState() =>
      _StudentOnlineExamListScreenState();
}

class _StudentOnlineExamListScreenState
    extends State<StudentOnlineExamListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _exams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    try {
      final response = await _api.get("/api/v1/online-exams/list");
      setState(() {
        _exams = response["data"] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _startExam(dynamic exam) async {
    if (exam["attempt_status"] == 'submitted' ||
        exam["attempt_status"] == 'locked') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already attempted this exam.")),
      );
      return;
    }

    // Confirm start
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Start ${exam['title']}?"),
        content: Text(
          "Duration: ${exam['duration_mins']} mins\nOnce started, you must complete it. Exiting will lock the exam.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Start Now"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final startRes = await _api.post("/api/v1/online-exams/attempt", {
          "examId": exam["id"],
        });
        int attemptId = startRes["data"]["attemptId"];

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentExamPortalScreen(
              examId: exam["id"],
              attemptId: attemptId,
              title: exam["title"],
              durationMins: exam["duration_mins"],
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to start: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Online Exams"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: const Color(0xFF4A00E0)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
          ? const Center(child: Text("No exams scheduled for your section"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exams.length,
              itemBuilder: (context, index) {
                final exam = _exams[index];
                bool isAttempted = exam["attempt_status"] != null;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      exam["title"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text("Subject: ${exam['subject']}"),
                        Text("Duration: ${exam['duration_mins']} mins"),
                        Text("Deadline: ${exam['end_time']}"),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (exam["attempt_status"] == 'submitted') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentExamReviewScreen(
                                examId: exam["id"],
                                title: exam["title"],
                              ),
                            ),
                          );
                        } else if (isAttempted) {
                          return; // Do nothing if locked/started but not resume-able yet
                        } else {
                          _startExam(exam);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: exam["attempt_status"] == 'submitted'
                            ? Colors.green
                            : isAttempted
                            ? Colors.grey
                            : const Color(0xFF1A4DFF),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        exam["attempt_status"] == 'submitted'
                            ? "Review"
                            : isAttempted
                            ? "Attempted"
                            : "Start",
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
