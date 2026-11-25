import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class GameAssets {
  static final Map<String, ui.Image> gearImages = {};
  static ui.Image? help1Image;
  static ui.Image? help2Image;
  static ui.Image? pauseImage;

  static Future<void>? _loading;

  // These images are shared for the lifetime of the app.
  static Future<void> load() => _loading ??= _load();

  static Future<void> _load() async {
    try {
      final skins = [
        'gear_black',
        'gear_blue',
        'gear_red',
        'gear_green',
        'gear_yellow',
        'gear_fiolet',
        'gear_grey'
      ];
      for (final s in skins) {
        try {
          gearImages[s] = await _loadImage('assets/images/$s.png');
        } catch (_) {}
      }
      help1Image = await _loadImage('assets/images/help1.png');
      help2Image = await _loadImage('assets/images/help2.png');
      pauseImage = await _loadImage('assets/images/pause.png');
    } catch (_) {}
  }

  static Future<ui.Image> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  }
}
