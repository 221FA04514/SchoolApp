import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/api/api_service.dart';
import 'attendance_summary_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ApiService api = ApiService();

  DateTime focusedDay = DateTime.now();
  Map<String, String> attendanceMap = {};
  Map<String, dynamic> summary = {};

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    final month = focusedDay.month;
    final year = focusedDay.year;

    final calendarRes =
        await api.get("/api/v1/attendance/calendar?month=$month&year=$year");

    final summaryRes =
        await api.get("/api/v1/attendance/summary?month=$month&year=$year");

    setState(() {
      attendanceMap = Map<String, String>.from(calendarRes["data"]);
      summary = summaryRes["data"];
    });
  }

  Color? _getDayColor(DateTime day) {
    final key = day.toIso8601String().split("T")[0];
    final status = attendanceMap[key];

    if (status == "present") return Colors.green;
    if (status == "absent") return Colors.red;
    if (status == "holiday") return Colors.blue;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 📊 SUMMARY CARD
            if (summary.isNotEmpty)
              AttendanceSummaryCard(
                present: summary["present"],
                absent: summary["absent"],
                holiday: summary["holiday"],
                percentage: summary["percentage"],
              ),

            const SizedBox(height: 20),

            // 📅 CALENDAR
            TableCalendar(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              focusedDay: focusedDay,
              onPageChanged: (day) {
                focusedDay = day;
                fetchAttendance();
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  final color = _getDayColor(day);
                  if (color == null) return null;

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day.day.toString(),
                      style: const TextStyle(color: Colors.white),
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
}
