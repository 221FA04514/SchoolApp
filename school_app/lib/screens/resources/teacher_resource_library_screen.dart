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
      print("[LIBRARY] Fetching initial data...");
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
          print(
            "[LIBRARY] Fetched ${resources.length} resources and ${sections.length} sections.",
          );
        });
      }
    } catch (e) {
      print("[LIBRARY] Error fetching data: $e");
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading library data: $e")),
        );
      }
    }
  }

  int? _selectedSecId;
  PlatformFile? _pickedFile;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subjectController = TextEditingController();

  Future<void> _uploadResource() async {
    _titleController.clear();
    _descController.clear();
    _subjectController.clear();
    _selectedSecId = null;
    _pickedFile = null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Upload Study Material",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title (e.g. Chapter 1 Notes)",
                ),
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Description (Optional)",
                ),
              ),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: "Subject"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedSecId,
                hint: const Text("Select Targeted Section"),
                items: sections
                    .map<DropdownMenuItem<int>>(
                      (s) => DropdownMenuItem(
                        value: s["id"],
                        child: Text("Section ${s["name"]}"),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setModalState(() => _selectedSecId = v),
                decoration: InputDecoration(
                  labelText: "Target Section",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles();
                  if (result != null)
                    setModalState(() => _pickedFile = result.files.first);
                },
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _pickedFile == null ? "Pick File" : _pickedFile!.name,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_pickedFile == null ||
                      _selectedSecId == null ||
                      _titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please fill all fields (Title, Section, File)",
                        ),
                      ),
                    );
                    return;
                  }

                  // Multipart upload
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Uploading file... Please wait."),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    print(
                      "[LIBRARY] Preparing upload: Title=${_titleController.text}, Section=$_selectedSecId",
                    );
                    print(
                      "[LIBRARY] File: ${_pickedFile!.name}, Path: ${_pickedFile!.path}",
                    );

                    print("[LIBRARY] Uploading to /api/v1/resources/upload...");
                    dio_lib.FormData formData = dio_lib.FormData.fromMap({
                      "section_id": _selectedSecId,
                      "subject": _subjectController.text,
                      "title": _titleController.text,
                      "description": _descController.text,
                      "type": (_pickedFile!.extension ?? "file").toLowerCase(),
                      "file": await dio_lib.MultipartFile.fromFile(
                        _pickedFile!.path!,
                        filename: _pickedFile!.name,
                      ),
                    });

                    final res = await _api.postMultipart(
                      "/api/v1/resources/upload",
                      formData,
                    );

                    if (mounted) Navigator.pop(ctx); // Close loading dialog

                    if (res["success"] == true) {
                      Navigator.pop(ctx); // Close bottom sheet
                      _fetchInitialData();
                    } else {
                      throw Exception(res["message"] ?? "Upload failed");
                    }
                  } catch (e) {
                    if (mounted) Navigator.pop(ctx); // Close loading dialog
                    print("[LIBRARY] Upload Error: $e");
                    String msg = "Upload failed";
                    if (e is dio_lib.DioException) {
                      msg =
                          "Upload failed: ${e.response?.data['message'] ?? e.message}";
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A4DFF),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Upload Now"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("Digital Library"),
        backgroundColor: const Color(0xFF1A4DFF),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : resources.isEmpty
          ? const Center(child: Text("No resources uploaded yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final r = resources[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: _getIcon(r["type"]),
                    title: Text(
                      r["title"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${r["subject"]} • Section: ${r["section_name"] ?? 'All'}\n${r["description"] ?? ''}",
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        // TODO: Add delete functionality if needed
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadResource,
        backgroundColor: const Color(0xFF1A4DFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _getIcon(String? type) {
    type = type?.toLowerCase();
    if (type == "pdf")
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    if (type == "doc" || type == "docx")
      return const Icon(Icons.description, color: Colors.blue);
    if (type == "mp4" || type == "mov")
      return const Icon(Icons.video_library, color: Colors.purple);
    if (type == "mp3" || type == "wav")
      return const Icon(Icons.audiotrack, color: Colors.orange);
    if (type == "jpg" || type == "png" || type == "jpeg")
      return const Icon(Icons.image, color: Colors.green);
    return const Icon(Icons.insert_drive_file, color: Colors.grey);
  }
}
