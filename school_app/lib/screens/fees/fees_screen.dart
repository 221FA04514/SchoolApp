import 'package:flutter/material.dart';

import '../../core/api/api_service.dart';
import 'fees_summary_card.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  final ApiService api = ApiService();

  Map<String, dynamic> summary = {};
  List payments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchFees();
  }

  Future<void> fetchFees() async {
    final res = await api.get("/api/v1/fees/my");

    setState(() {
      summary = res["data"]["summary"];
      payments = res["data"]["payments"];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fees")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 💰 SUMMARY
                  FeesSummaryCard(
                    total: summary["total"],
                    paid: summary["paid"],
                    due: summary["due"],
                  ),

                  const SizedBox(height: 20),

                  // 📜 PAYMENT HISTORY
                  const Text(
                    "Payment History",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (payments.isEmpty)
                    const Text("No payments found"),

                  ...payments.map(
                    (p) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.payment),
                        title: Text("₹${p["amount_paid"]}"),
                        subtitle: Text(
                          "${p["payment_mode"]} • ${p["payment_date"].toString().split('T')[0]}",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
