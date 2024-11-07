import '../entities/character.dart';
import '../entities/monster.dart';
import '../entities/skill.dart';
import '../services/input_service.dart';
import '../services/output_service.dart';
import '../utils/type_effectiveness.dart';

class BattleSystem {
  final InputService _inputService = InputService();
  final OutputService _outputService = OutputService();

  Future<bool> initiateBattle(Character character, Monster monster) async {
    _outputService.showBattleStart(monster);

    while (character.health > 0 && monster.health > 0) {
      await _processTurn(character, monster);
      if (monster.health <= 0) {
        _outputService.showVictoryMessage(monster);
        return true;
      }
      if (character.health <= 0) {
        _outputService.showDefeatMessage();
        return false;
      }
    }
    return false;
  }

  Future<void> _processTurn(Character character, Monster monster) async {
    _outputService.showBattleStatus(character, monster);
    String? action = await _inputService.getPlayerAction();

    switch (action) {
      case '1': // 공격
        Skill skill = await _inputService.chooseSkill(character.skills);
        int damage = calculateDamage(character, monster, skill);
        monster.health -= damage;
        _outputService.showAttackResult(character, monster, skill, damage);
        break;
      case '2': // 방어
        character.defend();
        _outputService.showDefendResult(character);
        break;
      case '3': // 아이템 사용
        character.useItem();
        _outputService.showItemUseResult(character);
        break;
    }

    // 몬스터의 턴
    if (monster.health > 0) {
      Skill monsterSkill = monster.chooseRandomSkill();
      int monsterDamage = calculateDamage(monster, character, monsterSkill);
      character.health -= monsterDamage;
      _outputService.showMonsterAttackResult(
          monster, character, monsterSkill, monsterDamage);
    }
  }

  int calculateDamage(dynamic attacker, dynamic defender, Skill skill) {
    double effectiveness =
        TypeEffectiveness.getEffectiveness(skill.type, defender.type);
    int baseDamage = ((attacker.attack * skill.power) / 100).round();
    return (baseDamage * effectiveness - defender.defense).round();
  }
}
