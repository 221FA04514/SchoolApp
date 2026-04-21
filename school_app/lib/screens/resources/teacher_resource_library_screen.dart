import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio_lib;

class TeacherResourceLibraryScreen extends StatefulWidget {
  const TeacherResourceLibraryScreen({super.key});

  @override
  State<TeacherResourceLibraryScreen> createState() =>
      _TeacherResourceLibraryScreenState();
}

class _TeacherResourceLibraryScreenState
    extends State<TeacherResourceLibraryScreen> {
  final ApiService _api = ApiService();
  List resources = [];
  List sections = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      setState(() => loading = true);
      final results = await Future.wait([
        _api.get("/api/v1/resources"),
        _api.get("/api/v1/sections"),
      ]);

      if (mounted) {
        setState(() {
          resources = results[0]["data"] ?? [];
          sections = results[1]["data"] ?? [];
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  int? _selectedSecId;
  PlatformFile? _pickedFile;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subjectController = TextEditingController();

  Future<void> _deleteResource(int id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Resource?"),
        content: Text("Are you sure you want to delete '$title'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.delete("/api/v1/resources/$id");
        _fetchInitialData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
      }
    }
  }

  Future<void> _uploadResource() async {
    _titleController.clear();
    _descController.clear();
    _subjectController.clear();
    _selectedSecId = null;
    _pickedFile = null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 40,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upload Chapter Notes",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Files will be shared with targeted sections",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 25),
              _buildModernField(
                _titleController,
                "Chapter Title",
                Icons.title_rounded,
              ),
              _buildModernField(
                _subjectController,
                "Subject Name",
                Icons.auto_stories_rounded,
              ),
              _buildModernField(
                _descController,
                "Short Description",
                Icons.description_rounded,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _selectedSecId,
                items: sections.map<DropdownMenuItem<int>>((s) {
                  return DropdownMenuItem(
                    value: s["id"],
                    child: Text("Section ${s["name"]}"),
                  );
                }).toList(),
                onChanged: (v) => setModalState(() => _selectedSecId = v),
                decoration: _fieldDecoration(
                  "Target Section",
                  Icons.class_outlined,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles();
                  if (result != null)
                    setModalState(() => _pickedFile = result.files.first);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_upload_rounded,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          _pickedFile == null
                              ? "Select File (PDF, Video, etc.)"
                              : _pickedFile!.name,
                          style: TextStyle(
                            color: _pickedFile == null
                                ? Colors.grey
                                : Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A00E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (_pickedFile == null ||
                        _selectedSecId == null ||
                        _titleController.text.isEmpty) {
                      return;
                    }
                    try {
                      _showLoader();
                      dio_lib.FormData formData = dio_lib.FormData.fromMap({
                        "section_id": _selectedSecId,
                        "subject": _subjectController.text,
                        "title": _titleController.text,
                        "description": _descController.text,
                        "type": (_pickedFile!.extension ?? "file")
                            .toLowerCase(),
                        "file": await dio_lib.MultipartFile.fromFile(
                          _pickedFile!.path!,
                          filename: _pickedFile!.name,
                        ),
                      });
                      await _api.postMultipart(
                        "/api/v1/resources/upload",
                        formData,
                      );
                      if (mounted) {
                        Navigator.pop(context); // Close loader
                        Navigator.pop(ctx); // Close sheet
                        _fetchInitialData();
                      }
                    } catch (e) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Deploy Resource",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A00E0)),
      ),
    );
  }

  Widget _buildModernField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: _fieldDecoration(label, icon),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF4A00E0), size: 20),
      filled: true,
      fillColor: const Color(0xFFF1F4FA),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4A00E0), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [_buildPremiumHeader(), _buildResourceList()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadResource,
        backgroundColor: const Color(0xFF4A00E0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Chapter",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF4A00E0),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF6B11CB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Stack(
            children: [
              Positioned(
                bottom: 25,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Faculty Library",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      "Manage and share study materials",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceList() {
    if (loading)
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    if (resources.isEmpty)
      return const SliverFillRemaining(
        child: Center(child: Text("Start uploading resources to the cloud")),
      );

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final r = resources[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A00E0).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getIcon(r["type"]),
                  color: const Color(0xFF4A00E0),
                  size: 28,
                ),
              ),
              title: Text(
                r["title"],
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              subtitle: Text(
                "${r["subject"]} • Section ${r["section_name"] ?? 'All'}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.redAccent,
                ),
                onPressed: () => _deleteResource(r["id"], r["title"]),
              ),
            ),
          );
        }, childCount: resources.length),
      ),
    );
  }

  IconData _getIcon(String? type) {
    type = type?.toLowerCase();
    if (type == "pdf") return Icons.picture_as_pdf_rounded;
    if (type == "mp4" || type == "mov") return Icons.video_library_rounded;
    return Icons.insert_drive_file_rounded;
  }
}
