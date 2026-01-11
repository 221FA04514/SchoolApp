import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'timetable_model.dart';

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  final ApiService _api = ApiService();
  List sections = [];
  int? selectedSectionId;
  List timetable = [];
  bool isLoadingSections = true;
  bool isLoadingTimetable = false;

  @override
  void initState() {
    super.initState();
    fetchSections();
  }

  Future<void> fetchSections() async {
    try {
      final res = await _api.get("/api/v1/sections");
      setState(() {
        sections = res["data"] ?? [];
        isLoadingSections = false;
        if (sections.isNotEmpty) {
          selectedSectionId = sections[0]["id"];
          fetchTimetable(selectedSectionId!);
        }
      });
    } catch (e) {
      setState(() => isLoadingSections = false);
    }
  }

  Future<void> fetchTimetable(int sectionId) async {
    setState(() => isLoadingTimetable = true);
    try {
      final res = await _api.get(
        "/api/v1/timetable/section?section_id=$sectionId",
      );
      setState(() {
        timetable = res["data"] ?? [];
        isLoadingTimetable = false;
      });
    } catch (e) {
      setState(() => isLoadingTimetable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Timetable")),
      body: Column(
        children: [
          if (isLoadingSections)
            const LinearProgressIndicator()
          else if (sections.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No sections assigned to you."),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<int>(
                value: selectedSectionId,
                items: sections.map<DropdownMenuItem<int>>((s) {
                  return DropdownMenuItem(
                    value: s["id"],
                    child: Text(s["name"]),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => selectedSectionId = val);
                  if (val != null) fetchTimetable(val);
                },
                decoration: const InputDecoration(labelText: "Select Section"),
              ),
            ),
          Expanded(
            child: isLoadingTimetable
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: timetable.length,
                    itemBuilder: (context, index) {
                      final t = timetable[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(t["period"].toString()),
                          ),
                          title: Text("${t["subject"]} (${t["day"]})"),
                          subtitle: Text(
                            "${t["start_time"]} - ${t["end_time"]}",
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
