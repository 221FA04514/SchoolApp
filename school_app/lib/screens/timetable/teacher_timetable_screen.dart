import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/api_service.dart';
import 'timetable_model.dart';

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  final ApiService _api = ApiService();
  List _sections = [];
  int? _selectedSecId;
  List<TimetableItem> _slots = [];
  bool _isLoading = true;

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  @override
  void initState() {
    super.initState();
    _fetchSections(); // Changed to _fetchSections
  }

  Future<void> _fetchSections() async {
    // Renamed from fetchSections
    setState(() {
      _isLoading = true; // Set loading state for initial fetch
    });
    try {
      final role = Provider.of<AuthProvider>(context, listen: false).role;
      // Only admins need the section dropdown to view all timetables
      if (role == 'admin') {
        final res = await _api.get("/api/v1/sections");
        if (mounted) {
          setState(() {
            _sections = res["data"] ?? [];
            if (_sections.isNotEmpty) {
              _selectedSecId = _sections[0]["id"];
              _fetchTimetable(); // Call _fetchTimetable for admin
            } else {
              _isLoading = false; // No sections, stop loading
            }
          });
        }
      } else {
        // Teachers fetch their personal timetable directly
        _fetchPersonalTimetable();
      }
    } catch (e) {
      debugPrint("Error fetching sections: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPersonalTimetable() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get("/api/v1/timetable/personal");
      if (mounted) {
        setState(() {
          _slots = (res["data"] as List)
              .map((e) => TimetableItem.fromJson(e))
              .toList(); // Map to TimetableItem
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching personal timetable: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTimetable() async {
    // Renamed from fetchTimetable
    if (_selectedSecId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await _api.get(
        "/api/v1/timetable/section?section_id=$_selectedSecId", // Use _selectedSecId
      );
      if (mounted) {
        setState(() {
          _slots = (res["data"] as List)
              .map((e) => TimetableItem.fromJson(e))
              .toList(); // Map to TimetableItem
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching section timetable: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("Teacher Timetable"),
        backgroundColor: const Color(0xFF1A4DFF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDayHeader(),
                        const SizedBox(height: 16),
                        _buildTimetableGrid(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final role = Provider.of<AuthProvider>(context, listen: false).role;
    final isAdmin = role == 'admin';

    return Container(
      color: const Color(0xFF1A4DFF),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          if (_isLoading && _sections.isEmpty && isAdmin)
            const LinearProgressIndicator(color: Colors.white)
          else if (_sections.isEmpty && isAdmin)
            const Text(
              "No sections assigned",
              style: TextStyle(color: Colors.white),
            )
          else if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedSecId,
                  dropdownColor: const Color(0xFF1A4DFF),
                  items: _sections.map<DropdownMenuItem<int>>((s) {
                    return DropdownMenuItem(
                      value: s["id"],
                      child: Text(
                        "Section ${s["class"]}-${s["section"]}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedSecId = val);
                    _fetchTimetable();
                  },
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((day) {
          final isToday = day == _getCurrentDay();
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFF1A4DFF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isToday ? const Color(0xFF1A4DFF) : Colors.grey.shade200,
              ),
            ),
            child: Text(
              day,
              style: TextStyle(
                color: isToday ? Colors.white : Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCurrentDay() {
    int weekday = DateTime.now().weekday;
    if (weekday > 6) return "Sunday"; // Sunday usually not in timetable
    return days[weekday - 1];
  }

  Widget _buildTimetableGrid() {
    int maxPeriod = 0;
    for (var item in _slots) {
      if (item.period > maxPeriod) maxPeriod = item.period;
    }

    if (maxPeriod == 0) return _buildEmptyState();

    return Column(
      children: List.generate(maxPeriod, (index) {
        final period = index + 1;
        return _buildPeriodRow(period);
      }),
    );
  }

  Widget _buildPeriodRow(int period) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
          child: Text(
            "Period $period",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.blueGrey,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: days.map((day) {
              final item = _slots.firstWhere(
                (t) => t.day == day && t.period == period,
                orElse: () => TimetableItem(
                  day: day,
                  period: period,
                  subject: "Free",
                  teacherName: "",
                  startTime: "",
                  endTime: "",
                ),
              );
              return _buildGridCard(item, day);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGridCard(TimetableItem t, String day) {
    final bool isFree = t.subject == "Free";
    final isToday = day == _getCurrentDay();

    return Container(
      width: 140,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFree ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday && !isFree
              ? const Color(0xFF1A4DFF).withOpacity(0.3)
              : Colors.grey.shade200,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isFree ? Colors.grey : const Color(0xFF1E263E),
            ),
          ),
          if (!isFree) ...[
            const SizedBox(height: 4),
            Text(
              t.startTime,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A4DFF),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.event_available_rounded,
          size: 64,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        const Text(
          "No classes found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }
}
