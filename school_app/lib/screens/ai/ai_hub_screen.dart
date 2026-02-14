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
  List<dynamic> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
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
        title: const Text("Delete History?"),
        content: const Text("This interaction will be permanently removed."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _api.delete("/api/v1/ai/history/$id");
        _fetchHistory();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("History item deleted")));
        }
      } catch (e) {
        debugPrint("Error deleting history: $e");
      }
    }
  }

  Future<void> _showHomeworkHelper() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _HomeworkHelperSheet(
        api: _api,
        picker: _picker,
        onComplete: _fetchHistory,
      ),
    );
  }

  Future<void> _showDoubtSolver() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _DoubtSolverSheet(api: _api, onComplete: _fetchHistory),
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
                decoration: const BoxDecoration(color: const Color(0xFF4A00E0)),
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
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Activity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (_history.isNotEmpty)
                      TextButton(
                        onPressed: _fetchHistory,
                        child: const Text("Refresh"),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_loadingHistory)
                  const Center(child: CircularProgressIndicator())
                else if (_history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No history yet. Start learning!",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _history.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return _HistoryTile(
                        item: item,
                        onTap: () => _showHistoryDetail(item),
                        onDelete: () => _deleteHistoryItem(item['id']),
                      );
                    },
                  ),
                const SizedBox(height: 48),
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
                          "Powered by NeuralTrix AI",
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
  final VoidCallback? onComplete;
  const _HomeworkHelperSheet({
    required this.api,
    required this.picker,
    this.onComplete,
  });

  @override
  State<_HomeworkHelperSheet> createState() => _HomeworkHelperSheetState();
}

class _HomeworkHelperSheetState extends State<_HomeworkHelperSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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
        controller: _scrollController,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "AI Tutor",
                            style: TextStyle(
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                  ),
                ],
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
      widget.onComplete?.call();

      // Auto-scroll to result
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() => _result = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
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

  @override
  void initState() {
    super.initState();
    // Initial greeting
    _messages.add({
      "role": "assistant",
      "content": "Hi! I'm your AI study assistant. What are you stuck on?",
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _loading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      // Prepare history for API (exclude the very last user message we just added,
      // or include it? The API expects 'history'.
      // My backend implementation uses the history to build context,
      // and the 'query' is the new user input.
      // So I should pass PREVIOUS messages as history.

      final history = _messages.sublist(
        0,
        _messages.length - 1,
      ); // everything before current

      final res = await widget.api.post("/api/v1/ai/solve-doubt", {
        "query": text,
        "subject": "General",
        "history": history,
      });

      if (mounted) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": res["data"]["response"],
          });
          _loading = false;
        });
        widget.onComplete?.call();
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "Sorry, I encountered an error: $e",
          });
          _loading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // HANDLE
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // HEADER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFEC4899),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "AI Doubt Solver",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // CHAT AREA
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildLoadingBubble();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // INPUT AREA
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your question...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _loading ? null : _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEC4899),
                      shape: BoxShape.circle,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 24,
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

  Widget _buildMessageBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFEC4899) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Text(
                "Neuraltrix AI",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              msg['content']!,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF334155),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: const SizedBox(
          width: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 8,
                height: 8,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 4),
              SizedBox(
                width: 8,
                height: 8,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 4),
              SizedBox(
                width: 8,
                height: 8,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isHomework = item['type'] == 'homework';
    final date = DateTime.parse(item['created_at']);
    final timeStr =
        "${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    final color = isHomework
        ? const Color(0xFF4F46E5)
        : const Color(0xFFEC4899);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isHomework
                        ? Icons.camera_alt_rounded
                        : Icons.psychology_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['prompt'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.withOpacity(0.5),
                    size: 20,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
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
    final color = isHomework
        ? const Color(0xFF4F46E5)
        : const Color(0xFFEC4899);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isHomework
                              ? Icons.menu_book_rounded
                              : Icons.lightbulb_rounded,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isHomework ? "Solution Review" : "Concept Review",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "QUESTION",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['prompt'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isHomework
                              ? Icons.psychology_rounded
                              : Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.05),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            border: Border.all(color: color.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHomework ? "AI Tutor" : "Neuraltrix AI",
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['response'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.7,
                                  color: Color(0xFF334155),
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Close",
                style: TextStyle(color: Color(0xFF1E293B)),
              ),
            ),
          ),
        ],
      ),
    );
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
