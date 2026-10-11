import 'package:flutter/material.dart';

/// Renders the Digital Inertia Infinity Symbol logo.
/// Matches the sleek infinity curve shown on the splash and login screens.
class AppLogo extends StatelessWidget {
  final double size;
  final Color color;
  final bool showGlow;

  const AppLogo({
    super.key,
    this.size = 56,
    this.color = Colors.white,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.55),
      painter: _InfinityLogoPainter(
        color: color,
        showGlow: showGlow,
      ),
    );
  }
}

class _InfinityLogoPainter extends CustomPainter {
  final Color color;
  final bool showGlow;

  _InfinityLogoPainter({required this.color, required this.showGlow});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.height * 0.22;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final rx = w * 0.27;
    final ry = h * 0.40;

    // Left loop and right loop cubic beziers forming clean infinity
    final path = Path();
    
    // Start at center cross
    path.moveTo(cx, cy);
    // Upper-right curve
    path.cubicTo(cx + rx * 0.6, cy - ry, cx + rx * 1.5, cy - ry, cx + rx * 1.5, cy);
    // Lower-right curve back to center
    path.cubicTo(cx + rx * 1.5, cy + ry, cx + rx * 0.6, cy + ry, cx, cy);
    // Upper-left curve
    path.cubicTo(cx - rx * 0.6, cy - ry, cx - rx * 1.5, cy - ry, cx - rx * 1.5, cy);
    // Lower-left curve back to center
    path.cubicTo(cx - rx * 1.5, cy + ry, cx - rx * 0.6, cy + ry, cx, cy);

    if (showGlow) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(path, glowPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _InfinityLogoPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.showGlow != showGlow;
  }
}
