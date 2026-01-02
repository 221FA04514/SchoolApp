import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int teacherId;
  final String teacherName;

  const ChatScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();

  List messages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  // 🔹 Fetch conversation (student + selected teacher)
  Future<void> fetchMessages() async {
    try {
      final response = await _api.get(
        "/api/v1/messages?teacher_id=${widget.teacherId}",
      );

      setState(() {
        messages = response["data"];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // 🔹 Send doubt (student → teacher)
  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    await _api.post(
      "/api/v1/messages/student",
      {
        "teacher_id": widget.teacherId,
        "message": text,
      },
    );

    fetchMessages(); // refresh chat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacherName),
      ),
      body: Column(
        children: [
          // 🔹 Messages list
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(child: Text("No messages yet"))
                    : ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isStudent = msg["sender"] == "student";

                          return Align(
                            alignment: isStudent
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isStudent
                                    ? Colors.blue[100]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(msg["message"]),
                            ),
                          );
                        },
                      ),
          ),

          // 🔹 Input box
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your doubt...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
