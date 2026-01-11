import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/api/teacher_dashboard_service.dart';
import '../../models/teacher_dashboard_model.dart';

class TeacherCreateHomeworkScreen extends StatefulWidget {
  const TeacherCreateHomeworkScreen({super.key});

  @override
  State<TeacherCreateHomeworkScreen> createState() =>
      _TeacherCreateHomeworkScreenState();
}

class _TeacherCreateHomeworkScreenState
    extends State<TeacherCreateHomeworkScreen> {
  final ApiService _api = ApiService();
  final TeacherDashboardService _dashboardService = TeacherDashboardService();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String subject = "Loading...";
  int? selectedSectionId;
  DateTime? selectedDueDate;

  List sections = [];
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      // 1. Fetch Sections (now filtered by backend)
      final sectionRes = await _api.get("/api/v1/sections");

      // 2. Fetch Teacher Profile to get Subject
      final profile = await _dashboardService.fetchTeacherDashboard();

      setState(() {
        sections = sectionRes["data"];
        subject = profile.subject;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => selectedDueDate = picked);
    }
  }

  Future<void> submit() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        selectedSectionId == null ||
        selectedDueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await _api.post("/api/v1/homework", {
        "title": _titleController.text,
        "description": _descController.text,
        "subject": subject,
        "section_id": selectedSectionId,
        "due_date": selectedDueDate!.toIso8601String().split('T')[0],
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text("Create Homework"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Subject (Pre-filled & Locked) ---
                  _buildLabel("Subject"),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Section Dropdown ---
                  _buildLabel("Select Section"),
                  DropdownButtonFormField<int>(
                    value: selectedSectionId,
                    decoration: _inputDecoration("Pick a class/section"),
                    items: sections.map<DropdownMenuItem<int>>((s) {
                      return DropdownMenuItem(
                        value: s["id"],
                        child: Text(s["name"]),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedSectionId = val),
                  ),
                  const SizedBox(height: 20),

                  // --- Title ---
                  _buildLabel("Homework Title"),
                  TextField(
                    controller: _titleController,
                    decoration: _inputDecoration(
                      "Enter title (e.g. Chapter 1 Quiz)",
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Due Date Picker ---
                  _buildLabel("Due Date"),
                  GestureDetector(
                    onTap: _pickDueDate,
                    child: InputDecorator(
                      decoration: _inputDecoration("Select Date"),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDueDate == null
                                ? "Select Due Date"
                                : selectedDueDate!.toIso8601String().split(
                                    'T',
                                  )[0],
                            style: TextStyle(
                              color: selectedDueDate == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Description ---
                  _buildLabel("Instructions / Description"),
                  TextField(
                    controller: _descController,
                    maxLines: 5,
                    decoration: _inputDecoration("What should students do?"),
                  ),
                  const SizedBox(height: 32),

                  // --- Submit Button ---
                  ElevatedButton(
                    onPressed: isSubmitting ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1fa2ff),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Publish Homework",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1fa2ff), width: 2),
      ),
    );
  }
}
