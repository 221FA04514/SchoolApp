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
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1A4DFF),
                            Color(0xFF3A6BFF),
                            Color(0xFF6A11CB),
                          ],
                        ),
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
                                    milliseconds: 500 + index * 120),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset:
                                          Offset(0, 30 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Card(
                                  margin:
                                      const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor:
                                          Color(0xFF1A4DFF),
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
}
