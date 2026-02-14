import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class TeacherManualHomeworkScreen extends StatefulWidget {
  const TeacherManualHomeworkScreen({super.key});

  @override
  State<TeacherManualHomeworkScreen> createState() =>
      _TeacherManualHomeworkScreenState();
}

class _TeacherManualHomeworkScreenState
    extends State<TeacherManualHomeworkScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subjectController = TextEditingController();
  List<dynamic> _sections = [];
  String? _selectedSectionId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 2));
  bool _isOffline = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      final response = await ApiService().get("/api/v1/results/sections");
      setState(() {
        _sections = response["data"] ?? [];
      });
    } catch (e) {
      print("Error loading sections: $e");
    }
  }

  void _save() async {
    if (_titleController.text.isEmpty || _selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Section are required")),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      await ApiService().post("/api/v1/homework", {
        "title": _titleController.text,
        "description": _descController.text,
        "subject": _subjectController.text,
        "section_id": int.tryParse(_selectedSectionId!),
        "due_date": _dueDate.toIso8601String(),
        "is_offline": _isOffline,
      });

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Homework created!")));
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF673AB7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF673AB7), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // Header Background
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Manual Homework",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: _inputDecoration(
                              "Homework Title",
                              Icons.title,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _subjectController,
                            decoration: _inputDecoration("Subject", Icons.book),
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _descController,
                            maxLines: 4,
                            decoration: _inputDecoration(
                              "Description / Instructions",
                              Icons.description,
                            ).copyWith(alignLabelWithHint: true),
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: _selectedSectionId,
                            decoration: _inputDecoration(
                              "Select Section",
                              Icons.class_,
                            ),
                            items: _sections.map((s) {
                              return DropdownMenuItem(
                                value: s["id"].toString(),
                                child: Text(s["name"] ?? "S-${s['id']}"),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedSectionId = val),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: SwitchListTile(
                              title: const Text(
                                "Offline Mode",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                "No file submission required (physical work)",
                                style: TextStyle(fontSize: 12),
                              ),
                              value: _isOffline,
                              activeColor: const Color(0xFF673AB7),
                              onChanged: (val) =>
                                  setState(() => _isOffline = val),
                            ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF673AB7),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Submit Homework",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
          ),
        ],
      ),
    );
  }
}
