// widgets/glass_card.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color tint;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.blur = 14,
    this.tint = Colors.white,
    this.opacity = 0.16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),

      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),

        child: Container(
          padding: padding,

          decoration: BoxDecoration(
            color: tint.withValues(alpha: opacity),

            borderRadius: BorderRadius.circular(radius),

            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),

              width: 1,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),

                blurRadius: 18,

                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }
}
