import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'chat_screen.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  final ApiService _api = ApiService();
  bool loading = true;
  List teachers = [];

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    try {
      final response = await _api.get("/api/v1/messages/teachers");
      setState(() {
        teachers = response["data"];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Teacher")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : teachers.isEmpty
              ? const Center(child: Text("No teachers available"))
              : ListView.builder(
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final t = teachers[index];
                    return Card(
                      child: ListTile(
                        title: Text(t["name"]),
                        subtitle: Text(t["subject"]),
                        trailing: const Icon(Icons.chat),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                teacherId: t["id"],
                                teacherName: t["name"],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
