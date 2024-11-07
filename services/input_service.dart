import 'dart:io';
import '../entities/character.dart';
import '../entities/skill.dart';

class InputService {
  Future<String> chooseLanguage() async {
    print('Choose language / 언어를 선택하세요:');
    print('1. English');
    print('2. 한국어');
    while (true) {
      String? input = stdin.readLineSync()?.trim();
      if (input == '1') return 'en';
      if (input == '2') return 'ko';
      print(
          'Invalid input. Please choose 1 or 2. / 잘못된 입력입니다. 1 또는 2를 선택해주세요.');
    }
  }

  Future<bool> askForTutorial() async {
    print('튜토리얼을 보시겠습니까? (y/n)');
    String choice = await getPlayerChoice(validChoices: ['y', 'n']);
    return choice.toLowerCase() == 'y';
  }

  Future<String> getCharacterName() async {
    while (true) {
      stdout.write('Enter your character name: ');
      String? name = stdin.readLineSync()?.trim();
      if (name != null &&
          name.isNotEmpty &&
          RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name)) {
        return name;
      }
      print(
          'Please enter a valid name (only letters and Korean characters are allowed).');
    }
  }

  Future<Character> chooseCharacter() async {
    // 캐릭터 선택 로직 구현
    // 예시:
    print('캐릭터를 선택하세요:');
    print('1. 아이언맨');
    print('2. 캡틴 아메리카');
    String choice = await getPlayerChoice(validChoices: ['1', '2']);
    if (choice == '1') {
      return Character('아이언맨', 'Technology', 100, 20, 15, []);
    } else {
      return Character('캡틴 아메리카', 'Strength', 120, 18, 18, []);
    }
  }

  Future<String?> getPlayerAction() async {
    while (true) {
      stdout.write('Choose your action (1: Attack, 2: Defend, 3: Use Item): ');
      String? input = stdin.readLineSync()?.toLowerCase().trim();
      if (input == 'reset') return 'reset';
      if (['1', '2', '3'].contains(input)) return input;
      print('Invalid action. Please choose 1, 2, or 3.');
    }
  }

  Future<String> getPlayerChoice({List<String>? validChoices}) async {
    while (true) {
      String? input = stdin.readLineSync()?.toLowerCase().trim();
      if (input == null || input.isEmpty) continue;
      if (input == 'reset') return 'reset';
      if (validChoices == null || validChoices.contains(input)) {
        return input;
      }
      print('Invalid choice. Please enter one of: ${validChoices?.join(", ")}');
    }
  }

  Future<bool> askForConfirmation() async {
    while (true) {
      stdout.write('Do you want to continue? (y/n): ');
      String? input = stdin.readLineSync()?.toLowerCase().trim();
      if (input == 'y') return true;
      if (input == 'n') return false;
      print('Invalid input. Please enter y or n.');
    }
  }

  Future<bool> askToContinue() async {
    return await askForConfirmation();
  }

  Future<bool> getYesNoAnswer() async {
    while (true) {
      String? answer = stdin.readLineSync()?.toLowerCase().trim();
      if (answer == 'y') return true;
      if (answer == 'n') return false;
      print('Invalid input. Please enter y or n.');
    }
  }

  Future<Skill> chooseSkill(List<Skill> skills) async {
    while (true) {
      for (int i = 0; i < skills.length; i++) {
        print(
            '${i + 1}: ${skills[i].name} (Power: ${skills[i].power}, Type: ${skills[i].type})');
      }
      stdout.write('Choose a skill (1-${skills.length}): ');
      String? input = stdin.readLineSync()?.trim();
      int? choice = int.tryParse(input ?? '');
      if (choice != null && choice > 0 && choice <= skills.length) {
        return skills[choice - 1];
      }
      print(
          'Invalid choice. Please enter a number between 1 and ${skills.length}.');
    }
  }

  Future<String> getLevelUpChoice() async {
    print('레벨업 보너스를 선택하세요:');
    print('1. 체력 증가');
    print('2. 공격력 증가');
    print('3. 방어력 증가');
    return await getPlayerChoice(validChoices: ['1', '2', '3']);
  }
}
