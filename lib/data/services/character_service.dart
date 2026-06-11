import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/services/file_share_service.dart';
import 'package:characterbook/services/pdf_export_manager.dart';
import 'package:characterbook/data/services/relationship_service.dart';
import 'package:characterbook/services/word_export_manager.dart';
import 'package:characterbook/ui/widgets/dialogs/error_dialog.dart';
import 'package:characterbook/ui/widgets/dialogs/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class CharacterService extends ChangeNotifier {
  final CharacterRepository _repository;
  final RelationshipService _relationshipService;

  CharacterService(this._repository, this._relationshipService);

  Future<dynamic> saveCharacter(Character character, {int? key}) async {
    final result = await _repository.save(character, key: key);
    notifyListeners();
    return result;
  }

  Future<void> deleteCharacter(Character character) async {
    await _relationshipService.deleteRelationshipsForCharacter(character.id);
    await _repository.delete(character.key);
    notifyListeners();
  }

  Future<List<Character>> getAllCharacters() => _repository.getAll();

  Future<Character?> getCharacterByKey(int key) async {
    final all = await _repository.getAll();
    return all.firstWhereOrNull((c) => c.key == key);
  }

  Future<List<Character>> getCharactersByRaceId(String raceId) async {
    final all = await _repository.getAll();
    return all.where((c) => c.race?.id == raceId).toList();
  }

  Future<Character?> getCharacterById(String id) async {
    final all = await _repository.getAll();
    return all.firstWhereOrNull((c) => c.id == id);
  }

  Future<Character> duplicateCharacter(Character character) async {
    try {
      final duplicated = character.copyWith(
        id: _generateUniqueId(),
        name: '${character.name} (${S.current.copy})',
      );
      await _repository.save(duplicated);
      return duplicated;
    } catch (e) {
      throw Exception('${S.current.duplicate_error}: $e');
    }
  }

  String _generateUniqueId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(1000000);
    return '${timestamp}_$randomNum';
  }

  Future<void> exportToPdf(BuildContext context, Character character) async {
    try {
      await PdfExportManager.exportCharacterWithDialog(
        context,
        character,
        fileName: '${character.name}.pdf',
        shareText: S.current.character_exported(character.name),
      );
    } catch (e) {
      _handleError(context, S.current.export_error, e);
    }
  }

  Future<void> exportToJson(BuildContext context, Character character) async {
    try {
      showLoadingDialog(context: context, message: S.current.creating_file);
      final jsonStr = jsonEncode(character.toJson());
      final fileName =
          '${character.name}_${DateTime.now().millisecondsSinceEpoch}.character';
      if (context.mounted) hideLoadingDialog(context);
      await FileShareService.shareFile(
        Uint8List.fromList(jsonStr.codeUnits),
        fileName,
        text: '${S.current.character}: ${character.name}',
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(S.current.export_error),
      );
    } on TimeoutException {
      if (context.mounted) {
        hideLoadingDialog(context);
        _showErrorDialog(
            context, S.current.export_error, S.current.export_timeout);
      }
    } catch (e) {
      if (context.mounted) {
        hideLoadingDialog(context);
        _showErrorDialog(
            context, S.current.export_error, '${S.current.export_error}: $e');
      }
    }
  }

  void _handleError(BuildContext context, String title, Object error) {
    if (context.mounted) {
      _showErrorDialog(context, title, error.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        showErrorDialog(context: context, title: title, message: message);
      }
    });
  }

  Future<void> exportToWord(BuildContext context, Character character) async {
    await WordExportManager.exportCharacterWithDialog(context, character);
  }
}
