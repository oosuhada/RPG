import 'dart:io';
import 'dart:math';
import 'class.dart';

// 게임 클래스 정의
class Game {
  Character? character; //character 필드가 non-nullable로 선언되는 문제 ?로 해결
  List<Monster> monsters = [];
  int defeatedMonsters = 0;
  int totalMonsters = 0;

  // 게임 시작 메서드
  void startGame() {
    loadCharacterStats();
    loadMonsterStats();
    totalMonsters = monsters.length;

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
          print('다음 몬스터와 싸우시겠습니까? (y/n) :');
          String? answer = stdin.readLineSync()?.toLowerCase();
          if (answer != 'y') break;
        }
      }

      if (character!.health <= 0) {
        print('게임 오버! ${character!.name}이(가) 쓰러졌습니다.');
        break;
      }
    }

    if (defeatedMonsters == totalMonsters) {
      print('축하합니다! 모든 몬스터를 물리쳤습니다.');
    }

    saveResult();
  }

  // 전투 진행 메서드
  void battle(Monster monster) {
    while (character!.health > 0 && monster.health > 0) {
      print('${character!.name}의 턴');
      character!.showStatus();
      monster.showStatus();

      print('행동을 선택하세요 (1: 공격, 2: 방어):');
      String? action = stdin.readLineSync();

      if (action == '1') {
        character!.attackMonster(monster);
      } else if (action == '2') {
        character!.defend();
      } else {
        print('잘못된 입력입니다. 다시 선택해주세요.');
        continue;
      }

      if (monster.health > 0) {
        print('${monster.name}의 턴');
        monster.attackCharacter(character!);
      }
    }
  }

  // 랜덤 몬스터 선택 메서드
  Monster getRandomMonster() {
    return monsters[Random().nextInt(monsters.length)];
  }

  // 캐릭터 스탯 로드 메서드
  void loadCharacterStats() {
    try {
      // characters.txt 파일에서 캐릭터 스탯 읽기
      var file = File('characters.txt');
      var contents = file.readAsStringSync();
      var stats = contents.split(',');
      if (stats.length != 3) throw FormatException('Invalid character data');

      int health = int.parse(stats[0]);
      int attack = int.parse(stats[1]);
      int defense = int.parse(stats[2]);

      print('캐릭터의 이름을 입력하세요:');
      String? name = stdin.readLineSync();
      while (name == null ||
          name.isEmpty ||
          !RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name)) {
        print('올바른 이름을 입력해주세요 (한글 또는 영문):');
        name = stdin.readLineSync();
      }

      character = Character(name, health, attack, defense);
    } catch (e) {
      print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  // 몬스터 스탯 로드 메서드
  void loadMonsterStats() {
    try {
      // monsters.txt 파일에서 몬스터 스탯 읽기
      var file = File('monsters.txt');
      var lines = file.readAsLinesSync();
      for (var line in lines) {
        var stats = line.split(',');
        if (stats.length != 3) throw FormatException('Invalid monster data');

        String name = stats[0];
        int health = int.parse(stats[1]);
        int maxAttack = int.parse(stats[2]);

        monsters.add(Monster(name, health, maxAttack));
      }
    } catch (e) {
      print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
      exit(1);
    }
  }

  // 게임 결과 저장 메서드
  void saveResult() {
    print('결과를 저장하시겠습니까? (y/n)');
    String? answer = stdin.readLineSync()?.toLowerCase();
    if (answer == 'y') {
      try {
        // result.txt 파일에 게임 결과 저장
        var file = File('result.txt');
        String result = defeatedMonsters == totalMonsters ? '승리' : '패배';
        file.writeAsStringSync(
            '캐릭터 이름: ${character!.name}, 남은 체력: ${character!.health}, 게임 결과: $result');
        print('결과가 저장되었습니다.');
      } catch (e) {
        print('결과 저장에 실패했습니다: $e');
      }
    }
  }
}
