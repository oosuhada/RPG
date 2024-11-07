import 'dart:math';

class Character {
  String name;
  String characterType;
  int health;
  late int maxHealth;
  int attack;
  int defense;
  bool hasUsedItem = false;
  int level = 1;
  List<Skill> skills = [];

  Character(this.name, this.characterType, this.health, this.attack,
      this.defense, List<Skill> skills) {
    this.maxHealth = health;
    this.skills = skills;
  }

  void setHealth(int newHealth) {
    health = min(newHealth, maxHealth);
  }

  void levelUpBonus() {
    health += 10;
    maxHealth += 10;
    print('레벨업 보너스로 체력이 증가했습니다! 현재 체력: $health');
  }

  void useSkill(Monster monster, Skill skill) {
    int damage = calculateDamage(skill, monster);
    monster.health -= damage;
    if (monster.health < 0) monster.health = 0;
    print(
        '$name이(가) ${skill.name}을(를) 사용하여 ${monster.name}에게 $damage의 데미지를 입혔습니다!');
    if (skill.effect != null) {
      skill.effect!(this, monster);
    }
  }

  int calculateDamage(Skill skill, Monster monster) {
    double effectiveness = 1.0;
    // 타입 상성 계산
    if (skill.type == 'Flying' && monster.type == 'Ground') effectiveness = 2.0;
    if (skill.type == 'Strength' && monster.type == 'Flying')
      effectiveness = 2.0;
    if (skill.type == 'Speed' && monster.type == 'Strength')
      effectiveness = 2.0;

    int baseDamage = ((attack * skill.power) / 100).round();
    return (baseDamage * effectiveness - monster.defense).round();
  }

  void defend() {
    int healAmount = (maxHealth * 0.15).round();
    health = min(maxHealth, health + healAmount);
    print('$name이(가) 방어 태세를 취하여 $healAmount 만큼 체력을 회복했습니다.');
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
    print(
        '$name ($characterType) - 체력: $health/$maxHealth, 공격력: $attack, 방어력: $defense');
  }

  void showSkills() {
    print('\n사용 가능한 기술:');
    for (int i = 0; i < skills.length; i++) {
      print(
          '${i + 1}: ${skills[i].name} (위력: ${skills[i].power}, 타입: ${skills[i].type})');
    }
  }
}

class Skill {
  String name;
  int power;
  String type;
  Function(Character, Monster)? effect;

  Skill(this.name, this.power, this.type, {this.effect});
}

class Monster {
  String name;
  String type;
  int health;
  int maxAttack;
  late int attack;
  int defense;
  int level;
  List<Skill> skills = [];

  Monster(this.name, this.type, this.health, this.maxAttack, this.level,
      this.skills,
      {this.defense = 1}) {
    attack = Random().nextInt(maxAttack) + level * 5;
  }

  void attackCharacter(Character character) {
    Skill selectedSkill = skills[Random().nextInt(skills.length)];
    int damage = calculateDamage(selectedSkill, character);
    character.health -= damage;
    print(
        '${this.name}이(가) ${selectedSkill.name}을(를) 사용하여 ${character.name}에게 $damage의 데미지를 입혔습니다!');
    if (selectedSkill.effect != null) {
      selectedSkill.effect!(character as Character, this);
    }
  }

  int calculateDamage(Skill skill, Character character) {
    double effectiveness = 1.0;
    // 타입 상성 계산 (캐릭터 타입에 따라)
    int baseDamage = ((attack * skill.power) / 100).round();
    return (baseDamage * effectiveness - character.defense).round();
  }

  void showStatus() {
    print('$name ($type) - 체력: $health, 공격력: $attack, 방어력: $defense');
  }
}
