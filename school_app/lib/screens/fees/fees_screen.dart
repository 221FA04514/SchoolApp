import 'package:flutter/material.dart';

import '../../core/api/api_service.dart';
import 'fees_summary_card.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen>
    with SingleTickerProviderStateMixin {
  final ApiService api = ApiService();

  Map<String, dynamic> summary = {};
  List payments = [];
  bool loading = true;

  late AnimationController _pageController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    fetchFees();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchFees() async {
    final res = await api.get("/api/v1/fees/my");

    setState(() {
      summary = res["data"]["summary"];
      payments = res["data"]["payments"];
      loading = false;
    });

    _pageController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                        color: const Color(0xFF4A00E0),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(28),
                        ),
                      ),
                      child: SafeArea(
                        child: Row(
                          children: const [
                            BackButton(color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "💸 Fees",
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
                    child: SlideTransition(
                      position: _slide,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 💰 SUMMARY CARD
                            FeesSummaryCard(
                              total: summary["total"],
                              paid: summary["paid"],
                              due: summary["due"],
                            ),

                            const SizedBox(height: 20),

                            // 💳 Pay Now Button
                            if (summary["due"] > 0)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showPaymentDialog(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A00E0),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                  ),
                                  icon: const Icon(Icons.payment),
                                  label: const Text(
                                    "Pay Now",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 26),

                            // 📜 PAYMENT HISTORY TITLE
                            const Text(
                              "📜 Payment History",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            if (payments.isEmpty)
                              const Text(
                                "🎉 No payments found",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),

                            // ================= PAYMENT LIST =================
                            ...List.generate(payments.length, (index) {
                              final p = payments[index];

                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(
                                  milliseconds: 500 + index * 120,
                                ),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 30 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFF1A4DFF),
                                      child: Text(
                                        "💳",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    title: Text(
                                      "₹${p["amount_paid"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${p["payment_mode"]} • ${p["payment_date"].toString().split('T')[0]}",
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showPaymentDialog() {
    final TextEditingController amountController = TextEditingController(
      text: summary["due"].toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Make Payment",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Enter Amount",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A00E0),
              ),
              decoration: InputDecoration(
                prefixText: "₹ ",
                prefixStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A00E0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF4F6FB),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = int.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid amount")),
                    );
                    return;
                  }

                  if (amount > summary["due"]) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Amount cannot exceed due fees"),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  _processPayment(amount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirm Payment",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(int amount) async {
    setState(() => loading = true);

    try {
      await api.post("/api/v1/fees/pay-online", {
        "amount_paid": amount,
        "payment_mode": "Online",
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Payment Successful!"),
            backgroundColor: Colors.green,
          ),
        );
      }
      fetchFees();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Payment Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => loading = false);
      }
    }
  }
}
