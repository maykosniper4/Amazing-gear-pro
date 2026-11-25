import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../models/game_theme.dart';
import '../util/sounds.dart';

class ThemeSheet extends StatelessWidget {
  final GameController controller;

  const ThemeSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = controller.currentTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: theme.isDark ? const Color(0xFF1E232E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THEMES & GEARS',
                style: TextStyle(
                  color: theme.hudColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: theme.hudColor),
                onPressed: () => controller.toggleThemePicker(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Background Themes Section
          Text(
            'BACKGROUND THEME',
            style: TextStyle(
              color: theme.hudColor.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // 2-row Grid for 6 available themes
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GameTheme.availableThemes.map((t) {
              final isSelected = controller.currentTheme.id == t.id;
              return GestureDetector(
                onTap: () => controller.setTheme(t),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 56) / 3,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: t.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF42A5F5) : Colors.grey.withValues(alpha: 0.4),
                      width: isSelected ? 2.5 : 1.0,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFF42A5F5).withValues(alpha: 0.45),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      t.name.split(' ').last,
                      style: TextStyle(
                        color: t.hudColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Gear Skins Section
          Text(
            'GEAR COLOR',
            style: TextStyle(
              color: theme.hudColor.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: GearSkinOption.availableSkins.map((s) {
              final isSelected = controller.currentSkin.id == s.id;
              return GestureDetector(
                onTap: () => controller.setSkin(s),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: s.previewColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF42A5F5) : Colors.transparent,
                      width: 3.0,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFF42A5F5).withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Sound Toggle Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Sounds.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: theme.hudColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SOUND FX',
                    style: TextStyle(
                      color: theme.hudColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Switch(
                value: Sounds.soundEnabled,
                activeColor: const Color(0xFF42A5F5),
                onChanged: (val) {
                  Sounds.playButton();
                  Sounds.soundEnabled = val;
                  (context as Element).markNeedsBuild();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
