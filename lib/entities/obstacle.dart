import 'dart:math';
import 'package:flutter/material.dart';

class HazardQuad {
  double x;
  double y;
  final double initialX;
  final bool moving;
  final double moveSpeed;
  final double moveAmplitude;
  double time = 0;

  static const double size = 2.62; // Values.BRICK_QUAD = 2.62f

  HazardQuad({
    required this.x,
    required this.y,
    this.moving = false,
    this.moveSpeed = 2.0,
    this.moveAmplitude = 5.0,
  }) : initialX = x;

  void update(double dt) {
    if (moving) {
      time += dt;
      x = (initialX + sin(time * moveSpeed) * moveAmplitude).clamp(5.0, 33.5);
    }
  }

  Rect get rect => Rect.fromCenter(
        center: Offset(x, y),
        width: size,
        height: size,
      );
}

class BrickGate {
  final double y;
  double gapX;
  final double initialGapX;
  final bool moving;
  final double moveSpeed;
  final double moveAmplitude;
  double time = 0;

  static const double brickWidth = 38.57; // Values.WIDTH
  static const double brickHeight = 3.931; // Values.BRICK_HEIGHT
  static const double gapWidth = 15.0; // More room to correct a jump.
  final Color color;
  final List<HazardQuad> quads;
  bool scored = false;

  BrickGate({
    required this.y,
    required this.gapX,
    required this.color,
    required this.quads,
    this.moving = false,
    this.moveSpeed = 1.4,
    this.moveAmplitude = 6.0,
  }) : initialGapX = gapX;

  void update(double dt) {
    if (moving) {
      time += dt;
      const minX = 3.931 + (gapWidth / 2);
      const maxX = brickWidth - (3.931 + (gapWidth / 2));
      gapX = (initialGapX + sin(time * moveSpeed) * moveAmplitude)
          .clamp(minX, maxX);
    }

    for (final quad in quads) {
      quad.update(dt);
    }
  }

  Rect get leftBrickRect {
    final leftWidth = max(0.0, gapX - (gapWidth / 2));
    return Rect.fromLTWH(0, y - (brickHeight / 2), leftWidth, brickHeight);
  }

  Rect get rightBrickRect {
    final rightStart = min(brickWidth, gapX + (gapWidth / 2));
    final rightWidth = max(0.0, brickWidth - rightStart);
    return Rect.fromLTWH(
        rightStart, y - (brickHeight / 2), rightWidth, brickHeight);
  }

  bool checkCollision(Offset gearPos, double gearRadius) {
    final r = gearRadius * 0.85; // Tight, accurate hitbox

    if (_circleIntersectsRect(gearPos, r, leftBrickRect)) return true;
    if (_circleIntersectsRect(gearPos, r, rightBrickRect)) return true;

    for (final quad in quads) {
      if (_circleIntersectsRect(gearPos, r, quad.rect)) return true;
    }

    return false;
  }

  bool _circleIntersectsRect(Offset circle, double radius, Rect rect) {
    final closestX = circle.dx.clamp(rect.left, rect.right);
    final closestY = circle.dy.clamp(rect.top, rect.bottom);
    final dx = circle.dx - closestX;
    final dy = circle.dy - closestY;
    return (dx * dx + dy * dy) < (radius * radius);
  }

  // Exact 6 colors extracted directly from original data.atlas texture
  static const List<Color> colors = [
    Color(0xFF6FA6FF), // brick_blue
    Color(0xFFFF5D3F), // brick_red
    Color(0xFFCEC100), // brick_gold
    Color(0xFF31CC7C), // brick_green
    Color(0xFFAA5EB9), // brick_fiolet
    Color(0xFF919191), // brick_grey
  ];
}
