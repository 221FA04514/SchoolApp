import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'timetable_model.dart';

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  final ApiService _api = ApiService();
  
  List<TimetableItem> _mySlots = [];
  List<TimetableItem> _sectionSlots = [];
  List _sections = [];
  int? _selectedSecId;
  
  bool _isMyLoading = true;
  bool _isSecLoading = false;
  bool _isSectionsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyTimetable();
    _fetchSections();
  }

  Future<void> _fetchMyTimetable() async {
    setState(() => _isMyLoading = true);
    try {
      final res = await _api.get("/api/v1/timetable/personal");
      if (mounted) {
        setState(() {
          _mySlots = (res["data"] as List)
              .map((e) => TimetableItem.fromJson(e))
              .toList();
          _isMyLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isMyLoading = false);
    }
  }

  Future<void> _fetchSections() async {
    setState(() => _isSectionsLoading = true);
    try {
      final res = await _api.get("/api/v1/sections");
      if (mounted) {
        setState(() {
          _sections = res["data"] ?? [];
          _isSectionsLoading = false;
          if (_sections.isNotEmpty) {
            _selectedSecId = _sections[0]["id"];
            _fetchSectionTimetable();
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSectionsLoading = false);
    }
  }

  Future<void> _fetchSectionTimetable() async {
    if (_selectedSecId == null) return;
    setState(() => _isSecLoading = true);
    try {
      final res = await _api.get("/api/v1/timetable/section?section_id=$_selectedSecId");
      if (mounted) {
        setState(() {
          _sectionSlots = (res["data"] as List)
              .map((e) => TimetableItem.fromJson(e))
              .toList();
          _isSecLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSecLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFF),
        body: Stack(
          children: [
            // Curved Header Background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 180, // Slightly taller for tabs
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF4A00E0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
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
                          "Timetable",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const TabBar(
                      indicatorColor: Colors.white,
                      indicatorWeight: 4,
                      indicatorPadding: EdgeInsets.symmetric(horizontal: 4),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      dividerColor: Colors.transparent,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(text: "MY SCHEDULE"),
                        Tab(text: "CLASS SCHEDULER"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Main Content
                  Expanded(
                    child: TabBarView(
                      children: [
                        // My Schedule Tab
                        _buildMyScheduleViewWrapper(),
                        // Class Scheduler Tab
                        _buildClassSchedulerViewWrapper(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wrappers to call internal methods from different context
  static Widget _buildMyScheduleViewWrapper() {
    return Builder(
      builder: (context) {
        final state = context.findAncestorStateOfType<_TeacherTimetableScreenState>();
        return state?._buildMyScheduleView() ?? const SizedBox();
      },
    );
  }

  static Widget _buildClassSchedulerViewWrapper() {
    return Builder(
      builder: (context) {
        final state = context.findAncestorStateOfType<_TeacherTimetableScreenState>();
        return state?._buildClassSchedulerView() ?? const SizedBox();
      },
    );
  }

  Widget _buildMyScheduleView() {
    if (_isMyLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)));
    }
    if (_mySlots.isEmpty) {
      return _buildEmptyState("No personal schedule found");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mySlots.length,
      itemBuilder: (context, index) => _buildTimetableCard(_mySlots[index], isPersonal: true),
    );
  }

  Widget _buildClassSchedulerView() {
    return Column(
      children: [
        _buildSectionSelector(),
        Expanded(
          child: _isSecLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)))
              : _sectionSlots.isEmpty
                  ? _buildEmptyState("No classes for this section")
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _sectionSlots.length,
                      itemBuilder: (context, index) => _buildTimetableCard(_sectionSlots[index], isPersonal: false),
                    ),
        ),
      ],
    );
  }

  Widget _buildSectionSelector() {
    if (_isSectionsLoading) return const SizedBox.shrink();
    if (_sections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonFormField<int>(
          value: _selectedSecId,
          decoration: InputDecoration(
            labelText: "Select Section",
            labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 14),
            prefixIcon: const Icon(Icons.menu_book_rounded, color: Color(0xFF4A00E0)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A00E0), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _sections.map((s) {
            return DropdownMenuItem<int>(
              value: s["id"],
              child: Text(
                "${s["class"]}-${s["section"]}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedSecId = val;
              _fetchSectionTimetable();
            });
          },
        ),
      ),
    );
  }

  Widget _buildTimetableCard(TimetableItem item, {required bool isPersonal}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Period Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4A00E0).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              item.period.toString(),
              style: const TextStyle(
                color: Color(0xFF4A00E0),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E263E),
                  ),
                ),
                const SizedBox(height: 4),
                if (isPersonal)
                  Text(
                    "${item.day} | N/A",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  )
                else ...[
                  Text(
                    "(${item.day})",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  Text(
                    "Teacher: ${item.teacherName}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          // Time
          Text(
            "${item.startTime} - ${item.endTime}",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
