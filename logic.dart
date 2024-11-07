import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'characterclass.dart';
import 'io.dart';

class Game {
  Character? character;
  List<Monster> monsters = [];
  int defeatedMonsters = 0;
  final int totalMonsters = 3;
  bool gameOver = false;
  int level = 1;
  int stage = 1;

  Future loadMonsterStats() async {
    try {
      monsters.clear();
      final monsterLines = await GameIO.readMonsterFile();
      for (int i = 0; i < totalMonsters && i < monsterLines.length; i++) {
        final stats = monsterLines[i].split(',');
        if (stats.length != 3) continue;
        String name = stats[0];
        int baseHealth = int.parse(stats[1]);
        int baseAttack = int.parse(stats[2]);
        int health = baseHealth + (level - 1) * 5;
        int maxAttack = baseAttack + (level - 1) * 5;
        monsters.add(Monster(name, health, maxAttack, level));
      }
      assert(monsters.length == totalMonsters,
          "몬스터 수가 $totalMonsters가 아닙니다: ${monsters.length}");
      if (level > 1) {
        print('\n몬스터들이 강화되었습니다!');
        print('체력 증가: +5');
        print('공격력 증가: +5');
      }
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      GameIO.exitGame();
    }
  }

  Future loadCharacterStats() async {
    await GameIO.showRecentPlayHistory(''); // 모든 플레이어의 기록을 표시
    String name = await GameIO.getCharacterName();

    character = Character(name, 100, 20, 1);
    print('\n${name}님 반갑습니다.');
    bool isNewPlayer = await GameIO.isNewPlayer(name);
    if (isNewPlayer) {
      if (await GameIO.askForTutorial(true)) {
        await GameIO.showTutorial();
      }
    } else {
      if (await GameIO.askForTutorial(false)) {
        await GameIO.showTutorial();
      }
    }
    await loadPreviousResult(name);
  }

  Future loadPreviousResult(String name) async {
    try {
      final previousResults = await GameIO.loadPreviousResults(name);
      if (previousResults.isNotEmpty) {
        print('\n이전 게임 기록을 찾았습니다.');
        print('1: 기존 게임 진행, 2: 새 게임 시작');
        String? choice = await GameIO.getPlayerChoice(validChoices: ['1', '2']);

        if (choice == '1') {
          final results = previousResults.last.split(',');
          if (results.length == 8) {
            // 날짜 포함 8개 항목
            String date = results[0];
            int previousHealth = int.parse(results[2]);
            String previousResult = results[3];
            int previousLevel = int.parse(results[4]);
            int previousStage = int.parse(results[5]);
            int previousAttack = int.parse(results[6]);
            int previousDefense = int.parse(results[7]);

            print(
                '\n이전 게임 상태: $date - 레벨 $previousLevel, 스테이지 $previousStage, $previousResult, 체력: $previousHealth, 공격력: $previousAttack, 방어력: $previousDefense');

            if (previousResult.contains('Stage') ||
                previousResult.contains('최종승리')) {
              character!.setHealth(previousHealth);
              character!.level = previousLevel;
              character!.attack = previousAttack;
              character!.defense = previousDefense;
              level = previousLevel;
              stage = previousStage;

              print(
                  '\n현재 게임 상태: 레벨 $level, 스테이지 $stage, 체력: ${character!.health}, 공격력: ${character!.attack}, 방어력: ${character!.defense}');

              if (previousResult.contains('최종승리')) {
                print('축하합니다! 이전 게임에서 최종 승리하셨습니다. 새로운 도전을 시작합니다.');
                level = 1;
                stage = 1;
                character!.level = level;
                resetMonsters();
              }
            } else {
              print('이전 게임에서 패배하셨습니다. 해당 단계부터 다시 시작합니다.');
              level = previousLevel;
              stage = previousStage;
              character!.level = level;
              resetMonsters();
            }
          } else {
            print('저장된 데이터 형식이 올바르지 않습니다. 새로운 게임을 시작합니다.');
          }
        } else {
          print('새 게임을 시작합니다.');
        }
      } else {
        print('이전 게임 기록을 찾지 못했습니다. 새로운 게임을 시작합니다.');
      }
    } catch (e) {
      print('이전 결과를 불러오는 데 실패했습니다: $e');
      print('새로운 게임을 시작합니다.');
    }
  }

  void resetMonsters() {
    monsters.clear();
    defeatedMonsters = 0;
    loadMonsterStats();
  }

  void applyHealthBonus() {
    if (Random().nextDouble() < 0.3) {
      character?.health += 10;
      print('보너스 체력을 얻었습니다! 현재 체력: ${character?.health}');
    }
  }

  Monster getRandomMonster() {
    return monsters[Random().nextInt(monsters.length)];
  }

  Future<bool> battle(Monster monster) async {
    print('\n새로운 몬스터가 나타났습니다!');
    monster.showStatus();
    while (character!.health > 0 && monster.health > 0) {
      print('\n${character?.name}의 턴');
      character?.showStatus();
      monster.showStatus();
      String? action = await GameIO.getPlayerAction();
      if (await checkGameEnd(action)) return false;
      await performAction(action, monster);
      if (monster.health <= 0) {
        print('${monster.name}을(를) 물리쳤습니다!');
        return true;
      }
      print('\n${monster.name}의 턴');
      int initialHealth = character!.health;
      monster.attackCharacter(character!);
      int damage = initialHealth - character!.health;
      print('${monster.name}이(가) ${character!.name}에게 $damage의 데미지를 입혔습니다.');
      if (character!.health <= 0) {
        print('${character?.name}이(가) 쓰러졌습니다. 게임 오버!');
        return false;
      }
    }
    return false;
  }

  Future performAction(String? action, Monster monster) async {
    switch (action) {
      case '1':
      case '2':
        print('전투중입니다...');
        await Future.delayed(Duration(seconds: 1));
        if (action == '1') {
          character?.attackMonster(monster);
        } else {
          character?.defend();
        }
        break;
      case '3':
        character?.useItem();
        print('\n아이템 사용 후 행동을 선택하세요.');
        // 아이템 사용 후 공격/방어만 선택 가능하도록 수정된 행동 선택
        String? nextAction;
        while (true) {
          stdout.write('행동을 선택하세요 (1: 공격, 2: 방어): ');
          nextAction = stdin.readLineSync()?.toLowerCase().trim();

          if (nextAction == 'reset') {
            return await checkGameEnd(nextAction);
          }
          if (['1', '2'].contains(nextAction)) {
            break;
          }
          print('올바른 행동을 선택해주세요.');
        }
        // 선택된 행동 수행
        print('전투중입니다...');
        await Future.delayed(Duration(seconds: 1));
        if (nextAction == '1') {
          character?.attackMonster(monster);
        } else {
          character?.defend();
        }
        break;
      default:
        print('잘못된 입력입니다. 다시 선택해주세요.');
        await performAction(await GameIO.getPlayerAction(), monster);
    }
  }

  Future startGame() async {
    try {
      if (character == null) {
        await loadCharacterStats();
      }
      await loadMonsterStats();
      print('');
      print('게임을 시작합니다!');
      print('현재 레벨: $level, 스테이지: $stage');
      checkAndDisplayCharacterStatus();
      while (character!.health > 0 && defeatedMonsters < totalMonsters) {
        Monster currentMonster = getRandomMonster();
        bool victorious = await battle(currentMonster);
        if (!victorious) {
          if (await checkGameEnd('reset')) return;
          await endGame(false);
          return;
        }
        monsters.remove(currentMonster);
        defeatedMonsters++;
        if (defeatedMonsters == totalMonsters) {
          await endGame(true);
          return;
        }
        if (!await askForNextBattle()) {
          await endGame(true);
          return;
        }
      }
    } catch (e) {
      await handleGameError(e);
    }
  }

  Future levelUpBonus() async {
    print('레벨업 보너스를 선택하세요:');
    print('1. 체력 10 증가');
    print('2. 공격력 10 증가');
    print('3. 방어력 10 증가');
    String? choice = await GameIO.getPlayerChoice();
    switch (choice) {
      case '1':
        character!.health += 10;
        print('체력이 10 증가했습니다. 현재 체력: ${character!.health}');
        break;
      case '2':
        character!.attack += 10;
        print('공격력이 10 증가했습니다. 현재 공격력: ${character!.attack}');
        break;
      case '3':
        character!.defense += 10;
        print('방어력이 10 증가했습니다. 현재 방어력: ${character!.defense}');
        break;
      default:
        print('잘못된 선택입니다. 체력이 10 증가합니다.');
        character!.health += 10;
        print('체력이 10 증가했습니다. 현재 체력: ${character!.health}');
    }
    print('캐릭터의 능력치가 향상되었습니다!');
  }

  Future levelUp() async {
    level++;
    stage = 1;
    character!.level = level;
    print('모든 몬스터를 물리쳤습니다.');
    print('\n축하합니다! 레벨 ${level - 1}을 클리어하셨습니다.');
    print('레벨이 올랐습니다! 현재 레벨: $level');
    await levelUpBonus();
    print('\n주의: 새로운 레벨에서는 몬스터가 더 강력해집니다!');
  }

  void resetGame() {
    level = 1;
    stage = 1;
    defeatedMonsters = 0;
    monsters.clear();
    character = null;
  }

  Future endGame(bool isVictory) async {
    String result;
    if (isVictory) {
      if (defeatedMonsters == totalMonsters) {
        if (level == 10 && stage == 3) {
          result = '최종승리';
        } else {
          result = 'Stage $stage Clear';
          stage++;
          if (stage > 3) {
            await levelUp();
            stage = 1;
          }
        }
      } else {
        result = 'Stage $stage 중간승리';
      }
    } else {
      result = '$level단계 패배';
    }

    if (!isVictory) {
      print('\n게임이 종료되었습니다. 결과: $result');
      print('물리친 몬스터 수: $defeatedMonsters');
      print('남은 몬스터 수: ${totalMonsters - defeatedMonsters}');
      if (await askToRetry()) {
        resetMonsters();
        await startGame();
        return;
      }
    }

    if (isVictory && defeatedMonsters == totalMonsters) {
      if (await GameIO.askToContinueNextLevel()) {
        resetMonsters();
        await startGame();
      }
    }
  }

  Future<bool> askToRetry() async {
    print('해당 단계부터 다시 도전하시겠습니까? (y/n)');
    String? retry = await GameIO.getPlayerChoice(validChoices: ['y', 'n']);
    return retry.toLowerCase() == 'y';
  }

  void checkAndDisplayCharacterStatus() {
    if (character != null) {
      character!.showStatus();
      if (character!.health <= 0) {
        print('캐릭터의 체력이 0 이하입니다. 체력을 회복합니다.');
        character!.health = 100;
      }
    } else {
      print('캐릭터 생성에 실패했습니다. 게임을 다시 시작합니다.');
      resetGame();
      startGame();
    }
  }

  Future<bool> checkGameEnd(String? action) async {
    if (GameIO.checkForReset(action ?? '')) {
      print('게임을 종료합니다.');
      return true;
    }
    return false;
  }

  Future<bool> askForNextBattle() async {
    if (defeatedMonsters < totalMonsters) {
      print('다음 몬스터와 싸우시겠습니까? (y/n): ');
      String? response = await GameIO.getPlayerChoice(validChoices: ['y', 'n']);

      if (response == 'reset') {
        if (await confirmEndGame()) {
          return false;
        }
      } else if (response == 'n') {
        print(
            '\n게임 결과: 레벨: $level, Stage $stage 승리, 물리친 몬스터 수: $defeatedMonsters 남은 몬스터 수: ${totalMonsters - defeatedMonsters}');

        print('\n1: 결과 저장 후 종료하기');
        print('2: 저장하지 않고 종료하기');

        String? choice = await GameIO.getPlayerChoice(validChoices: ['1', '2']);
        if (choice == '1') {
          await GameIO.saveResult(
              character!, 'Stage $stage 중간승리', level, stage);
          print('\n게임이 저장되었습니다. 게임을 종료하시려면 reset을 입력해주세요');
          String? exitChoice =
              await GameIO.getPlayerChoice(validChoices: ['reset']);
          if (exitChoice == 'reset') {
            return false;
          }
        } else {
          return false;
        }
      }
    }
    return true;
  }

  Future<bool> confirmEndGame() async {
    print('\n정말 게임을 종료하시겠습니까? (y/n): ');
    String? response = await GameIO.getPlayerChoice(validChoices: ['y', 'n']);
    if (response == 'y') {
      print('\n게임을 종료합니다.');
      return true;
    }
    return false;
  }

  Future<void> handleGameError(dynamic error) async {
    print('게임 진행 중 오류가 발생했습니다: $error');
    print('게임을 다시 시작합니다.');
    resetGame();
    await startGame();
  }
}
