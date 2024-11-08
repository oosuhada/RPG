import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'characterclass.dart';

class GameIO {
  static Future<String> getCharacterName() async {
    while (true) {
      stdout.write('캐릭터의 이름을 입력하세요: ');
      String? name = stdin.readLineSync()?.trim();
      if (name != null &&
          name.isNotEmpty &&
          name == name.trim() && // 앞뒤 공백 제거 확인
          RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name) && // 한글/영문만 허용
          !name.contains(RegExp(r'[0-9]')) && // 숫자 불허용
          !name.contains(RegExp(r'[^\w\s가-힣]'))) {
        // 특수문자 불허용
        return name;
      }
      print('올바른 이름을 입력해주세요 (한글 또는 영문만 사용 가능).');
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

  static Future<Character> chooseCharacter() async {
    print('\n사용 가능한 캐릭터:');
    print('1. 아이언맨 (Technology) - 높은 공격력, 중간 방어력');
    print('2. 캡틴 아메리카 (Strength) - 높은 방어력, 중간 공격력');
    print('3. 블랙 위도우 (Speed) - 높은 회피율, 낮은 방어력');
    print('4. 토르 (Lightning) - 매우 높은 공격력, 낮은 방어력');

    while (true) {
      stdout.write('캐릭터를 선택하세요 (1-4): ');
      String? choice = stdin.readLineSync()?.trim();

      switch (choice) {
        case '1':
          return createIronMan();
        case '2':
          return createCaptainAmerica();
        case '3':
          return createBlackWidow();
        case '4':
          return createThor();
        default:
          print('올바른 번호를 입력해주세요.');
      }
    }
  }

  static Character createIronMan() {
    return Character("IronMan", "Technology", 100, 25, 10, [
      Skill("Repulsor Blast", 30, "Technology"),
      Skill("Unibeam", 45, "Technology", effect: (character, monster) {
        character.defense -= 2;
        print('강력한 공격으로 인해 방어력이 2 감소했습니다.');
      }),
      Skill("Missile Barrage", 35, "Technology"),
      Skill("Energy Shield", 0, "Defense", effect: (character, monster) {
        character.defense += 5;
        print('에너지 실드로 방어력이 5 증가했습니다.');
      }),
    ]);
  }

  static Character createCaptainAmerica() {
    return Character("Captain America", "Strength", 120, 20, 15, [
      Skill("Shield Throw", 25, "Strength"),
      Skill("Shield Bash", 35, "Strength", effect: (character, monster) {
        monster.defense -= 2;
        print('방패 강타로 적의 방어력이 2 감소했습니다.');
      }),
      Skill("Shield Block", 0, "Defense", effect: (character, monster) {
        character.defense += 8;
        print('방패 방어로 방어력이 8 증가했습니다.');
      }),
      Skill("Patriot Strike", 40, "Strength", effect: (character, monster) {
        character.attack += 3;
        print('애국심으로 공격력이 3 증가했습니다.');
      }),
    ]);
  }

  static Character createBlackWidow() {
    return Character("Black Widow", "Speed", 90, 22, 8, [
      Skill("Widow's Bite", 30, "Speed"),
      Skill("Acrobatic Strike", 35, "Speed", effect: (character, monster) {
        character.defense += 3;
        print('곡예 공격으로 방어력이 3 증가했습니다.');
      }),
      Skill("Silent Strike", 45, "Speed", effect: (character, monster) {
        monster.attack -= 3;
        print('은밀한 공격으로 적의 공격력이 3 감소했습니다.');
      }),
      Skill("Martial Arts Combo", 40, "Speed", effect: (character, monster) {
        character.attack += 4;
        print('연계 공격으로 공격력이 4 증가했습니다.');
      }),
    ]);
  }

  static Character createThor() {
    return Character("Thor", "Lightning", 110, 30, 8, [
      Skill("Lightning Strike", 35, "Lightning"),
      Skill("Mjolnir Throw", 40, "Lightning", effect: (character, monster) {
        monster.defense -= 3;
        print('묠니르 투척으로 적의 방어력이 3 감소했습니다.');
      }),
      Skill("Thunder God's Wrath", 50, "Lightning",
          effect: (character, monster) {
        character.attack += 5;
        print('번개의 격노로 공격력이 5 증가했습니다.');
      }),
      Skill("Storm Breaker", 45, "Lightning", effect: (character, monster) {
        monster.attack -= 4;
        print('스톰브레이커의 힘으로 적의 공격력이 4 감소했습니다.');
      }),
    ]);
  }

  static Future<String?> getPlayerAction() async {
    while (true) {
      stdout.write('행동을 선택하세요 (1: 공격, 2: 방어, 3: 아이템 사용): ');
      String? input = stdin.readLineSync()?.toLowerCase().trim();

      if (input == 'reset') return 'reset';
      if (['1', '2', '3'].contains(input)) return input;

      print('올바른 행동을 선택해주세요.');
    }
  }

  static Future<String> getPlayerChoice({List<String>? validChoices}) async {
    while (true) {
      String? input = stdin.readLineSync()?.toLowerCase().trim();
      if (input == null || input.isEmpty) continue;

      if (input == 'reset') return 'reset';
      if (validChoices == null || validChoices.contains(input)) {
        return input;
      }
      print('올바른 선택지를 입력해주세요: ${validChoices.join("/")}');
    }
  }

  static Future<bool> askToContinue() async {
    return await getYesNoAnswer('\n다음 몬스터와 싸우시겠습니까? (y/n): ');
  }

  static Future<bool> askToContinueNextLevel() async {
    return await getYesNoAnswer('다음 레벨을 이어서 진행하시겠습니까? (y/n): ');
  }

  static Future<String> saveResult(
      Character character, String result, int level, int stage) async {
    String currentDateTime = DateTime.now().toString().split('.')[0];
    String date = currentDateTime.split(' ')[0];
    String time = currentDateTime.split(' ')[1];

    String content = '플레이어 이름/${character.name}, '
        '캐릭터/${character.characterType}, '
        '레벨/$level, '
        '결과/스테이지$stage 클리어, '
        '체력/${character.health}, '
        '공격력/${character.attack}, '
        '방어력/${character.defense}, '
        '날짜/$date, '
        '시간/$time\n';

    try {
      await File('result.txt').writeAsString(content, mode: FileMode.append);
      print('결과가 저장되었습니다.');
      return content;
    } catch (e) {
      print('결과 저장 중 오류가 발생했습니다: $e');
      return '';
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
    try {
      final file = File('result.txt');
      if (await file.exists()) {
        final lines = await file.readAsLines();
        final records = lines
            .map((line) {
              final parts = line.split(', ');
              if (parts.length < 8) return null;

              Map<String, String> record = {};
              for (var part in parts) {
                final keyValue = part.split('/');
                if (keyValue.length == 2) {
                  record[keyValue[0]] = keyValue[1];
                }
              }

              return {
                'name': record['플레이어 이름'] ?? '',
                'level': record['레벨'] ?? '',
                'result': record['결과'] ?? '',
                'health': record['체력'] ?? '',
                'attack': record['공격력'] ?? '',
                'defense': record['방어력'] ?? '',
                'date': record['날짜'] ?? '',
                'time': record['시간'] ?? '',
                'timestamp': DateTime.parse('${record['날짜']} ${record['시간']}')
              };
            })
            .where((record) => record != null)
            .toList();

        records.sort((a, b) => b!['timestamp']!.compareTo(a!['timestamp']));

        print('\n최근 5개의 플레이 기록:');
        for (int i = 0; i < min(5, records.length); i++) {
          final record = records[i]!;
          print('${record['date']} ${record['time']} - '
              '플레이어: ${record['name']}, '
              '레벨: ${record['level']}, '
              '${record['result']}, '
              '체력: ${record['health']}, '
              '공격력: ${record['attack']}, '
              '방어력: ${record['defense']}');
        }
      }
    } catch (e) {
      print('기록을 불러오는 중 오류가 발생했습니다: $e');
    }
  }
}

extension on Object {
  compareTo(Object? object) {}
}
