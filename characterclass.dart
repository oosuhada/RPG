import 'dart:math';

class Character {
  String name;
  int health;
  late int maxHealth;
  int attack;
  int defense;
  bool hasUsedItem = false;
  int level = 1;

  Character(this.name, this.health, this.attack, this.defense) {
    this.maxHealth = health;
  }

  void setHealth(int newHealth) {
    health = min(newHealth, maxHealth);
  }

  void levelUpBonus() {
    health += 10;
    maxHealth += 10;
    print('레벨업 보너스로 체력이 증가했습니다! 현재 체력: $health');
  }

  void attackMonster(Monster monster) {
    int damage = attack - monster.defense;
    if (damage < 0) damage = 0;
    monster.health -= damage;
    if (monster.health < 0) monster.health = 0;
    print('$name이(가) ${monster.name}에게 $damage의 데미지를 입혔습니다.');
  }

  void defend() {
    int healAmount = 0;
    health += healAmount;
    print('$name이(가) 방어 태세를 취하여 $healAmount 만큼 체력을 얻었습니다.');
  }

  void useItem() {
    if (!hasUsedItem) {
      attack *= 2;
      hasUsedItem = true;
      print('$name이(가) 특수 아이템을 사용했습니다! 공격력이 두 배로 증가합니다.');
    } else {
      print('이미 아이템을 사용했습니다.');
    }
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack, 방어력: $defense');
  }
}

class Monster {
  String name;
  int health;
  int maxAttack;
  late int attack;
  int defense = 0;
  int turnCounter = 0;
  int level;

  Monster(this.name, this.health, this.maxAttack, this.level,
      {this.defense = 1}) {
    attack = Random().nextInt(maxAttack) + level * 5;
  }

  void attackCharacter(Character character) {
    int damage = max(0, attack - character.defense);
    character.health -= damage;
    print('${this.name}이(가) ${character.name}에게 $damage의 데미지를 입혔습니다.');
    turnCounter++;
    if (turnCounter == 3) {
      defense += 2;
      turnCounter = 0;
      print('$name의 방어력이 증가했습니다! 현재 방어력: $defense');
    }
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attack, 방어력: $defense');
  }
}
