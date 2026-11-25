import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_theme.dart';
import '../util/sounds.dart';
import 'game_world.dart';

enum GameState {
  playing,
  paused,
  gameOver,
}

class GameController extends ChangeNotifier {
  final GameWorld world;
  GameState state = GameState.playing;

  int highScore = 0;
  GameTheme currentTheme = GameTheme.availableThemes.first;
  GearSkinOption currentSkin = GearSkinOption.availableSkins.first;
  bool showThemePicker = false;

  SharedPreferences? _prefs;

  GameController({required this.world}) {
    world.onScore = _onScore;
    world.onGameOver = _onGameOver;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      highScore = _prefs?.getInt('amazing_gear_best') ?? 0;

      final savedThemeId = _prefs?.getString('amazing_gear_theme_id');
      if (savedThemeId != null) {
        currentTheme = GameTheme.availableThemes.firstWhere(
          (t) => t.id == savedThemeId,
          orElse: () => GameTheme.availableThemes.first,
        );
      }

      final savedSkinId = _prefs?.getString('amazing_gear_skin_id');
      if (savedSkinId != null) {
        currentSkin = GearSkinOption.availableSkins.firstWhere(
          (s) => s.id == savedSkinId,
          orElse: () => GearSkinOption.availableSkins.first,
        );
        world.setSkin(currentSkin.assetName);
      }
      notifyListeners();
    } catch (_) {}
  }

  void setTheme(GameTheme theme) {
    Sounds.playButton();
    currentTheme = theme;
    _prefs?.setString('amazing_gear_theme_id', theme.id);
    notifyListeners();
  }

  void setSkin(GearSkinOption skin) {
    Sounds.playButton();
    currentSkin = skin;
    world.setSkin(skin.assetName);
    _prefs?.setString('amazing_gear_skin_id', skin.id);
    notifyListeners();
  }

  void toggleThemePicker() {
    Sounds.playButton();
    showThemePicker = !showThemePicker;
    notifyListeners();
  }

  void _onScore() {
    HapticFeedback.selectionClick();
    if (world.score > highScore) {
      highScore = world.score;
      _prefs?.setInt('amazing_gear_best', highScore);
    }
    notifyListeners();
  }

  void _onGameOver() {
    HapticFeedback.mediumImpact();
    state = GameState.gameOver;
    showThemePicker = false;
    if (world.score > highScore) {
      highScore = world.score;
      _prefs?.setInt('amazing_gear_best', highScore);
    }
    notifyListeners();
  }

  void restartGame() {
    Sounds.playButton();
    world.reset();
    state = GameState.playing;
    showThemePicker = false;
    notifyListeners();
  }

  void pauseGame() {
    if (state == GameState.playing) {
      Sounds.playButton();
      state = GameState.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (state == GameState.paused) {
      Sounds.playButton();
      state = GameState.playing;
      showThemePicker = false;
      notifyListeners();
    }
  }
}
