import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubstitutionBanner extends StatefulWidget {
  final List<Map<String, dynamic>> assignments;
  final VoidCallback onDismiss;

  const SubstitutionBanner({
    super.key,
    required this.assignments,
    required this.onDismiss,
  });

  @override
  State<SubstitutionBanner> createState() => _SubstitutionBannerState();
}

class _SubstitutionBannerState extends State<SubstitutionBanner>
    with TickerProviderStateMixin {
  late AnimationController _dismissController;
  late Animation<double> _fold;
  late Animation<double> _flyToBottom;
  late Animation<double> _shrink;
  late Animation<double> _fadeOut;
  late AnimationController _floatController;

  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fold = Tween<double>(begin: 0.0, end: math.pi / 2).animate(
      CurvedAnimation(parent: _dismissController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _flyToBottom = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dismissController, curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCubic)),
    );

    _shrink = Tween<double>(begin: 1.0, end: 0.05).animate(
      CurvedAnimation(parent: _dismissController, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _dismissController, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    setState(() => _isDismissing = true);
    await _dismissController.forward();
    if (mounted) widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assignments.isEmpty) return const SizedBox.shrink();
    
    final first = widget.assignments.first;
    final extraCount = widget.assignments.length - 1;

    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _dismissController]),
      builder: (context, child) {
        double verticalOffset = 0;
        double rotationOffset = 0;
        if (!_isDismissing) {
          verticalOffset = math.sin(_floatController.value * 2 * math.pi) * 8;
          rotationOffset = math.sin(_floatController.value * 2 * math.pi) * 0.02;
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final targetX = (screenWidth * 0.3) - (screenWidth / 2);
        final targetY = screenHeight * 0.65;

        return Transform.translate(
          offset: Offset(
            _flyToBottom.value * targetX,
            verticalOffset + (_flyToBottom.value * targetY),
          ),
          child: Transform.rotate(
            angle: rotationOffset,
            child: Opacity(
              opacity: _fadeOut.value,
              child: Transform.scale(
                scale: _shrink.value,
                alignment: Alignment.center,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_fold.value),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: Material( // CRITICAL: Material prevents the yellow underlines in Stack/Overlay
        type: MaterialType.transparency,
        child: _buildCard(first, extraCount),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> first, int extraCount) {
    final className = first['class_name']?.toString() ?? '—';
    final sectionName = first['section_name']?.toString() ?? '—';
    final classLabel = (className == '—' && sectionName == '—') ? 'Assigned Class' : 'Class $className-$sectionName';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4F46E5).withOpacity(0.92), // Indigo
                  const Color(0xFF7C3AED).withOpacity(0.85), // Violet
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Decorative light blobs
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.info_outline_rounded, size: 14, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'ASSIGNMENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _dismiss,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Main Content Row
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Covering for',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  first['original_teacher'] ?? 'Colleague',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Details Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            _detailItem(Icons.school_rounded, classLabel),
                            const Spacer(),
                            Container(width: 1.5, height: 24, color: Colors.white.withOpacity(0.2)),
                            const Spacer(),
                            _detailItem(Icons.schedule_rounded, 'Period ${first['period'] ?? '—'}'),
                          ],
                        ),
                      ),
                      
                      if (extraCount > 0) ...[
                        const SizedBox(height: 14),
                        Text(
                          '+ $extraCount more duties today',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
