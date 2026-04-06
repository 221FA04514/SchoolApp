import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_service.dart';

class ManageSubstitutionsScreen extends StatefulWidget {
  const ManageSubstitutionsScreen({super.key});

  @override
  State<ManageSubstitutionsScreen> createState() =>
      _ManageSubstitutionsScreenState();
}

class _ManageSubstitutionsScreenState extends State<ManageSubstitutionsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;

  List teachers = [];
  List activeSubs = [];
  List suggestions = [];

  bool isLoadingTeachers = true;
  bool isLoadingSubs = true;
  bool isLoadingSuggestions = false;

  int? selectedTeacherId;
  String? selectedPeriod;
  final List<String> periods = ["1", "2", "3", "4", "5", "6", "7", "8"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTeachers();
    _fetchActiveSubs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTeachers() async {
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

  Future<void> _fetchActiveSubs() async {
    if (mounted) setState(() => isLoadingSubs = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final res = await _api.get(
        "/api/v2/admin/substitutions/list?date=$dateStr",
      );
      if (mounted) {
        setState(() {
          activeSubs = res["data"] ?? [];
          isLoadingSubs = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingSubs = false);
    }
  }

  Future<void> _findSubstitutes() async {
    if (selectedTeacherId == null || selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a teacher and period.")),
      );
      return;
    }

    setState(() => isLoadingSuggestions = true);
    _tabController.animateTo(1); // Go to Suggestions tab

    try {
      final day = DateFormat('EEEE').format(DateTime.now());
      // we do not need to pass subject since the backend will filter without it, sorting might not happen but that's fine.
      final res = await _api.get(
        "/api/v2/admin/substitutions/suggestions?day=$day&period=$selectedPeriod&subject=",
      );

      if (mounted) {
        setState(() {
          suggestions = res["data"] ?? [];
          isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingSuggestions = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching suggestions: $e")),
        );
      }
    }
  }

  Future<void> _assignSubstitute(int substituteId, String substituteName) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _api.post("/api/v2/admin/substitutions/assign", {
        "date": dateStr,
        "period": selectedPeriod,
        "absent_teacher_id": selectedTeacherId,
        "substitute_teacher_id": substituteId,
        "remarks": "AI Suggested",
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Assigned $substituteName successfully!")),
        );
        _fetchActiveSubs(); // Refresh active subs
        _tabController.animateTo(2); // Go to Active Subs tab
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error assigning substitute: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text(
          "Substitution Manager",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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
          _buildFindSubTab(),
          _buildSuggestionsTab(),
          _buildActiveSubsTab(),
        ],
      ),
    );
  }

  Widget _buildFindSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Find Substitute",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF673AB7),
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(
              value: selectedTeacherId,
              icon: const Icon(Icons.arrow_drop_down),
              decoration: InputDecoration(
                labelText: "Absent Teacher",
                prefixIcon: const Icon(
                  Icons.person_off,
                  color: Color(0xFF673AB7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF673AB7)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF673AB7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF673AB7),
                    width: 2,
                  ),
                ),
              ),
              items: isLoadingTeachers
                  ? []
                  : teachers
                      .map(
                        (t) => DropdownMenuItem<int>(
                          value: t["id"],
                          child: Text(t["name"]),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                setState(() => selectedTeacherId = val);
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedPeriod,
              icon: const Icon(Icons.arrow_drop_down),
              decoration: InputDecoration(
                labelText: "Period",
                prefixIcon: const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF673AB7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF673AB7)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF673AB7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF673AB7),
                    width: 2,
                  ),
                ),
              ),
              items: periods
                  .map(
                    (p) => DropdownMenuItem<String>(
                      value: p,
                      child: Text("Period $p"),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() => selectedPeriod = val);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _findSubstitutes,
                icon: const Icon(Icons.search, color: Colors.white, size: 20),
                label: const Text(
                  "Find Substitutes",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    if (isLoadingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (suggestions.isEmpty) {
      return const Center(
        child: Text(
          "No suggestions. Please select a teacher and period first.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final teacher = suggestions[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF3E5F5), // Light purple
                radius: 24,
                child: Text(
                  teacher["name"][0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF673AB7),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Current Load: Low",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () =>
                    _assignSubstitute(teacher["id"], teacher["name"]),
                child: const Text(
                  "Assign",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveSubsTab() {
    if (isLoadingSubs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activeSubs.isEmpty) {
      return const Center(
        child: Text(
          "No active substitutions for today.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: activeSubs.length,
      itemBuilder: (context, index) {
        final sub = activeSubs[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange.shade50,
                radius: 24,
                child: Icon(
                  Icons.sync_alt,
                  color: Colors.orange.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "For: ${sub['original_teacher']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sub: ${sub['substitute_teacher']} (Period ${sub['period']})",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Active",
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
