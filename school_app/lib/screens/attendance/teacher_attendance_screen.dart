import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'attendance_model.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final ApiService _api = ApiService();

  List<AttendanceItem> students = [];
  bool loading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final response =
          await _api.get("/api/v1/attendance/students");

      final List data = response["data"];

      setState(() {
        students = data
            .map(
              (s) => AttendanceItem(
                studentId: s["student_id"],
                name: s["name"],
                rollNumber: s["roll_number"],
              ),
            )
            .toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load students")),
      );
    }
  }

  Future<void> submitAttendance() async {
    try {
      final body = {
        "date": selectedDate.toIso8601String().split("T")[0],
        "attendance": students.map((s) => s.toJson()).toList(),
      };

      await _api.post("/api/v1/attendance/submit", body);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance submitted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submit failed")),
      );
    }
  }

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: pickDate,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "Date: ${selectedDate.toIso8601String().split("T")[0]}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (_, i) {
                      final s = students[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(s.name),
                          subtitle: Text("Roll: ${s.rollNumber}"),
                          trailing: DropdownButton<String>(
                            value: s.status,
                            items: const [
                              DropdownMenuItem(
                                  value: "present",
                                  child: Text("Present")),
                              DropdownMenuItem(
                                  value: "absent",
                                  child: Text("Absent")),
                              DropdownMenuItem(
                                  value: "holiday",
                                  child: Text("Holiday")),
                            ],
                            onChanged: (val) {
                              setState(() {
                                s.status = val!;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitAttendance,
                      child: const Text("Submit Attendance"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
