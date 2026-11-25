import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../game/game_world.dart';
import '../game/game_controller.dart';
import '../rendering/game_painter.dart';
import '../util/image_loader.dart';
import '../util/sounds.dart';
import 'hud_overlay.dart';
import 'game_over_overlay.dart';
import 'theme_sheet.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final GameWorld _world;
  late final GameController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _foreground = true;

  // Fixed physics accumulator for silky smooth 60/120 FPS
  double _physicsAccumulator = 0.0;
  static const double _fixedDt = 1.0 / 60.0;

  @override
  void initState() {
    super.initState();
    _world = GameWorld();
    _controller = GameController(world: _world);

    // Preload original extracted assets and audio
    GameAssets.load().then((_) {
      if (mounted) setState(() {});
    });
    Sounds.init();

    _ticker = createTicker(_onTick);
    _world.addListener(_syncTicker);
    _controller.addListener(_syncTicker);
    WidgetsBinding.instance.addObserver(this);
  }

  void _syncTicker() {
    final shouldRun = _foreground &&
        _controller.state == GameState.playing &&
        _world.isStarted &&
        _world.isAlive;
    if (shouldRun == _ticker.isActive) return;
    _lastElapsed = Duration.zero;
    _physicsAccumulator = 0.0;
    if (shouldRun) {
      _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncTicker();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final double frameDt = ((elapsed - _lastElapsed).inMicroseconds / 1000000.0)
        .clamp(0.001, 0.05);
    _lastElapsed = elapsed;

    if (_controller.state == GameState.playing) {
      _physicsAccumulator += frameDt;
      int steps = 0;
      // Bound catch-up work and stop immediately if this step ends the round.
      while (_physicsAccumulator >= _fixedDt && steps < 4 && _world.isAlive) {
        _physicsAccumulator -= _fixedDt;
        _world.updatePhysics(_fixedDt);
        steps++;
      }
      if (_physicsAccumulator > _fixedDt * 4) {
        _physicsAccumulator = 0.0; // Prevent spiral of death
      }
      if (steps > 0) {
        _world.notify();
      }
    } else {
      _physicsAccumulator = 0.0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _world.removeListener(_syncTicker);
    _controller.removeListener(_syncTicker);
    _ticker.dispose();
    _controller.dispose();
    _world.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details, double screenWidth) {
    if (_controller.showThemePicker) {
      _controller.toggleThemePicker();
      return;
    }
    if (_controller.state != GameState.playing) return;

    final isRight = details.localPosition.dx >= (screenWidth / 2);
    if (isRight) {
      _world.tapRight();
    } else {
      _world.tapLeft();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (_controller.showThemePicker) return;
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (_controller.state == GameState.gameOver) {
        _controller.restartGame();
      }
      if (_controller.state == GameState.playing) {
        _world.start();
      }
      return;
    }
    if (_controller.state != GameState.playing) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      _world.tapLeft();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      _world.tapRight();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final theme = _controller.currentTheme;

        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);

              return Focus(
                autofocus: true,
                onKeyEvent: (node, event) {
                  _handleKeyEvent(event);
                  return KeyEventResult.handled;
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => _handleTapDown(details, size.width),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Main Game Canvas
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: GamePainter(
                            world: _world,
                            theme: theme,
                          ),
                          size: size,
                        ),
                      ),

                      // HUD (top-left pause & theme, top-right score)
                      HudOverlay(controller: _controller),

                      // Pause Overlay
                      if (_controller.state == GameState.paused)
                        _buildPauseOverlay(theme),

                      // Game Over Overlay
                      if (_controller.state == GameState.gameOver)
                        GameOverOverlay(controller: _controller),

                      // Theme Customization Sheet
                      if (_controller.showThemePicker)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ThemeSheet(controller: _controller),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPauseOverlay(theme) {
    return Container(
      color: theme.backgroundColor.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAUSED',
              style: TextStyle(
                color: theme.hudColor,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: () {
                _physicsAccumulator = 0.0;
                _lastElapsed = Duration.zero;
                _controller.resumeGame();
              },
              child: Image.asset(
                'assets/images/play.png',
                width: 140,
                // Keep original vibrant button graphic with white PLAY text
                color: null,
                errorBuilder: (_, __, ___) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text('RESUME',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => _controller.toggleThemePicker(),
              icon: Icon(Icons.palette_outlined, color: theme.hudColor),
              label: Text(
                'CUSTOMIZE THEME',
                style: TextStyle(
                    color: theme.hudColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
