import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'timetable_model.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() =>
      _StudentTimetableScreenState();
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
    "Saturday"
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
    final res = await _api.get("/api/v1/timetable/my");

    setState(() {
      timetable =
          (res["data"] as List).map((e) => TimetableItem.fromJson(e)).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Timetable"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: days.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: days.map((day) {
                final dayItems =
                    timetable.where((t) => t.day == day).toList();

                if (dayItems.isEmpty) {
                  return const Center(child: Text("No classes"));
                }

                return ListView.builder(
                  itemCount: dayItems.length,
                  itemBuilder: (_, i) {
                    final t = dayItems[i];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(t.period.toString()),
                        ),
                        title: Text(t.subject),
                        subtitle: Text(
                          "${t.teacherName}\n${t.startTime} - ${t.endTime}",
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
