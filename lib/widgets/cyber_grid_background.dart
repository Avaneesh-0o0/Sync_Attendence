import 'package:flutter/material.dart';

class CyberGridBackground extends StatelessWidget {
  final Widget child;
  final double gridOpacity;

  const CyberGridBackground({
    super.key,
    required this.child,
    this.gridOpacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        // Base dark background
        Positioned.fill(
          child: Container(
            color: theme.scaffoldBackgroundColor,
          ),
        ),
        // Grid Lines
        Positioned.fill(
          child: Opacity(
            opacity: gridOpacity,
            child: CustomPaint(
              painter: _GridPainter(gridColor: colorScheme.primary),
            ),
          ),
        ),
        // Corner Neon Glowing Spots (Gradients)
        Positioned(
          top: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withOpacity(0.12),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.secondary.withOpacity(0.08),
            ),
          ),
        ),
        // Content
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color gridColor;

  _GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const double step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
