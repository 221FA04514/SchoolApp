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
<<<<<<< HEAD
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
=======
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

          isLoadingInit = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingInit = false);
      print("Error initializing data: $e");
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
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
<<<<<<< HEAD
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
=======
      print("Error fetching timetable: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Robustly get periods
    final periods = periodSettings
        .map((p) => p["period_number"] as int)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Timetable Studio"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header / Filter
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.folder_open, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      "Classes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (isLoadingInit)
                  LinearProgressIndicator(color: primaryColor)
                else if (sections.isEmpty)
                  const Text(
                    "No sections found. Create sections first.",
                    style: TextStyle(color: Colors.red),
                  )
                else
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sections.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final s = sections[index];
                        final isSelected = s["id"] == selectedSectionId;
                        return InkWell(
                          onTap: () {
                            setState(() => selectedSectionId = s["id"]);
                            fetchTimetable(s["id"]);
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                s["name"],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: selectedSectionId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Select a class to view/edit timetable",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : isLoadingTimetable
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          primaryColor, // Violet Header
                        ),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        dataRowMinHeight: 100, // Taller rows for rich content
                        dataRowMaxHeight: 110,
                        columnSpacing: 25,
                        horizontalMargin: 20,
                        border: TableBorder(
                          verticalInside: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          horizontalInside: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        columns: [
                          const DataColumn(
                            label: Row(
                              children: [
                                Text("Time Hub"),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.timer_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          ...days.map(
                            (d) => DataColumn(
                              label: SizedBox(
                                width: 120, // Fixed width for columns
                                child: Text(d, textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        ],
                        rows: periods.map<DataRow>((pNum) {
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
                          final setting = periodSettings.firstWhere(
                            (s) => s["period_number"] == pNum,
                            orElse: () => null,
                          );
<<<<<<< HEAD
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
=======
                          final timeLabel = setting != null
                              ? "${setting['start_time']}-${setting['end_time']}"
                              : "";

                          return DataRow(
                            cells: [
                              // Period Column
                              DataCell(
                                Container(
                                  width: 80,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  color: const Color(
                                    0xFFF8F9FA,
                                  ), // Light grey bg for period col
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: primaryColor, // Violet Bubble
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          "$pNum",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        timeLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Day Columns
                              ...days.map((day) {
                                final slot = getSlot(day, pNum);
                                final isSlot = slot != null;
                                return DataCell(
                                  InkWell(
                                    onTap: () => _showSlotDialog(
                                      day: day,
                                      periodNum: pNum,
                                    ),
                                    child: Container(
                                      width: 120,
                                      padding: const EdgeInsets.all(8),
                                      child: isSlot
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Subject Row
                                                Row(
                                                  children: [
                                                    Icon(
                                                      _getSubjectIcon(
                                                        slot["subject"],
                                                      ),
                                                      size: 16,
                                                      color: _getSubjectColor(
                                                        slot["subject"],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        slot["subject"],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                          color:
                                                              _getSubjectColor(
                                                                slot["subject"],
                                                              ),
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                // Teacher Row
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.person_outline,
                                                      size: 14,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        slot["teacher_name"],
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey
                                                              .shade700,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Center(
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.grey.shade400,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
      ),
    );
  }

<<<<<<< HEAD
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
=======
  // --- Helper Methods ---

  Map<String, dynamic>? getSlot(String day, int periodNum) {
    try {
      final slot = timetable.firstWhere((t) {
        // Robust comparison for period (int vs string)
        final p = t["period"];
        final pInt = (p is int) ? p : int.tryParse(p.toString()) ?? -1;
        return t["day"] == day && pInt == periodNum;
      }, orElse: () => null);

      // Ensure result is castable to Map<String, dynamic> or return null
      if (slot != null && slot is Map) {
        return Map<String, dynamic>.from(slot);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  // ... (rest of methods unchanged, skipping to color/icon Logic)

  IconData _getSubjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains("math")) return Icons.calculate_outlined;
    if (s.contains("science") || s.contains("physics"))
      return Icons.science_outlined;
    if (s.contains("chem")) return Icons.science;
    if (s.contains("bio")) return Icons.biotech;
    if (s.contains("computer") ||
        s.contains("prog") ||
        s.contains("python") ||
        s.contains("java") ||
        s == "c" ||
        s == "c++" ||
        s == "cpp")
      return Icons.computer;
    if (s.contains("eng")) return Icons.menu_book;
    if (s.contains("hist") || s.contains("geo")) return Icons.public;
    if (s.contains("sport") || s.contains("game")) return Icons.sports_soccer;
    if (s.contains("art") || s.contains("draw")) return Icons.palette_outlined;
    return Icons.book_outlined;
  }

  Color _getSubjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains("math")) return Colors.amber.shade700;
    if (s.contains("science")) return Colors.blue.shade600;
    if (s.contains("computer") ||
        s.contains("tech") ||
        s == "c" ||
        s == "c++" ||
        s == "cpp")
      return Colors.purple.shade600;
    if (s.contains("eng")) return Colors.red.shade400;
    if (s.contains("sport")) return Colors.green.shade600;
    return const Color(0xFF2C3E50);
  }

  void _showSlotDialog({required String day, required int periodNum}) {
    if (teachers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No teachers available. Please add teachers first."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final existingSlot = getSlot(day, periodNum);
    final setting = periodSettings.firstWhere(
      (p) => p["period_number"] == periodNum,
      orElse: () => {},
    );

    final subjectController = TextEditingController(
      text: existingSlot?["subject"] ?? "",
    );

    // Ensure selectedTeacher is a valid teacher name from our list, or null
    String? selectedTeacher = existingSlot?["teacher_name"];
    if (selectedTeacher != null &&
        !teachers.any((t) => t["name"] == selectedTeacher)) {
      selectedTeacher = null; // Reset if teacher no longer exists
    }

    final startController = TextEditingController(
      text: existingSlot?["start_time"] ?? setting["start_time"] ?? "09:00",
    );
    final endController = TextEditingController(
      text: existingSlot?["end_time"] ?? setting["end_time"] ?? "09:45",
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.edit_calendar, color: primaryColor),
              const SizedBox(width: 10),
              Text(
                "$day - Period $periodNum",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: "Subject",
                      labelStyle: TextStyle(color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: Icon(Icons.book, color: primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Subject is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedTeacher,
                    hint: const Text("Select Teacher"),
                    items: teachers.map<DropdownMenuItem<String>>((t) {
                      return DropdownMenuItem(
                        value: t["name"],
                        child: Text(t["name"] ?? "Unnamed"),
                      );
                    }).toList(),
                    onChanged: (val) => selectedTeacher = val,
                    decoration: InputDecoration(
                      labelText: "Teacher",
                      labelStyle: TextStyle(color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: Icon(Icons.person, color: primaryColor),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "Teacher is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: startController,
                          decoration: InputDecoration(
                            labelText: "Start Time",
                            labelStyle: TextStyle(color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: endController,
                          decoration: InputDecoration(
                            labelText: "End Time",
                            labelStyle: TextStyle(color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (existingSlot != null)
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Confirm Delete"),
                      content: const Text("Delete this slot?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _deleteSlot(existingSlot["id"]);
                    if (mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text("Delete"),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final success = await _saveSlot(
                    id: existingSlot?["id"], // Pass existing ID if any
                    day: day,
                    period: periodNum,
                    subject: subjectController.text,
                    teacherName: selectedTeacher!,
                    startTime: startController.text,
                    endTime: endController.text,
                  );

                  if (success && mounted) Navigator.pop(context);
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
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

<<<<<<< HEAD
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
=======
  Future<bool> _saveSlot({
    int? id,
    required String day,
    required int period,
    required String subject,
    required String teacherName,
    required String startTime,
    required String endTime,
  }) async {
    try {
      // 1. Try to find ID from local list if not provided (Safety check)
      if (id == null) {
        final conflict = getSlot(day, period);
        if (conflict != null) id = conflict['id'];
      }

      // 2. If we stand to overwrite (id != null), DELETE first
      if (id != null) {
        try {
          await _api.delete("/api/v1/timetable/$id");
        } catch (e) {
          print("Delete failed (maybe already gone): $e");
        }
      }

      // 3. Attempt Creation
      await _attemptPost(day, period, subject, teacherName, startTime, endTime);
      return true;
    } catch (e) {
      final errString = e.toString().toLowerCase();
      // 4. Handle Duplicate/Constraint Error
      if (errString.contains("duplicate") ||
          errString.contains("already has a slot")) {
        try {
          print("Detected duplicate. Attempting auto-fix...");

          // A. Refresh data to find the hidden conflict
          // We can't await fetchTimetable here easily without messy state,
          // but we can try to delete blind if we knew the ID, but we don't.
          // So we MUST fetch.
          final res = await _api.get(
            "/api/v1/timetable/section?section_id=$selectedSectionId",
          );
          final freshList = res["data"] ?? [];
          final conflict = freshList.firstWhere(
            (t) => t["day"] == day && t["period"] == period,
            orElse: () => null,
          );

          if (conflict != null) {
            // B. Delete the conflict
            await _api.delete("/api/v1/timetable/${conflict['id']}");

            // C. Retry Post
            await _attemptPost(
              day,
              period,
              subject,
              teacherName,
              startTime,
              endTime,
            );

            // Refresh UI
            if (mounted) fetchTimetable(selectedSectionId!);
            return true;
          }
        } catch (retryErr) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Retry failed: $retryErr")));
          }
        }
      }

      // 5. Handle Teacher Conflict (Busy elsewhere)
      if (errString.contains("assigned elsewhere")) {
        if (mounted) {
          final shouldForce = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Teacher Busy"),
                ],
              ),
              content: Text(
                "Teacher '$teacherName' is already teaching in another class at this time.\n\nDo you want to assign them anyway?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    "Assign Anyway",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );

          if (shouldForce == true) {
            try {
              await _attemptPost(
                day,
                period,
                subject,
                teacherName,
                startTime,
                endTime,
                force: true,
              );
              return true;
            } catch (forceErr) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Force assign failed: $forceErr")),
                );
              }
              return false;
            }
          } else {
            return false;
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
      return false;
    }
  }

  Future<void> _attemptPost(
    String day,
    int period,
    String subject,
    String teacherName,
    String startTime,
    String endTime, {
    bool force = false,
  }) async {
    final res = await _api.post("/api/v1/timetable", {
      "section_id": selectedSectionId,
      "day": day,
      "period": period,
      "subject": subject,
      "teacher_name": teacherName,
      "start_time": startTime,
      "end_time": endTime,
      "force": force,
    });

    if (res["success"]) {
      if (mounted) fetchTimetable(selectedSectionId!);
    } else {
      throw Exception(res["message"] ?? "Failed to save slot");
    }
  }

  Future<void> _deleteSlot(int id) async {
    try {
      await _api.delete("/api/v1/timetable/$id");
      if (mounted) fetchTimetable(selectedSectionId!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error deleting: $e")));
      }
    }
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
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
