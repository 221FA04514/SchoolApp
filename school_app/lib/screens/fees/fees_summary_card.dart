import 'package:flutter/material.dart';

class FeesSummaryCard extends StatelessWidget {
  final int total;
  final int paid;
  final int due;

  const FeesSummaryCard({
    super.key,
    required this.total,
    required this.paid,
    required this.due,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Fees Summary",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item("Total", total, Colors.blue),
                _item("Paid", paid, Colors.green),
                _item("Due", due, Colors.red),
              ],
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
          "₹$value",
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
