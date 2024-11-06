import 'dart:io';
import 'dart:math';

// 캐릭터 클래스 정의
class Character {
  String name;
  int health;
  int attack;
  int defense;

  Character(this.name, this.health, this.attack, this.defense);

  // 몬스터를 공격하는 메서드
  void attackMonster(Monster monster) {
    int damage = max(0, attack - monster.defense);
    monster.health -= damage;
    print('$name이(가) ${monster.name}에게 $damage의 데미지를 입혔습니다.');
    print('');
  }

  // 방어 메서드, 체력 회복 0으로 설정
  void defend() {
    int healAmount = 0;
    health += healAmount;
    print('$name이(가) 방어 태세를 취하여 $healAmount 만큼 체력을 얻었습니다.');
    print('');
  }

  // 캐릭터 상태 출력 메서드
  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack, 방어력: $defense');
  }
}

// 몬스터 클래스 정의
class Monster {
  String name;
  int health;
  int maxAttack;
  late int attack; //attack 필드가 non-nullable로 선언되는 문제 late로 해결
  int defense = 0;

  Monster(this.name, this.health, this.maxAttack) {
    attack = Random().nextInt(maxAttack) + 1;
  }

  // 캐릭터를 공격하는 메서드
  void attackCharacter(Character character) {
    int damage = max(0, attack - character.defense);
    character.health -= damage;
    print('${this.name}이(가) ${character.name}에게 $damage의 데미지를 입혔습니다.');
    print('');
  }

  // 몬스터 상태 출력 메서드
  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack');
    print('');
  }
}
