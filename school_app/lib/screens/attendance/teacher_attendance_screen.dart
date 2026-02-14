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
        .map<AttendanceItem>(
          (s) => AttendanceItem(
            studentId: s["student_id"],
            name: s["name"],
            rollNumber: s["roll_number"],
          ),
        )
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

  void markClassHoliday() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mark Class Holiday?"),
        content: const Text(
          "This will mark 'Holiday' status for ALL students in this section. Existing entries will be overwritten.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              setState(() {
                for (var s in students) {
                  s.status = "holiday";
                }
                filteredStudents = List.from(students);
              });
              Navigator.pop(ctx);
            },
            child: const Text(
              "Mark Holiday",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitAttendance() async {
    if (selectedSectionId == null || students.isEmpty) return;

    setState(() => submitting = true);

    try {
      await _api.post("/api/v1/attendance/submit", {
        "date": selectedDate.toIso8601String().split("T")[0],
        "attendance": students.map((s) => s.toJson()).toList(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Attendance submitted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
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
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          // ================= HEADER BACKGROUND =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                color: const Color(0xFF4A00E0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          // ================= BODY CONTENT =================
          SafeArea(
            child: Column(
              children: [
                // ------ APP BAR ROW ------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const BackButton(color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            "Mark Attendance",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // GLOBAL HOLIDAY BUTTON
                      if (students.isNotEmpty)
                        GestureDetector(
                          onTap: markClassHoliday,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.holiday_village_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Holiday",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ------ CONTROLS CARD ------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Row 1: Date & Section
                        Row(
                          children: [
                            // DATE PICKER
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: pickDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F8FB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_rounded,
                                        size: 18,
                                        color: Colors.blueGrey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        selectedDate.toIso8601String().split(
                                          "T",
                                        )[0],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // SECTION DROP DOWN
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F8FB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: selectedSectionId,
                                    hint: const Text(
                                      "Section",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    isExpanded: true,
                                    items: sections.map<DropdownMenuItem<int>>((
                                      s,
                                    ) {
                                      return DropdownMenuItem(
                                        value: s["id"],
                                        child: Text(
                                          s["name"],
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
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
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Row 2: Search + Mark All
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 0,
                                  ),
                                  hintText: "Search student...",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF6F8FB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    size: 20,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                            if (students.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: markAllPresent,
                                child: const Text("Reset All"),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ------ STUDENT LIST ------
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredStudents.isEmpty
                      ? const Center(
                          child: Text(
                            "No students found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 100,
                          ),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final s = filteredStudents[index];
                            final isHoliday = s.status == "holiday";

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: isHoliday
                                      ? Colors.amber.shade100
                                      : const Color(0xFFF0F4FF),
                                  child: Text(
                                    s.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isHoliday
                                          ? Colors.amber.shade800
                                          : const Color(0xFF1fa2ff),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  "Roll No: ${s.rollNumber}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                trailing: isHoliday
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.amber.shade200,
                                          ),
                                        ),
                                        child: const Text(
                                          "HOLIDAY",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // PRESENT BUTTON
                                          _statusOption(
                                            s,
                                            "P",
                                            "present",
                                            Colors.green,
                                          ),
                                          const SizedBox(width: 8),
                                          // ABSENT BUTTON
                                          _statusOption(
                                            s,
                                            "A",
                                            "absent",
                                            Colors.red,
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: filteredStudents.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: submitting ? null : submitAttendance,
              backgroundColor: const Color(0xFF1fa2ff),
              label: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Submit Attendance"),
              icon: submitting ? null : const Icon(Icons.check_circle_rounded),
            )
          : null,
    );
  }

  Widget _statusOption(
    AttendanceItem s,
    String label,
    String statusValue,
    Color color,
  ) {
    bool isSelected = s.status == statusValue;
    return GestureDetector(
      onTap: () {
        setState(() => s.status = statusValue);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade400,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
