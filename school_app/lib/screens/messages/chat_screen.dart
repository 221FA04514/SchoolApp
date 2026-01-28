import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/socket/socket_service.dart';
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

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  StreamSubscription? _socketSub;

  List messages = [];
  bool loading = true;

  late AnimationController _pageController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    fetchMessages();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);

    // 🔹 Listen for Real-time messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socket = Provider.of<SocketService>(context, listen: false);
      _socketSub = socket.messageStream.listen((data) {
        print("[CHAT] Socket Event Received: $data");
        if (data["type"] == "chat" && data["sender"] == "teacher") {
          fetchMessages();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _socketSub?.cancel();
    super.dispose();
  }

  // 🔹 Fetch conversation (student ↔ teacher)
  Future<void> fetchMessages() async {
    try {
      final response = await _api.get(
        "/api/v1/messages?teacher_id=${widget.teacherId}",
      );

      setState(() {
        messages = response["data"];
        loading = false;
      });

      _pageController.forward(from: 0);
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // 🔹 Send message
  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    await _api.post("/api/v1/messages/student", {
      "teacher_id": widget.teacherId,
      "message": text,
    });

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
              colors: [Color(0xFF1A4DFF), Color(0xFF3A6BFF), Color(0xFF6A11CB)],
            ),
          ),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("👨‍🏫"),
            ),
            const SizedBox(width: 8),
            Text(widget.teacherName),
          ],
        ),
      ),

      // ================= BODY =================
      body: Column(
        children: [
          // 🔹 Messages list
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? const Center(
                    child: Text(
                      "💬 No messages yet",
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : FadeTransition(
                    opacity: _fade,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isStudent = msg["sender"] == "student";

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 300 + index * 60),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 12 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Align(
                            alignment: isStudent
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth: size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                gradient: isStudent
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF1A4DFF),
                                          Color(0xFF3A6BFF),
                                        ],
                                      )
                                    : null,
                                color: isStudent ? null : Colors.grey.shade300,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(
                                    isStudent ? 16 : 0,
                                  ),
                                  bottomRight: Radius.circular(
                                    isStudent ? 0 : 16,
                                  ),
                                ),
                              ),
                              child: Text(
                                msg["message"],
                                style: TextStyle(
                                  color: isStudent
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

          // 🔹 INPUT BOX (FIXED POSITION)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Type your doubt… ✍️",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A4DFF), Color(0xFF3A6BFF)],
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
          ),
        ],
      ),
    );
  }
}
