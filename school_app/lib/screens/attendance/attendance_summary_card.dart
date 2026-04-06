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
      duration: const Duration(seconds: 2),
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
    final total = widget.present + widget.absent + widget.holiday;
    final hasData = total > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              // 🍩 DONUT CHART
              SizedBox(
                height: 140,
                width: 140,
                child: hasData
                    ? Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _rotationAnim,
                            builder: (context, child) {
                              return PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 45,
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
                                      const Color(0xFFFBC02D),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${widget.percentage}%",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: _getPercentageColor(
                                      widget.percentage,
                                    ),
                                    letterSpacing: -1,
                                  ),
                                ),
                                const Text(
                                  "SCORE",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _buildEmptyChart(),
              ),
              const SizedBox(width: 32),
              // 📊 LEGEND
              Expanded(
                child: Column(
                  children: [
                    _legendItem(
                      "Present ✅",
                      widget.present,
                      const Color(0xFF43CEA2),
                    ),
                    const SizedBox(height: 12),
                    _legendItem(
                      "Absent ❌",
                      widget.absent,
                      const Color(0xFFFF5F6D),
                    ),
                    const SizedBox(height: 12),
                    _legendItem(
                      "Holiday 🗓️",
                      widget.holiday,
                      const Color(0xFFFBC02D),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 140,
      width: 140,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          "NO DATA 📭",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  PieChartSectionData _section(int value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: "",
      radius: 18,
      showTitle: false,
    );
  }

  Widget _legendItem(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E263E),
              ),
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E263E),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(int p) {
    if (p >= 75) return const Color(0xFF43CEA2);
    if (p >= 60) return Colors.orange;
    return const Color(0xFFFF5F6D);
  }
}
