import '../entities/character.dart';
import '../entities/monster.dart';
import '../utils/constants.dart';

class GameState {
  late Character character;
  List<Monster> monsters = [];
  int defeatedMonsters = 0;
  int level = 1;
  int stage = 1;
  bool isGameOver = false;
  bool isLevelComplete = false;
  String language = 'en'; // 기본 언어는 영어

  void setCharacter(Character character) {
    this.character = character;
  }

  void setLanguage(String language) {
    this.language = language;
  }

  Monster getRandomMonster() {
    // 랜덤 몬스터 선택 로직
    return monsters[0]; // 임시 구현
  }

  void resetMonsters() {
    // 몬스터 리스트 초기화 및 새로운 몬스터 생성 로직
  }

  void loadFromPreviousResult(Map<String, dynamic> result) {
    // 이전 게임 결과로부터 상태 로드
  }
}
