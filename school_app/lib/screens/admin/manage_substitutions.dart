import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:intl/intl.dart';
=======
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
import '../../core/api/api_service.dart';

class ManageSubstitutionsScreen extends StatefulWidget {
  const ManageSubstitutionsScreen({super.key});

  @override
  State<ManageSubstitutionsScreen> createState() =>
      _ManageSubstitutionsScreenState();
}

<<<<<<< HEAD
class _ManageSubstitutionsScreenState extends State<ManageSubstitutionsScreen> {
  final ApiService _api = ApiService();
  List substitutions = [];
  List teachers = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
=======
class _ManageSubstitutionsScreenState extends State<ManageSubstitutionsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;

  // Data
  List teachers = [];
  List substitutions = [];
  List suggestions = [];

  // Selections
  String? selectedAbsentTeacherId;
  String? selectedPeriod;
  String? selectedDate = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD

  bool isLoading = false;

  // Theme Color
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() => isLoading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final res = await _api.get(
        "/api/v2/admin/substitutions/list?date=$dateStr",
      );
      final tRes = await _api.get("/api/v1/admin/teachers");

      if (mounted) {
        setState(() {
          substitutions = res["data"] ?? [];
          teachers = tRes["data"] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
=======
    _tabController = TabController(length: 3, vsync: this);
    _fetchTeachers();
    _fetchSubstitutions();
  }

  Future<void> _fetchTeachers() async {
    try {
      final res = await _api.get("/api/v1/admin/teachers");
      if (mounted) {
        setState(() {
          teachers = res["data"] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching teachers: $e");
    }
  }

  Future<void> _fetchSubstitutions() async {
    try {
      final res = await _api.get(
        "/api/v2/admin/substitutions/list?date=${DateTime.now().toIso8601String().split('T')[0]}",
      );
      if (mounted) {
        setState(() {
          substitutions = res["data"] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching substitutions: $e");
    }
  }

  Future<void> _getSuggestions() async {
    if (selectedAbsentTeacherId == null || selectedPeriod == null) return;

    setState(() => isLoading = true);
    try {
      // Calculate day name from selectedDate
      final dayName = _getDayName(DateTime.parse(selectedDate!));

      final res = await _api.get(
        "/api/v2/admin/substitutions/suggestions?absent_teacher_id=$selectedAbsentTeacherId&period=$selectedPeriod&day=$dayName",
      );
      if (mounted) {
        setState(() {
          suggestions = res["data"] ?? [];
          isLoading = false;
          _tabController.animateTo(1); // Move to suggestions tab
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching suggestions: $e")),
        );
      }
    }
  }

  String _getDayName(DateTime date) {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    // weekday is 1-7 (Mon-Sun)
    return days[date.weekday - 1];
  }

  Future<void> _assignSubstitution(String teacherId, String teacherName) async {
    try {
      // 1. Ensure Absence Record Exists (Workaround for backend issue)
      String? absenceId;
      try {
        final absRes = await _api.post("/api/v2/admin/substitutions/absent", {
          "teacher_id": selectedAbsentTeacherId,
          "absence_date": selectedDate,
          "reason": "Substitution Assigned",
        });
        if (absRes["success"] == true) {
          absenceId = absRes["data"]["absenceId"].toString();
        }
      } catch (e) {
        print("Absence creation skipped or failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to mark teacher absent: $e")),
        );
        return; // STOP HERE if we don't have an ID (assuming backend is old)
      }

      if (absenceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not retrieve Absence ID. Cannot assign."),
          ),
        );
        return;
      }

      // 2. Assign Substitution
      final res = await _api.post("/api/v2/admin/substitutions/assign", {
        "original_teacher_id": selectedAbsentTeacherId,
        "substitute_teacher_id": teacherId,
        "period": selectedPeriod,
        "date": selectedDate,
        "section_id":
            "1", // Client-side fallback to ensure NOT NULL (Backend will use this)
        "absence_id": absenceId, // Explicitly pass ID
      });

      if (res["success"]) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Assigned $teacherName successfully!")),
          );
          _fetchSubstitutions();
          _tabController.animateTo(2); // Move to active list
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error assigning: $e")));
      }
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildDateHeader()),
          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _buildSubstitutionList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showMarkAbsentDialog,
        backgroundColor: const Color(0xFF1A4DFF),
        icon: const Icon(Icons.person_off_rounded, color: Colors.white),
        label: const Text(
          "Mark Absence",
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
          "Substitutions",
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

  Widget _buildDateHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A4DFF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF1A4DFF),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Viewing Schedule for",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E263E),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF1A4DFF),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (d != null) {
                setState(() => selectedDate = d);
                _fetchData();
              }
            },
            child: const Text(
              "Change",
              style: TextStyle(
                color: Color(0xFF1A4DFF),
                fontWeight: FontWeight.bold,
=======
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Substitution Manager",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.person_search), text: "Find Sub"),
            Tab(icon: Icon(Icons.lightbulb_outline), text: "Suggestions"),
            Tab(icon: Icon(Icons.list_alt), text: "Active Subs"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestTab(),
          _buildSuggestionsTab(),
          _buildActiveTab(),
        ],
      ),
    );
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find Substitute",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedAbsentTeacherId,
                    decoration: InputDecoration(
                      labelText: "Absent Teacher",
                      labelStyle: TextStyle(color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: Icon(Icons.person_off, color: primaryColor),
                    ),
                    items: teachers.map<DropdownMenuItem<String>>((t) {
                      return DropdownMenuItem(
                        value: t["id"].toString(),
                        child: Text(t["name"]),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => selectedAbsentTeacherId = val),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedPeriod,
                    decoration: InputDecoration(
                      labelText: "Period",
                      labelStyle: TextStyle(color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: Icon(Icons.access_time, color: primaryColor),
                    ),
                    items: List.generate(8, (i) => (i + 1).toString())
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text("Period $p"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedPeriod = val),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isLoading ? null : _getSuggestions,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        isLoading ? "Searching..." : "Find Substitutes",
                      ),
                    ),
                  ),
                ],
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
              ),
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildSubstitutionList() {
    if (substitutions.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              "All slots are covered!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const Text(
              "No substitutions found for this date.",
=======
  Widget _buildSuggestionsTab() {
    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "No suggestions found or search not performed.",
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
<<<<<<< HEAD

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildSubstitutionCard(substitutions[index]),
          childCount: substitutions.length,
        ),
      ),
    );
  }

  Widget _buildSubstitutionCard(Map s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Period ${s["period"]}",
                    style: TextStyle(
                      color: Colors.indigo.shade700,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Class ${s["class"]}-${s["section_name"]}",
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTeacherInfo(
                    label: "Original",
                    name: s["original_teacher"],
                    isAbsent: true,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: _buildTeacherInfo(
                    label: "Substitute",
                    name: s["substitute_teacher"],
                    isAbsent: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherInfo({
    required String label,
    required String name,
    required bool isAbsent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isAbsent ? Colors.red.shade400 : const Color(0xFF1E263E),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showMarkAbsentDialog() {
    int? selectedTeacherId;
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mark Attendance",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildDropdownField<int>(
                label: "Select Teacher",
                value: selectedTeacherId,
                icon: Icons.person_outline_rounded,
                items: teachers,
                onChanged: (val) =>
                    setDialogState(() => selectedTeacherId = val),
              ),
              _buildTextField(
                reasonController,
                "Reason for Absence",
                Icons.notes_rounded,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedTeacherId == null) return;
                    try {
                      final res = await _api
                          .post("/api/v2/admin/substitutions/absent", {
                            "teacher_id": selectedTeacherId,
                            "absence_date": selectedDate
                                .toIso8601String()
                                .split('T')[0],
                            "reason": reasonController.text,
                          });
                      if (res["success"]) {
                        Navigator.pop(context);
                        _showSubstitutionWizard(
                          res["data"]["absenceId"],
                          res["data"]["impacted"],
                          selectedTeacherId!,
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                  child: const Text(
                    "Find Substitutes",
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

  void _showSubstitutionWizard(
    int absenceId,
    List impacted,
    int originalTeacherId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8FAFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "Assign Substitutes",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: impacted.length,
                itemBuilder: (context, index) {
                  final p = impacted[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        "Period ${p["period"]}: ${p["subject"]}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Section: ${p["section_name"] ?? p["section_id"]}",
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A4DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () =>
                            _pickSubstitute(absenceId, p, originalTeacherId),
                        child: const Text(
                          "Assign",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
    );
  }

  void _pickSubstitute(
    int absenceId,
    Map periodInfo,
    int originalTeacherId,
  ) async {
    setState(() => isLoading = true);
    try {
      final day = periodInfo["day"];
      final period = periodInfo["period"];
      final subject = periodInfo["subject"];
      final res = await _api.get(
        "/api/v2/admin/substitutions/suggestions?day=$day&period=$period&subject=$subject",
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      showDialog(
        context: context,
        builder: (context) {
          final suggestions = res["data"] as List;
          return AlertDialog(
            title: Text(
              "Substitute Suggestions",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: suggestions.length,
                separatorBuilder: (context, i) => const Divider(),
                itemBuilder: (context, i) {
                  final s = suggestions[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade50,
                      child: Text(
                        s["name"][0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      s["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(s["subject"] ?? "Free Slot"),
                    trailing: s["is_subject_match"]
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "MATCH",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                    onTap: () async {
                      await _api.post("/api/v2/admin/substitutions/assign", {
                        "absence_id": absenceId,
                        "date": DateFormat('yyyy-MM-dd').format(selectedDate),
                        "period": period,
                        "section_id": periodInfo["section_id"],
                        "original_teacher_id": originalTeacherId,
                        "substitute_teacher_id": s["id"],
                        "remarks": "AI Suggested",
                      });
                      if (!mounted) return;
                      Navigator.pop(context);
                      _fetchData();
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
          prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey.shade300),
          filled: true,
          fillColor: const Color(0xFFF4F6FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required IconData icon,
    required List items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items
            .map(
              (i) =>
                  DropdownMenuItem(value: i["id"] as T, child: Text(i["name"])),
            )
            .toList(),
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1E263E)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
          prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey.shade300),
          filled: true,
          fillColor: const Color(0xFFF4F6FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
        ),
      ),
=======
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final s = suggestions[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Text(
                s["name"][0],
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              s["name"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Current Load: ${s["load_score"] ?? 'Low'}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () =>
                  _assignSubstitution(s["id"].toString(), s["name"]),
              child: const Text("Assign"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveTab() {
    if (substitutions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              "No active substitutions.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: substitutions.length,
      itemBuilder: (context, index) {
        final sub = substitutions[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: const Icon(Icons.swap_horiz, color: Colors.orange),
            ),
            title: Text(
              "For: ${sub["original_teacher"] ?? "Unknown"}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Sub: ${sub["substitute_teacher"] ?? "Unknown"} (Period ${sub["period"]})",
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Active",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
    );
  }
}
