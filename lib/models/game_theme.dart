import 'package:flutter/material.dart';

class GameTheme {
  final String id;
  final String name;
  final Color backgroundColor;
  final Color hudColor;
  final bool isDark;

  const GameTheme({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.hudColor,
    required this.isDark,
  });

  static const List<GameTheme> availableThemes = [
    GameTheme(
      id: 'white',
      name: 'Classic White',
      backgroundColor: Color(0xFFFFFFFF),
      hudColor: Color(0xFF000000),
      isDark: false,
    ),
    GameTheme(
      id: 'blue',
      name: 'Pastel Blue',
      backgroundColor: Color(0xFF88B0F8),
      hudColor: Color(0xFF000000),
      isDark: false,
    ),
    GameTheme(
      id: 'yellow',
      name: 'Solar Yellow',
      backgroundColor: Color(0xFFF5D65A),
      hudColor: Color(0xFF000000),
      isDark: false,
    ),
    GameTheme(
      id: 'purple',
      name: 'Royal Purple',
      backgroundColor: Color(0xFFA57CCB),
      hudColor: Color(0xFFFFFFFF),
      isDark: true,
    ),
    GameTheme(
      id: 'dark',
      name: 'Dark Night',
      backgroundColor: Color(0xFF12141A),
      hudColor: Color(0xFFFFFFFF),
      isDark: true,
    ),
    GameTheme(
      id: 'slate',
      name: 'Soft Slate',
      backgroundColor: Color(0xFF262C36),
      hudColor: Color(0xFFFFFFFF),
      isDark: true,
    ),
  ];
}

class GearSkinOption {
  final String id;
  final String name;
  final String assetName;
  final Color previewColor;

  const GearSkinOption({
    required this.id,
    required this.name,
    required this.assetName,
    required this.previewColor,
  });

  static const List<GearSkinOption> availableSkins = [
    GearSkinOption(
      id: 'black',
      name: 'Classic Black',
      assetName: 'gear_black',
      previewColor: Color(0xFF111111),
    ),
    GearSkinOption(
      id: 'blue',
      name: 'Electric Blue',
      assetName: 'gear_blue',
      previewColor: Color(0xFF42A5F5),
    ),
    GearSkinOption(
      id: 'red',
      name: 'Crimson Red',
      assetName: 'gear_red',
      previewColor: Color(0xFFE53935),
    ),
    GearSkinOption(
      id: 'green',
      name: 'Emerald Green',
      assetName: 'gear_green',
      previewColor: Color(0xFF43A047),
    ),
    GearSkinOption(
      id: 'yellow',
      name: 'Golden Gear',
      assetName: 'gear_yellow',
      previewColor: Color(0xFFFDD835),
    ),
    GearSkinOption(
      id: 'fiolet',
      name: 'Purple Core',
      assetName: 'gear_fiolet',
      previewColor: Color(0xFFAB47BC),
    ),
  ];
}
