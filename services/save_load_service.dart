import 'dart:io';
import '../core/game_state.dart';

class SaveLoadService {
  Future<void> saveGameState(GameState gameState) async {
    try {
      final file = File('game_save.txt');
      final content =
          '${gameState.character.name},${gameState.level},${gameState.stage},${gameState.defeatedMonsters},${gameState.character.health},${gameState.character.attack},${gameState.character.defense}';
      await file.writeAsString(content);
      print('Game saved successfully.');
    } catch (e) {
      print('Failed to save the game: $e');
    }
  }

  Future<GameState?> loadGameState() async {
    try {
      final file = File('game_save.txt');
      if (await file.exists()) {
        final content = await file.readAsString();
        final parts = content.split(',');
        if (parts.length == 7) {
          // 여기서 GameState를 생성하고 반환합니다.
          // 실제 구현에서는 Character 생성 등 더 복잡한 로직이 필요할 수 있습니다.
          print('Game loaded successfully.');
          return GameState(); // 임시 반환, 실제로는 로드된 데이터로 GameState를 생성해야 합니다.
        }
      }
    } catch (e) {
      print('Failed to load the game: $e');
    }
    return null;
  }

  Future<List<String>> loadMonsterData() async {
    try {
      final file = File('monsters.txt');
      return await file.readAsLines();
    } catch (e) {
      print('Failed to load monster data: $e');
      return [];
    }
  }

  Future<void> showPlayHistory() async {
    try {
      final file = File('play_history.txt');
      if (await file.exists()) {
        final contents = await file.readAsLines();
        print('\nRecent Play History:');
        for (var i = 0; i < 5 && i < contents.length; i++) {
          print(contents[i]);
        }
      } else {
        print('No play history found.');
      }
    } catch (e) {
      print('Failed to load play history: $e');
    }
  }

  Future<Map<String, dynamic>?> loadPreviousResults(String name) async {
    // 이전 결과 로드 로직 구현
    // 예시:
    final file = File('result.txt');
    if (await file.exists()) {
      final lines = await file.readAsLines();
      for (var line in lines.reversed) {
        if (line.startsWith(name)) {
          // 간단한 파싱 예시, 실제로는 더 복잡할 수 있습니다.
          var parts = line.split(',');
          return {
            'name': parts[0],
            'level': int.parse(parts[1]),
            'health': int.parse(parts[2]),
            // ... 기타 필요한 정보 파싱
          };
        }
      }
    }
    return null;
  }
}
