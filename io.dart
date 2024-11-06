import 'dart:async';
import 'dart:io';
import 'characterclass.dart';

class GameIO {
  static Future<String> getCharacterName() async {
    // 사용자로부터 올바른 캐릭터 이름 입력 받기
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

  static Future<void> showTutorial() async {
    print('\n=== 게임 튜토리얼 ===');
    print('1. 당신은 몬스터와 싸우는 용사입니다.');
    print('2. 각 턴마다 공격, 방어, 아이템 사용 중 하나를 선택할 수 있습니다.');
    print('3. 모든 몬스터를 물리치면 레벨업합니다.');
    print('4. 체력이 0이 되면 게임 오버입니다.');
    print('5. 게임 결과는 저장할 수 있으며, 다음 게임에 이어서 플레이할 수 있습니다.');
    print('=== 튜토리얼 종료 ===\n');
    stdout.write('게임을 시작하려면 아무 키나 누르세요...');
    stdin.readLineSync();
  }

  static Future<bool> isNewPlayer(String name) async {
    final file = File('result.txt');
    if (await file.exists()) {
      final contents = await file.readAsLines();
      return !contents.any((line) => line.startsWith(name));
    }
    return true;
  }

  static Future<bool> askForTutorial(bool isNewPlayer) async {
    if (isNewPlayer) {
      print('튜토리얼을 확인하시겠습니까? (y/n)');
    } else {
      print('튜토리얼을 다시 확인하시겠습니까? (y/n)');
    }
    String? response = stdin.readLineSync()?.toLowerCase();
    return response == 'y';
  }

  static Future<List<String>> readMonsterFile() async {
    final file = File('monsters.txt');
    final contents = await file.readAsString();
    return contents.split('\n');
  }

  static void exitGame() {
    exit(1);
  }

  static Future<List<String>> loadPreviousResults(String name) async {
    final file = File('result.txt');
    if (await file.exists()) {
      final contents = await file.readAsLines();
      return contents.where((line) => line.startsWith(name)).toList();
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
      choice = stdin.readLineSync();
    } while (validChoices != null && !validChoices.contains(choice));
    return choice ?? '';
  }

  static Future<bool> askToContinue() async {
    while (true) {
      stdout.write('\n다음 몬스터와 싸우시겠습니까? (y/n): ');
      String? answer = stdin.readLineSync()?.toLowerCase();
      if (answer == 'y') return true;
      if (answer == 'n') return false;
      print('올바른 입력이 아닙니다. y 또는 n을 입력해주세요.');
    }
  }

  static Future<bool> askToContinueNextLevel() async {
    stdout.write('다음 레벨을 이어서 진행하시겠습니까? (y/n): ');
    String? answer = stdin.readLineSync()?.toLowerCase();
    return answer == 'y';
  }

  static Future<void> saveResult(Character character, String result) async {
    while (true) {
      stdout.write('결과를 저장하시겠습니까? (y/n): ');
      String? answer = stdin.readLineSync()?.toLowerCase();
      if (answer == 'y') {
        String content =
            '${character.name},${character.health},$result,${character.level}';
        try {
          await File('result.txt')
              .writeAsString(content + '\n', mode: FileMode.append);
          print('결과가 result.txt 파일에 저장되었습니다.');
        } catch (e) {
          print('결과 저장 중 오류가 발생했습니다: $e');
        }
        break;
      } else if (answer == 'n') {
        stdout.write('정말 결과를 저장하지 않으시겠습니까? (y/n): ');
        String? confirmAnswer = stdin.readLineSync()?.toLowerCase();
        if (confirmAnswer == 'y') {
          print('결과를 저장하지 않고 진행합니다.');
          break;
        }
      } else {
        print('올바른 입력이 아닙니다. y 또는 n을 입력해주세요.');
      }
    }
  }
}
