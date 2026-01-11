import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageSectionsScreen extends StatefulWidget {
  const ManageSectionsScreen({super.key});

  @override
  State<ManageSectionsScreen> createState() => _ManageSectionsScreenState();
}

class _ManageSectionsScreenState extends State<ManageSectionsScreen> {
  final ApiService _api = ApiService();
  List sections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSections();
  }

  Future<void> fetchSections() async {
    try {
      final res = await _api.get("/api/v1/admin/sections");
      setState(() {
        sections = res["data"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showAddSectionDialog() {
    final classController = TextEditingController();
    final sectionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Section"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: classController,
              decoration: const InputDecoration(labelText: "Class (e.g. 10)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: sectionController,
              decoration: const InputDecoration(labelText: "Section (e.g. A)"),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (classController.text.isEmpty ||
                  sectionController.text.isEmpty)
                return;
              try {
                final res = await _api.post("/api/v1/admin/sections", {
                  "class": classController.text,
                  "section": sectionController.text,
                });
                if (res["success"]) {
                  if (mounted) Navigator.pop(context);
                  fetchSections();
                }
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Sections")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final s = sections[index];
                return ListTile(
                  title: Text(s["name"]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Confirm delete
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Section"),
                          content: const Text(
                            "Are you sure you want to delete this section?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          final res = await _api.delete(
                            "/api/v1/admin/sections/${s["id"]}",
                          );
                          if (res["success"]) {
                            fetchSections();
                          }
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                        }
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSectionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
