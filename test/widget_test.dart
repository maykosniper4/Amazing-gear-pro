import 'package:flutter_test/flutter_test.dart';
import 'package:amezing_gear/main.dart';
import 'package:amezing_gear/rendering/game_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  testWidgets(
      'Space starts and retries a round without jumping again mid-round',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AmazingGearApp());
    await tester.pump();
    final canvas = tester.widget<CustomPaint>(find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is GamePainter,
    ));
    final world = (canvas.painter! as GamePainter).world;
    expect(world.isStarted, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(world.isStarted, isTrue);
    expect(world.gear.vy, greaterThan(0));
    expect(world.gear.vx, 0);

    world.gear.vy = 12;
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(world.gear.vy, 12);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    expect(world.gear.vx, lessThan(0));

    world.isAlive = false;
    world.score = 7;
    world.onGameOver!();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(world.isAlive, isTrue);
    expect(world.isStarted, isTrue);
    expect(world.score, 0);
    expect(world.gear.vy, greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AmazingGearApp());
    expect(find.byType(AmazingGearApp), findsOneWidget);

    final canvas = tester.widget<CustomPaint>(find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is GamePainter,
    ));
    final world = (canvas.painter! as GamePainter).world;
    var notifications = 0;
    void onWorldChanged() => notifications++;
    world.addListener(onWorldChanged);
    // No physics or repaint notifications should run on the static tutorial.
    for (var frame = 0; frame < 120; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(notifications, 0);
    world.removeListener(onWorldChanged);

    world.onGameOver!();
    await tester.pump();
    await tester.tap(find.text('ABOUT'));
    await tester.pumpAndSettle();
    expect(find.text('Amazing gear 2'), findsOneWidget);
    expect(find.text('Bereketab Mihiretab'), findsOneWidget);
    expect(find.text('bereketab00@gmail.com'), findsOneWidget);
    expect(find.text('@BereketabMihiretab'), findsOneWidget);
    expect(find.text('@bereketabmihiretab'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('ABOUT'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
