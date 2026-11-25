import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../util/sounds.dart';

class HudOverlay extends StatelessWidget {
  final GameController controller;

  const HudOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = controller.currentTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Pause Button
                GestureDetector(
                  onTap: () {
                    Sounds.playButton();
                    if (controller.state == GameState.playing) {
                      controller.pauseGame();
                    } else if (controller.state == GameState.paused) {
                      controller.resumeGame();
                    }
                  },
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: Image.asset(
                      'assets/images/pause.png',
                      color: theme.hudColor,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.hudColor, width: 2),
                        ),
                        child: Icon(Icons.pause, color: theme.hudColor, size: 22),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Theme & Customization Button
                GestureDetector(
                  onTap: () => controller.toggleThemePicker(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.hudColor.withValues(alpha: 0.6), width: 1.5),
                    ),
                    child: Icon(Icons.palette_outlined, color: theme.hudColor, size: 20),
                  ),
                ),
              ],
            ),

            // Score Digits
            _buildScoreDisplay(controller.world.score, theme.hudColor),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(int score, Color color) {
    final digits = score.toString().split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: digits.map((d) {
        return Image.asset(
          'assets/images/num_$d.png',
          height: 36,
          color: color,
          errorBuilder: (_, __, ___) => Text(
            d,
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'sans-serif',
            ),
          ),
        );
      }).toList(),
    );
  }
}
