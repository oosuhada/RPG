import 'dart:async';
import 'game_state.dart';
import 'battle_system.dart';
import '../entities/character.dart';
import '../entities/monster.dart';
import '../services/input_service.dart';
import '../services/output_service.dart';
import '../services/save_load_service.dart';
import '../utils/constants.dart';

class GameEngine {
  late GameState _gameState;
  late BattleSystem _battleSystem;
  late InputService _inputService;
  late OutputService _outputService;
  late SaveLoadService _saveLoadService;

  GameEngine() {
    _gameState = GameState();
    _battleSystem = BattleSystem();
    _inputService = InputService();
    _outputService = OutputService();
    _saveLoadService = SaveLoadService();
  }

  Future<void> startGame() async {
    await _initializeGame();
    await _gameLoop();
  }

  Future<void> _initializeGame() async {
    String language = await _inputService.chooseLanguage();
    _gameState.setLanguage(language);

    await _saveLoadService.showPlayHistory();

    String name = await _inputService.getCharacterName();
    Character character = await _inputService.chooseCharacter();
    _gameState.setCharacter(character);

    bool showTutorial = await _inputService.askForTutorial();
    if (showTutorial) {
      _outputService.showTutorial();
    }

    await _loadPreviousResult(name);
  }

  Future<void> _gameLoop() async {
    while (!_gameState.isGameOver) {
      await _processBattles();
      if (_gameState.isLevelComplete) {
        await _processLevelUp();
      }
    }
    await _endGame();
  }

  Future<void> _processBattles() async {
    while (_gameState.defeatedMonsters < Constants.totalMonsters &&
        !_gameState.isGameOver) {
      Monster monster = _gameState.getRandomMonster();
      bool victorious =
          await _battleSystem.initiateBattle(_gameState.character, monster);
      if (!victorious) {
        _gameState.isGameOver = true;
        return;
      }
      _gameState.defeatedMonsters++;
      if (!await _inputService.askToContinue()) {
        _gameState.isGameOver = true;
        return;
      }
    }
    _gameState.isLevelComplete = true;
  }

  Future<void> _processLevelUp() async {
    _gameState.level++;
    _gameState.stage = 1;
    _gameState.character.levelUp();
    _outputService.showLevelUpMessage(_gameState.level);
    await _applyLevelUpBonus();
    _gameState.resetMonsters();
    _gameState.isLevelComplete = false;
  }

  Future<void> _applyLevelUpBonus() async {
    String choice = await _inputService.getLevelUpChoice();
    switch (choice) {
      case '1':
        _gameState.character.increaseHealth(10);
        break;
      case '2':
        _gameState.character.increaseAttack(10);
        break;
      case '3':
        _gameState.character.increaseDefense(10);
        break;
    }
    _outputService.showCharacterStatus(_gameState.character);
  }

  Future<void> _endGame() async {
    _outputService.showGameResult(_gameState);
    await _saveLoadService.saveGameState(_gameState);
  }

  Future<void> _loadPreviousResult(String name) async {
    var previousResult = await _saveLoadService.loadPreviousResults(name);
    if (previousResult != null) {
      _gameState.loadFromPreviousResult(previousResult);
    }
  }
}
