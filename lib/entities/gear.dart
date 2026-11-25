import 'dart:math';

class Gear {
  double x;
  double y;
  double vx = 0;
  double vy = 0;
  double angle = 0;
  double targetAngularVelocity = 0;

  // Exact physics constants extracted directly from original LibGDX APK
  static const double width = 38.57;
  static const double height = 64.28;
  static const double radius = 1.5; // GEAR diameter = 3.0f
  static const double mass = pi * radius * radius; // 7.06858f
  static const double impulseX = 70.0;
  static const double impulseY = 440.0;
  static const double gravity = -150.0; // Gravity pulling downward

  Gear({
    required this.x,
    required this.y,
  });

  void jumpLeft() {
    // In original game: body.setLinearVelocity(0, 0) then applyLinearImpulse(-70, 440)
    vx = -impulseX / mass;
    vy = impulseY / mass;
    targetAngularVelocity = -7.5; // Rotates during jump
  }

  void jumpRight() {
    // In original game: body.setLinearVelocity(0, 0) then applyLinearImpulse(+70, 440)
    vx = impulseX / mass;
    vy = impulseY / mass;
    targetAngularVelocity = 7.5;
  }

  void update(double dt) {
    // Apply gravity
    vy += gravity * dt;

    // Apply linear velocity
    x += vx * dt;
    y += vy * dt;

    // Apply rotation
    angle += targetAngularVelocity * dt;
    targetAngularVelocity *= (1.0 - dt * 2.0); // Damping rotation

    // Wall boundaries (Left: 0, Right: width)
    if (x - radius < 0) {
      x = radius;
      vx = -vx * 0.35; // Bounce off wall
    } else if (x + radius > width) {
      x = width - radius;
      vx = -vx * 0.35;
    }
  }
}
