import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ResourceLibraryScreen extends StatefulWidget {
  const ResourceLibraryScreen({super.key});

  @override
  State<ResourceLibraryScreen> createState() => _ResourceLibraryScreenState();
}

class _ResourceLibraryScreenState extends State<ResourceLibraryScreen> {
  final ApiService _api = ApiService();
  late Future<List<dynamic>> _resourcesFuture;

  @override
  void initState() {
    super.initState();
    _resourcesFuture = _fetchResources();
  }

  Future<List<dynamic>> _fetchResources() async {
    final res = await _api.get("/api/v1/resources");
    return res["data"];
  }

  Future<void> _downloadAndOpenFile(Map<String, dynamic> resource) async {
    try {
      // 1. Request Permissions (Android)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          // Fallback check for Android 13+
          final photoStatus = await Permission.photos.request();
          if (!photoStatus.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Storage permission required to download files"),
              ),
            );
            return;
          }
        }
      }

      // 2. Show Progress Dialog
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
                  Text("Downloading file..."),
                ],
              ),
            ),
          ),
        ),
      );

      // 3. Prepare URL and Path
      final fileName = resource["file_url"].split('/').last;
      final fullUrl = "${AppConstants.baseUrl}${resource["file_url"]}";
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/$fileName";

      print("[DOWNLOAD] Starting: $fullUrl -> $filePath");

      // 4. Download using Dio
      final dio = Dio();
      await dio.download(fullUrl, filePath);

      if (mounted) Navigator.pop(context); // Close dialog

      // 5. Open File (using url_launcher for cross-platform compatibility)
      final Uri fileUri = Uri.file(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloaded to: $fileName"),
          action: SnackBarAction(
            label: "Open",
            onPressed: () async {
              if (await canLaunchUrl(fileUri)) {
                await launchUrl(fileUri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Could not open file directly. Please find it in your documents.",
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("[DOWNLOAD] Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("Digital Library"),
<<<<<<< HEAD
        backgroundColor: const Color(0xFF1A4DFF),
=======
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: const Color(0xFF4A00E0)),
        ),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _resourcesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No resources available right now.",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          final resources = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final r = resources[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A4DFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(r["type"]),
                      color: const Color(0xFF1A4DFF),
                    ),
                  ),
                  title: Text(
                    r["title"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "${r["subject"]} • ${r["uploader_name"] ?? 'Faculty'}\n${r["description"] ?? ''}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A4DFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.download_for_offline_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => _downloadAndOpenFile(r),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String? type) {
    type = type?.toLowerCase();
    if (type == "pdf") return Icons.picture_as_pdf;
    if (type == "mp4" || type == "mov") return Icons.video_library;
    if (type == "mp3" || type == "wav") return Icons.audiotrack;
    if (type == "jpg" || type == "png") return Icons.image;
    return Icons.insert_drive_file;
  }
}
