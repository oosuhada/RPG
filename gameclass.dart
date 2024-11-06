import 'dart:io';
import 'dart:math';
import 'characterclass.dart';

// 게임 클래스 정의
class Game {
  Character? character; //character 필드가 non-nullable로 선언되는 문제 ?로 해결
  List<Monster> monsters = [];
  int defeatedMonsters = 0;
  int totalMonsters = 0;
  bool gameOver = false;
  int level = 1; // 추가도전: level 개념 추가

  Future<void> showTutorial() async {
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

  Future<void> loadMonsterStats() async {
    try {
      final file = File('monsters.txt');
      final contents = await file.readAsString();
      final monsterLines = contents.split('\n');
      for (var line in monsterLines) {
        final stats = line.split(',');
        if (stats.length != 3) continue;
        String name = stats[0];
        int health = int.parse(stats[1]);
        int maxAttack = int.parse(stats[2]) + level * 5;
        monsters.add(Monster(name, health, maxAttack, level));
      }
      totalMonsters = monsters.length;
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  Future<void> loadCharacterStats() async {
    String name = getCharacterName();
    character = Character(name, 100, 20, 1);
    print('\n${name}님 반갑습니다.');

    bool isNewPlayer = !(await File('result.txt').exists());
    if (isNewPlayer) {
      stdout.write('게임 튜토리얼을 확인하시겠습니까? (y/n): ');
      String? answer = stdin.readLineSync()?.toLowerCase();
      if (answer == 'y') {
        await showTutorial();
      }
    }
    await loadPreviousResult(name);
  }

  // 게임 결과 저장 불러오는 메서드 수정
  Future<void> loadPreviousResult(String name) async {
    try {
      final file = File('result.txt');
      if (await file.exists()) {
        final contents = await file.readAsLines();
        List<String> previousResults =
            contents.where((line) => line.startsWith(name)).toList();
        if (previousResults.isNotEmpty) {
          String lastResult = previousResults.last;
          final results = lastResult.split(',');
          if (results.length == 4) {
            int previousHealth = int.parse(results[1]);
            String previousResult = results[2];
            int previousLevel = int.parse(results[3]);
            print(
                '이전 게임 결과: 체력 $previousHealth, 결과 $previousResult, 레벨 $previousLevel');

            if (previousResult.contains('중간승리') ||
                previousResult.contains('최종승리')) {
              character!.setHealth(previousHealth);
              character!.level = previousLevel;
              level = previousLevel;
              print(
                  '이전 게임의 체력과 레벨을 이어받았습니다. 현재 체력: ${character!.health}, 레벨: ${character!.level}');
              if (previousResult.contains('최종승리')) {
                print('축하합니다! 이전 게임에서 최종 승리하셨습니다. 새로운 도전을 시작합니다.');
                level++;
                character!.level = level;
                resetMonsters();
              }
            } else {
              print('이전 게임에서 패배하셨습니다. 새로운 게임을 시작합니다.');
            }
          }
        }
      }
    } catch (e) {
      print('이전 결과를 불러오는 데 실패했습니다: $e');
    }
  }

  void resetMonsters() {
    monsters.clear();
    defeatedMonsters = 0;
    loadMonsterStats();
  }

  // 도전: 캐릭터 체력 보너스 기능
  void applyHealthBonus() {
    if (Random().nextDouble() < 0.3) {
      // 30%의 확률로 character의 health를 10 증가
      character?.health += 10;
      print('보너스 체력을 얻었습니다! 현재 체력: ${character?.health}');
    }
  }

  String getCharacterName() {
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

  Monster getRandomMonster() {
    // 남아있는 몬스터 중 랜덤으로 선택
    return monsters[Random().nextInt(monsters.length)];
  }

  Future<void> battle(Monster monster) async {
    print('\n새로운 몬스터가 나타났습니다!');
    monster.showStatus();

    while (character!.health > 0 && monster.health > 0) {
      print('\n${character?.name}의 턴');
      character?.showStatus();
      monster.showStatus();

      String? action = await getPlayerAction();
      await performAction(action, monster);

      if (monster.health <= 0) {
        print('${monster.name}을(를) 물리쳤습니다!');
        return;
      }

      print('\n${monster.name}의 턴');
      monster.attackCharacter(character!);

      if (character!.health <= 0) {
        print('${character?.name}이(가) 쓰러졌습니다. 게임 오버!');
        return;
      }
    }
  }

  Future<String?> getPlayerAction() async {
    while (true) {
      stdout.write('행동을 선택하세요 (1: 공격, 2: 방어, 3: 아이템 사용): ');
      return stdin.readLineSync();
    }
  }

  Future<void> performAction(String? action, Monster monster) async {
    switch (action) {
      case '1':
        character?.attackMonster(monster);
        break;
      case '2':
        character?.defend();
        break;
      case '3':
        character?.useItem();
        break;
      default:
        print('잘못된 입력입니다. 다시 선택해주세요.');
        await performAction(await getPlayerAction(), monster);
    }
  }

  // 게임 시작 메서드
  Future<void> startGame() async {
    await loadCharacterStats();
    await loadMonsterStats();
    totalMonsters = monsters.length;

    print('');
    print('게임을 시작합니다!');
    print('현재 레벨: $level');
    character!.showStatus();

    while (character!.health > 0 && defeatedMonsters < totalMonsters) {
      Monster currentMonster = getRandomMonster();
      print('새로운 몬스터가 나타났습니다!');
      currentMonster.showStatus();

      await battle(currentMonster);

      if (currentMonster.health <= 0) {
        defeatedMonsters++;
        monsters.remove(currentMonster);
        print('${currentMonster.name}을(를) 물리쳤습니다!');

        if (defeatedMonsters < totalMonsters && !await askToContinue()) {
          await endGame(true);
          return;
        }
      }

      if (character!.health <= 0) {
        print('게임 오버! ${character!.name}이(가) 쓰러졌습니다.');
        await endGame(false);
        return;
      }
    }

    if (defeatedMonsters == totalMonsters) {
      print('축하합니다! 모든 몬스터를 물리쳤습니다.');
      level++;
      character!.levelUpBonus();
      print('레벨이 올랐습니다! 현재 레벨: $level');
      await endGame(true);
    }
  }

  Future<bool> askToContinue() async {
    while (true) {
      stdout.write('\n다음 몬스터와 싸우시겠습니까? (y/n): ');
      String? answer = stdin.readLineSync()?.toLowerCase();
      if (answer == 'y') return true;
      if (answer == 'n') return false;
      print('올바른 입력이 아닙니다. y 또는 n을 입력해주세요.');
    }
  }

  Future<void> endGame(bool isVictory) async {
    String result = isVictory
        ? (defeatedMonsters == totalMonsters ? '최종승리' : '중간승리')
        : '패배';

    print('\n게임이 종료되었습니다. 결과: $result');
    print('물리친 몬스터 수: $defeatedMonsters');
    if (!isVictory) {
      print('남은 몬스터 수: ${totalMonsters - defeatedMonsters}');
    }

    await saveResult(result);

    if (isVictory && defeatedMonsters == totalMonsters) {
      stdout.write('다음 레벨을 이어서 진행하시겠습니까? (y/n): ');
      String? answer = stdin.readLineSync()?.toLowerCase();
      if (answer == 'y') {
        level++;
        character!.levelUpBonus();
        print('레벨이 올랐습니다! 현재 레벨: $level');
        resetMonsters();
        await startGame();
      }
    }
  }

  Future<void> saveResult(String result) async {
    while (true) {
      stdout.write('결과를 저장하시겠습니까? (y/n): ');
      String? answer = stdin.readLineSync()?.toLowerCase();
      if (answer == 'y') {
        String content =
            '${character!.name},${character!.health},$result,${character!.level}';
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
