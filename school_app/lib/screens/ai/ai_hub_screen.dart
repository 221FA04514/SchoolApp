import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_service.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key});

  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends State<AiHubScreen> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _showHomeworkHelper() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _HomeworkHelperSheet(api: _api, picker: _picker),
    );
  }

  Future<void> _showDoubtSolver() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DoubtSolverSheet(api: _api),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern Clean White
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF4F46E5),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "AI Learning Hub",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: -40,
                      right: -40,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Your Smarter Study Companion",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  "What would you like to do?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 24),
                _StudentAiCard(
                  title: "Homework Helper",
                  desc: "Scan your problem and get a step-by-step solution.",
                  icon: Icons.camera_alt_rounded,
                  color: const Color(0xFF4F46E5),
                  onTap: _showHomeworkHelper,
                ),
                const SizedBox(height: 16),
                _StudentAiCard(
                  title: "Doubt Solver",
                  desc: "Ask any question and get a simple explanation.",
                  icon: Icons.psychology_rounded,
                  color: const Color(0xFFEC4899),
                  onTap: _showDoubtSolver,
                ),
                const SizedBox(height: 16),
                _StudentAiCard(
                  title: "Study Planner",
                  desc: "Create a perfect schedule for your exams.",
                  icon: Icons.calendar_today_rounded,
                  color: const Color(0xFF0EA5E9),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Planning your success... Coming soon!"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF1E293B),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Powered by Neuraltrix AI",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAiCard extends StatelessWidget {
  final String title, desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StudentAiCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeworkHelperSheet extends StatefulWidget {
  final ApiService api;
  final ImagePicker picker;
  const _HomeworkHelperSheet({required this.api, required this.picker});

  @override
  State<_HomeworkHelperSheet> createState() => _HomeworkHelperSheetState();
}

class _HomeworkHelperSheetState extends State<_HomeworkHelperSheet> {
  final TextEditingController _controller = TextEditingController();
  XFile? _image;
  bool _loading = false;
  String? _result;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: const Color(0xFF4F46E5),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Homework Helper",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type your question or click an image...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _ActionBtn(
                  icon: Icons.camera_alt_rounded,
                  label: "Take Photo",
                  onTap: () async {
                    final img = await widget.picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (img != null) setState(() => _image = img);
                  },
                ),
                const SizedBox(width: 12),
                _ActionBtn(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  onTap: () async {
                    final img = await widget.picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (img != null) setState(() => _image = img);
                  },
                ),
                if (_image != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                ],
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Solve Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 32),
              const Text(
                "Solution Analysis:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  _result!,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _analyze() async {
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      String? base64Img;
      if (_image != null) {
        final bytes = await _image!.readAsBytes();
        base64Img = base64Encode(bytes);
      }
      final res = await widget.api.post("/api/v1/ai/homework-helper", {
        "prompt": _controller.text,
        "image": base64Img,
      });
      setState(() => _result = res["data"]["analysis"]);
    } catch (e) {
      setState(() => _result = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }
}

class _DoubtSolverSheet extends StatefulWidget {
  final ApiService api;
  const _DoubtSolverSheet({required this.api});

  @override
  State<_DoubtSolverSheet> createState() => _DoubtSolverSheetState();
}

class _DoubtSolverSheetState extends State<_DoubtSolverSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _result;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.psychology_rounded,
                  color: const Color(0xFFEC4899),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Ask a Doubt",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "What are you confused about?",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _solve,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Get Explanation",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFEC4899).withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AI EXPLANATION",
                      style: TextStyle(
                        color: Color(0xFFEC4899),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _result!,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text("Need more help? Ask a Teacher"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _solve() async {
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      final res = await widget.api.post("/api/v1/ai/solve-doubt", {
        "query": _controller.text,
        "subject": "General",
      });
      setState(() => _result = res["data"]["response"]);
    } catch (e) {
      setState(() => _result = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
