import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

/// A vector-based app logo drawn via [CustomPainter].
///
/// Renders a shield containing a steering-wheel motif, accent badge,
/// and a success checkmark — matching the Android adaptive-icon artwork.
class AppLogoWidget extends StatelessWidget {
  final double size;
  const AppLogoWidget({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AppLogoPainter()),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width; // assume square
    final scale = s / 108;

    // Shield body
    final shieldPaint = Paint()..color = AppColors.primary;
    final shield = Path()
      ..moveTo(54 * scale, 16 * scale)
      ..lineTo(28 * scale, 20 * scale)
      ..cubicTo(26 * scale, 20.4 * scale, 24.5 * scale, 22 * scale,
          24.5 * scale, 24 * scale)
      ..lineTo(24.5 * scale, 50 * scale)
      ..cubicTo(24.5 * scale, 66 * scale, 36 * scale, 78 * scale,
          54 * scale, 88 * scale)
      ..cubicTo(72 * scale, 78 * scale, 83.5 * scale, 66 * scale,
          83.5 * scale, 50 * scale)
      ..lineTo(83.5 * scale, 24 * scale)
      ..cubicTo(83.5 * scale, 22 * scale, 82 * scale, 20.4 * scale,
          80 * scale, 20 * scale)
      ..close();
    canvas.drawPath(shield, shieldPaint);

    // Shield inner glow
    final innerPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.3);
    final inner = Path()
      ..moveTo(54 * scale, 20 * scale)
      ..lineTo(31 * scale, 23.5 * scale)
      ..cubicTo(29.5 * scale, 23.8 * scale, 28.5 * scale, 25 * scale,
          28.5 * scale, 26.5 * scale)
      ..lineTo(28.5 * scale, 49 * scale)
      ..cubicTo(28.5 * scale, 63 * scale, 38.5 * scale, 73.5 * scale,
          54 * scale, 82.5 * scale)
      ..cubicTo(69.5 * scale, 73.5 * scale, 79.5 * scale, 63 * scale,
          79.5 * scale, 49 * scale)
      ..lineTo(79.5 * scale, 26.5 * scale)
      ..cubicTo(79.5 * scale, 25 * scale, 78.5 * scale, 23.8 * scale,
          77 * scale, 23.5 * scale)
      ..close();
    canvas.drawPath(inner, innerPaint);

    // Steering wheel ring
    final wheelPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale;
    canvas.drawCircle(
      Offset(54 * scale, 52 * scale),
      12 * scale,
      wheelPaint,
    );

    // Hub
    final hubPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(54 * scale, 52 * scale),
      3.5 * scale,
      hubPaint,
    );

    // Spokes
    final spokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale
      ..strokeCap = StrokeCap.round;
    // Top spoke
    canvas.drawLine(
        Offset(54 * scale, 48.5 * scale), Offset(54 * scale, 40 * scale), spokePaint);
    // Bottom-left spoke
    canvas.drawLine(
        Offset(50.5 * scale, 53.5 * scale), Offset(44 * scale, 57 * scale), spokePaint);
    // Bottom-right spoke
    canvas.drawLine(
        Offset(57.5 * scale, 53.5 * scale), Offset(64 * scale, 57 * scale), spokePaint);

    // Accent badge (orange ellipse at top)
    final accentPaint = Paint()..color = AppColors.accent;
    canvas.save();
    canvas.translate(54 * scale, 24 * scale);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 8 * scale, height: 5 * scale),
      accentPaint,
    );
    canvas.restore();

    // Checkmark at bottom
    final checkPaint = Paint()
      ..color = AppColors.successLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final checkPath = Path()
      ..moveTo(47 * scale, 72 * scale)
      ..lineTo(52 * scale, 77 * scale)
      ..lineTo(63 * scale, 66 * scale);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
