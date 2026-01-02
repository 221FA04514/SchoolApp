import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'teacher_chat_screen.dart';

class TeacherStudentListScreen extends StatefulWidget {
  const TeacherStudentListScreen({super.key});

  @override
  State<TeacherStudentListScreen> createState() =>
      _TeacherStudentListScreenState();
}

class _TeacherStudentListScreenState
    extends State<TeacherStudentListScreen> {
  final ApiService _api = ApiService();
  List students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final response = await _api.get("/api/v1/messages/students");
    setState(() {
      students = response["data"];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Messages")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(child: Text("No messages yet"))
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (_, i) {
                    final s = students[i];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(s["name"]),
                      subtitle: Text("Roll: ${s["roll_number"]}"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherChatScreen(
                              studentId: s["id"],
                              studentName: s["name"],
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
