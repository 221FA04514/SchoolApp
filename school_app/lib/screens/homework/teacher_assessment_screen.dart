import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/api_service.dart';
import '../../core/constants.dart';

class TeacherHomeworkAssessmentScreen extends StatefulWidget {
  final int homeworkId;
  final String title;

  const TeacherHomeworkAssessmentScreen({
    super.key,
    required this.homeworkId,
    required this.title,
  });

  @override
  State<TeacherHomeworkAssessmentScreen> createState() =>
      _TeacherHomeworkAssessmentScreenState();
}

class _TeacherHomeworkAssessmentScreenState
    extends State<TeacherHomeworkAssessmentScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      final response = await _api.get(
        "/api/v1/homework/submissions/${widget.homeworkId}",
      );
      setState(() {
        _submissions = response["data"] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _gradeSubmission(
    int submissionId,
    int marks,
    String feedback,
    String status,
  ) async {
    try {
      await _api.post("/api/v1/homework/grade", {
        "submission_id": submissionId,
        "marks": marks,
        "feedback": feedback,
        "status": status,
      });
      _loadSubmissions(); // Refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'graded'
                ? "Approved successfully!"
                : "Rejected successfully!",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: const Color(0xFF4A00E0)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _submissions.isEmpty
          ? const Center(child: Text("No submissions yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _submissions.length,
              itemBuilder: (context, index) {
                final sub = _submissions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sub["student_name"] ?? "Student",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: sub["status"] == "graded"
                                    ? Colors.green.shade50
                                    : sub["status"] == "rejected"
                                    ? Colors.red.shade50
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sub["status"].toString().toUpperCase(),
                                style: TextStyle(
                                  color: sub["status"] == "graded"
                                      ? Colors.green
                                      : sub["status"] == "rejected"
                                      ? Colors.red
                                      : Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(sub["content"] ?? "No text content"),
                        if (sub["file_url"] != null) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _openAttachment(sub["file_url"]),
                            icon: const Icon(Icons.attachment_rounded),
                            label: Text(
                              "View Attachment",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                        const Divider(),
                        if (sub["status"] != "graded" &&
                            sub["status"] != "rejected") ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _showGradeDialog(sub["id"], 0, 'graded'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Approve / Grade"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _showGradeDialog(
                                    sub["id"],
                                    0,
                                    'rejected',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text("Reject"),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            "Marks: ${sub["marks"]} | Feedback: ${sub["feedback"]}",
                            style: TextStyle(
                              color: sub["status"] == "rejected"
                                  ? Colors.red
                                  : Colors.black87,
                              fontWeight: sub["status"] == "rejected"
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (sub["status"] == "rejected")
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ElevatedButton(
                                onPressed: () =>
                                    _showGradeDialog(sub["id"], 0, 'graded'),
                                child: const Text("Re-evaluate / Approve"),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showGradeDialog(int subId, int currentMarks, String status) {
    final marksController = TextEditingController(
      text: currentMarks.toString(),
    );
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == 'graded' ? "Approve & Grade" : "Reject Submission",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'graded')
              TextField(
                controller: marksController,
                decoration: const InputDecoration(labelText: "Marks"),
                keyboardType: TextInputType.number,
              ),
            TextField(
              controller: feedbackController,
              decoration: InputDecoration(
                labelText: status == 'graded'
                    ? "Feedback / Marks Comment"
                    : "Reason for Rejection",
              ),
              maxLines: 3,
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
              _gradeSubmission(
                subId,
                int.tryParse(marksController.text) ?? 0,
                feedbackController.text,
                status,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'graded' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(status == 'graded' ? "Submit Grade" : "Confirm Reject"),
          ),
        ],
      ),
    );
  }

  Future<void> _openAttachment(String fileUrl) async {
    // Normalize path just in case
    final cleanPath = fileUrl.replaceAll('\\', '/');
    final fullUrl = "${AppConstants.baseUrl}/$cleanPath";
    final uri = Uri.parse(fullUrl);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $fullUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open file: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
