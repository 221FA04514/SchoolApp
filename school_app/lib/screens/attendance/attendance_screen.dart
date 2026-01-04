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
  late Animation<Offset> _slide;

  bool isLoadingMonth = false;

  final List<String> _weekdays = const [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
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

    _fade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOut),
    );

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

    final calendarRes =
        await api.get("/api/v1/attendance/calendar?month=$month&year=$year");

    final summaryRes =
        await api.get("/api/v1/attendance/summary?month=$month&year=$year");

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          // ================= HEADER =================
          SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Container(
                height: size.height * 0.22,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1A4DFF),
                      Color(0xFF3A6BFF),
                      Color(0xFF6A11CB),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: SafeArea(
                  child: Row(
                    children: const [
                      BackButton(color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Attendance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ================= CONTENT =================
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ================= SUMMARY =================
                    if (summary.isNotEmpty)
                      AnimatedSlide(
                        offset: Offset(0, _fade.value == 1 ? 0 : 0.1),
                        duration: const Duration(milliseconds: 500),
                        child: AttendanceSummaryCard(
                          present: summary["present"],
                          absent: summary["absent"],
                          holiday: summary["holiday"],
                          percentage: summary["percentage"],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ================= CALENDAR =================
                    AnimatedOpacity(
                      opacity: isLoadingMonth ? 0.5 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _calendarController,
                          curve: Curves.easeOutBack,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2020),
                            lastDay: DateTime.utc(2030),
                            focusedDay: focusedDay,

                            // ✅ FIX + SPACE FOR WEEKDAY ROW
                            daysOfWeekHeight: 32,

                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            calendarStyle: const CalendarStyle(
                              outsideDaysVisible: false,
                              cellMargin: EdgeInsets.all(6),
                            ),

                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              weekendStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),

                            onPageChanged: (day) {
                              focusedDay = day;
                              fetchAttendance();
                            },

                            calendarBuilders: CalendarBuilders(
                              // 🎬 WEEKDAY ANIMATION
                              dowBuilder: (context, day) {
                                final label =
                                    _weekdays[day.weekday % 7];

                                return AnimatedBuilder(
                                  animation: _calendarController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity:
                                          _calendarController.value,
                                      child: Transform.translate(
                                        offset: Offset(
                                          0,
                                          12 *
                                              (1 -
                                                  _calendarController
                                                      .value),
                                        ),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Center(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: day.weekday ==
                                                DateTime.sunday
                                            ? Colors.black54
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              },

                              // 📅 DAY CELLS
                              defaultBuilder: (context, day, _) {
                                final color = _getDayColor(day);
                                if (color == null) return null;

                                return AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    day.day.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
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
    );
  }
}
