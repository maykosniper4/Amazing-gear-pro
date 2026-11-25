import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_world.dart';
import '../models/game_theme.dart';
import '../entities/gear.dart';
import '../entities/obstacle.dart';
import '../util/image_loader.dart';
import 'gear_painter.dart';

class GamePainter extends CustomPainter {
  final GameWorld world;
  final GameTheme theme;

  GamePainter({
    required this.world,
    required this.theme,
  }) : super(repaint: world);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dynamic background color (theme control)
    canvas.drawColor(theme.backgroundColor, BlendMode.src);

    // 2. Exact LibGDX coordinate mapping
    final double scale = size.width / Gear.width;
    final double viewHeight = size.height / scale;

    canvas.save();
    canvas.scale(scale, scale);

    // 3. Draw colored brick gates & moving quads
    for (final gate in world.gates) {
      final paint = Paint()
        ..color = gate.color
        ..style = PaintingStyle.fill;

      // Left brick
      final leftW = max(0.0, gate.gapX - (BrickGate.gapWidth / 2));
      final gateScreenY =
          world.cameraY + viewHeight - (gate.y + (BrickGate.brickHeight / 2));
      canvas.drawRect(
        Rect.fromLTWH(0, gateScreenY, leftW, BrickGate.brickHeight),
        paint,
      );

      // Right brick
      final rightX = min(Gear.width, gate.gapX + (BrickGate.gapWidth / 2));
      final rightW = max(0.0, Gear.width - rightX);
      canvas.drawRect(
        Rect.fromLTWH(rightX, gateScreenY, rightW, BrickGate.brickHeight),
        paint,
      );

      // Hazard Quads (Static & Moving)
      for (final quad in gate.quads) {
        final quadScreenY =
            world.cameraY + viewHeight - (quad.y + (HazardQuad.size / 2));
        final quadScreenX = quad.x - (HazardQuad.size / 2);
        canvas.drawRect(
          Rect.fromLTWH(
              quadScreenX, quadScreenY, HazardQuad.size, HazardQuad.size),
          paint,
        );
      }
    }

    // 4. Transform gear position to screen
    final gearScreenX = world.gear.x;
    final gearScreenY = world.cameraY + viewHeight - world.gear.y;

    // 5. Draw tutorial overlays if game hasn't started yet
    if (!world.isStarted) {
      _drawTutorial(canvas, gearScreenX, gearScreenY);
    }

    // 6. Draw player gear with selected skin
    _drawGear(canvas, gearScreenX, gearScreenY);

    canvas.restore();
  }

  void _drawGear(Canvas canvas, double gx, double gy) {
    canvas.save();
    canvas.translate(gx, gy);
    canvas.rotate(world.gear.angle);

    final gearImg = GameAssets.gearImages[world.currentSkinName] ??
        GameAssets.gearImages['gear_black'];
    if (gearImg != null) {
      final src = Rect.fromLTWH(
          0, 0, gearImg.width.toDouble(), gearImg.height.toDouble());
      final dst = Rect.fromCenter(
        center: Offset.zero,
        width: Gear.radius * 2,
        height: Gear.radius * 2,
      );
      canvas.drawImageRect(gearImg, src, dst, Paint());
    } else {
      GearPainter.drawGear(
        canvas,
        center: Offset.zero,
        radius: Gear.radius,
        angle: 0,
        color: theme.hudColor,
      );
    }

    canvas.restore();
  }

  void _drawTutorial(Canvas canvas, double gx, double gy) {
    final help1 = GameAssets.help1Image;

    // 1. Draw dashed arc trajectories & preview gears
    if (help1 != null) {
      const h1W = 20.2;
      const h1H = 9.5;
      final src1 =
          Rect.fromLTWH(0, 0, help1.width.toDouble(), help1.height.toDouble());
      final dst1 = Rect.fromCenter(
        center: Offset(gx, gy - 6.2),
        width: h1W,
        height: h1H,
      );
      final p1 = Paint();
      if (theme.isDark) {
        p1.colorFilter = const ColorFilter.mode(Colors.white30, BlendMode.plus);
      }
      canvas.drawImageRect(help1, src1, dst1, p1);
    } else {
      _drawVectorArcs(canvas, gx, gy);
    }

    // 2. Draw TAP prompt: Red arrows + contrast text guaranteed on ALL themes
    _drawTapPrompt(canvas, gx, gy + 3.8);
  }

  void _drawTapPrompt(Canvas canvas, double gx, double y) {
    // Red arrows match original LibGDX extracted sprite color #FE4445
    const arrowColor = Color(0xFFFE4445);
    final textColor = theme.hudColor;

    // Left red arrow
    final leftArrow = Path()
      ..moveTo(gx - 5.5, y)
      ..lineTo(gx - 4.1, y - 0.95)
      ..lineTo(gx - 4.1, y + 0.95)
      ..close();
    canvas.drawPath(
        leftArrow,
        Paint()
          ..color = arrowColor
          ..style = PaintingStyle.fill);

    // Right red arrow
    final rightArrow = Path()
      ..moveTo(gx + 5.5, y)
      ..lineTo(gx + 4.1, y - 0.95)
      ..lineTo(gx + 4.1, y + 0.95)
      ..close();
    canvas.drawPath(
        rightArrow,
        Paint()
          ..color = arrowColor
          ..style = PaintingStyle.fill);

    // TAP label in theme.hudColor for 100% contrast on any theme
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'TAP',
        style: TextStyle(
          color: textColor,
          fontSize: 2.4,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.2,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas,
        Offset(gx - (textPainter.width / 2), y - (textPainter.height / 2)));
    textPainter.dispose();
  }

  void _drawVectorArcs(Canvas canvas, double gx, double gy) {
    final arcPaint = Paint()
      ..color = theme.isDark ? const Color(0xFF888888) : const Color(0xFFB0B0B0)
      ..strokeWidth = 0.25
      ..style = PaintingStyle.stroke;

    final leftEnd = Offset(gx - 7.5, gy - 6.5);
    final rightEnd = Offset(gx + 7.5, gy - 6.5);

    _drawDashedParabola(canvas, Offset(gx, gy), leftEnd, arcPaint,
        isLeft: true);
    _drawDashedParabola(canvas, Offset(gx, gy), rightEnd, arcPaint,
        isLeft: false);

    GearPainter.drawGear(canvas,
        center: leftEnd,
        radius: Gear.radius,
        angle: 0.3,
        color: const Color(0xFF9E9E9E));
    GearPainter.drawGear(canvas,
        center: rightEnd,
        radius: Gear.radius,
        angle: -0.3,
        color: const Color(0xFF9E9E9E));
  }

  void _drawDashedParabola(Canvas canvas, Offset start, Offset end, Paint paint,
      {required bool isLeft}) {
    final control =
        Offset(isLeft ? start.dx - 2.8 : start.dx + 2.8, start.dy - 8.5);
    const segments = 18;
    for (int i = 0; i < segments; i += 2) {
      final t1 = i / segments;
      final t2 = (i + 1) / segments;
      final p1 = _quadraticBezier(start, control, end, t1);
      final p2 = _quadraticBezier(start, control, end, t2);
      canvas.drawLine(p1, p2, paint);
    }
  }

  Offset _quadraticBezier(Offset p0, Offset p1, Offset p2, double t) {
    final u = 1 - t;
    final x = u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx;
    final y = u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
