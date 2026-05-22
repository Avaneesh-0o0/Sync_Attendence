import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomLogoWidget extends StatelessWidget {
  final double size;
  final bool animate;

  const CustomLogoWidget({
    super.key,
    this.size = 100.0,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoImage = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: animate
            ? [
                BoxShadow(
                  color: const Color(0xFF00F5FF).withValues(alpha: 0.3),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ]
            : [],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/ourlogo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );

    if (!animate) return logoImage;

    return logoImage
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 2500.ms,
          curve: Curves.easeInOutSine,
        )
        .shimmer(
          duration: 4000.ms,
          color: Colors.white.withValues(alpha: 0.15),
          angle: 1.0,
        );
  }
}
