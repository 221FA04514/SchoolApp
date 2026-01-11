import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class AttendanceSummaryCard extends StatefulWidget {
  final int present;
  final int absent;
  final int holiday;
  final int percentage;

  const AttendanceSummaryCard({
    super.key,
    required this.present,
    required this.absent,
    required this.holiday,
    required this.percentage,
  });

  @override
  State<AttendanceSummaryCard> createState() => _AttendanceSummaryCardState();
}

class _AttendanceSummaryCardState extends State<AttendanceSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Live rotation duration
    );

    _rotationAnim = Tween<double>(begin: 0, end: 360).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AttendanceSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Avoid division by zero
    final total = widget.present + widget.absent + widget.holiday;
    final hasData = total > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🍩 COMPACT DONUT CHART (LEFT)
          SizedBox(
            height: 120,
            width: 120,
            child: hasData
                ? Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _rotationAnim,
                        builder: (context, child) {
                          return PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              startDegreeOffset: _rotationAnim.value - 90,
                              sections: [
                                _section(
                                  widget.present,
                                  const Color(0xFF43CEA2),
                                ),
                                _section(
                                  widget.absent,
                                  const Color(0xFFFF5F6D),
                                ),
                                _section(
                                  widget.holiday,
                                  const Color(0xFF3A6BFF),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // 🎯 CENTER PERCENTAGE
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${widget.percentage}%",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getPercentageColor(widget.percentage),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      "No Data",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
          ),

          const SizedBox(width: 24),

          // 📊 STATS LIST (RIGHT)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _compactLegendItem(
                  "Present",
                  widget.present,
                  const Color(0xFF43CEA2),
                ),
                const SizedBox(height: 8),
                _compactLegendItem(
                  "Absent",
                  widget.absent,
                  const Color(0xFFFF5F6D),
                ),
                const SizedBox(height: 8),
                _compactLegendItem(
                  "Holiday",
                  widget.holiday,
                  const Color(0xFF3A6BFF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(int value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: "",
      radius: 14,
      showTitle: false,
    );
  }

  Widget _compactLegendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getPercentageColor(int p) {
    if (p >= 75) return const Color(0xFF43CEA2);
    if (p >= 60) return Colors.orange;
    return const Color(0xFFFF5F6D);
  }
}
