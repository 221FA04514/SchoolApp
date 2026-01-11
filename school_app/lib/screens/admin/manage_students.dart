import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final ApiService _api = ApiService();
  List students = [];
  List sections = [];
  String? selectedSection;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final sRes = await _api.get("/api/v1/admin/students");
      final secRes = await _api.get("/api/v1/admin/sections");
      setState(() {
        students = sRes["data"] ?? [];
        sections = secRes["data"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchStudents() async {
    try {
      final res = await _api.get("/api/v1/admin/students");
      setState(() {
        students = res["data"] ?? [];
      });
    } catch (e) {}
  }

  List get filteredStudents {
    if (selectedSection == null || selectedSection == "All") return students;
    return students.where((s) => s["section_name"] == selectedSection).toList();
  }

  void _showEditStudentDialog(Map s) {
    final nameController = TextEditingController(text: s["name"]);
    final emailController = TextEditingController(text: s["email"]);
    final passwordController = TextEditingController();
    final classController = TextEditingController(text: s["class"].toString());
    final sectionController = TextEditingController(text: s["section"]);
    final rollController = TextEditingController(
      text: s["roll_number"].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Student"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "New Password (Leave blank to keep current)",
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: classController,
                  decoration: const InputDecoration(
                    labelText: "Class (e.g. 10)",
                  ),
                ),
                TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(
                    labelText: "Section (e.g. A)",
                  ),
                ),
                TextField(
                  controller: rollController,
                  decoration: const InputDecoration(labelText: "Roll Number"),
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
                try {
                  final res = await _api
                      .put("/api/v1/admin/users/${s["user_id"]}", {
                        "role": "student",
                        "name": nameController.text,
                        "email": emailController.text,
                        "password": passwordController.text,
                        "class": classController.text,
                        "section": sectionController.text,
                        "roll_number": rollController.text,
                      });
                  if (res["success"]) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Student updated!")),
                      );
                    }
                    fetchStudents();
                  }
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final classController = TextEditingController();
    final sectionController = TextEditingController();
    final rollController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Register Student"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                TextField(
                  controller: classController,
                  decoration: const InputDecoration(
                    labelText: "Class (e.g. 10)",
                  ),
                ),
                TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(
                    labelText: "Section (e.g. A)",
                  ),
                ),
                TextField(
                  controller: rollController,
                  decoration: const InputDecoration(labelText: "Roll Number"),
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
                try {
                  final res = await _api.post("/api/v1/admin/register", {
                    "role": "student",
                    "name": nameController.text,
                    "email": emailController.text,
                    "password": passwordController.text,
                    "class": classController.text,
                    "section": sectionController.text,
                    "roll_number": rollController.text,
                  });
                  if (res["success"]) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Student registered!")),
                      );
                    }
                    fetchStudents();
                  }
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Register"),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildStudentList() {
    final list = <Widget>[];
    final studentsToShow = filteredStudents;

    if (selectedSection == null || selectedSection == "All") {
      final grouped = <String, List>{};
      for (var s in studentsToShow) {
        final sec = s["section_name"] ?? "No Section";
        grouped.putIfAbsent(sec, () => []).add(s);
      }

      final sortedSections = grouped.keys.toList()..sort();
      for (var sec in sortedSections) {
        list.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            width: double.infinity,
            child: Text(
              "Section $sec",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        for (var s in grouped[sec]!) {
          list.add(_buildStudentTile(s));
        }
      }
    } else {
      for (var s in studentsToShow) {
        list.add(_buildStudentTile(s));
      }
    }
    return list;
  }

  Widget _buildStudentTile(Map s) {
    return ListTile(
      title: Text(s["name"]),
      subtitle: Text(
        "Class ${s["class"]} ${s["section"]} | Roll: ${s["roll_number"]}",
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s["email"]),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showEditStudentDialog(s),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Students")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Filter by Section"),
              value: selectedSection,
              items: [
                const DropdownMenuItem(
                  value: "All",
                  child: Text("All Sections"),
                ),
                ...sections.map(
                  (sec) => DropdownMenuItem(
                    value: sec["name"],
                    child: Text("Section ${sec["name"]}"),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() => selectedSection = val);
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(children: _buildStudentList()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
