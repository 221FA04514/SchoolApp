import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_service.dart';
import 'package:intl/intl.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key});

  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends State<AiHubScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _history = [];
  bool _loadingHistory = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _fetchHistory();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    try {
      final res = await _api.get("/api/v1/ai/history");
      setState(() {
        _history = res["data"]["history"] ?? [];
        _loadingHistory = false;
      });
    } catch (e) {
      debugPrint("Error fetching AI history: $e");
      setState(() => _loadingHistory = false);
    }
  }

  void _showHistoryDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HistoryDetailSheet(item: item),
    );
  }

  Future<void> _deleteHistoryItem(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Delete Record?", style: TextStyle(color: Colors.white)),
        content: const Text("This AI interaction will be permanently removed.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep it"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
              elevation: 0,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _api.delete("/api/v1/ai/history/$id");
        _fetchHistory();
      } catch (e) {
        debugPrint("Error deleting history: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Ambient backgrounds
          _buildAmbientGlow(),
          
          SafeArea(
            child: Column(
              children: [
                _buildModernAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildHeroCard(),
                        const SizedBox(height: 32),
                        _buildSectionHeader("AI SUITE", "SELECT A CAPABILITY"),
                        const SizedBox(height: 16),
                        _AiCoreCard(
                          title: "Homework Helper",
                          subtitle: "Step-by-step logic solver",
                          icon: Icons.menu_book_rounded,
                          color: const Color(0xFF6366F1),
                          onTap: () => _showSheet(context, _HomeworkHelperSheet(api: _api, picker: _picker, onComplete: _fetchHistory)),
                        ),
                        const SizedBox(height: 16),
                        _AiCoreCard(
                          title: "Doubt Solver",
                          subtitle: "Chat with a Neural Expert",
                          icon: Icons.psychology_rounded,
                          color: const Color(0xFFEC4899),
                          onTap: () => _showSheet(context, _DoubtSolverSheet(api: _api, onComplete: _fetchHistory)),
                        ),
                        const SizedBox(height: 32),
                        _buildSectionHeader("ACTIVITY", "RECENT INTERACTIONS"),
                        const SizedBox(height: 16),
                        _buildHistoryList(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => sheet,
    );
  }

  Widget _buildAmbientGlow() {
    return Stack(
      children: [
        Positioned(
          top: -150,
          right: -100,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.12 * _pulseController.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _GlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "NeuralHub",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              Text(
                "ADVANCED LEARNING AI",
                style: TextStyle(color: const Color(0xFF6366F1), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ],
          ),
          const Spacer(),
          _buildAiBadge(),
        ],
      ),
    );
  }

  Widget _buildAiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          const Text("V3.2 LATEST", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Master Any Subject",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Upload your homework or ask complex questions. NeuralTrix processes logic in real-time.",
            style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String tag, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tag, style: TextStyle(color: const Color(0xFF6366F1).withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_loadingHistory) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFF6366F1))));
    }
    if (_history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(24)),
        child: const Center(child: Text("No records available yet", style: TextStyle(color: Colors.white24, fontSize: 14))),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HistoryItemTile(
            item: item,
            onTap: () => _showHistoryDetail(item),
            onDelete: () => _deleteHistoryItem(item['id']),
          ),
        );
      },
    );
  }
}

class _AiCoreCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AiCoreCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap, onDelete;

  const _HistoryItemTile({required this.item, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isHomework = item['type'] == 'homework';
    final date = DateTime.parse(item['created_at']);
    final timeStr = DateFormat('MMM d, h:mm a').format(date);
    final color = isHomework ? const Color(0xFF6366F1) : const Color(0xFFEC4899);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(isHomework ? Icons.auto_awesome_rounded : Icons.chat_bubble_rounded, color: color, size: 18),
        ),
        title: Text(item['prompt'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(timeStr, style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)),
        trailing: IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, color: Colors.white12, size: 18)),
      ),
    );
  }
}

class _HistoryDetailSheet extends StatelessWidget {
  final Map<String, dynamic> item;
  const _HistoryDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final isHomework = item['type'] == 'homework';
    final color = isHomework ? const Color(0xFF6366F1) : const Color(0xFFEC4899);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(isHomework ? Icons.auto_awesome_rounded : Icons.psychology_rounded, color: color),
                const SizedBox(width: 12),
                Text(isHomework ? "Solution Detail" : "Interaction Detail", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                _GlassButton(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PROMPT", style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(item['prompt'], style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 32),
                  const Text("NEURALTRIX RESPONSE", style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
                    child: Text(item['response'], style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeworkHelperSheet extends StatefulWidget {
  final ApiService api;
  final ImagePicker picker;
  final VoidCallback? onComplete;
  const _HomeworkHelperSheet({required this.api, required this.picker, this.onComplete});

  @override
  State<_HomeworkHelperSheet> createState() => _HomeworkHelperSheetState();
}

class _HomeworkHelperSheetState extends State<_HomeworkHelperSheet> {
  final TextEditingController _controller = TextEditingController();
  XFile? _image;
  bool _loading = false;
  String? _result;

  Future<void> _analyze() async {
    if (_controller.text.isEmpty && _image == null) return;
    setState(() { _loading = true; _result = null; });
    try {
      String? base64Image;
      if (_image != null) {
        final bytes = await _image!.readAsBytes();
        base64Image = base64Encode(bytes);
      }
      final res = await widget.api.post("/api/v1/ai/homework-helper", {
        "prompt": _controller.text,
        "image": base64Image,
      });
      setState(() { _result = res["data"]["analysis"]; _loading = false; });
      widget.onComplete?.call();
    } catch (e) {
      setState(() { _result = "An error occurred while connecting to Neural Core. Please check your connection."; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text("Neural Homework Solver", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Describe the problem or context...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.02),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _GlassActionBtn(icon: Icons.camera_alt_rounded, label: "Capture", onTap: () async {
                  final img = await widget.picker.pickImage(source: ImageSource.camera);
                  if (img != null) setState(() => _image = img);
                }),
                const SizedBox(width: 12),
                _GlassActionBtn(icon: Icons.photo_library_rounded, label: "Gallery", onTap: () async {
                  final img = await widget.picker.pickImage(source: ImageSource.gallery);
                  if (img != null) setState(() => _image = img);
                }),
                if (_image != null) Padding(padding: const EdgeInsets.only(left: 12), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_image!.path), width: 40, height: 40, fit: BoxFit.cover))),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: Colors.white10,
                ),
                child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Initiate Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 32),
              const Text("SOLUTION ENGINE OUTPUT", style: TextStyle(color: Color(0xFF6366F1), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2))),
                child: Text(_result!, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DoubtSolverSheet extends StatefulWidget {
  final ApiService api;
  final VoidCallback? onComplete;
  const _DoubtSolverSheet({required this.api, this.onComplete});

  @override
  State<_DoubtSolverSheet> createState() => _DoubtSolverSheetState();
}

class _DoubtSolverSheetState extends State<_DoubtSolverSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() { _messages.add({"role": "user", "content": text}); _controller.clear(); _loading = true; });
    _scrollToBottom();
    try {
      final res = await widget.api.post("/api/v1/ai/solve-doubt", {"query": text});
      setState(() { _messages.add({"role": "ai", "content": res["data"]["response"]}); _loading = false; });
      widget.onComplete?.call();
    } catch (e) {
      setState(() { _messages.add({"role": "ai", "content": "Critical system timeout. Unable to sync with Neural Core."}); _loading = false; });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded, color: Color(0xFFEC4899)),
                const SizedBox(width: 12),
                const Text("Neural Concept Solver", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                _GlassButton(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildLoader();
                final msg = _messages[index];
                return _ChatBubble(msg: msg);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEC4899))),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: "Ask anything...", hintStyle: const TextStyle(color: Colors.white24), border: InputBorder.none),
              onSubmitted: (_) => _send(),
            ),
          ),
          IconButton(onPressed: _send, icon: const Icon(Icons.send_rounded, color: Color(0xFFEC4899))),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Map<String, String> msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFEC4899) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: Text(msg['content']!, style: TextStyle(color: isUser ? Colors.white : Colors.white70, fontSize: 14, height: 1.5)),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _GlassActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GlassActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white54),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
