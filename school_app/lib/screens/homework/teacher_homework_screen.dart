import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../models/homework_model.dart';
import 'teacher_create_homework_screen.dart';

class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  State<TeacherHomeworkScreen> createState() =>
      _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState
    extends State<TeacherHomeworkScreen> {
  final ApiService _api = ApiService();
  bool loading = true;
  List homeworkList = [];

  @override
  void initState() {
    super.initState();
    fetchHomework();
  }

  Future<void> fetchHomework() async {
    final res = await _api.get("/api/v1/homework/teacher");
    setState(() {
      homeworkList = res["data"];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Homework")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TeacherCreateHomeworkScreen(),
            ),
          );

          if (created == true) {
            setState(() => loading = true);
            fetchHomework();
          }
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : homeworkList.isEmpty
              ? const Center(child: Text("No homework posted"))
              : ListView.builder(
                  itemCount: homeworkList.length,
                  itemBuilder: (_, i) {
                    final h = homeworkList[i];
                    return ListTile(
                      title: Text(h["title"]),
                      subtitle: Text(
                          "Section: ${h["section"]} | Subject: ${h["subject"]}"),
                      trailing: Text(h["due_date"]),
                    );
                  },
                ),
    );
  }
}
