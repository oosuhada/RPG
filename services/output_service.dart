import '../entities/character.dart';
import '../entities/monster.dart';
import '../entities/skill.dart';
import '../core/game_state.dart';

class OutputService {
  void showBattleStatus(Character character, Monster monster) {
    print('\n--- Battle Status ---');
    character.showStatus();
    monster.showStatus();
  }

  void showCharacterStatus(Character character) {
    print('\n--- Character Status ---');
    character.showStatus();
  }

  void showMonsterStatus(Monster monster) {
    print('\n--- Monster Status ---');
    monster.showStatus();
  }

  void showTutorial() {
    print('''
Tutorial:
1. Enter your character's name.
2. Choose your character type.
3. Battle monsters by selecting actions:
   - Attack: Use a skill to damage the monster
   - Defend: Recover some health
   - Use Item: Boost your attack power (can be used only once per battle)
4. Defeat all monsters to level up.
5. The game ends when you reach level 10 or lose all your health.
Good luck!
    ''');
  }

  void showGameResult(GameState gameState) {
    print('\n--- Game Result ---');
    print('Level: ${gameState.level}');
    print('Stage: ${gameState.stage}');
    print('Defeated Monsters: ${gameState.defeatedMonsters}');
    gameState.character.showStatus();
  }

  void showErrorMessage(String message) {
    print('\nError: $message');
  }

  void showBattleStart(Monster monster) {
    print('\nA wild ${monster.name} appeared!');
  }

  void showVictoryMessage(Monster monster) {
    print('\nYou defeated the ${monster.name}!');
  }

  void showDefeatMessage() {
    print('\nYou were defeated...');
  }

  void showAttackResult(
      Character character, Monster monster, Skill skill, int damage) {
    print(
        '\n${character.name} used ${skill.name} and dealt $damage damage to ${monster.name}!');
  }

  void showDefendResult(Character character) {
    print(
        '\n${character.name} took a defensive stance and recovered some health.');
  }

  void showItemUseResult(Character character) {
    print(
        '\n${character.name} used a special item and doubled their attack power!');
  }

  void showMonsterAttackResult(
      Monster monster, Character character, Skill skill, int damage) {
    print(
        '\n${monster.name} used ${skill.name} and dealt $damage damage to ${character.name}!');
  }

  void showLevelUpMessage(int level) {
    print('\nCongratulations! You reached level $level!');
  }
}
