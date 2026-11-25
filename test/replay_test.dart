import 'package:amezing_gear/game/game_world.dart';
import 'package:amezing_gear/util/sounds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Thirty replays reset obstacles and notify death only once per round',
      () {
    final world = GameWorld();
    final previousSoundEnabled = Sounds.soundEnabled;
    Sounds.soundEnabled = false;
    addTearDown(() {
      Sounds.soundEnabled = previousSoundEnabled;
      world.dispose();
    });
    var deaths = 0;
    world.onGameOver = () => deaths++;

    for (var round = 0; round < 30; round++) {
      final oldGates = world.gates.toList();
      world.reset();
      expect(world.gates.length, 5);
      expect(world.gates.any(oldGates.contains), isFalse);
      expect(world.score, 0);
      expect(world.cameraY, 0);
      expect(world.isStarted, isFalse);
      expect(world.isAlive, isTrue);

      world.tapLeft();
      for (var frame = 0; frame < 600; frame++) {
        world.updatePhysics(1 / 60);
      }
      expect(world.isAlive, isFalse);
      expect(deaths, round + 1);
    }
  });
}
