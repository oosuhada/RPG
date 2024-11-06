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

  void loadCharacterStats() {
    try {
      final file = File('characters.txt');
      final contents = file.readAsStringSync();
      final stats = contents.split(',');
      if (stats.length != 3) throw FormatException('Invalid character data');

      int health = int.parse(stats[0]);
      int attack = int.parse(stats[1]);
      int defense = int.parse(stats[2]);

      String name = getCharacterName();
      character = Character(name, health, attack, defense);

      // 이전 게임 결과 불러오기
      loadPreviousResult(name);

      // 도전: 캐릭터 체력 보너스 기능 호출
      applyHealthBonus();
    } catch (e) {
      print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  // 게임 결과 저장 불러오는 메서드 수정
  void loadPreviousResult(String name) {
    try {
      final file = File('result.txt');
      if (file.existsSync()) {
        final contents = file.readAsLinesSync();
        List<String> previousResults =
            contents.where((line) => line.startsWith(name)).toList();

        if (previousResults.isNotEmpty) {
          String lastResult = previousResults.last;
          final results = lastResult.split(',');
          if (results.length == 3) {
            int previousHealth = int.parse(results[1]);
            String previousResult = results[2];
            print('이전 게임 결과: 체력 $previousHealth, 결과 $previousResult');

            if (previousResult == '중간승리' || previousResult == '최종승리') {
              character!.setHealth(previousHealth); // 체력 설정 메서드 사용
              print('이전 게임의 체력을 이어받았습니다. 현재 체력: ${character!.health}');
              if (previousResult == '최종승리') {
                print('축하합니다! 이전 게임에서 최종 승리하셨습니다. 새로운 도전을 시작합니다.');
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

  void loadMonsterStats() {
    try {
      // monsters.txt 파일에서 몬스터 정보 읽기
      final file = File('monsters.txt');
      final contents = file.readAsStringSync();
      final monsterLines = contents.split('\n');

      for (var line in monsterLines) {
        final stats = line.split(',');
        if (stats.length != 3) continue;

        String name = stats[0];
        int health = int.parse(stats[1]);
        int maxAttack = int.parse(stats[2]);

        monsters.add(Monster(name, health, maxAttack));
      }
      totalMonsters = monsters.length;
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
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

  void battle(Monster monster) {
    print('\n새로운 몬스터가 나타났습니다!');
    monster.showStatus();

    while (character!.health > 0 && monster.health > 0) {
      print('\n${character?.name}의 턴');
      character?.showStatus();
      monster.showStatus();

      // 사용자 행동 선택
      stdout.write('행동을 선택하세요 (1: 공격, 2: 방어, 3: 아이템 사용): ');
      String? action = stdin.readLineSync();

      if (action == '1') {
        character?.attackMonster(monster);
      } else if (action == '2') {
        character?.defend();
      } else if (action == '3') {
        character?.useItem(); // 아이템 사용 기능 추가
      } else {
        print('잘못된 입력입니다. 다시 선택해주세요.');
        continue;
      }

      // 몬스터 처치 확인
      if (monster.health <= 0) {
        print('${monster.name}을(를) 물리쳤습니다!');
        defeatedMonsters++;
        monsters.remove(monster);
        break;
      }

      // 몬스터의 턴
      print('\n${monster.name}의 턴');
      monster.attackCharacter(character!);

      // 캐릭터 사망 확인
      if (character!.health <= 0) {
        print('${character?.name}이(가) 쓰러졌습니다. 게임 오버!');
        break;
      }
    }
  }

  // 게임 시작 메서드
  void startGame() {
    loadCharacterStats();
    loadMonsterStats();
    totalMonsters = monsters.length;

    print('');
    print('게임을 시작합니다!');
    character!.showStatus();

    while (character!.health > 0 && defeatedMonsters < totalMonsters) {
      Monster currentMonster = getRandomMonster();
      print('새로운 몬스터가 나타났습니다!');
      currentMonster.showStatus();

      battle(currentMonster);

      if (currentMonster.health <= 0) {
        defeatedMonsters++;
        monsters.remove(currentMonster);
        print('${currentMonster.name}을(를) 물리쳤습니다!');

        if (defeatedMonsters < totalMonsters) {
          bool validInput = false;
          while (!validInput) {
            stdout.write('\n다음 몬스터와 싸우시겠습니까? (y/n): ');
            String? answer = stdin.readLineSync()?.toLowerCase();
            if (answer == 'y') {
              validInput = true;
            } else if (answer == 'n') {
              validInput = true;
              endGame(true); // 몬스터를 물리치고 종료할 때는 저장을 승리로 처리
              return;
            } else {
              print('올바른 입력이 아닙니다. y 또는 n을 입력해주세요.');
            }
          }
        }
      }

      if (character!.health <= 0) {
        print('게임 오버! ${character!.name}이(가) 쓰러졌습니다.');
        endGame(false);
        return;
      }
    }

    if (defeatedMonsters == totalMonsters) {
      print('축하합니다! 모든 몬스터를 물리쳤습니다.');
      endGame(true);
    }
  }

  void endGame(bool isVictory) {
    String result;
    if (isVictory) {
      result = defeatedMonsters == totalMonsters ? '최종승리' : '중간승리';
    } else {
      result = '패배';
    }

    print('\n게임이 종료되었습니다. 결과: $result');
    print('물리친 몬스터 수: $defeatedMonsters');
    if (!isVictory) {
      print('남은 몬스터 수: ${totalMonsters - defeatedMonsters}');
    }

    saveResult(result);
  }

  void saveResult(String result) {
    while (true) {
      stdout.write('결과를 저장하시겠습니까? (y/n): ');
      String? answer = stdin.readLineSync()?.toLowerCase();
      if (answer == 'y') {
        // 결과 문자열 생성
        String content = '${character!.name},${character!.health},$result';

        // result.txt 파일에 결과 추가
        try {
          File('result.txt')
              .writeAsStringSync(content + '\n', mode: FileMode.append);
          print('결과가 result.txt 파일에 저장되었습니다.');
        } catch (e) {
          print('결과 저장 중 오류가 발생했습니다: $e');
        }
        break;
      } else if (answer == 'n') {
        stdout.write('정말 결과를 저장하지 않고 게임을 종료하시겠습니까? (y/n): ');
        String? confirmAnswer = stdin.readLineSync()?.toLowerCase();
        if (confirmAnswer == 'y') {
          print('결과를 저장하지 않고 게임을 종료합니다.');
          break;
        } else if (confirmAnswer == 'n') {
          continue; // 다시 저장 여부를 물어봄
        } else {
          print('올바른 입력이 아닙니다. 다시 선택해주세요.');
        }
      } else {
        print('올바른 입력이 아닙니다. y 또는 n을 입력해주세요.');
      }
    }
  }
}
