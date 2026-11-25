import 'dart:math';
import 'package:flutter/material.dart';
import '../entities/gear.dart';
import '../entities/obstacle.dart';
import '../util/sounds.dart';

class GameWorld extends ChangeNotifier {
  late Gear gear;
  final List<BrickGate> gates = [];

  bool isStarted = false;
  bool isAlive = true;
  int score = 0;
  String currentSkinName = 'gear_black';

  double cameraY = 0.0;
  static const double brickDistance = 34.0344; // Values.BRICK_DISTANCE
  double _highestSpawnY = 0.0;
  int _colorIndex = 0;

  final Random _random = Random();

  VoidCallback? onScore;
  VoidCallback? onGameOver;

  GameWorld() {
    reset();
  }

  void setSkin(String skinName) {
    currentSkinName = skinName;
    notifyListeners();
  }

  void reset() {
    isStarted = false;
    isAlive = true;
    score = 0;
    cameraY = 0.0;
    _colorIndex = 0;
    gates.clear();

    // Player starts at bottom-center
    gear = Gear(
      x: Gear.width / 2,
      y: 7.0,
    );

    // Initial runway
    _highestSpawnY = 7.0 + brickDistance;
    for (int i = 0; i < 5; i++) {
      _spawnGate(_highestSpawnY);
      _highestSpawnY += brickDistance;
    }

    notifyListeners();
  }

  void tapLeft() {
    if (!isAlive) return;
    if (!isStarted) isStarted = true;
    Sounds.playJump();
    gear.jumpLeft();
    notifyListeners();
  }

  void tapRight() {
    if (!isAlive) return;
    if (!isStarted) isStarted = true;
    Sounds.playJump();
    gear.jumpRight();
    notifyListeners();
  }

  void updatePhysics(double dt) {
    if (!isStarted || !isAlive) return;

    // 1. Update gear physics
    gear.update(dt);

    // 2. Buttery smooth exponential camera interpolation
    final targetCameraY = gear.y - 18.0;
    if (targetCameraY > cameraY) {
      final factor = 1.0 - exp(-15.0 * dt);
      cameraY += (targetCameraY - cameraY) * factor;
    }

    // 3. Update moving obstacles, collision and scoring
    final gearPos = Offset(gear.x, gear.y);
    for (final gate in gates) {
      gate.update(dt);

      // Score increment when passing gate Y
      if (!gate.scored && gear.y > gate.y) {
        gate.scored = true;
        score++;
        Sounds.playScore();
        onScore?.call();
      }

      // Check collision with brick gate or floating quads
      if (gate.checkCollision(gearPos, Gear.radius)) {
        Sounds.playBrick();
        _triggerDeath();
        return;
      }
    }

    // 4. Check if gear fell below camera bottom edge
    if (gear.y < cameraY - 1.5) {
      Sounds.playBrick();
      _triggerDeath();
      return;
    }

    // 5. Clean up gates far below camera view
    gates.removeWhere((g) => g.y < cameraY - 18);

    // 6. Spawn new gates ahead as player ascends
    if (cameraY + Gear.height + 40 > _highestSpawnY) {
      _spawnGate(_highestSpawnY);
      _highestSpawnY += brickDistance;
    }
  }

  void notify() {
    notifyListeners();
  }

  void update(double dt) {
    updatePhysics(dt);
    notifyListeners();
  }

  void _spawnGate(double y) {
    const double minGap = 3.931 + (BrickGate.gapWidth / 2);
    const double maxGap = Gear.width - (3.931 + (BrickGate.gapWidth / 2));
    final double gapX = minGap + _random.nextDouble() * (maxGap - minGap);

    final color = BrickGate.colors[_colorIndex % BrickGate.colors.length];
    _colorIndex++;

    // Let players learn the controls before introducing gentle moving bars.
    final bool isMovingGate = score >= 20 && _random.nextDouble() < 0.20;

    final quads = <HazardQuad>[];

    // One floating brick from the start; movement unlocks later.
    final bool isMovingQuad1 = score >= 10 && _random.nextDouble() < 0.30;
    quads.add(HazardQuad(
      x: (gapX + (_random.nextDouble() - 0.5) * 6.0).clamp(minGap, maxGap),
      y: y + 9.5 + (_random.nextDouble() - 0.5) * 2.5,
      moving: isMovingQuad1,
      moveSpeed: 0.8 + min(score * 0.02, 0.6),
      moveAmplitude: 2.5 + _random.nextDouble() * 1.5,
    ));

    // Floating hazard quad 2: below gate
    if (score >= 8 && _random.nextDouble() < 0.45) {
      final bool isMovingQuad2 = score >= 15 && _random.nextDouble() < 0.25;
      quads.add(HazardQuad(
        x: (gapX + (_random.nextDouble() - 0.5) * 8.0).clamp(minGap, maxGap),
        y: y - 9.5 + (_random.nextDouble() - 0.5) * 2.5,
        moving: isMovingQuad2,
        moveSpeed: 0.7 + min(score * 0.02, 0.6),
        moveAmplitude: 2.0 + _random.nextDouble() * 1.5,
      ));
    }

    gates.add(BrickGate(
      y: y,
      gapX: gapX,
      color: color,
      quads: quads,
      moving: isMovingGate,
      moveSpeed: 0.65 + min(score * 0.015, 0.55),
      moveAmplitude: 2.5,
    ));
  }

  void _triggerDeath() {
    isAlive = false;
    onGameOver?.call();
    notifyListeners();
  }
}
