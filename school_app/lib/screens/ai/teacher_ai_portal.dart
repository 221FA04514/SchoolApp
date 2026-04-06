import 'package:flutter/material.dart';
import '../../core/api/teacher_ai_service.dart';
import '../../core/api/api_service.dart';
import 'teacher_homework_gen_screen.dart';
import 'teacher_manual_homework_screen.dart';

class TeacherAiAssistantPortal extends StatefulWidget {
  const TeacherAiAssistantPortal({super.key});

  @override
  State<TeacherAiAssistantPortal> createState() =>
      _TeacherAiAssistantPortalState();
}

class _TeacherAiAssistantPortalState extends State<TeacherAiAssistantPortal> {
  final TextEditingController _draftController = TextEditingController();
  String _refinedOutput = "";
  bool _isLoading = false;

  void _refineAnnouncement() async {
    if (_draftController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final result = await TeacherAiService().refineAnnouncement(
        _draftController.text,
      );

      setState(() {
        _refinedOutput = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _publishAnnouncement() async {
    if (_refinedOutput.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      await ApiService().post("/api/v1/announcements", {
        "title": "School Announcement", // Default title
        "description": _refinedOutput,
      });

      setState(() {
        _refinedOutput = "";
        _draftController.clear();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Announcement published successfully!")),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to publish: $e")));
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
                        "AI Teacher Assistant",
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _toolCard(
                          "📝 AI Announcement Writer",
                          "Turn rough notes into professional school updates.",
                          Column(
                            children: [
                              TextField(
                                controller: _draftController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: "Enter your draft here...",
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _refineAnnouncement,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A00E0),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text("Refine Announcement",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                ),
                              ),
                              if (_refinedOutput.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(_refinedOutput),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              _draftController.clear();
                                              setState(
                                                  () => _refinedOutput = "");
                                            },
                                            icon: const Icon(Icons.clear,
                                                size: 18),
                                            label: const Text("Clear"),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: _isLoading
                                                ? null
                                                : _publishAnnouncement,
                                            icon:
                                                const Icon(Icons.send, size: 18),
                                            label: const Text("Publish Now"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _toolCard(
                          "📚 Smart Exam Generator",
                          "Generate difficulty-based exam questions instantly.",
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TeacherHomeworkGenScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text("Open Generator"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4A00E0),
                                side: const BorderSide(
                                    color: Color(0xFF4A00E0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _toolCard(
                          "✍️ Manual Homework",
                          "Create offline or text-based assignments manually.",
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TeacherManualHomeworkScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_note),
                              label: const Text("Create Manually"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4A00E0),
                                side: const BorderSide(
                                    color: Color(0xFF4A00E0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _toolCard(String title, String subtitle, Widget content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }
}
