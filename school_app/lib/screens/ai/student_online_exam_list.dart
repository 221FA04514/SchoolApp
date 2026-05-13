import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  /// Helper to safely parse potentially timezone-less dates from DB as UTC
  DateTime? _parseUtcToLocal(dynamic raw) {
    if (raw == null) return null;
    try {
      String rawStr = raw.toString();
      // If no timezone indicator, assume UTC
      if (!rawStr.endsWith('Z') && !rawStr.contains('+')) {
        rawStr = rawStr.replaceAll(' ', 'T') + 'Z';
      }
      return DateTime.parse(rawStr).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Parses a raw ISO-8601 UTC string and formats it as local time.
  String _formatDateTime(dynamic raw) {
    final dt = _parseUtcToLocal(raw);
    if (dt == null) return raw?.toString() ?? '—';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  /// Returns a color based on how close the deadline is.
  Color _deadlineColor(dynamic raw) {
    final dt = _parseUtcToLocal(raw);
    if (dt == null) return Colors.grey;
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return Colors.red.shade700;
    if (diff.inMinutes <= 30) return Colors.orange.shade700;
    return Colors.grey.shade700;
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

    final dt = _parseUtcToLocal(exam['end_time']);
    if (dt != null && dt.difference(DateTime.now()).isNegative) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("This exam has already ended and was missed.")),
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
                  child: RefreshIndicator(
                    onRefresh: _loadExams,
                    color: const Color(0xFF4A00E0),
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
                                  final rawPublished = exam["is_published"];
                                  bool isPublished = rawPublished == 1 || 
                                                    rawPublished == true || 
                                                    rawPublished.toString() == "1" || 
                                                    rawPublished.toString() == "true";
                                  final dt = _parseUtcToLocal(exam['end_time']);
                                  bool isMissed = !isAttempted && dt != null && dt.difference(DateTime.now()).isNegative;

                                  String buttonText = "Start";
                                  Color buttonColor = const Color(0xFF4A00E0);
                                  String? scoreText;
                                  
                                  // If there is a status, it means they started/submitted
                                  if (isAttempted) {
                                    if (exam["marks_obtained"] != null) {
                                      scoreText = "Score: ${exam['marks_obtained']} / ${exam['total_marks']}";
                                    }

                                    final String status = exam["attempt_status"].toString().toLowerCase();

                                    if (status == 'submitted' || exam["marks_obtained"] != null) {
                                      if (isPublished) {
                                        buttonText = "Evaluation";
                                        buttonColor = Colors.green;
                                      } else {
                                        buttonText = "Pending Result";
                                        buttonColor = Colors.orange;
                                      }
                                    } else {
                                      // If started but not submitted, and no marks yet
                                      buttonText = "Attempted";
                                      buttonColor = Colors.grey;
                                    }
                                  } else if (isMissed) {
                                    buttonText = "Missed";
                                    buttonColor = Colors.red;
                                  }

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
                                          if (scoreText != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              scoreText,
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.play_circle_outline,
                                                  size: 14,
                                                  color: Colors.green.shade600),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  "Starts: ${_formatDateTime(exam['start_time'])}",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.green.shade700),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.timer_off_outlined,
                                                  size: 14,
                                                  color: _deadlineColor(
                                                      exam['end_time'])),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  "Ends: ${_formatDateTime(exam['end_time'])}",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: _deadlineColor(
                                                          exam['end_time']),
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () {
                                          final String? status = exam["attempt_status"]?.toString().toLowerCase();
                                          
                                          if (status == 'submitted' || exam["marks_obtained"] != null) {
                                            if (isPublished) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      StudentExamReviewScreen(
                                                    examId: exam["id"],
                                                    title: exam["title"],
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Result not published yet")));
                                            }
                                          } else if (isAttempted || isMissed) {
                                            // Show why they can't start
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(isMissed ? "This exam has ended." : "You have already started/attempted this exam."))
                                            );
                                          } else {
                                            _startExam(exam);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: buttonColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(buttonText),
                                      ),
                                    ),
                                  );
                                },
                              ),
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
