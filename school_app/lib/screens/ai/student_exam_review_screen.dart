import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class StudentExamReviewScreen extends StatefulWidget {
  final int examId;
  final String title;

  const StudentExamReviewScreen({
    super.key,
    required this.examId,
    required this.title,
  });

  @override
  State<StudentExamReviewScreen> createState() =>
      _StudentExamReviewScreenState();
}

class _StudentExamReviewScreenState extends State<StudentExamReviewScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _attemptData;
  List<dynamic> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchReview();
  }

  Future<void> _fetchReview() async {
    try {
      final res = await _api.get(
        "/api/v1/online-exams/attempt/${widget.examId}",
      );
      setState(() {
        _attemptData = res["data"]["attempt"];
        _questions = res["data"]["questions"] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching review: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Review: ${widget.title}"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xFF4A00E0)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attemptData == null
          ? const Center(child: Text("No details found."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummary(),
                  const SizedBox(height: 20),
                  const Text(
                    "Question Analysis",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._questions.asMap().entries.map((entry) {
                    return _buildQuestionCard(entry.key + 1, entry.value);
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummary() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem(
              "Marks",
              "${_attemptData!['marks_obtained']}",
              Colors.blue,
            ),
            _summaryItem(
              "Status",
              "${_attemptData!['status']}".toUpperCase(),
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildQuestionCard(int index, dynamic q) {
    bool isCorrect = q["is_correct"] == 1;
    String studentAnswer = q["student_answer"] ?? "Not Answered";
    String correctAnswer = q["correct_answer"] ?? "";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isCorrect ? Colors.green : Colors.red,
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Q$index: ${q['question_text']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  "${q['marks_awarded']} / ${q['marks']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(),
            _answerRow("Your Answer:", studentAnswer, isCorrect),
            if (!isCorrect) ...[
              const SizedBox(height: 8),
              _answerRow("Correct Answer:", correctAnswer, true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _answerRow(String label, String text, bool isCorrect) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
