import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:characterbook/data/enums/character_sort_enum.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/services/clipboard_service.dart';
import 'package:characterbook/services/pdf_export_manager.dart';
import 'package:characterbook/services/word_export_manager.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CharacterListController extends ChangeNotifier {
  final CharacterRepository _repository;
  List<Character> _all = [];
  List<Character> _filtered = [];
  String _searchQuery = '';
  String? _selectedTag;
  CharacterSort _sort = CharacterSort.nameAsc;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  CharacterListController(this._repository) {
    _subscription = _repository.watchAll().listen(
      (list) {
        _all = list;
        _applyFilterAndSort();
      },
      onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  List<Character> get filteredItems => _filtered;
  String? get selectedTag => _selectedTag;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _applyFilterAndSort();
  }

  void setSelectedTag(String? tag) {
    if (_selectedTag == tag) return;
    _selectedTag = tag;
    _applyFilterAndSort();
  }

  void setSort(CharacterSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    _filtered = _all.where(_matchesSearchAndTag).toList();
    _sortItems();
    notifyListeners();
  }

  bool _matchesSearchAndTag(Character c) {
    final queryLower = _searchQuery.toLowerCase();
    final matchesSearch = _searchQuery.isEmpty ||
        c.name.toLowerCase().contains(queryLower) ||
        c.age.toString().contains(_searchQuery) ||
        c.tags.any((t) => t.toLowerCase().contains(queryLower));
    final matchesTag = _selectedTag == null || c.tags.contains(_selectedTag);
    return matchesSearch && matchesTag;
  }

  void _sortItems() {
    switch (_sort) {
      case CharacterSort.nameAsc:
        _filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CharacterSort.nameDesc:
        _filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case CharacterSort.ageAsc:
        _filtered.sort((a, b) => a.age.compareTo(b.age));
        break;
      case CharacterSort.ageDesc:
        _filtered.sort((a, b) => b.age.compareTo(a.age));
        break;
    }
  }

  Set<String> get allTags => _all.expand((c) => c.tags).toSet();

  Future<void> deleteCharacter(Character character) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.delete(character.key);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportCharacterToWord(Character character, BuildContext context) async {
    await WordExportManager.exportCharacterWithDialog(context, character);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    try {
      await _repository.reorder(oldIndex, newIndex);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> characterClipboardText(Character character, BuildContext context) async {
    await ClipboardService.copyCharacterToClipboard(
      context: context,
      name: character.name,
      age: character.age,
      gender: character.gender,
      raceName: character.race?.name,
      biography: character.biography,
      appearance: character.appearance,
      personality: character.personality,
      abilities: character.abilities,
      other: character.other,
      customFields: character.customFields
          .map((f) => {'key': f.key, 'value': f.value})
          .toList(),
    );
  }

  Future<void> shareCharacterAsFile(Character character) async {
    final fileName = '${character.name}.character';
    final content = jsonEncode(character.toJson());
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${character.name}',
    );
  }

  Future<void> duplicateCharacter(
      Character character, CharacterService service) async {
    await service.duplicateCharacter(character);
  }

  Future<Character?> importCharacter(
    Future<Character?> Function() pickFile,
    CharacterService service,
  ) async {
    final character = await pickFile();
    if (character != null) {
      await service.saveCharacter(character);
    }
    return character;
  }

  Future<void> exportCharacterToPdf(
      Character character, BuildContext context) async {
    await PdfExportManager.exportCharacterWithDialog(context, character);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
