import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/api/api_service.dart';
import 'attendance_summary_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {
  final ApiService api = ApiService();

  DateTime focusedDay = DateTime.now();
  Map<String, String> attendanceMap = {};
  Map<String, dynamic> summary = {};

  late AnimationController _pageController;
  late AnimationController _calendarController;

  late Animation<double> _fade;

  bool isLoadingMonth = false;

  final List<String> _weekdays = const [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  void initState() {
    super.initState();
    fetchAttendance();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _calendarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);

    _pageController.forward();
    _calendarController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> fetchAttendance() async {
    setState(() => isLoadingMonth = true);

    final month = focusedDay.month;
    final year = focusedDay.year;

    final calendarRes = await api.get(
      "/api/v1/attendance/calendar?month=$month&year=$year",
    );

    final summaryRes = await api.get(
      "/api/v1/attendance/summary?month=$month&year=$year",
    );

    setState(() {
      attendanceMap = Map<String, String>.from(calendarRes["data"]);
      summary = summaryRes["data"];
      isLoadingMonth = false;
    });

    // 🔁 Replay weekday + calendar animation
    _calendarController.forward(from: 0);
  }

  Color? _getDayColor(DateTime day) {
    final key = day.toIso8601String().split("T")[0];
    final status = attendanceMap[key];

    if (status == "present") return const Color(0xFF43CEA2);
    if (status == "absent") return const Color(0xFFFF5F6D);
    if (status == "holiday") return const Color(0xFF3A6BFF);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          // ================= HEADER =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280, // Increased height for better centered overlap
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1fa2ff),
                    Color(0xFF12d8fa),
                    Color(0xFFa6ffcb),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          // ================= CONTENT =================
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                        "My Attendance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22, // Slightly smaller title
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Hug content
                        children: [
                          // ✨ UNIFIED DASHBOARD CARD ✨
                          AnimatedSlide(
                            offset: Offset(0, _fade.value == 1 ? 0 : 0.05),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutBack,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // 1. SUMMARY SECTION (COMPACT)
                                  if (summary.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: AttendanceSummaryCard(
                                        present: summary["present"],
                                        absent: summary["absent"],
                                        holiday: summary["holiday"],
                                        percentage: summary["percentage"],
                                      ),
                                    ),

                                  // 2. DIVIDER
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Divider(
                                      color: Colors.grey.withOpacity(0.1),
                                      thickness: 1,
                                    ),
                                  ),

                                  // 3. CALENDAR SECTION
                                  AnimatedOpacity(
                                    opacity: isLoadingMonth ? 0.6 : 1,
                                    duration: const Duration(milliseconds: 300),
                                    child: TableCalendar(
                                      firstDay: DateTime.utc(2020),
                                      lastDay: DateTime.utc(2030),
                                      focusedDay: focusedDay,
                                      daysOfWeekHeight: 32, // Compact
                                      rowHeight: 42, // Compact
                                      headerStyle: const HeaderStyle(
                                        formatButtonVisible: false,
                                        titleCentered: true,
                                        titleTextStyle: TextStyle(
                                          fontSize: 16, // Smaller header
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        leftChevronIcon: Icon(
                                          Icons.chevron_left_rounded,
                                          size: 20,
                                        ),
                                        rightChevronIcon: Icon(
                                          Icons.chevron_right_rounded,
                                          size: 20,
                                        ),
                                      ),
                                      calendarStyle: const CalendarStyle(
                                        outsideDaysVisible: false,
                                        cellMargin: EdgeInsets.all(
                                          2,
                                        ), // Tighter cells
                                        isTodayHighlighted: true,
                                        todayDecoration: BoxDecoration(
                                          color: Color(0xFF1fa2ff),
                                          shape: BoxShape.circle,
                                        ),
                                        defaultTextStyle: TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                      daysOfWeekStyle: const DaysOfWeekStyle(
                                        weekdayStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                        weekendStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      onPageChanged: (day) {
                                        focusedDay = day;
                                        fetchAttendance();
                                      },
                                      calendarBuilders: CalendarBuilders(
                                        dowBuilder: (context, day) {
                                          final label =
                                              _weekdays[day.weekday % 7];
                                          final isSunday =
                                              day.weekday == DateTime.sunday;
                                          return Center(
                                            child: Text(
                                              label.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isSunday
                                                    ? Colors.redAccent
                                                    : Colors.grey.shade600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          );
                                        },
                                        defaultBuilder: (context, day, _) {
                                          final color = _getDayColor(day);
                                          final isSunday =
                                              day.weekday == DateTime.sunday;

                                          if (color == null && isSunday) {
                                            return Container(
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.04,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                day.day.toString(),
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }

                                          if (color == null) return null;

                                          return Container(
                                            margin: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: color.withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              day.day.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
