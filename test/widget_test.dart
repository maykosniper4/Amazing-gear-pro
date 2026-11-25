import 'package:flutter_test/flutter_test.dart';
import 'package:amezing_gear/main.dart';
import 'package:amezing_gear/rendering/game_painter.dart';
import 'package:flutter/material.dart';

void main() {
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
