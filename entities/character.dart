import 'monster.dart';
import 'skill.dart';
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
      this.defense, this.skills) {
    this.maxHealth = health;
  }

  // 체력 설정
  void setHealth(int newHealth) {
    health = min(newHealth, maxHealth);
  }

  void levelUp() {
    level++;
    maxHealth += 10;
    health = maxHealth;
    attack += 5;
    defense += 3;
  }

  // 레벨업 보너스
  void levelUpBonus() {
    health += 10;
    maxHealth += 10;
    print('레벨업 보너스로 체력이 증가했습니다! 현재 체력: $health');
  }

  void increaseHealth(int amount) {
    maxHealth += amount;
    health = maxHealth;
  }

  void increaseAttack(int amount) {
    attack += amount;
  }

  void increaseDefense(int amount) {
    defense += amount;
  }

  // 스킬 사용
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

  // 데미지 계산
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

  // 방어
  void defend() {
    int healAmount = (maxHealth * 0.15).round();
    health = min(maxHealth, health + healAmount);
    print('$name이(가) 방어 태세를 취하여 $healAmount 만큼 체력을 회복했습니다.');
  }

  // 아이템 사용
  void useItem() {
    if (!hasUsedItem) {
      attack *= 2;
      hasUsedItem = true;
      print('$name이(가) 특수 아이템을 사용했습니다! 공격력이 두 배로 증가합니다.');
    } else {
      print('이미 아이템을 사용했습니다.');
    }
  }

  // 상태 표시
  void showStatus() {
    print(
        '$name ($characterType) - 체력: $health/$maxHealth, 공격력: $attack, 방어력: $defense');
  }

  // 스킬 표시
  void showSkills() {
    print('\n사용 가능한 기술:');
    for (int i = 0; i < skills.length; i++) {
      print(
          '${i + 1}: ${skills[i].name} (위력: ${skills[i].power}, 타입: ${skills[i].type})');
    }
  }
}
