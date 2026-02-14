import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'timetable_model.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  String _getDayLabel(String day) {
    switch (day) {
      case "Monday":
        return "Monday";
      case "Tuesday":
        return "Tuesday";
      case "Wednesday":
        return "Wednesday";
      case "Thursday":
        return "Thursday";
      case "Friday":
        return "Friday";
      case "Saturday":
        return "Saturday";
      default:
        return day;
    }
  }

  List<TimetableItem> timetable = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: days.length, vsync: this);
    fetchTimetable();
  }

  Future<void> fetchTimetable() async {
<<<<<<< HEAD
    try {
      final res = await _api.get("/api/v1/timetable/my");
      if (mounted) {
        setState(() {
          timetable = (res["data"] as List)
              .map((e) => TimetableItem.fromJson(e))
              .toList();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
=======
    final res = await _api.get("/api/v1/timetable/my");

    setState(() {
      timetable = (res["data"] as List)
          .map((e) => TimetableItem.fromJson(e))
          .toList();
      loading = false;
    });
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFFF8FAFF),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF1A4DFF),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
                tabs: days.map((d) => Tab(text: d.toUpperCase())).toList(),
              ),
            ),
          ),
        ],
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: days.map((day) {
                  final dayItems = timetable
                      .where((t) => t.day == day)
                      .toList();

                  if (dayItems.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dayItems.length,
                    itemBuilder: (_, i) => _buildTimetableCard(dayItems[i]),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF1A4DFF),
      elevation: 0,
      leading: const BackButton(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          "My Timetable",
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
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }
=======
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: const Color(0xFF4A00E0)),
        ),
        title: const Text(
          "Timetable🗓️",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          indicatorColor: Colors.white,
          tabs: days.map((d) => Tab(text: _getDayLabel(d))).toList(),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: days.map((day) {
                final dayItems = timetable.where((t) => t.day == day).toList();
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)

  Widget _buildTimetableCard(TimetableItem t) {
    String emoji = "📚";
    final sub = t.subject.toLowerCase();
    if (sub.contains("math")) emoji = "📐";
    if (sub.contains("science") || sub.contains("physics")) emoji = "🧪";
    if (sub.contains("yoga") || sub.contains("pt") || sub.contains("sport"))
      emoji = "⚽";
    if (sub.contains("python") || sub.contains("computer")) emoji = "💻";
    if (sub.contains("english")) emoji = "📖";

<<<<<<< HEAD
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1A4DFF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              t.period.toString(),
              style: const TextStyle(
                color: Color(0xFF1A4DFF),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
=======
                return ListView.builder(
                  itemCount: dayItems.length,
                  itemBuilder: (_, i) {
                    final t = dayItems[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A00E0).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${t.period}",
                                style: const TextStyle(
                                  color: Color(0xFF4A00E0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.subject,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        t.teacherName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${t.startTime} - ${t.endTime}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
            ),
          ),
        ),
        title: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              t.subject,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF1E263E),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "👤 ${t.teacherName}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade400,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Color(0xFF1A4DFF),
                ),
                const SizedBox(width: 4),
                Text(
                  "${t.startTime} - ${t.endTime}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A4DFF),
                  ),
                ),
              ],
            ),
          ],
        ),
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
          "No classes scheduled",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const Text(
          "Enjoy your free time!",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
