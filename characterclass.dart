import 'dart:math';

// 캐릭터 클래스 정의
class Character {
  String name;
  int health;
  late int maxHealth; // 최대 체력 개념 추가
  int attack;
  int defense;
  bool hasUsedItem = false; // 도전: 아이템 사용 여부 확인 변수

  Character(this.name, this.health, this.attack, this.defense) {
    this.maxHealth = health; // 초기 체력을 최대 체력으로 설정
  }

  // 체력 설정 메서드 추가
  void setHealth(int newHealth) {
    health = min(newHealth, maxHealth); // 최대 체력을 초과하지 않도록 설정
  }

  // 몬스터를 공격하는 메서드
  void attackMonster(Monster monster) {
    int damage = max(0, attack - monster.defense);
    monster.health -= damage;
    print('$name이(가) ${monster.name}에게 $damage의 데미지를 입혔습니다.');
  }

  // 방어 메서드, 체력 회복 0으로 설정
  void defend() {
    int healAmount = 0;
    health += healAmount;
    print('$name이(가) 방어 태세를 취하여 $healAmount 만큼 체력을 얻었습니다.');
  }

  // 도전: 아이템 사용
  void useItem() {
    if (!hasUsedItem) {
      attack *= 2; // 공격력 두 배로 증가
      hasUsedItem = true;
      print('$name이(가) 특수 아이템을 사용했습니다! 공격력이 두 배로 증가합니다.');
    } else {
      print('이미 아이템을 사용했습니다.');
    }
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
  int turnCounter = 0; // 도전: 턴 카운터 변수 추가

  Monster(this.name, this.health, this.maxAttack) {
    attack = Random().nextInt(maxAttack) + 1;
  }

  // 캐릭터를 공격하는 메서드
  void attackCharacter(Character character) {
    int damage = max(0, attack - character.defense);
    character.health -= damage;
    print('${this.name}이(가) ${character.name}에게 $damage의 데미지를 입혔습니다.');

    // 도전: 턴 카운터 증가 및 방어력 증가 처리
    turnCounter++;
    if (turnCounter == 3) {
      defense += 2;
      turnCounter = 0;
      print('$name의 방어력이 증가했습니다! 현재 방어력: $defense');
    }
  }

  // 몬스터 상태 출력 메서드
  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack');
  }
}
