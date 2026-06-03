import 'dart:async';
import 'package:characterbook/data/enums/tool_type_enum.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/services/pin_service.dart';
import 'package:characterbook/ui/screens/calendar_screen.dart';
import 'package:characterbook/ui/screens/characters/relationships_screen.dart';
import 'package:characterbook/ui/screens/settings/export_pdf_settings_screen.dart';
import 'package:characterbook/ui/screens/random_number_screen.dart';
import 'package:characterbook/ui/screens/templates/template_list_screen.dart';
import 'package:characterbook/ui/widgets/items/home_item.dart';
import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  final CharacterService _characterService;
  final RaceService _raceService;

  List<CharacterHomeItem> _characters = [];
  List<RaceHomeItem> _races = [];
  final List<ToolHomeItem> _tools = [];
  List<HomeItem> _filteredItems = [];
  String _searchQuery = '';

  Set<String> _pinnedIds = {};


  List<HomeItem> get filteredItems => _filteredItems;
  String get searchQuery => _searchQuery;
  bool get hasItems => _filteredItems.isNotEmpty;

  List<CharacterHomeItem> get characters => List.unmodifiable(_characters);
  List<RaceHomeItem> get races => List.unmodifiable(_races);
  List<ToolHomeItem> get tools => List.unmodifiable(_tools);

  List<HomeItem> get pinnedItems {
    return [
      ..._characters.where((c) => _pinnedIds.contains(c.character.id)),
      ..._races.where((r) => _pinnedIds.contains(r.race.id)),
    ];
  }

  HomeController({
    required CharacterService characterService,
    required RaceService raceService,
  })  : _characterService = characterService,
        _raceService = raceService {
    _initTools();
    _loadPinnedIds(); // загружаем сохранённые пины
  }

  void _initTools() {
    _tools.addAll([
      ToolHomeItem(
          type: ToolType.randomNumber, page: const RandomNumberScreen()),
      ToolHomeItem(
          type: ToolType.pdfExport, page: const ExportPdfSettingsScreen()),
      ToolHomeItem(type: ToolType.templates, page: const TemplatesListScreen()),
      ToolHomeItem(type: ToolType.calendar, page: const CalendarScreen()),
      ToolHomeItem(type: ToolType.relationships, page: RelationshipsScreen())
    ]);
  }

  Future<void> loadData() async {
    try {
      final characters = await _characterService.getAllCharacters();
      final races = await _raceService.getAllRaces();

      _characters = characters.map(CharacterHomeItem.new).toList();
      _races = races.map(RaceHomeItem.new).toList();
      _applyFilter();
    } catch (e) {
      rethrow;
    }
  }

  List<String> getAllNamesForSuggestions() {
    return [
      ..._characters.map((item) => item.character.name),
      ..._races.map((item) => item.race.name),
    ];
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _applyFilter();
  }

  void _applyFilter() {
    List<HomeItem> filteredCharactersAndRaces = [];
    if (_searchQuery.isEmpty) {
      filteredCharactersAndRaces = [..._characters, ..._races];
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      filteredCharactersAndRaces = [
        ..._characters.where(
            (item) => item.character.name.toLowerCase().contains(lowerQuery)),
        ..._races
            .where((item) => item.race.name.toLowerCase().contains(lowerQuery)),
      ];
    }
    _filteredItems = [...filteredCharactersAndRaces, ..._tools];
    notifyListeners();
  }

  int characterCountForRace(Race race) {
    return _characters
        .where((item) => item.character.race?.id == race.id)
        .length;
  }

  Future<void> deleteItem(HomeItem item) async {
    final originalCharacters = List<CharacterHomeItem>.from(_characters);
    final originalRaces = List<RaceHomeItem>.from(_races);

    if (item is CharacterHomeItem) {
      _characters.remove(item);
      _pinnedIds.remove(item.character.id);
    } else if (item is RaceHomeItem) {
      _races.remove(item);
      _pinnedIds.remove(item.race.id);
    } else {
      return;
    }

    _applyFilter();
    await _savePinnedIds();

    try {
      if (item is CharacterHomeItem) {
        await _characterService.deleteCharacter(item.character);
      } else if (item is RaceHomeItem) {
        await _raceService.deleteRace(item.race.key);
      }
    } catch (e) {
      _characters = originalCharacters;
      _races = originalRaces;
      _applyFilter();
      rethrow;
    }
  }

  int get itemCount => _filteredItems.length;

  Future<void> _loadPinnedIds() async {
    _pinnedIds = await PinService.loadPinnedIds();
    notifyListeners();
  }

  Future<void> _savePinnedIds() async {
    await PinService.savePinnedIds(_pinnedIds);
  }

  void togglePin(HomeItem item) {
    final id = item.id;
    if (_pinnedIds.contains(id)) {
      _pinnedIds.remove(id);
    } else {
      _pinnedIds.add(id);
    }
    _savePinnedIds();
    notifyListeners();
  }

  void unpinItem(HomeItem item) {
    _pinnedIds.remove(item.id);
    _savePinnedIds();
    notifyListeners();
  }

  bool isPinned(HomeItem item) => _pinnedIds.contains(item.id);
}
