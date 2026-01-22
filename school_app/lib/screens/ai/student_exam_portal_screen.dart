import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class StudentExamPortalScreen extends StatefulWidget {
  final int examId;
  final int attemptId;
  final String title;
  final int durationMins;

  const StudentExamPortalScreen({
    super.key,
    required this.examId,
    required this.attemptId,
    required this.title,
    required this.durationMins,
  });

  @override
  State<StudentExamPortalScreen> createState() =>
      _StudentExamPortalScreenState();
}

class _StudentExamPortalScreenState extends State<StudentExamPortalScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  Map<int, String> _userAnswers = {};
  late Timer _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationMins * 60;
    _loadQuestions();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _submitExam(auto: true);
      }
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await _api.get(
        "/api/v1/online-exams/questions/${widget.examId}",
      );
      setState(() {
        _questions = response["data"] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  Future<void> _submitExam({bool auto = false}) async {
    _timer.cancel();
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> answers = [];
      for (var q in _questions) {
        answers.add({
          "question_id": q["id"],
          "student_answer": _userAnswers[q["id"]] ?? "",
        });
      }

      await _api.post("/api/v1/online-exams/submit", {
        "attemptId": widget.attemptId,
        "answers": answers,
      });

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Exam Submitted"),
          content: Text(
            auto
                ? "Time's up! Your answers have been saved."
                : "You have successfully completed the exam.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to list
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Submission failed: $e")));
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Basic "Lock" simulation: WillPopScope to prevent easy accidental exit
    return WillPopScope(
      onWillPop: () async {
        bool? exit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit Exam?"),
            content: const Text(
              "If you exit now, your exam will be submitted as-is and you won't be able to re-enter.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Stay"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Exit & Submit",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        if (exit == true) {
          await _submitExam();
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.title),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  _formatTime(_secondsRemaining),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Question ${_currentIndex + 1} of ${_questions.length}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _questions[_currentIndex]["question_text"],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Check if it's MCQ (has options_json)
                          if (_questions[_currentIndex]["options_json"] != null)
                            ...(_questions[_currentIndex]["options_json"] as List).map((
                              opt,
                            ) {
                              return RadioListTile<String>(
                                title: Text(opt.toString()),
                                value: opt.toString(),
                                groupValue:
                                    _userAnswers[_questions[_currentIndex]["id"]],
                                onChanged: (val) {
                                  setState(
                                    () =>
                                        _userAnswers[_questions[_currentIndex]["id"]] =
                                            val!,
                                  );
                                },
                              );
                            }).toList()
                          else
                            TextField(
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: "Type your answer here...",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                _userAnswers[_questions[_currentIndex]["id"]] =
                                    val;
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  _buildNavigation(),
                ],
              ),
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentIndex > 0)
            ElevatedButton(
              onPressed: () => setState(() => _currentIndex--),
              child: const Text("Previous"),
            )
          else
            const SizedBox(width: 80),

          if (_currentIndex < _questions.length - 1)
            ElevatedButton(
              onPressed: () => setState(() => _currentIndex++),
              child: const Text("Next"),
            )
          else
            ElevatedButton(
              onPressed: () => _submitExam(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Finish Exam"),
            ),
        ],
      ),
    );
  }
}
