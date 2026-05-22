import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

enum CyberBackgroundType {
  clean,      // bg1.png - used for clean, functional, data-heavy screens
  cinematic,  // bg2.png - used for cinematic, visual, high-impact screens
}

class CyberGridBackground extends StatefulWidget {
  final Widget child;
  final CyberBackgroundType type;
  final double? opacity;
  final bool showGrid;
  final bool showScanlines;
  final bool showAmbientGlow;

  const CyberGridBackground({
    super.key,
    required this.child,
    this.type = CyberBackgroundType.clean,
    this.opacity,
    this.showGrid = true,
    this.showScanlines = true,
    this.showAmbientGlow = true,
  });

  @override
  State<CyberGridBackground> createState() => _CyberGridBackgroundState();
}

class _CyberGridBackgroundState extends State<CyberGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 30 seconds loop for ultra-slow, premium ambient animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use bg1 for clean functional screens, bg2 for cinematic ones
    final String assetPath = widget.type == CyberBackgroundType.clean
        ? 'assets/images/bg1.png'
        : 'assets/images/bg2.png';

    // Opacity rules: 8%–12% for bg1 (clean), 14%–18% for bg2 (cinematic) unless overridden
    final double imageOpacity = widget.opacity ??
        (widget.type == CyberBackgroundType.clean ? 0.09 : 0.16);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // LAYER 1: Scaffold Base Solid Layer (Dark navy/black)
          Positioned.fill(
            child: Container(
              color: theme.scaffoldBackgroundColor,
            ),
          ),

          // LAYER 2: Compressed Background Asset Image with Opacity & Blend Mode
          Positioned.fill(
            child: Opacity(
              opacity: imageOpacity,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                // Ensures the image blends beautifully with the dark scaffold background
                color: Colors.black.withValues(alpha: 0.15),
                colorBlendMode: BlendMode.dstATop,
              ),
            ),
          ),

          // LAYER 3: Dark Translucent Gradient Overlay (ensures readability of UI content)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // LAYER 4: Dynamic Soft Ambient Glow (Floating blurred neon circles)
          if (widget.showAmbientGlow)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final angle = _controller.value * 2 * math.pi;
                  
                  // Calculate circulating coordinate offsets for floating ambient lights
                  final dx1 = math.sin(angle) * 80;
                  final dy1 = math.cos(angle) * 50;
                  
                  final dx2 = math.cos(angle + math.pi / 2) * 60;
                  final dy2 = math.sin(angle + math.pi / 2) * 80;

                  return Stack(
                    children: [
                      // Top-Left Soft Neon Purple/Blue Glow
                      Positioned(
                        top: -100 + dy1,
                        left: -100 + dx1,
                        child: BackClutterBlur(
                          key: const ValueKey('glow1'),
                          sigma: 75,
                          child: Container(
                            width: 320,
                            height: 320,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                      ),
                      // Bottom-Right Soft Emerald/Cyan Glow
                      Positioned(
                        bottom: -120 + dy2,
                        right: -120 + dx2,
                        child: BackClutterBlur(
                          key: const ValueKey('glow2'),
                          sigma: 85,
                          child: Container(
                            width: 380,
                            height: 380,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.secondary.withValues(alpha: 0.09),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          // LAYER 5: Cybernetic Grid Pattern Overlay
          if (widget.showGrid)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: widget.type == CyberBackgroundType.clean ? 0.03 : 0.06,
                  child: CustomPaint(
                    painter: _GridPainter(gridColor: colorScheme.primary),
                  ),
                ),
              ),
            ),

          // LAYER 6: Subtle Scrolling Scanline Effect for cinematic depth
          if (widget.showScanlines)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ScanlinePainter(
                        progress: _controller.value,
                        lineColor: colorScheme.primary.withValues(alpha: 0.015),
                      ),
                    );
                  },
                ),
              ),
            ),

          // LAYER 7: Main Interactive Screen Content
          Positioned.fill(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

// Separate widget for standard blurred background spot
class BackClutterBlur extends StatelessWidget {
  final Widget child;
  final double sigma;

  const BackClutterBlur({
    super.key,
    required this.child,
    this.sigma = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
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

    const double step = 38.0;
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

class _ScanlinePainter extends CustomPainter {
  final double progress;
  final Color lineColor;

  _ScanlinePainter({required this.progress, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    // Subtle moving scanner line
    final double y = progress * size.height;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // Static micro-scanlines overlay
    final staticPaint = Paint()
      ..color = lineColor.withValues(alpha: lineColor.a * 0.4)
      ..strokeWidth = 0.5;

    const double step = 6.0;
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), staticPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.lineColor != lineColor;
  }
}
