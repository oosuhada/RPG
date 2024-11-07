import 'character.dart';
import 'monster.dart';

typedef SkillEffect = void Function(Character, Monster);

class Skill {
  String name;
  int power;
  String type;
  SkillEffect? effect;

  Skill(this.name, this.power, this.type, {this.effect});
}
