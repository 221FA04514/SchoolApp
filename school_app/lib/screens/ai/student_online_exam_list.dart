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
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          // Curved Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4A00E0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const BackButton(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Online Exams",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _exams.isEmpty
                          ? const Center(
                              child: Text("No exams scheduled for your section"))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _exams.length,
                              itemBuilder: (context, index) {
                                final exam = _exams[index];
                                bool isAttempted = exam["attempt_status"] != null;

                                return Card(
                                  elevation: 2,
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
                                        Text(
                                            "Duration: ${exam['duration_mins']} mins"),
                                        Text("Deadline: ${exam['end_time']}"),
                                      ],
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        if (exam["attempt_status"] ==
                                            'submitted') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  StudentExamReviewScreen(
                                                examId: exam["id"],
                                                title: exam["title"],
                                              ),
                                            ),
                                          );
                                        } else if (isAttempted) {
                                          return;
                                        } else {
                                          _startExam(exam);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            exam["attempt_status"] == 'submitted'
                                                ? Colors.green
                                                : isAttempted
                                                    ? Colors.grey
                                                    : const Color(0xFF4A00E0),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
