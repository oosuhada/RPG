import 'dart:async';
import 'dart:math';
import 'characterclass.dart';
import 'io.dart';

// 게임 클래스 정의
class Game {
  Character? character; //character 필드가 non-nullable로 선언되는 문제 ?로 해결
  List<Monster> monsters = [];
  int defeatedMonsters = 0;
  final int totalMonsters = 3;
  bool gameOver = false;
  int level = 1; // 추가도전: level 개념 추가

  Future<void> loadMonsterStats() async {
    try {
      monsters.clear();
      final monsterLines = await GameIO.readMonsterFile();
      for (int i = 0; i < totalMonsters && i < monsterLines.length; i++) {
        final stats = monsterLines[i].split(',');
        if (stats.length != 3) continue;
        String name = stats[0];
        int baseHealth = int.parse(stats[1]);
        int baseAttack = int.parse(stats[2]);
        int health = baseHealth + (level - 1) * 10;
        int maxAttack = baseAttack + (level - 1) * 5;
        monsters.add(Monster(name, health, maxAttack, level));
      }
      // 검증 코드 추가
      assert(monsters.length == totalMonsters,
          "몬스터 수가 $totalMonsters가 아닙니다: ${monsters.length}");
      if (level > 1) {
        print('\n몬스터들이 강화되었습니다!');
        print('체력 증가: +${(level - 1) * 10}');
        print('공격력 증가: +${(level - 1) * 5}');
      }
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      GameIO.exitGame();
    }
  }

  Future<void> loadCharacterStats() async {
    String name = await GameIO.getCharacterName();
    character = Character(name, 100, 20, 1);
    print('\n${name}님 반갑습니다.');
    bool isNewPlayer = await GameIO.isNewPlayer(name);
    if (isNewPlayer) {
      print('튜토리얼을 확인하시겠습니까? (y/n)');
      if (await GameIO.getPlayerChoice(validChoices: ['y', 'n']) == 'y') {
        await GameIO.showTutorial();
      }
    } else {
      print('튜토리얼을 다시 확인하시겠습니까? (y/n)');
      if (await GameIO.getPlayerChoice(validChoices: ['y', 'n']) == 'y') {
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
        bool foundExactMatch = false;
        for (String result in previousResults.reversed) {
          final results = result.split(',');
          if (results.length == 5 && results[0] == name) {
            // 이름 필드 추가 및 정확한 일치 확인
            foundExactMatch = true;
            int previousHealth = int.parse(results[1]);
            String previousResult = results[2];
            int previousLevel = int.parse(results[3]);
            int previousAttack = int.parse(results[4]);
            print(
                '이전 게임 결과: 체력 $previousHealth, 레벨 $previousLevel $previousResult');
            if (previousResult.contains('중간승리') ||
                previousResult.contains('최종승리')) {
              character!.setHealth(previousHealth);
              character!.level = previousLevel;
              character!.attack = previousAttack;
              level = previousLevel;
              print(
                  '이전 게임의 체력과 레벨을 이어받았습니다. 현재 체력: ${character!.health}, 레벨: ${character!.level}, 공격력: ${character!.attack}');
              if (previousResult.contains('최종승리')) {
                print('축하합니다! 이전 게임에서 최종 승리하셨습니다. 새로운 도전을 시작합니다.');
                level++;
                character!.level = level;
                resetMonsters();
              }
            } else {
              print('이전 게임에서 패배하셨습니다. 새로운 게임을 시작합니다.');
            }
            break;
          }
        }
        if (!foundExactMatch) {
          print('반갑습니다. 이전 게임 기록을 찾지 못했습니다. 새로운 게임을 시작합니다.');
        }
      } else {
        print('반갑습니다. 이전 게임 기록을 찾지 못했습니다. 새로운 게임을 시작합니다.');
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
      monster.attackCharacter(character!);
      if (character!.health <= 0) {
        print('${character?.name}이(가) 쓰러졌습니다. 게임 오버!');
        return false;
      }
    }
    return false;
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
    try {
      if (character == null) {
        await loadCharacterStats();
      }
      await loadMonsterStats();
      defeatedMonsters = 0;
      print('');
      print('게임을 시작합니다!');
      print('현재 레벨: $level');
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
        if (!await askForNextBattle()) {
          await endGame(true);
          return;
        }
      }
      if (defeatedMonsters == totalMonsters) {
        await endGame(true);
      }
    } catch (e) {
      await handleGameError(e);
    }
  }

  Future<void> levelUpBonus() async {
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

  Future<void> levelUp() async {
    level++;
    character!.level = level;
    print('모든 몬스터를 물리쳤습니다.');
    print('\n축하합니다! 레벨 ${level - 1}을 클리어하셨습니다.');
    print('레벨이 올랐습니다! 현재 레벨: $level');
    await levelUpBonus();
    print('\n주의: 새로운 레벨에서는 몬스터가 더 강력해집니다!');
  }

  void resetGame() {
    level = 1;
    defeatedMonsters = 0;
    monsters.clear();
    character = null; // 캐릭터를 새로 생성하기 위해 null로 설정
  }

  Future<void> endGame(bool isVictory) async {
    String result = isVictory
        ? (defeatedMonsters == totalMonsters ? '최종승리' : '중간승리')
        : '패배';
    print('\n게임이 종료되었습니다. 결과: $result');
    print('물리친 몬스터 수: $defeatedMonsters');
    if (!isVictory) {
      print('남은 몬스터 수: ${totalMonsters - defeatedMonsters}');
      if (await askToRetry()) {
        resetGame();
        await startGame();
        return;
      }
    }
    if (isVictory && defeatedMonsters == totalMonsters) {
      await levelUp();
    }
    if (!await confirmSaveResult()) return;
    await GameIO.saveResult(character!, result);
    print('결과가 저장되었습니다.');
    if (isVictory && defeatedMonsters == totalMonsters) {
      if (await GameIO.askToContinueNextLevel()) {
        resetMonsters();
        await startGame();
      }
    }
  }

  void checkAndDisplayCharacterStatus() {
    if (character != null) {
      character!.showStatus();
      if (character!.health <= 0) {
        print('캐릭터의 체력이 0 이하입니다. 체력을 회복합니다.');
        character!.health = 100; // 또는 다른 적절한 초기 체력값
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
      print('다음 몬스터와 싸우시겠습니까? (y/n/reset):');
      String? response =
          await GameIO.getPlayerChoice(validChoices: ['y', 'n', 'reset']);
      if (response == 'reset' || response == 'n') {
        return false;
      }
    }
    return true;
  }

  Future<void> handleGameError(dynamic error) async {
    print('게임 진행 중 오류가 발생했습니다: $error');
    print('게임을 다시 시작합니다.');
    resetGame();
    await startGame();
  }

  Future<bool> askToRetry() async {
    print('처음부터 다시 도전하시겠습니까? (y/n)');
    String? retry = await GameIO.getPlayerChoice(validChoices: ['y', 'n']);
    return retry.toLowerCase() == 'y';
  }

  Future<bool> confirmSaveResult() async {
    print('정말 결과를 저장하지 않고 종료하시려면 "종료"를 입력해주세요.');
    String? response = await GameIO.getPlayerChoice();
    return response.toLowerCase() != '종료';
  }
}
