import 'package:flutter/material.dart';
import 'dart:async';

class PremiumPaymentSheet extends StatefulWidget {
  final double dueAmount;
  final Function(double amount, String method) onPaymentConfirm;

  const PremiumPaymentSheet({
    super.key,
    required this.dueAmount,
    required this.onPaymentConfirm,
  });

  @override
  State<PremiumPaymentSheet> createState() => _PremiumPaymentSheetState();
}

class _PremiumPaymentSheetState extends State<PremiumPaymentSheet> {
  // ================= CONFIGURATION =================
  // CHANGE THIS TO YOUR RECIPIENT UPI ID
  final String _schoolUpiId = "8185864150@ybl";
  // =================================================

  int _currentStep = 0; // 0: Select Method, 1: Details, 2: Verification
  String _selectedMethod = "UPI";
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _trxIdController = TextEditingController();

  // Card Info
  final TextEditingController _cardNumber = TextEditingController();
  final TextEditingController _expiry = TextEditingController();
  final TextEditingController _cvv = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.dueAmount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _trxIdController.dispose();
    _cardNumber.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildStepContent(),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildMethodSelection();
      case 1: return _buildMethodDetails();
      case 2: return _buildPaymentProcessing();
      default: return _buildMethodSelection();
    }
  }

  Widget _buildMethodSelection() {
    return Column(
      key: const ValueKey(0),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
        const SizedBox(height: 25),
        const Text("Online Fee Payment", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 5),
        const Text("Choose your preferred method", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 25),
        
        const Text("AMOUNT TO PAY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1)),
        const SizedBox(height: 10),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF4A00E0)),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFF4A00E0)),
            hintText: "Enter Amount",
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            suffixText: "/ ₹${widget.dueAmount.toStringAsFixed(0)}",
            suffixStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 25),

        _buildMethodTile("UPI", "GPay, PhonePe, BHIM", Icons.account_balance_wallet_rounded, Colors.orange),
        const SizedBox(height: 12),
        _buildMethodTile("Card", "Credit / Debit Cards", Icons.credit_card_rounded, Colors.blue),
        
        const SizedBox(height: 35),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              double? amount = double.tryParse(_amountController.text);
              if (amount == null || amount <= 0 || amount > widget.dueAmount) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount within due limit.")));
                return;
              }
              setState(() => _currentStep = 1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A00E0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text("Generate Payment QR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodTile(String title, String sub, IconData icon, Color color) {
    bool isSelected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isSelected ? color : Colors.grey.shade100, width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodDetails() {
    if (_selectedMethod == "UPI") return _buildUpiDetails();
    if (_selectedMethod == "Card") return _buildCardDetails();
    return _buildUpiDetails();
  }

  Widget _buildUpiDetails() {
    final amount = double.tryParse(_amountController.text) ?? widget.dueAmount;
    final String qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=upi://pay?pa=$_schoolUpiId&pn=SchoolFees&am=$amount&cu=INR";

    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () => setState(() => _currentStep = 0), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
            const Text("Scan & Verify", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
          ),
          child: Column(
            children: [
              Image.network(qrUrl, height: 200, width: 200),
              const SizedBox(height: 15),
              const Text("SCAN TO PAY ₹", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey)),
              Text(amount.toStringAsFixed(2), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 10),
              Text("ID: $_schoolUpiId", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text("ENTER TRANSACTION REFERENCE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1)),
        const SizedBox(height: 10),
        TextField(
          controller: _trxIdController,
          decoration: InputDecoration(
            hintText: "Ref Number (e.g. 123456...)",
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              if (_trxIdController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter transaction reference for verification.")));
                return;
              }
              setState(() => _currentStep = 2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Verify Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetails() {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () => setState(() => _currentStep = 0), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
            const Text("Card Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF232526), Color(0xFF414345)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.credit_card_rounded, color: Colors.white, size: 40),
              const SizedBox(height: 25),
              const Text("•••• •••• •••• 5521", style: TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("SECURE PAYMENT", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("VAL THRU 12/28", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        TextField(
          controller: _cardNumber,
          decoration: InputDecoration(hintText: "Card Number", prefixIcon: const Icon(Icons.credit_card), border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)), filled: true, fillColor: Colors.grey.shade50),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: TextField(controller: _expiry, decoration: InputDecoration(hintText: "MM/YY", border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)), filled: true, fillColor: Colors.grey.shade50))),
            const SizedBox(width: 15),
            Expanded(child: TextField(controller: _cvv, obscureText: true, decoration: InputDecoration(hintText: "CVV", border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)), filled: true, fillColor: Colors.grey.shade50))),
          ],
        ),
        const SizedBox(height: 35),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => setState(() => _currentStep = 2),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A00E0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Process Secure Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentProcessing() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onPaymentConfirm(double.tryParse(_amountController.text) ?? widget.dueAmount, _selectedMethod);
      }
    });

    return Column(
      key: const ValueKey(3),
      mainAxisSize: MainAxisSize.min,
      children: const [
        SizedBox(height: 40),
        CircularProgressIndicator(color: Color(0xFF4A00E0), strokeWidth: 5),
        SizedBox(height: 25),
        Text("Verifying Your Payment...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        SizedBox(height: 10),
        Text("Validating with UPI Gateway", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        SizedBox(height: 40),
      ],
    );
  }
}
