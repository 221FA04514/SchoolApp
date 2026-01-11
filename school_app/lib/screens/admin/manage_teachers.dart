import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  final ApiService _api = ApiService();
  List teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    try {
      final res = await _api.get("/api/v1/admin/teachers");
      setState(() {
        teachers = res["data"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showAddTeacherDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final subjectController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Register Teacher"),
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
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: "Subject"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone (Optional)",
                  ),
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
                    "role": "teacher",
                    "name": nameController.text,
                    "email": emailController.text,
                    "password": passwordController.text,
                    "subject": subjectController.text,
                    "phone": phoneController.text,
                  });
                  if (res["success"]) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Teacher registered!")),
                      );
                    }
                    fetchTeachers();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Teachers")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final t = teachers[index];
                return ListTile(
                  title: Text(t["name"]),
                  subtitle: Text("${t["subject"]} | ${t["email"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t["phone"] ?? ""),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditTeacherDialog(t),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTeacherDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditTeacherDialog(Map t) {
    final nameController = TextEditingController(text: t["name"]);
    final emailController = TextEditingController(text: t["email"]);
    final passwordController = TextEditingController();
    final subjectController = TextEditingController(text: t["subject"]);
    final phoneController = TextEditingController(text: t["phone"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Teacher"),
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
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: "Subject"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone (Optional)",
                  ),
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
                      .put("/api/v1/admin/users/${t["user_id"]}", {
                        "role": "teacher",
                        "name": nameController.text,
                        "email": emailController.text,
                        "password": passwordController.text,
                        "subject": subjectController.text,
                        "phone": phoneController.text,
                      });
                  if (res["success"]) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Teacher updated!")),
                      );
                    }
                    fetchTeachers();
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
}
