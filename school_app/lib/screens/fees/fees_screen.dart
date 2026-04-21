import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'fees_summary_card.dart';
import 'premium_payment_sheet.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> with SingleTickerProviderStateMixin {
  final ApiService api = ApiService();

  Map<String, dynamic> summary = {};
  List payments = [];
  bool loading = true;

  late AnimationController _pageController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    fetchFees();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchFees() async {
    try {
      final res = await api.get("/api/v1/fees/my");
      if (mounted) {
        setState(() {
          summary = res["data"]["summary"];
          payments = res["data"]["payments"];
          loading = false;
        });
        _pageController.forward();
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusRibbon(),
                          const SizedBox(height: 20),
                          FeesSummaryCard(
                            total: summary["total"],
                            paid: summary["paid"],
                            due: summary["due"],
                          ),
                          const SizedBox(height: 30),
                          _buildSectionLabel("ONLINE SERVICES"),
                          const SizedBox(height: 15),
                          _buildOnlineServicesGrid(),
                          const SizedBox(height: 35),
                          _buildSectionLabel("TRANSACTION HISTORY"),
                          const SizedBox(height: 15),
                          if (payments.isEmpty)
                            _buildEmptyState()
                          else
                            ...List.generate(payments.length, (i) => _buildPaymentItem(payments[i])),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1.2),
    );
  }

  Widget _buildStatusRibbon() {
    bool isCleared = (summary["due"] ?? 0) <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCleared ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isCleared ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(isCleared ? Icons.verified_rounded : Icons.pending_actions_rounded, color: isCleared ? Colors.green : Colors.orange, size: 18),
          const SizedBox(width: 10),
          Text(
            isCleared ? "YOUR ACCOUNT IS FULLY CLEARED" : "YOU HAVE PENDING DUES",
            style: TextStyle(color: isCleared ? Colors.green.shade700 : Colors.orange.shade800, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineServicesGrid() {
    return Row(
      children: [
         Expanded(
           child: _buildServiceCard(
             title: "Pay Fee\nOnline",
             sub: "UPI/Card",
             icon: Icons.bolt_rounded,
             color: const Color(0xFF4A00E0),
             onTap: summary["due"] > 0 ? () => _showPaymentSheet() : null,
           ),
         ),
         const SizedBox(width: 15),
         Expanded(
           child: _buildServiceCard(
             title: "Download\nReceipt",
             sub: "PDF Format",
             icon: Icons.file_download_rounded,
             color: const Color(0xFF00C9FF),
             onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Receipt generation is being processed...")));
             },
           ),
         ),
      ],
    );
  }

  Widget _buildServiceCard({required String title, required String sub, required IconData icon, required Color color, VoidCallback? onTap}) {
    bool isDisabled = onTap == null;
    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 15),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.2, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text(sub, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF4A00E0),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        title: Row(
          children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20)),
            const Text("FEES PORTAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumPaymentSheet(
        dueAmount: (summary["due"] as num).toDouble(),
        onPaymentConfirm: (amount, method) => _processPayment(amount.toInt(), method),
      ),
    );
  }

  Future<void> _processPayment(int amount, String method) async {
    setState(() => loading = true);
    try {
      await api.post("/api/v1/fees/pay-online", {
        "amount_paid": amount,
        "payment_mode": method,
      });

      if (mounted) {
        _showSuccessAnimation();
        fetchFees();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Failed: $e"), backgroundColor: Colors.red));
        setState(() => loading = false);
      }
    }
  }

  void _showSuccessAnimation() {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                child: Icon(Icons.check_rounded, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 25),
              const Text("PAYMENT SUCCESSFULL!", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 10),
              const Text("Your fee record has been updated.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text("GREAT!", style: TextStyle(color: Colors.white)),
                ),
              ),
           ],
         ),
       ),
     );
  }

  Widget _buildPaymentItem(dynamic p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(15)),
             child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF4A00E0)),
           ),
           const SizedBox(width: 15),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text("₹${p["amount_paid"]}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
                 Text(p["payment_mode"], style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
               ],
             ),
           ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Text(p["payment_date"].toString().split('T')[0], style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
               const Text("SUCCESS", style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.w900)),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
       child: Column(
         children: [
            const SizedBox(height: 40),
            Icon(Icons.history_rounded, size: 50, color: Colors.grey.shade100),
            const SizedBox(height: 10),
            const Text("No transactions yet", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
         ],
       ),
     );
  }
}
