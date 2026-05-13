import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'timetable_model.dart';

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;

  List<TimetableItem> _mySlots = [];
  List<TimetableItem> _sectionSlots = [];
  List _sections = [];
  int? _selectedSecId;

  bool _isMyLoading = true;
  bool _isSecLoading = false;
  bool _isSectionsLoading = true;

  // Day order for grid
  static const _dayOrder = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  // Accent colours per day
  static const _dayColors = [
    Color(0xFF4A00E0), // Mon – purple
    Color(0xFF0077FF), // Tue – blue
    Color(0xFF00897B), // Wed – teal
    Color(0xFFE65100), // Thu – deep orange
    Color(0xFF558B2F), // Fri – green
    Color(0xFF6D4C41), // Sat – brown
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMyTimetable();
    _fetchSections();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────
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
      final res =
          await _api.get("/api/v1/timetable/section?section_id=$_selectedSecId");
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

  // ── Helpers ──────────────────────────────────────────────────────
  /// Group slots by day, preserving _dayOrder
  Map<String, List<TimetableItem>> _groupByDay(List<TimetableItem> slots) {
    final Map<String, List<TimetableItem>> map = {};
    for (final d in _dayOrder) {
      final list = slots
          .where((s) => s.day.toLowerCase() == d.toLowerCase())
          .toList()
        ..sort((a, b) => a.period.compareTo(b.period));
      if (list.isNotEmpty) map[d] = list;
    }
    return map;
  }

  Color _colorForDay(String day) {
    final idx = _dayOrder.indexWhere((d) => d.toLowerCase() == day.toLowerCase());
    return idx >= 0 ? _dayColors[idx] : const Color(0xFF4A00E0);
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF4A00E0),
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const BackButton(color: Colors.white),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    _fetchMyTimetable();
                    _fetchSections();
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 62),
                title: const Text(
                  'Timetable Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4A00E0), Color(0xFF2D31FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Abstract circles for premium look
                    Positioned(
                      right: -50,
                      top: -50,
                      child: CircleAvatar(
                        radius: 120,
                        backgroundColor: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 4,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    tabs: const [
                      Tab(text: 'MY SCHEDULE'),
                      Tab(text: 'CLASS VIEW'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMySchedule(),
            _buildClassScheduler(),
          ],
        ),
      ),
    );
  }

  // ── TAB 1: My Schedule — day-grouped grid ──────────────────────
  Widget _buildMySchedule() {
    if (_isMyLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)));
    }
    if (_mySlots.isEmpty) {
      return _emptyState('No personal schedule found');
    }

    final grouped = _groupByDay(_mySlots);

    return RefreshIndicator(
      onRefresh: _fetchMyTimetable,
      color: const Color(0xFF4A00E0),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: grouped.entries.map((entry) {
          final day = entry.key;
          final slots = entry.value;
          final color = _colorForDay(day);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Day header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        day.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Divider(color: color.withOpacity(0.2), thickness: 1.5)),
                    const SizedBox(width: 8),
                    Text(
                      '${slots.length} period${slots.length > 1 ? 's' : ''}',
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              // ── Period cards row (wrap to next line if needed) ──
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: slots.map((slot) => _buildMyPeriodCell(slot, color)).toList(),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMyPeriodCell(TimetableItem slot, Color color) {
    final cardWidth = (MediaQuery.of(context).size.width - 16 * 2 - 10) / 2;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period badge + time row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'P${slot.period}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              if (slot.startTime.isNotEmpty)
                Text(
                  slot.startTime,
                  style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Subject
          Text(
            slot.subject,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Class label
          if (slot.classLabel.isNotEmpty)
            Row(
              children: [
                Icon(Icons.groups_rounded, size: 12, color: color.withOpacity(0.7)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    slot.classLabel,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            Text(
              '—',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),

          if (slot.endTime.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 11, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text(
                  '${slot.startTime} – ${slot.endTime}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── TAB 2: Class Scheduler ─────────────────────────────────────
  Widget _buildClassScheduler() {
    return Column(
      children: [
        _buildSectionSelector(),
        Expanded(
          child: _isSecLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)))
              : _sectionSlots.isEmpty
                  ? _emptyState('No classes for this section')
                  : _buildSectionGrid(),
        ),
      ],
    );
  }

  Widget _buildSectionGrid() {
    final grouped = _groupByDay(_sectionSlots);

    return RefreshIndicator(
      onRefresh: _fetchSectionTimetable,
      color: const Color(0xFF4A00E0),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: grouped.entries.map((entry) {
          final day = entry.key;
          final slots = entry.value;
          final color = _colorForDay(day);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                      child: Text(day.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Divider(color: color.withOpacity(0.2), thickness: 1.5)),
                  ],
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: slots.map((slot) => _buildSectionPeriodCell(slot, color)).toList(),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionPeriodCell(TimetableItem slot, Color color) {
    final cardWidth = (MediaQuery.of(context).size.width - 16 * 2 - 10) / 2;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text('P${slot.period}', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)),
              ),
              const Spacer(),
              if (slot.startTime.isNotEmpty)
                Text(slot.startTime, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(slot.subject,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          if (slot.teacherName.isNotEmpty)
            Row(
              children: [
                Icon(Icons.person_rounded, size: 12, color: color.withOpacity(0.7)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(slot.teacherName,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          if (slot.endTime.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 11, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text('${slot.startTime} – ${slot.endTime}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionSelector() {
    if (_isSectionsLoading || _sections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: DropdownButtonFormField<int>(
        value: _selectedSecId,
        decoration: InputDecoration(
          labelText: 'Select Section',
          labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 13),
          prefixIcon: const Icon(Icons.menu_book_rounded, color: Color(0xFF4A00E0)),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF4A00E0), width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _sections
            .map((s) => DropdownMenuItem<int>(
                  value: s["id"],
                  child: Text('${s["class"]}-${s["section"]}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ))
            .toList(),
        onChanged: (val) {
          setState(() => _selectedSecId = val);
          _fetchSectionTimetable();
        },
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(msg,
              style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
