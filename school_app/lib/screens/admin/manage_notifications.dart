import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageNotificationsScreen extends StatefulWidget {
  const ManageNotificationsScreen({super.key});

  @override
  State<ManageNotificationsScreen> createState() =>
      _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  final ApiService _api = ApiService();
  final titleController = TextEditingController();
  final messageController = TextEditingController();

  String targetAudience = "all"; // all, teachers, students
  bool isSending = false;
  bool isGenerating = false; // For AI actions
  List history = [];
  DateTime? expirationDate;

  // Theme Color
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final res = await _api.get("/api/v2/admin/notifications");
      if (mounted) {
        setState(() {
          history = res["data"] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  Future<void> _formalizeMessage() async {
    if (messageController.text.isEmpty) return;
    setState(() => isGenerating = true);
    try {
      final res = await _api.post("/api/v2/admin/notifications/ai/formalize", {
        "text": messageController.text,
      });
      if (res["success"] && mounted) {
        setState(() {
          messageController.text = res["data"]["formalized"];
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("AI Error: $e")));
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  Future<void> _translateMessage(String lang) async {
    if (messageController.text.isEmpty) return;
    setState(() => isGenerating = true);
    try {
      final res = await _api.post("/api/v2/admin/notifications/ai/translate", {
        "text": messageController.text,
        "lang": lang,
      });
      if (res["success"] && mounted) {
        setState(() {
          messageController.text = res["data"]["translated"];
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Translation Error: $e")));
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => expirationDate = picked);
    }
  }

  Future<void> _sendNotification() async {
    if (titleController.text.isEmpty || messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Message required")),
      );
      return;
    }

    setState(() => isSending = true);

    try {
      // Construct targets based on simplified dropdown
      List targets = [];
      if (targetAudience == "all") {
        targets.add({"type": "role", "id": "teacher"});
        targets.add({"type": "role", "id": "student"});
      } else if (targetAudience == "teachers") {
        targets.add({"type": "role", "id": "teacher"});
      } else if (targetAudience == "students") {
        targets.add({"type": "role", "id": "student"});
      }

      final res = await _api.post("/api/v2/admin/notifications/send", {
        "title": titleController.text,
        "body": messageController.text,
        "targets": targets,
        "expires_at": expirationDate?.toIso8601String(),
      });

      if (res["success"]) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Notification Launched Successfully!"),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          titleController.clear();
          messageController.clear();
          setState(() => expirationDate = null);
          _fetchHistory();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error sending: $e")));
      }
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> _confirmDelete(Map n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Notification"),
        content: Text("Delete '${n['title']}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.delete("/api/v2/admin/notifications/${n['id']}");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Notification deleted")));
          _fetchHistory();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Light grey bg
      appBar: AppBar(
        title: const Text(
          "Notify Hub",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compose Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Announcement Title",
                      labelStyle: TextStyle(color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Your message...",
                      labelStyle: TextStyle(color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Audience Dropdown
                  DropdownButtonFormField<String>(
                    value: targetAudience,
                    decoration: InputDecoration(
                      labelText: "Target Audience",
                      labelStyle: TextStyle(color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: Icon(
                        Icons.people_outline,
                        color: primaryColor,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("Everyone")),
                      DropdownMenuItem(
                        value: "teachers",
                        child: Text("Teachers Only"),
                      ),
                      DropdownMenuItem(
                        value: "students",
                        child: Text("Students Only"),
                      ),
                    ],
                    onChanged: (val) => setState(() => targetAudience = val!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // AI Smart Tools
            const Text(
              "✨ AI Smart Tools",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildAIToolBtn(
                    "Formalize",
                    "👔",
                    () => _formalizeMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAIToolBtn(
                    "Telugu",
                    "🇮🇳",
                    () => _translateMessage('telugu'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAIToolBtn(
                    "Hindi",
                    "🕉️",
                    () => _translateMessage('hindi'),
                  ),
                ),
              ],
            ),
            if (isGenerating) LinearProgressIndicator(color: primaryColor),

            const SizedBox(height: 25),

            // Expiration Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.orange, size: 28),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Expiration Date (Optional)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          expirationDate == null
                              ? "Persistent forever"
                              : expirationDate.toString().split(' ')[0],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(
                      "Set",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Launch Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
                onPressed: isSending ? null : _sendNotification,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, size: 22),
                label: Text(
                  isSending ? "Launching..." : "Launch Announcement",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // History
            const Text(
              "📜 Notification History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Text(
              "Manage and delete sent notifications",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final n = history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n["title"] ?? "No Title",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n["expires_at"] != null
                                  ? "Expires: ${n['expires_at'].toString().split('T')[0]}"
                                  : "No Expiration",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _confirmDelete(n),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIToolBtn(String label, String icon, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: primaryColor,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor),
        ),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
