import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageTimetableScreen extends StatefulWidget {
  const ManageTimetableScreen({super.key});

  @override
  State<ManageTimetableScreen> createState() => _ManageTimetableScreenState();
}

class _ManageTimetableScreenState extends State<ManageTimetableScreen> {
  final ApiService _api = ApiService();
  List sections = [];
  List teachers = [];
  List periodSettings = [];
  int? selectedSectionId;
  String? selectedTeacher;
  List timetable = [];
  bool isLoadingSections = true;
  bool isLoadingTeachers = true;
  bool isLoadingSettings = true;
  bool isLoadingTimetable = false;

  @override
  void initState() {
    super.initState();
    fetchSections();
    fetchTeachers();
    fetchPeriodSettings();
  }

  Future<void> fetchSections() async {
    try {
      final res = await _api.get("/api/v1/admin/sections");
      setState(() {
        sections = res["data"] ?? [];
        isLoadingSections = false;
      });
    } catch (e) {
      setState(() => isLoadingSections = false);
    }
  }

  Future<void> fetchTeachers() async {
    try {
      final res = await _api.get("/api/v1/admin/teachers");
      setState(() {
        teachers = res["data"] ?? [];
        isLoadingTeachers = false;
      });
    } catch (e) {
      setState(() => isLoadingTeachers = false);
    }
  }

  Future<void> fetchPeriodSettings() async {
    try {
      final res = await _api.get("/api/v1/admin/period-settings");
      setState(() {
        periodSettings = res["data"] ?? [];
        isLoadingSettings = false;
      });
    } catch (e) {
      setState(() => isLoadingSettings = false);
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

  void _showAddSlotDialog() {
    String selectedDay = "Monday";
    final periodController = TextEditingController();
    final subjectController = TextEditingController();
    String? currentTeacher = selectedTeacher;
    final startController = TextEditingController(text: "09:00");
    final endController = TextEditingController(text: "09:50");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Timetable Slot"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  items:
                      [
                            "Monday",
                            "Tuesday",
                            "Wednesday",
                            "Thursday",
                            "Friday",
                            "Saturday",
                          ]
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                  onChanged: (val) => selectedDay = val!,
                  decoration: const InputDecoration(labelText: "Day"),
                ),
                TextField(
                  controller: periodController,
                  decoration: const InputDecoration(
                    labelText: "Period (e.g. 1)",
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    if (val.isNotEmpty) {
                      final pNum = int.tryParse(val);
                      final setting = periodSettings.firstWhere(
                        (s) => s["period_number"] == pNum,
                        orElse: () => null,
                      );
                      if (setting != null) {
                        setState(() {
                          startController.text = setting["start_time"];
                          endController.text = setting["end_time"];
                        });
                      }
                    }
                  },
                ),
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: "Subject"),
                ),
                DropdownButtonFormField<String>(
                  value: currentTeacher,
                  hint: const Text("Select Teacher"),
                  items: teachers.map<DropdownMenuItem<String>>((t) {
                    return DropdownMenuItem(
                      value: t["name"],
                      child: Text(t["name"]),
                    );
                  }).toList(),
                  onChanged: (val) => currentTeacher = val,
                  decoration: const InputDecoration(labelText: "Teacher"),
                ),
                TextField(
                  controller: startController,
                  decoration: const InputDecoration(
                    labelText: "Start Time (HH:mm)",
                  ),
                ),
                TextField(
                  controller: endController,
                  decoration: const InputDecoration(
                    labelText: "End Time (HH:mm)",
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
                if (periodController.text.isEmpty || currentTeacher == null)
                  return;
                try {
                  final res = await _api.post("/api/v1/timetable", {
                    "section_id": selectedSectionId,
                    "day": selectedDay,
                    "period": int.parse(periodController.text),
                    "subject": subjectController.text,
                    "teacher_name": currentTeacher,
                    "start_time": startController.text,
                    "end_time": endController.text,
                  });
                  if (res["success"]) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Slot added!")),
                      );
                    }
                    fetchTimetable(selectedSectionId!);
                  }
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Add Slot"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Timetable")),
      body: Column(
        children: [
          if (isLoadingSections)
            const LinearProgressIndicator()
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<int>(
                value: selectedSectionId,
                hint: const Text("Select Section"),
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
              ),
            ),
          Expanded(
            child: isLoadingTimetable
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: timetable.length,
                    itemBuilder: (context, index) {
                      final t = timetable[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(t["period"].toString()),
                        ),
                        title: Text("${t["subject"]} (${t["day"]})"),
                        subtitle: Text(
                          "${t["teacher_name"]} | ${t["start_time"]} - ${t["end_time"]}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Slot"),
                                content: const Text(
                                  "Are you sure you want to delete this slot?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await _api.delete(
                                  "/api/v1/timetable/${t["id"]}",
                                );
                                fetchTimetable(selectedSectionId!);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error: ${e.toString()}"),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedSectionId == null ? null : _showAddSlotDialog,
        backgroundColor: selectedSectionId == null ? Colors.grey : null,
        child: const Icon(Icons.add),
      ),
    );
  }
}
