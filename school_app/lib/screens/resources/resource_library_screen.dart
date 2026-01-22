import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital Library"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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
            return const Center(
              child: Text("No resources available right now."),
            );
          }

          final resources = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final r = resources[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: Icon(
                      r["type"] == 'pdf'
                          ? Icons.picture_as_pdf
                          : Icons.video_library,
                      color: Colors.indigo,
                    ),
                  ),
                  title: Text(
                    r["title"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${r["subject"]} • Uploaded by ${r["uploader_name"] ?? 'Unknown'}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download_rounded),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Downloading ${r["title"]}...")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
