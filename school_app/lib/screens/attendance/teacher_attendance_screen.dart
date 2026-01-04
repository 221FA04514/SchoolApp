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
  final TextEditingController _searchController = TextEditingController();

  List sections = [];
  List<AttendanceItem> students = [];
  List<AttendanceItem> filteredStudents = [];

  int? selectedSectionId;
  DateTime selectedDate = DateTime.now();
  bool loading = false;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    fetchSections();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /* ------------------ API CALLS ------------------ */

  Future<void> fetchSections() async {
    final res = await _api.get("/api/v1/sections");
    setState(() => sections = res["data"]);
  }

  Future<void> fetchStudents() async {
    if (selectedSectionId == null) return;

    setState(() => loading = true);

    final res = await _api.get(
      "/api/v1/attendance/students?section_id=$selectedSectionId",
    );

    students = res["data"]
        .map<AttendanceItem>((s) => AttendanceItem(
              studentId: s["student_id"],
              name: s["name"],
              rollNumber: s["roll_number"],
            ))
        .toList();

    filteredStudents = List.from(students);

    setState(() => loading = false);
  }

  /* ------------------ DATE PICKER ------------------ */

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(), // 🔒 NO FUTURE
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchStudents(); // reload attendance for date
    }
  }

  /* ------------------ ACTIONS ------------------ */

  void markAllPresent() {
    setState(() {
      for (var s in students) {
        s.status = "present";
      }
      filteredStudents = List.from(students);
    });
  }

  Future<void> submitAttendance() async {
    if (selectedSectionId == null || students.isEmpty) return;

    setState(() => submitting = true);

    await _api.post("/api/v1/attendance/submit", {
      "date": selectedDate.toIso8601String().split("T")[0],
      "attendance": students.map((s) => s.toJson()).toList(),
    });

    setState(() => submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Attendance submitted successfully")),
    );
  }

  /* ------------------ SEARCH ------------------ */

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredStudents = students.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.rollNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  /* ------------------ UI ------------------ */

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
      body: Column(
        children: [
          /* -------- SECTION SELECT -------- */
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButtonFormField<int>(
              hint: const Text("Select Section"),
              value: selectedSectionId,
              items: sections
                  .map<DropdownMenuItem<int>>(
                    (s) => DropdownMenuItem(
                      value: s["id"],
                      child: Text(s["name"]),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedSectionId = val;
                  students.clear();
                  filteredStudents.clear();
                });
                fetchStudents();
              },
            ),
          ),

          /* -------- DATE + MARK ALL -------- */
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date: ${selectedDate.toIso8601String().split("T")[0]}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed:
                      students.isEmpty ? null : markAllPresent,
                  child: const Text("Mark All Present"),
                ),
              ],
            ),
          ),

          /* -------- SEARCH -------- */
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search student",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          /* -------- GRID -------- */
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredStudents.isEmpty
                    ? const Center(child: Text("No students"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: filteredStudents.length,
                        itemBuilder: (_, i) {
                          final s = filteredStudents[i];

                          Color bg;
                          if (s.status == "present") {
                            bg = Colors.green.shade100;
                          } else if (s.status == "absent") {
                            bg = Colors.red.shade100;
                          } else {
                            bg = Colors.amber.shade100;
                          }

                          return Card(
                            color: bg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        s.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Roll: ${s.rollNumber}"),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _statusBtn("P", Colors.green,
                                          s.status == "present", () {
                                        setState(
                                            () => s.status = "present");
                                      }),
                                      _statusBtn("A", Colors.red,
                                          s.status == "absent", () {
                                        setState(
                                            () => s.status = "absent");
                                      }),
                                      _statusBtn("H", Colors.amber,
                                          s.status == "holiday", () {
                                        setState(
                                            () => s.status = "holiday");
                                      }),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      /* -------- STICKY SUBMIT BAR -------- */
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: (selectedSectionId == null ||
                  students.isEmpty ||
                  submitting)
              ? null
              : submitAttendance,
          child: submitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Submit Attendance"),
        ),
      ),
    );
  }

  /* ------------------ HELPER ------------------ */

  Widget _statusBtn(
      String label, Color color, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
