import 'dart:async';
import 'dart:math';
import 'characterclass.dart';
import 'io.dart';

// 게임 클래스 정의
class Game {
  Character? character; //character 필드가 non-nullable로 선언되는 문제 ?로 해결
  List<Monster> monsters = [];
  int defeatedMonsters = 0;
  int totalMonsters = 0;
  bool gameOver = false;
  int level = 1; // 추가도전: level 개념 추가

  Future<void> loadMonsterStats() async {
    try {
      final monsterLines = await GameIO.readMonsterFile();
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
      GameIO.exitGame();
    }
  }

  Future<void> loadCharacterStats() async {
    String name = await GameIO.getCharacterName();
    character = Character(name, 100, 20, 1);
    print('\n${name}님 반갑습니다.');

    bool isNewPlayer = await GameIO.isNewPlayer();
    if (isNewPlayer) {
      if (await GameIO.askForTutorial()) {
        await GameIO.showTutorial();
      }
    }

    await loadPreviousResult(name);
  }

  // 게임 결과 저장 불러오는 메서드 수정
  Future<void> loadPreviousResult(String name) async {
    try {
      final previousResults = await GameIO.loadPreviousResults(name);
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

  Monster getRandomMonster() {
    // 남아있는 몬스터 중 랜덤으로 선택
    return monsters[Random().nextInt(monsters.length)];
  }

  Stream<BattleState> battle(Monster monster) async* {
    print('\n새로운 몬스터가 나타났습니다!');
    monster.showStatus();

    while (character!.health > 0 && monster.health > 0) {
      yield BattleState(character!, monster);
      String? action = await GameIO.getPlayerAction();
      await performAction(action, monster);

      switch (monster.health) {
        case <= 0:
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
        await performAction(await GameIO.getPlayerAction(), monster);
    }
  }

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

      // ignore: unused_local_variable
      await for (var state in battle(currentMonster)) {
        // 전투 상태 처리
      }

      if (currentMonster.health <= 0) {
        defeatedMonsters++;
        monsters.remove(currentMonster);
        print('${currentMonster.name}을(를) 물리쳤습니다!');

        if (defeatedMonsters < totalMonsters && !await GameIO.askToContinue()) {
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
      await endGame(true);
    }
  }

  Future<void> levelUp() async {
    level++;
    int healthIncrease = 10;
    character!.health += healthIncrease;
    character!.level = level;
    print('축하합니다! 모든 몬스터를 물리쳤습니다.');
    print('레벨이 올랐습니다! 현재 레벨: $level');
    print('레벨업 보너스로 체력이 $healthIncrease 증가했습니다! 현재 체력: ${character!.health}');
    character!.levelUpBonus();
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

    if (isVictory && defeatedMonsters == totalMonsters) {
      await levelUp();
    }
    await GameIO.saveResult(character!, result);

    if (isVictory && defeatedMonsters == totalMonsters) {
      if (await GameIO.askToContinueNextLevel()) {
        resetMonsters();
        await startGame();
      }
    }
  }
}

class BattleState {
  final Character character;
  final Monster monster;

  BattleState(this.character, this.monster);
}