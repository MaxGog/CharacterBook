import 'package:hive/hive.dart';
import '../models/character_model.dart';

class CharacterService {
  static const String _boxName = 'characters';

  Future<Box<Character>> _openBox() async {
    return await Hive.openBox<Character>(_boxName);
  }

  Future<void> saveCharacter(Character character, {int? key}) async {
    final box = await _openBox();
    if (key != null) {
      await box.put(key, character);
    } else {
      await box.add(character);
    }
  }

  Future<List<Character>> getAllCharacters() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> deleteCharacter(int key) async {
    final box = await _openBox();
    await box.delete(key);
  }
}