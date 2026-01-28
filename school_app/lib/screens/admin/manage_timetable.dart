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
      if (mounted) {
        setState(() {
          sections = res["data"] ?? [];
          if (sections.isNotEmpty && selectedSectionId == null) {
            selectedSectionId = sections[0]["id"];
            fetchTimetable(selectedSectionId!);
          }
          isLoadingSections = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingSections = false);
    }
  }

  Future<void> fetchTeachers() async {
    try {
      final res = await _api.get("/api/v1/admin/teachers");
      if (mounted) {
        setState(() {
          teachers = res["data"] ?? [];
          isLoadingTeachers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingTeachers = false);
    }
  }

  Future<void> fetchPeriodSettings() async {
    try {
      final res = await _api.get("/api/v1/admin/period-settings");
      if (mounted) {
        setState(() {
          periodSettings = res["data"] ?? [];
          isLoadingSettings = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingSettings = false);
    }
  }

  Future<void> fetchTimetable(int sectionId) async {
    setState(() => isLoadingTimetable = true);
    try {
      final res = await _api.get(
        "/api/v1/timetable/section?section_id=$sectionId",
      );
      if (mounted) {
        setState(() {
          timetable = res["data"] ?? [];
          isLoadingTimetable = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingTimetable = false);
    }
  }

  void _showAddSlotDialog({int? period, String? day}) {
    String selectedDay = day ?? "Monday";
    final periodController = TextEditingController(
      text: period?.toString() ?? "",
    );
    final subjectController = TextEditingController();
    String? currentTeacher;

    // Auto-fill times if period is provided
    final initialSetting = period != null
        ? periodSettings.firstWhere(
            (s) => s["period_number"] == period,
            orElse: () => null,
          )
        : null;

    final startController = TextEditingController(
      text: initialSetting?["start_time"] ?? "09:00",
    );
    final endController = TextEditingController(
      text: initialSetting?["end_time"] ?? "09:50",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "🗓️ Schedule Session",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
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
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                onChanged: (val) => setDialogState(() => selectedDay = val!),
                decoration: _fieldDecoration(
                  "Day of Week",
                  Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: periodController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          final pNum = int.tryParse(val);
                          final setting = periodSettings.firstWhere(
                            (s) => s["period_number"] == pNum,
                            orElse: () => null,
                          );
                          if (setting != null) {
                            setDialogState(() {
                              startController.text = setting["start_time"];
                              endController.text = setting["end_time"];
                            });
                          }
                        }
                      },
                      decoration: _fieldDecoration(
                        "Period #",
                        Icons.tag_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: subjectController,
                      onChanged: (val) {
                        setDialogState(() {}); // Re-sorts teachers in dropdown
                      },
                      decoration: _fieldDecoration(
                        "Subject",
                        Icons.book_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: currentTeacher,
                hint: const Text("Select Teacher"),
                items: (() {
                  // Priority Sorting Logic
                  List sortedTeachers = List.from(teachers);
                  String filter = subjectController.text.toLowerCase().trim();

                  if (filter.isNotEmpty) {
                    sortedTeachers.sort((a, b) {
                      bool aMatches =
                          a["subject"]?.toString().toLowerCase().contains(
                            filter,
                          ) ??
                          false;
                      bool bMatches =
                          b["subject"]?.toString().toLowerCase().contains(
                            filter,
                          ) ??
                          false;

                      if (aMatches && !bMatches) return -1;
                      if (!aMatches && bMatches) return 1;
                      return 0;
                    });
                  }

                  return sortedTeachers.map<DropdownMenuItem<String>>((t) {
                    bool isMatch =
                        filter.isNotEmpty &&
                        (t["subject"]?.toString().toLowerCase().contains(
                              filter,
                            ) ??
                            false);
                    return DropdownMenuItem(
                      value: t["name"],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t["name"]),
                          if (t["subject"] != null)
                            Text(
                              " (${t["subject"]})",
                              style: TextStyle(
                                fontSize: 12,
                                color: isMatch ? Colors.blue : Colors.grey,
                                fontWeight: isMatch
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList();
                })(),
                onChanged: (val) {
                  setDialogState(() {
                    currentTeacher = val;
                    if (subjectController.text.isEmpty && val != null) {
                      final selected = teachers.firstWhere(
                        (t) => t["name"] == val,
                        orElse: () => null,
                      );
                      if (selected != null && selected["subject"] != null) {
                        subjectController.text = selected["subject"];
                      }
                    }
                  });
                },
                isExpanded: true,
                decoration: _fieldDecoration(
                  "Assign Teacher",
                  Icons.person_rounded,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      decoration: _fieldDecoration(
                        "Start",
                        Icons.access_time_filled_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      decoration: _fieldDecoration("End", Icons.update_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A4DFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _saveSlot(
                    context,
                    sectionId: selectedSectionId,
                    day: selectedDay,
                    period: periodController.text,
                    subject: subjectController.text,
                    teacher: currentTeacher,
                    start: startController.text,
                    end: endController.text,
                  ),
                  child: const Text(
                    "Save Slot",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSlot(
    BuildContext context, {
    required int? sectionId,
    required String day,
    required String period,
    required String subject,
    required String? teacher,
    required String start,
    required String end,
    bool force = false,
  }) async {
    if (period.isEmpty || teacher == null) return;
    try {
      final res = await _api.post("/api/v1/timetable", {
        "section_id": sectionId,
        "day": day,
        "period": int.parse(period),
        "subject": subject,
        "teacher_name": teacher,
        "start_time": start,
        "end_time": end,
        "force": force,
      });

      if (res["success"]) {
        if (context.mounted) Navigator.pop(context);
        fetchTimetable(sectionId!);
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 409) {
        final suggestions = (e.data["data"]?["suggestions"] as List?)
            ?.cast<String>();
        _showConflictDialog(context, e.message, suggestions, () {
          _saveSlot(
            context,
            sectionId: sectionId,
            day: day,
            period: period,
            subject: subject,
            teacher: teacher,
            start: start,
            end: end,
            force: true,
          );
        });
      } else {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _showConflictDialog(
    BuildContext context,
    String error,
    List<String>? suggestions,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("⚠️ Schedule Overlap"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error, style: const TextStyle(fontWeight: FontWeight.w500)),
            if (suggestions != null && suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "Available Teachers:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: suggestions
                    .map(
                      (s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.blue.withOpacity(0.05),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              "You can either double-book or choose someone else.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text(
              "Assign anyway",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey.shade300),
      filled: true,
      fillColor: const Color(0xFFF4F6FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildSectionHub(),
          isLoadingTimetable
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildTimetableList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedSectionId == null
            ? null
            : () => _showAddSlotDialog(),
        backgroundColor: selectedSectionId == null
            ? Colors.grey
            : const Color(0xFF1A4DFF),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text(
          "Add Slot",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A4DFF),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          "Timetable Studio",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A4DFF), Color(0xFF0031D1)],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHub() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "📂 Classes",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 45,
              child: isLoadingSections
                  ? const Center(child: LinearProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sections.length,
                      itemBuilder: (context, index) {
                        final s = sections[index];
                        final isSelected = selectedSectionId == s["id"];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(s["name"]),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setState(() => selectedSectionId = s["id"]);
                                fetchTimetable(s["id"]);
                              }
                            },
                            selectedColor: const Color(0xFF1A4DFF),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: Colors.white,
                            elevation: isSelected ? 4 : 0,
                            pressElevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableList() {
    if (periodSettings.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("Please configure Period Settings first.")),
      );
    }

    final days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
    ];

    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  _buildCell("Time Hub ⏱️", isHeader: true, width: 100),
                  ...days.map((d) => _buildCell(d, isHeader: true, width: 140)),
                ],
              ),
              // Data Rows
              ...periodSettings.map((s) {
                final period = s["period_number"];
                return Row(
                  children: [
                    // Time Label Column
                    _buildTimeLabelCell(s, width: 100),
                    // Days Matrix
                    ...days.map((day) {
                      final slot = timetable.firstWhere(
                        (t) => t["day"] == day && t["period"] == period,
                        orElse: () => null,
                      );
                      return _buildGridSlot(slot, period, day, width: 140);
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String text, {bool isHeader = false, double width = 120}) {
    return Container(
      width: width,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFF1E263E) : Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? Colors.white : const Color(0xFF1E263E),
          fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500,
          fontSize: isHeader ? 13 : 14,
        ),
      ),
    );
  }

  Widget _buildTimeLabelCell(Map s, {double width = 100}) {
    return Container(
      width: width,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A4DFF).withOpacity(0.03),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF1A4DFF),
            child: Text(
              s["period_number"].toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              "${s["start_time"]}-${s["end_time"]}",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSlot(Map? t, int period, String day, {double width = 140}) {
    if (t == null) {
      return Container(
        width: width,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: InkWell(
          onTap: () => _showAddSlotDialog(period: period, day: day),
          child: Center(
            child: Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.blue.withOpacity(0.3),
              size: 18,
            ),
          ),
        ),
      );
    }

    String emoji = "📚";
    final sub = t["subject"].toString().toLowerCase();
    if (sub.contains("math"))
      emoji = "📐";
    else if (sub.contains("science") || sub.contains("physics"))
      emoji = "🔬";
    else if (sub.contains("yoga") || sub.contains("pt"))
      emoji = "🏆";
    else if (sub.contains("python"))
      emoji = "🖥️";

    return Container(
      width: width,
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onLongPress: () => _confirmDelete(t),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(
                "$emoji ${t["subject"]}",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFF1A4DFF),
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                "👔 ${t["teacher_name"]}",
                style: TextStyle(
                  color: Colors.blueGrey.shade400,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Slot?"),
        content: Text("Discard '${t["subject"]}' session for '${t["day"]}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep it"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _api.delete("/api/v1/timetable/${t["id"]}");
        fetchTimetable(selectedSectionId!);
      } catch (e) {}
    }
  }
}
