import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'attendance_model.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List sections = [];
  List<AttendanceItem> students = [];
  List<AttendanceItem> filteredStudents = [];

  int? selectedSectionId;
  DateTime selectedDate = DateTime.now();
  bool loading = false;
  bool submitting = false;

  late AnimationController _pageController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    fetchSections();

    _searchController.addListener(_filterStudents);

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOut),
    );

    _pageController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /* ---------------- API ---------------- */

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

  /* ---------------- DATE ---------------- */

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchStudents();
    }
  }

  /* ---------------- ACTIONS ---------------- */

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
      "attendance": students.map((s) => s.toJson()).toList(), // ✅ FIXED
    });

    setState(() => submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Attendance submitted successfully")),
    );
  }

  /* ---------------- SEARCH ---------------- */

  void _filterStudents() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      filteredStudents = students.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.rollNumber.toLowerCase().contains(q);
      }).toList();
    });
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // HEADER
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A4DFF),
                Color(0xFF3A6BFF),
                Color(0xFF6A11CB),
              ],
            ),
          ),
        ),
        title: const Text("📋 Mark Attendance"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: pickDate,
          ),
        ],
      ),

      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            children: [
              // SECTION
              Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<int>(
                  value: selectedSectionId,
                  hint: const Text("📚 Select Section"),
                  items: sections
                      .map<DropdownMenuItem<int>>(
                        (s) => DropdownMenuItem(
                          value: s["id"],
                          child: Text(s["name"]),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedSectionId = v;
                      students.clear();
                      filteredStudents.clear();
                    });
                    fetchStudents();
                  },
                ),
              ),

              // DATE + MARK ALL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        "📅 ${selectedDate.toIso8601String().split("T")[0]}",
                      ),
                    ),
                    TextButton.icon(
                      onPressed:
                          students.isEmpty ? null : markAllPresent,
                      icon: const Text("✅"),
                      label: const Text("Mark All Present"),
                    ),
                  ],
                ),
              ),

              // SEARCH
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "🔍 Search student",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // GRID
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredStudents.isEmpty
                        ? const Center(child: Text("No students"))
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.05,
                            ),
                            itemCount: filteredStudents.length,
                            itemBuilder: (_, i) {
                              final s = filteredStudents[i];

                              Color bg = s.status == "present"
                                  ? Colors.green.shade100
                                  : s.status == "absent"
                                      ? Colors.red.shade100
                                      : Colors.amber.shade100;

                              return AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        const CircleAvatar(
                                          child: Text("👨‍🎓"),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          s.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Roll: ${s.rollNumber}",
                                          style: const TextStyle(
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _statusBtn("P", Colors.green,
                                            s.status == "present", () {
                                          setState(() =>
                                              s.status = "present");
                                        }),
                                        _statusBtn("A", Colors.red,
                                            s.status == "absent", () {
                                          setState(() =>
                                              s.status = "absent");
                                        }),
                                        _statusBtn("H", Colors.amber,
                                            s.status == "holiday", () {
                                          setState(() =>
                                              s.status = "holiday");
                                        }),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),

      // SUBMIT
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(14),
        child: ElevatedButton(
          onPressed: (selectedSectionId == null ||
                  students.isEmpty ||
                  submitting)
              ? null
              : submitAttendance,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: submitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("🚀 Submit Attendance"),
        ),
      ),
    );
  }

  Widget _statusBtn(
      String label, Color color, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
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
