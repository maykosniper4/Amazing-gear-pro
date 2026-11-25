import 'dart:math';
import 'package:flutter/material.dart';

class GearPainter {
  /// Procedurally draws the authentic Amazing Gear cog:
  /// Black outer ring with square teeth and white center hole.
  static void drawGear(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double angle,
    Color color = Colors.black,
    int teethCount = 14,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final rOuter = radius;
    final rRoot = radius * 0.75;
    final rCenterHole = radius * 0.38;

    final path = Path();
    final step = (2 * pi) / teethCount;
    final halfToothAngle = step * 0.26;

    for (int i = 0; i < teethCount; i++) {
      final baseAngle = i * step;
      final a0 = baseAngle - step * 0.25;
      final a1 = baseAngle - halfToothAngle;
      final a2 = baseAngle + halfToothAngle;
      final a3 = baseAngle + step * 0.25;

      final p0 = Offset(cos(a0) * rRoot, sin(a0) * rRoot);
      final p1 = Offset(cos(a1) * rOuter, sin(a1) * rOuter);
      final p2 = Offset(cos(a2) * rOuter, sin(a2) * rOuter);
      final p3 = Offset(cos(a3) * rRoot, sin(a3) * rRoot);

      if (i == 0) {
        path.moveTo(p0.dx, p0.dy);
      } else {
        path.lineTo(p0.dx, p0.dy);
      }
      path.lineTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(p3.dx, p3.dy);
    }
    path.close();

    // 1. Draw solid gear body
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // 2. Cutout center hole (matches white background)
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, rCenterHole, holePaint);

    canvas.restore();
  }
}
