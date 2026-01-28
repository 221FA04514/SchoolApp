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

    try {
      final calendarRes = await api.get(
        "/api/v1/attendance/calendar?month=$month&year=$year",
      );
      final summaryRes = await api.get(
        "/api/v1/attendance/summary?month=$month&year=$year",
      );

      if (mounted) {
        setState(() {
          attendanceMap = Map<String, String>.from(calendarRes["data"] ?? {});
          summary = summaryRes["data"] ?? {};
          isLoadingMonth = false;
        });
        _calendarController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingMonth = false);
    }
  }

  Color? _getDayColor(DateTime day) {
    final key =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    final status = attendanceMap[key];

    if (status == "present") return const Color(0xFF43CEA2);
    if (status == "absent") return const Color(0xFFFF5F6D);
    if (status == "late") return const Color(0xFFFFA726);
    if (status == "holiday") return const Color(0xFFFBC02D);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          _buildHeaderBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(children: [_buildAttendanceHub()]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 280,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A4DFF), Color(0xFF12D8FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
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
            "Attendance Hub 📋",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHub() {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            if (summary.isNotEmpty)
              AttendanceSummaryCard(
                present: summary["present"] ?? 0,
                absent: summary["absent"] ?? 0,
                holiday: summary["holiday"] ?? 0,
                percentage: summary["percentage"] ?? 0,
              ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 1),
            ),
            _buildCalendar(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return AnimatedOpacity(
      opacity: isLoadingMonth ? 0.6 : 1,
      duration: const Duration(milliseconds: 300),
      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030),
        focusedDay: focusedDay,
        daysOfWeekHeight: 32,
        rowHeight: 48,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E263E),
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            size: 24,
            color: Color(0xFF1A4DFF),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: Color(0xFF1A4DFF),
          ),
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          isTodayHighlighted: false,
        ),
        onPageChanged: (day) {
          setState(() => focusedDay = day);
          fetchAttendance();
        },
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            final label = _weekdays[day.weekday % 7];
            final isSunday = day.weekday == DateTime.sunday;
            return Center(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSunday ? Colors.redAccent : Colors.blueGrey.shade300,
                  letterSpacing: 1,
                ),
              ),
            );
          },
          todayBuilder: (context, day, _) {
            final color = _getDayColor(day);
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: color != null
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: color != null ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            );
          },
          defaultBuilder: (context, day, _) {
            final color = _getDayColor(day);
            if (day.weekday == DateTime.sunday && color == null) {
              return Center(
                child: Text(
                  day.day.toString(),
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            }
            if (color == null) return null;

            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                day.day.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
