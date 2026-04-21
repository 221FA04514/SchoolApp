import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageExamsScreen extends StatefulWidget {
  const ManageExamsScreen({super.key});

  @override
  State<ManageExamsScreen> createState() => _ManageExamsScreenState();
}

class _ManageExamsScreenState extends State<ManageExamsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _exams = [];
  List<dynamic> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final examRes = await _api.get("/api/v1/results/list");
      final sectionRes = await _api.get("/api/v1/results/sections");
      setState(() {
        _exams = examRes["data"] ?? [];
        _sections = sectionRes["data"] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load data: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _togglePublish(int examId, bool currentStatus) async {
    try {
      await _api.post("/api/v1/results/toggle-publish", {
        "examId": examId,
        "isPublished": !currentStatus,
      });
      _loadData();
    } catch (e) {
      _showError("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text("Exam Management", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
                    final isPub = exam["is_published"] == 1;
                    return _buildExamCard(exam, isPub);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        label: const Text("New Offline Exam", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF673AB7),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No exams found", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _showCreateDialog, child: const Text("Create First Exam")),
        ],
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam, bool isPublished) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF673AB7).withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.event_note_rounded, color: Color(0xFF673AB7)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exam["name"] ?? "Standard Exam", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text("Class: ${exam["class"] ?? 'N/A'}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: isPublished,
                  onChanged: (val) => _togglePublish(exam["id"], isPublished),
                  activeColor: Colors.green,
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(Icons.calendar_today_rounded, exam["exam_date"]?.toString().split('T')[0] ?? 'N/A'),
                _buildInfoItem(Icons.star_rounded, "Pass: ${exam["passing_marks"]}/${exam["total_marks"]}"),
                Text(
                  isPublished ? "PUBLISHED" : "DRAFT",
                  style: TextStyle(color: isPublished ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final classCtrl = TextEditingController();
    final totalCtrl = TextEditingController(text: "100");
    final passCtrl = TextEditingController(text: "35");
    String? selSection;
    DateTime selDate = DateTime.now();

    // Local state for filtered sections
    List<dynamic> filteredSections = List.from(_sections);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setDimState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create New Exam", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: nameCtrl, decoration: _inputStyle("Exam Name (e.g. Mid Term)")),
              const SizedBox(height: 16),
              TextField(
                controller: classCtrl,
                decoration: _inputStyle("Class (e.g. 10)"),
                onChanged: (val) {
                  setDimState(() {
                    if (val.isEmpty) {
                      filteredSections = List.from(_sections);
                    } else {
                      filteredSections = _sections.where((s) {
                        final sClass = s["class"]?.toString() ?? "";
                        return sClass.toLowerCase() == val.toLowerCase();
                      }).toList();
                    }
                    if (selSection != null && !filteredSections.any((s) => s["id"].toString() == selSection)) {
                      selSection = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selSection,
                decoration: _inputStyle("Select Target Section"),
                items: filteredSections.map((s) => DropdownMenuItem(value: s["id"].toString(), child: Text(s["name"]))).toList(),
                onChanged: (v) => setDimState(() => selSection = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: totalCtrl, decoration: _inputStyle("Total"), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: passCtrl, decoration: _inputStyle("Passing"), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Exam Date: ${selDate.toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_month_rounded, color: Color(0xFF673AB7)),
                onTap: () async {
                  final p = await showDatePicker(context: context, initialDate: selDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
                  if (p != null) setDimState(() => selDate = p);
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF673AB7), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () async {
                    if (selSection == null || nameCtrl.text.isEmpty) return;
                    try {
                      await _api.post("/api/v1/results/exam", {
                        "name": nameCtrl.text,
                        "className": classCtrl.text,
                        "section_id": int.parse(selSection!),
                        "total_marks": int.parse(totalCtrl.text),
                        "passing_marks": int.parse(passCtrl.text),
                        "exam_date": selDate.toIso8601String(),
                      });
                      Navigator.pop(context);
                      _loadData();
                    } catch (e) {
                      _showError("Creation failed: $e");
                    }
                  },
                  child: const Text("Create Exam", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}
