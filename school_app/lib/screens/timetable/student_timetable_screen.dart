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

  List<TimetableItem> timetable = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: days.length, vsync: this);
    fetchTimetable();
  }

  Future<void> fetchTimetable() async {
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
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      body: Stack(
        children: [
          // Galaxy Header Style
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8A6FFF), Color(0xFFC08CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "MY TIMETABLE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Day Tabs
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    indicatorWeight: 4,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.5),
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    tabs: days.map((d) => Tab(text: d.toUpperCase())).toList(),
                  ),
                ),

                const SizedBox(height: 15),

                // Main Content
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                              physics: const BouncingScrollPhysics(),
                              itemCount: dayItems.length,
                              itemBuilder: (_, i) => _buildTimetableCard(dayItems[i]),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableCard(TimetableItem t) {
    String emoji = "📚";
    final sub = t.subject.toLowerCase();
    if (sub.contains("math")) emoji = "📐";
    if (sub.contains("science") || sub.contains("physics")) emoji = "🧪";
    if (sub.contains("yoga") || sub.contains("pt") || sub.contains("sport"))
      emoji = "⚽";
    if (sub.contains("python") || sub.contains("computer")) emoji = "💻";
    if (sub.contains("english")) emoji = "📖";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC08CFF).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFF8A6FFF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                t.period.toString(),
                style: const TextStyle(
                  color: Color(0xFF8A6FFF),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.subject.toUpperCase(), // All capital letters for subject
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFF2D3250),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _toTitleCase(t.teacherName), // First letter capital for teacher
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_filled_rounded, size: 14, color: Color(0xFF8A6FFF)),
                    const SizedBox(width: 6),
                    Text(
                      "${t.startTime} - ${t.endTime}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8A6FFF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
            child: Icon(Icons.event_available_rounded, size: 64, color: const Color(0xFFC08CFF).withOpacity(0.5)),
          ),
          const SizedBox(height: 25),
          const Text(
            "NO CLASSES SCHEDULED",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3250)),
          ),
          const SizedBox(height: 5),
          const Text("Enjoy your free time!", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
