import 'package:flutter/material.dart';

class AttendanceSummaryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Attendance Summary",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item("Present", present, Colors.green),
                _item("Absent", absent, Colors.red),
                _item("Holiday", holiday, Colors.blue),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              "Percentage: $percentage%",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label),
      ],
    );
  }
}
