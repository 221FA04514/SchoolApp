import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../models/homework_model.dart';

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({super.key});

  @override
  State<StudentHomeworkScreen> createState() =>
      _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen> {
  final ApiService _api = ApiService();
  bool loading = true;
  List<Homework> homeworkList = [];

  @override
  void initState() {
    super.initState();
    fetchHomework();
  }

  Future<void> fetchHomework() async {
    final res = await _api.get("/api/v1/homework/student");

    setState(() {
      homeworkList = (res["data"] as List)
          .map((h) => Homework.fromJson(h))
          .toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Homework")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : homeworkList.isEmpty
              ? const Center(child: Text("No homework assigned"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: homeworkList.length,
                  itemBuilder: (_, i) {
                    final hw = homeworkList[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          hw.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(hw.subject),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Due"),
                            Text(
                              hw.dueDate
                                  .toIso8601String()
                                  .split("T")[0],
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(hw.title),
                              content: Text(hw.description),
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
