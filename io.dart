import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'characterclass.dart';

class GameIO {
  static Future<String> getCharacterName() async {
    while (true) {
      stdout.write('캐릭터의 이름을 입력하세요: ');
      String? name = stdin.readLineSync();
      if (name != null &&
          name.isNotEmpty &&
          RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name)) {
        return name;
      }
      print('올바른 이름을 입력해주세요 (한글 또는 영문).');
    }
  }

  static bool checkForReset(String input) {
    return input.toLowerCase() == 'reset';
  }

  static Future<void> showTutorial() async {
    print('''
튜토리얼:
1. 게임 시작 시 캐릭터의 이름을 입력합니다.
2. 몬스터와 전투를 시작합니다.
3. 전투 중 다음 행동을 선택할 수 있습니다:
   (1: 공격 2: 방어 3: 아이템 사용)
4. 몬스터를 물리치면 다음 몬스터와 싸울지 선택할 수 있습니다.
5. 모든 몬스터를 물리치면 레벨업합니다.
6. 게임 중 언제든지 'reset'을 입력하면 게임을 종료할 수 있습니다.
7. 게임 종료 시 결과를 저장할 수 있으며 다음 게임에서 이어서 플레이할 수 있습니다.
행운을 빕니다!
''');
    print('튜토리얼을 종료하려면 아무 키나 누르세요...');
    await stdin.readLineSync();
  }

  static Future<bool> isNewPlayer(String name) async {
    final file = File('result.txt');
    if (await file.exists()) {
      final contents = await file.readAsLines();
      return !contents.any((line) => line.split(',')[0].trim() == name.trim());
    }
    return true;
  }

  static Future<bool> askForTutorial(bool isNewPlayer) async {
    String prompt =
        isNewPlayer ? '튜토리얼을 확인하시겠습니까? (y/n)' : '튜토리얼을 다시 확인하시겠습니까? (y/n)';
    return await getYesNoAnswer(prompt);
  }

  static Future<List<String>> readMonsterFile() async {
    final file = File('monsters.txt');
    final contents = await file.readAsString();
    return contents
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
  }

  static void exitGame() {
    exit(1);
  }

  static Future<List<String>> loadPreviousResults(String name) async {
    final file = File('result.txt');
    if (await file.exists()) {
      final contents = await file.readAsLines();
      return contents.where((line) {
        final parts = line.split(',');
        return parts.isNotEmpty &&
            parts[0].trim().toLowerCase() == name.trim().toLowerCase();
      }).toList();
    }
    return [];
  }

  static Future<String?> getPlayerAction() async {
    stdout.write('행동을 선택하세요 (1: 공격, 2: 방어, 3: 아이템 사용): ');
    return stdin.readLineSync();
  }

  static Future<String> getPlayerChoice(
      {String? prompt, List<String>? validChoices}) async {
    String? choice;
    do {
      if (prompt != null) {
        print(prompt);
      }
      choice = stdin.readLineSync()?.toLowerCase();
      if (choice == 'reset') return 'reset';
    } while (validChoices != null && !validChoices.contains(choice));
    return choice ?? '';
  }

  static Future<bool> askToContinue() async {
    return await getYesNoAnswer('\n다음 몬스터와 싸우시겠습니까? (y/n): ');
  }

  static Future<bool> askToContinueNextLevel() async {
    return await getYesNoAnswer('다음 레벨을 이어서 진행하시겠습니까? (y/n): ');
  }

  static Future<void> saveResult(
      Character character, String result, int level, int stage) async {
    if (await getYesNoAnswer('결과를 저장하시겠습니까? (y/n): ')) {
      String currentDate =
          DateTime.now().toString().split('.')[0]; // YYYY-MM-DD HH:mm:ss 형식
      String content =
          '$currentDate,${character.name},${character.health},$result,$level,$stage,${character.attack},${character.defense}';
      try {
        await File('result.txt')
            .writeAsString(content + '\n', mode: FileMode.append);
        print('결과가 result.txt 파일에 저장되었습니다.');
      } catch (e) {
        print('결과 저장 중 오류가 발생했습니다: $e');
      }
    } else if (await getYesNoAnswer('정말 결과를 저장하지 않으시겠습니까? (y/n): ')) {
      print('결과를 저장하지 않고 진행합니다.');
    } else {
      await saveResult(character, result, level, stage);
    }
  }

  static Future<bool> askToEndGame() async {
    return await getYesNoAnswer('게임을 종료하시겠습니까? (y/n)');
  }

  static Future<bool> getYesNoAnswer(String prompt) async {
    while (true) {
      stdout.write(prompt);
      String? answer = stdin.readLineSync()?.toLowerCase();
      if (answer == 'y') return true;
      if (answer == 'n') return false;
      print('올바른 입력이 아닙니다. y 또는 n을 입력해주세요.');
    }
  }

  static Future<void> showRecentPlayHistory(String name) async {
    final previousResults = await loadPreviousResults(name);
    previousResults.sort((a, b) => DateTime.parse(b.split(',')[0])
        .compareTo(DateTime.parse(a.split(',')[0])));
    print('\n최근 5개의 플레이 기록:');
    for (int i = 0; i < min(5, previousResults.length); i++) {
      final results = previousResults[i].split(',');
      if (results.length == 8) {
        String date = results[0];
        String playerName = results[1];
        int previousHealth = int.parse(results[2]);
        String previousResult = results[3];
        int previousLevel = int.parse(results[4]);
        int previousStage = int.parse(results[5]);
        int previousAttack = int.parse(results[6]);
        int previousDefense = int.parse(results[7]);
        print(
            '$date - $playerName - 레벨: $previousLevel, 스테이지: $previousStage, $previousResult, 체력: $previousHealth, 공격력: $previousAttack, 방어력: $previousDefense');
      }
    }
  }
}
