import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageTimetableScreen extends StatefulWidget {
  const ManageTimetableScreen({super.key});

  @override
  State<ManageTimetableScreen> createState() => _ManageTimetableScreenState();
}

class _ManageTimetableScreenState extends State<ManageTimetableScreen> {
  final ApiService _api = ApiService();

  // Data
  List sections = [];
  List teachers = [];
  List periodSettings = [];
  List timetable = [];

  // Selections
  int? selectedSectionId;

  // Loading States
  bool isLoadingInit = true;
  bool isLoadingTimetable = false;

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  // Theme Color
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple (Violet)

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final sRes = await _api.get("/api/v1/admin/sections");
      final tRes = await _api.get("/api/v1/admin/teachers");

      // Try fetching settings, fallback if empty/error
      List pData = [];
      try {
        final pRes = await _api.get("/api/v1/admin/period-settings");
        pData = pRes["data"] ?? [];
      } catch (e) {
        print("Period settings not found, using defaults");
      }

      if (mounted) {
        setState(() {
          sections = sRes["data"] ?? [];
          teachers = tRes["data"] ?? [];

          if (pData.isNotEmpty) {
            periodSettings = pData;
            // Sort periods
            periodSettings.sort(
              (a, b) =>
                  (a['period_number'] as int).compareTo(b['period_number']),
            );
          } else {
            // Fallback default periods
            periodSettings = List.generate(
              8,
              (i) => {
                "period_number": i + 1,
                "start_time": "09:00",
                "end_time": "10:00",
              },
            );
          }

          if (sections.isNotEmpty && selectedSectionId == null) {
            selectedSectionId = sections[0]["id"];
            fetchTimetable(selectedSectionId!);
          }

          isLoadingInit = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingInit = false);
      print("Error initializing data: $e");
    }
  }

  Future<void> fetchTimetable(int sectionId) async {
    setState(() => isLoadingTimetable = true);
    try {
      // Clear current timetable to avoid confusion
      setState(() => timetable = []);

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
      print("Error fetching timetable: $e");
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
                      readOnly: true,
                      decoration: _fieldDecoration(
                        "Start",
                        Icons.access_time_filled_rounded,
                      ).copyWith(fillColor: Colors.grey.shade100),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      readOnly: true,
                      decoration: _fieldDecoration("End", Icons.update_rounded)
                          .copyWith(fillColor: Colors.grey.shade100),
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
                    backgroundColor: const Color(0xFF673AB7),
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
        final pickedSuggestion = await _showConflictDialog(context, e.message, suggestions);
        
        if (pickedSuggestion != null) {
          if (pickedSuggestion == "FORCE_ASSIGN") {
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
          } else {
            // Re-run with suggested teacher
            _saveSlot(
              context,
              sectionId: sectionId,
              day: day,
              period: period,
              subject: subject,
              teacher: pickedSuggestion, 
              start: start,
              end: end,
              force: false,
            );
          }
        }
      } else {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<String?> _showConflictDialog(
    BuildContext context,
    String error,
    List<String>? suggestions,
  ) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text("Schedule Conflict"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
            if (suggestions != null && suggestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                "Available Alternatives:",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Colors.blue,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions
                      .map(
                        (s) => InkWell(
                          onTap: () => Navigator.pop(ctx, s),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.withOpacity(0.2)),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              "You can choose a suggested teacher above or override the conflict below.",
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, "FORCE_ASSIGN"),
            child: const Text(
              "Assign anyway",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            : const Color(0xFF673AB7),
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
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: const Text(
          "Timetable Studio",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHub() {
    if (sections.isEmpty && !isLoadingInit)
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Icon(Icons.folder_open_rounded, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text(
                  "Classes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: sections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final s = sections[index];
                final isSelected = s["id"] == selectedSectionId;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedSectionId = s["id"]);
                    fetchTimetable(s["id"]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF673AB7)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.withOpacity(0.2),
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(0xFF673AB7).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        s["name"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTimetableList() {
    if (selectedSectionId == null)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF673AB7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    _buildHeaderCell("Time Hub ⏱", width: 100),
                    ...days.map((d) => _buildHeaderCell(d, width: 140)),
                  ],
                ),
              ),
              // Body Rows
              ...periodSettings.map((p) {
                final pNum = p["period_number"] as int;
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Time/Period Column
                      Container(
                        width: 100,
                        height: 110,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xFF673AB7),
                              child: Text(
                                "${pNum}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${p["start_time"]}-${p["end_time"]}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Day Columns
                      ...days.map((d) {
                        final slot = timetable.firstWhere(
                          (t) => t["day"] == d && t["period"] == pNum,
                          orElse: () => null,
                        );
                        return _buildSlotCell(d, pNum, slot);
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, {double width = 100}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSlotCell(String day, int period, Map? slot) {
    if (slot == null) {
      return Container(
        width: 140,
        height: 110,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
        ),
        child: Center(
          child: IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.grey.withOpacity(0.3),
              size: 32,
            ),
            onPressed: () => _showAddSlotDialog(period: period, day: day),
          ),
        ),
      );
    }

    // Icon logic based on subject
    IconData subIcon = Icons.subject_rounded;
    Color subColor = const Color(0xFF673AB7);
    final sub = slot["subject"].toString().toLowerCase();

    if (sub.contains("sci")) {
      subIcon = Icons.science_outlined;
      subColor = Colors.teal;
    } else if (sub.contains("math")) {
      subIcon = Icons.calculate_outlined;
      subColor = Colors.orange;
    } else if (sub.contains("comp") ||
        sub.contains("py") ||
        sub.contains("c ")) {
      subIcon = Icons.computer_rounded;
      subColor = Colors.blueGrey;
    } else if (sub.contains("eng")) {
      subIcon = Icons.translate_rounded;
      subColor = Colors.indigo;
    }

    return InkWell(
      onTap: () => _showAddSlotDialog(period: period, day: day),
      child: Container(
        width: 140,
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(subIcon, size: 18, color: subColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    slot["subject"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: subColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    slot["teacher_name"],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SlidableSlotCard extends StatelessWidget {
  final Map slot;
  final VoidCallback onTap;

  const SlidableSlotCard({super.key, required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF673AB7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "P${slot['period']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot['subject'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E263E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          slot['teacher_name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${slot['start_time']} - ${slot['end_time']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_rounded, size: 16, color: Colors.blueGrey),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
