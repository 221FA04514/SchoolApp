import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class TeacherChatScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const TeacherChatScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<TeacherChatScreen> createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends State<TeacherChatScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();

  List messages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final response = await _api.get(
      "/api/v1/messages?student_id=${widget.studentId}",
    );
    setState(() {
      messages = response["data"];
      loading = false;
    });
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    _controller.clear();

    await _api.post(
      "/api/v1/messages/teacher",
      {
        "student_id": widget.studentId,
        "message": text,
      },
    );

    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.studentName)),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      final isTeacher = m["sender"] == "teacher";

                      return Align(
                        alignment: isTeacher
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isTeacher
                                ? Colors.green[100]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(m["message"]),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: "Reply..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
