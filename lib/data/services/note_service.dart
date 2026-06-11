import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/services/file_share_service.dart';
import 'package:characterbook/ui/widgets/dialogs/loading_dialog.dart';
import 'package:flutter/material.dart';

class NoteService extends ChangeNotifier {
  final NoteRepository _repository;

  NoteService(this._repository);

  Future<dynamic> saveNote(Note note, {dynamic key}) async {
    final result = await _repository.save(note, key: key);
    notifyListeners();
    return result;
  }

  Future<void> deleteNote(Note note) async {
    await _repository.delete(note.key);
    notifyListeners();
  }

  Future<List<Note>> getAllNotes() => _repository.getAll();

  Future<List<Note>> getNotesForCharacter(String characterId) =>
      _repository.getNotesForCharacter(characterId);

  Future<void> exportToJson(BuildContext context, Note note) async {
    bool isLoadingVisible = false;

    try {
      isLoadingVisible = true;
      showLoadingDialog(context: context, message: S.of(context).creating_file);
      await Future.delayed(const Duration(milliseconds: 50));

      final jsonStr = jsonEncode(note.toJson());
      final fileName =
          '${note.title}_${DateTime.now().millisecondsSinceEpoch}.note';

      if (context.mounted) {
        hideLoadingDialog(context);
        isLoadingVisible = false;
        await Future.delayed(const Duration(milliseconds: 200));
      }

      await FileShareService.shareFile(
        Uint8List.fromList(jsonStr.codeUnits),
        fileName,
        text: 'Заметка: ${note.title}',
      );
    } catch (e) {
      if (isLoadingVisible && context.mounted) hideLoadingDialog(context);
      throw Exception('Ошибка экспорта в JSON: ${e.toString()}');
    }
  }

  Future<void> shareNote(BuildContext context, Note note) async {
    bool isLoadingVisible = false;

    try {
      isLoadingVisible = true;
      showLoadingDialog(context: context, message: S.of(context).creating_file);
      await Future.delayed(const Duration(milliseconds: 50));

      final jsonStr = jsonEncode(note.toJson());
      final fileName =
          '${note.title}_${DateTime.now().millisecondsSinceEpoch}.note';

      if (context.mounted) {
        hideLoadingDialog(context);
        isLoadingVisible = false;
        await Future.delayed(const Duration(milliseconds: 200));
      }

      await FileShareService.shareFile(
        Uint8List.fromList(jsonStr.codeUnits),
        fileName,
        text: 'Заметка: ${note.title}',
        subject: 'Заметка из CharacterBook',
      );
    } catch (e) {
      if (isLoadingVisible && context.mounted) hideLoadingDialog(context);
      throw Exception('Ошибка при шаринге заметки: ${e.toString()}');
    }
  }
}
