import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import 'about_screen.dart';

class GameOverOverlay extends StatelessWidget {
  final GameController controller;

  const GameOverOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final world = controller.world;
    final theme = controller.currentTheme;

    return Container(
      color: theme.backgroundColor.withValues(alpha: 0.92),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Original GAME OVER banner - tinted to match theme HUD color for 100% contrast
              Image.asset(
                'assets/images/game_over_en.png',
                width: 260,
                color: theme.hudColor,
                errorBuilder: (_, __, ___) => Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: theme.hudColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Score & Best
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatColumn('SCORE', world.score, theme.hudColor),
                  const SizedBox(width: 50),
                  _buildStatColumn(
                      'BEST', controller.highScore, theme.hudColor),
                ],
              ),

              const SizedBox(height: 40),

              // Play / Retry Button - keep original vibrant button graphic with white PLAY text
              GestureDetector(
                onTap: () {
                  controller.restartGame();
                },
                child: Image.asset(
                  'assets/images/play.png',
                  width: 140,
                  color: null,
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text('RETRY',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Theme Button on GameOver
              TextButton.icon(
                onPressed: () => controller.toggleThemePicker(),
                icon: Icon(Icons.palette_outlined,
                    color: theme.hudColor, size: 18),
                label: Text(
                  'CHANGE THEME',
                  style: TextStyle(
                    color: theme.hudColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AboutScreen(gameTheme: theme),
                  ),
                ),
                icon: Icon(Icons.info_outline, color: theme.hudColor, size: 18),
                label: Text('ABOUT', style: TextStyle(color: theme.hudColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color textColor) {
    final digits = value.toString().split('');

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: digits.map((d) {
            return Image.asset(
              'assets/images/num_$d.png',
              height: 32,
              color: textColor,
              errorBuilder: (_, __, ___) => Text(
                d,
                style: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
