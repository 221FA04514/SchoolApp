import 'package:flutter/material.dart';
import '../../core/api/teacher_ai_service.dart';
import '../homework/teacher_assessment_screen.dart';

class TeacherInsightDetailScreen extends StatefulWidget {
  final String type;
  final String title;

  const TeacherInsightDetailScreen({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<TeacherInsightDetailScreen> createState() =>
      _TeacherInsightDetailScreenState();
}

class _TeacherInsightDetailScreenState
    extends State<TeacherInsightDetailScreen> {
  final TeacherAiService _aiService = TeacherAiService();
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _aiService.getInsightDetails(widget.type);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
          : _data.isEmpty
          ? const Center(child: Text("No data found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final item = _data[index];
                if (widget.type == "low_attendance") {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: Text(
                          item["percentage"].toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(item["name"] ?? "Unknown"),
                      subtitle: Text("Roll No: ${item["roll_no"]}"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        // Show AI insights for this student
                        _showStudentInsight(
                          item["id"].toString(),
                          item["name"],
                        );
                      },
                    ),
                  );
                } else {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(
                          Icons.assignment,
                          color: Colors.orange,
                        ),
                      ),
                      title: Text(item["title"] ?? "Untitled"),
                      subtitle: Text("Due: ${item["due_date"]}"),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${item["submission_count"]} pending",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherHomeworkAssessmentScreen(
                              homeworkId: item["homework_id"],
                              title: item["title"],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
    );
  }

  void _showStudentInsight(String studentId, String name) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (_, controller) => FutureBuilder<String>(
          future: _aiService.getStudentInsights(studentId),
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AI Insights: $name",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.hasError)
                    Text("Error: ${snapshot.error}")
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: SelectableText(snapshot.data ?? ""),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
