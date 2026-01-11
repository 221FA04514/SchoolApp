import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'timetable_model.dart';

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() =>
      _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  final ApiService _api = ApiService();

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  String selectedDay = "Monday";
  int selectedSectionId = 1; // later make dynamic if needed

  final TextEditingController subjectCtrl = TextEditingController();
  final TextEditingController teacherCtrl = TextEditingController();
  final TextEditingController startCtrl = TextEditingController();
  final TextEditingController endCtrl = TextEditingController();
  final TextEditingController periodCtrl = TextEditingController();

  Future<void> saveTimetable() async {
    await _api.post("/api/v1/timetable", {
      "section_id": selectedSectionId,
      "day": selectedDay,
      "period": int.parse(periodCtrl.text),
      "subject": subjectCtrl.text,
      "teacher_name": teacherCtrl.text,
      "start_time": startCtrl.text,
      "end_time": endCtrl.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Timetable saved")),
    );

    subjectCtrl.clear();
    teacherCtrl.clear();
    startCtrl.clear();
    endCtrl.clear();
    periodCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Timetable")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              items: days
                  .map(
                    (d) => DropdownMenuItem(value: d, child: Text(d)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => selectedDay = val!),
              decoration: const InputDecoration(labelText: "Select Day"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: periodCtrl,
              decoration: const InputDecoration(labelText: "Period"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(labelText: "Subject"),
            ),
            TextField(
              controller: teacherCtrl,
              decoration: const InputDecoration(labelText: "Teacher Name"),
            ),
            TextField(
              controller: startCtrl,
              decoration: const InputDecoration(labelText: "Start Time (HH:MM)"),
            ),
            TextField(
              controller: endCtrl,
              decoration: const InputDecoration(labelText: "End Time (HH:MM)"),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveTimetable,
                child: const Text("Save Timetable"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
