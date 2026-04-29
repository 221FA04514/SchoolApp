import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/api_service.dart';
import '../../core/utils/date_time_utils.dart';
import 'teacher_marks_entry_screen.dart';

class TeacherResultsScreen extends StatefulWidget {
  const TeacherResultsScreen({super.key});

  @override
  State<TeacherResultsScreen> createState() => _TeacherResultsScreenState();
}

class _TeacherResultsScreenState extends State<TeacherResultsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _exams = [];
  List<dynamic> _sections = [];
  bool _isLoading = true;
  List<dynamic> _onlineExams = [];
  bool _isLoadingOnline = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
    _loadOnlineExams();
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      final response = await _api.get("/api/v1/results/sections");
      if (mounted) {
        setState(() {
          _sections = response["data"] ?? [];
        });
      }
    } catch (e) {}
  }

  Future<void> _loadExams() async {
    try {
      final response = await _api.get("/api/v1/results/list");
      if (mounted) {
        setState(() {
          _exams = response["data"] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOnlineExams() async {
    try {
      final response = await _api.get("/api/v1/online-exams/teacher/list");
      if (mounted) {
        setState(() {
          _onlineExams = response["data"] ?? [];
          _isLoadingOnline = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingOnline = false);
    }
  }

  void _togglePublish(int examId, bool currentStatus, {bool isOnline = false}) async {
    try {
      await _api.post("/api/v1/results/toggle-publish", {
        "examId": examId,
        "isPublished": !currentStatus,
      });
      if (isOnline) {
        _loadOnlineExams();
      } else {
        _loadExams();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Result ${!currentStatus ? 'published' : 'unpublished'}!",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _deleteOnlineExam(int examId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Online Exam"),
        content: const Text("Are you sure? This will permanently delete the exam, its questions, and all student submissions/results."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.delete("/api/v1/online-exams/teacher/$examId");
      _loadOnlineExams();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exam deleted")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: Stack(
          children: [
            // Curved Header Background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 180,
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
                          "Result Management",
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
                  
                  const TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(text: "Offline Results"),
                      Tab(text: "Online Exams"),
                    ],
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOfflineExams(),
                        _buildOnlineExams(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: context.watch<AuthProvider>().role == 'admin'
            ? FloatingActionButton.extended(
                onPressed: _showCreateExamDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Create Exam",
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF4A00E0),
              )
            : null,
      ),
    );
  }

  Widget _buildOfflineExams() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_exams.isEmpty) return const Center(child: Text("No exams recorded yet"));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _exams.length,
      itemBuilder: (context, index) {
        final exam = _exams[index];
        final isPublished = exam["is_published"] == 1 ||
            exam["is_published"] == true;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(
                    Icons.description_outlined,
                    color: Color(0xFF4A00E0),
                  ),
                ),
                title: Text(
                  exam["name"] ?? "Exam",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Date: ${DateTimeUtils.formatDate(exam["exam_date"])}  •  ${exam['section_name'] ?? 'All Sections'}"),
                trailing: Switch(
                  value: isPublished,
                  activeColor: Colors.green,
                  onChanged: (val) =>
                      _togglePublish(exam["id"], isPublished),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      isPublished ? "✅ PUBLIC" : "🔒 DRAFT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPublished ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Show locked badge if teacher can't enter marks for this section
                    if (exam['can_enter_marks'] != null && exam['can_enter_marks'] == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline_rounded, size: 10, color: Colors.orange.shade700),
                            const SizedBox(width: 4),
                            Text("Not Your Section", style: TextStyle(fontSize: 9, color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    const Spacer(),
                    if (exam['can_enter_marks'] == null || exam['can_enter_marks'] == 1)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TeacherMarksEntryScreen(
                                examId: exam["id"],
                                examName: exam["name"],
                                sectionId: exam["section_id"] ?? 1,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text("Upload Marks"),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4A00E0),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOnlineExams() {
    if (_isLoadingOnline) return const Center(child: CircularProgressIndicator());
    if (_onlineExams.isEmpty) return const Center(child: Text("No online exams recorded yet"));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _onlineExams.length,
      itemBuilder: (context, index) {
        final exam = _onlineExams[index];
        final isPublished = exam["is_published"] == 1 || exam["is_published"] == true;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(
                    Icons.computer_rounded,
                    color: Color(0xFF4A00E0),
                  ),
                ),
                title: Text(
                  exam["title"] ?? "Online Exam",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Subject: ${exam['subject']} • ${exam['section_name']}"),
                trailing: Switch(
                  value: isPublished,
                  activeColor: Colors.green,
                  onChanged: (val) => _togglePublish(exam["linked_exam_id"], isPublished, isOnline: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      isPublished ? "✅ PUBLIC" : "🔒 DRAFT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPublished ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Attempts: ${exam['attempt_count']} / ${exam['total_students']}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteOnlineExam(exam["id"]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateExamDialog() {
    final nameController = TextEditingController();
    final classController = TextEditingController();
    final totalController = TextEditingController(text: "100");
    final passController = TextEditingController(text: "35");
    String? selectedSectionId;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Create New Exam"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Exam Name"),
                ),
                TextField(
                  controller: classController,
                  decoration: const InputDecoration(
                    labelText: "Class (Optional)",
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: selectedSectionId,
                  decoration: const InputDecoration(
                    labelText: "Target Section",
                  ),
                  items: _sections.map((s) {
                    return DropdownMenuItem<String>(
                      value: s["id"].toString(),
                      child: Text(s["name"]),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedSectionId = val),
                ),
                TextField(
                  controller: totalController,
                  decoration: const InputDecoration(labelText: "Total Marks"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: passController,
                  decoration: const InputDecoration(labelText: "Passing Marks"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text("Date: ${selectedDate.toString().split(' ')[0]}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null)
                      setDialogState(() => selectedDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedSectionId == null) return;
                try {
                  await _api.post("/api/v1/results/exam", {
                    "name": nameController.text,
                    "className": classController.text,
                    "section_id": int.tryParse(selectedSectionId!),
                    "total_marks": int.tryParse(totalController.text),
                    "passing_marks": int.tryParse(passController.text),
                    "exam_date": selectedDate.toIso8601String(),
                  });
                  Navigator.pop(context);
                  _loadExams();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}
