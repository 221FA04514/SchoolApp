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

class _TeacherChatScreenState extends State<TeacherChatScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List messages = [];
  bool loading = true;

  late AnimationController _fadeController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    fetchMessages();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchMessages() async {
    final res = await _api.get(
      "/api/v1/messages?student_id=${widget.studentId}",
    );

    setState(() {
      messages = res["data"];
      loading = false;
    });

    _fadeController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  Future<void> sendReply() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // ================= HEADER =================
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A4DFF),
                Color(0xFF3A6BFF),
                Color(0xFF6A11CB),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("👨‍🎓"),
            ),
            const SizedBox(width: 8),
            Text(widget.studentName),
          ],
        ),
      ),

      // ================= BODY =================
      body: Column(
        children: [
          // 💬 Messages
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : FadeTransition(
                    opacity: _fade,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (_, index) {
                        final msg = messages[index];
                        final isTeacher =
                            msg["sender"] == "teacher";

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration:
                              Duration(milliseconds: 300 + index * 50),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Align(
                            alignment: isTeacher
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(
                                  maxWidth: size.width * 0.75),
                              decoration: BoxDecoration(
                                gradient: isTeacher
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF1A4DFF),
                                          Color(0xFF3A6BFF),
                                        ],
                                      )
                                    : null,
                                color: isTeacher
                                    ? null
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(
                                      isTeacher ? 16 : 0),
                                  bottomRight: Radius.circular(
                                      isTeacher ? 0 : 16),
                                ),
                              ),
                              child: Text(
                                msg["message"],
                                style: TextStyle(
                                  color: isTeacher
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),

          // ✍️ Reply box (FIXED & MOVED UP)
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Reply… ✍️",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: sendReply,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1A4DFF),
                            Color(0xFF3A6BFF),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
