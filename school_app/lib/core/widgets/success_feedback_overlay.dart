import 'package:flutter/material.dart';

class SuccessFeedbackOverlay {
  static void show(BuildContext context, {String message = "Operation Successful!"}) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _SuccessWidget(
        message: message,
        onDismiss: () {},
      ),
    );

    overlayState.insert(overlayEntry);

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(milliseconds: 2200), () {
      overlayEntry.remove();
    });
  }
}

class _SuccessWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _SuccessWidget({required this.message, required this.onDismiss});

  @override
  State<_SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<_SuccessWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );

    _controller.forward();
    
    // Start dismissal animation
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black26,
      child: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Success!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E263E),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
