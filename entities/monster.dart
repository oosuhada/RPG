import 'dart:math';
import 'character.dart';
import 'skill.dart';

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

  // 캐릭터 공격
  void attackCharacter(Character character) {
    Skill selectedSkill = skills[Random().nextInt(skills.length)];
    int damage = calculateDamage(selectedSkill, character);
    character.health -= damage;
    print(
        '${this.name}이(가) ${selectedSkill.name}을(를) 사용하여 ${character.name}에게 $damage의 데미지를 입혔습니다!');
    if (selectedSkill.effect != null) {
      selectedSkill.effect!(character, this);
    }
  }

  Skill chooseRandomSkill() {
    return skills[Random().nextInt(skills.length)];
  }

  // 데미지 계산
  int calculateDamage(Skill skill, Character character) {
    double effectiveness = 1.0;
    // 타입 상성 계산 (캐릭터 타입에 따라)
    int baseDamage = ((attack * skill.power) / 100).round();
    return (baseDamage * effectiveness - character.defense).round();
  }

  // 상태 표시
  void showStatus() {
    print('$name ($type) - 체력: $health, 공격력: $attack, 방어력: $defense');
  }
}
