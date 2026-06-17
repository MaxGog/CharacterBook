import 'dart:async';
import 'package:characterbook/data/enums/tool_type_enum.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/providers/pins_provider.dart';
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
  final PinsProvider _pinsProvider;

  List<CharacterHomeItem> _characters = [];
  List<RaceHomeItem> _races = [];
  final List<ToolHomeItem> _tools = [];
  List<HomeItem> _filteredItems = [];
  String _searchQuery = '';

  List<HomeItem> get filteredItems => _filteredItems;
  String get searchQuery => _searchQuery;
  bool get hasItems => _filteredItems.isNotEmpty;

  List<CharacterHomeItem> get characters => List.unmodifiable(_characters);
  List<RaceHomeItem> get races => List.unmodifiable(_races);
  List<ToolHomeItem> get tools => List.unmodifiable(_tools);

  List<HomeItem> get pinnedItems {
    final pinnedIds = _pinsProvider.pinnedIds;
    return [
      ..._characters.where((c) => pinnedIds.contains(c.character.id)),
      ..._races.where((r) => pinnedIds.contains(r.race.id)),
    ];
  }

  HomeController({
    required CharacterService characterService,
    required RaceService raceService,
    required PinsProvider pinsProvider,
  })  : _characterService = characterService,
        _raceService = raceService,
        _pinsProvider = pinsProvider {
    _initTools();
    _pinsProvider.addListener(_onPinsChanged);
    _characterService.addListener(_onDataChanged);
    _raceService.addListener(_onDataChanged);
  }

  void _onDataChanged() => loadData();
  void _onPinsChanged() => notifyListeners();

  void _initTools() {
    _tools.addAll([
      ToolHomeItem(
          type: ToolType.randomNumber, page: const RandomNumberScreen()),
      ToolHomeItem(
          type: ToolType.pdfExport, page: const ExportPdfSettingsScreen()),
      ToolHomeItem(type: ToolType.templates, page: const TemplatesListScreen()),
      ToolHomeItem(type: ToolType.calendar, page: const CalendarScreen()),
      ToolHomeItem(type: ToolType.relationships, page: RelationshipsScreen()),
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
      _pinsProvider.setPinned(item.character.id, false);
    } else if (item is RaceHomeItem) {
      _races.remove(item);
      _pinsProvider.setPinned(item.race.id, false);
    }

    _applyFilter();

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

  Future<void> togglePin(HomeItem item) async {
    await _pinsProvider.togglePin(item.id);
  }

  void unpinItem(HomeItem item) {
    _pinsProvider.setPinned(item.id, false);
  }

  bool isPinned(HomeItem item) => _pinsProvider.isPinned(item.id);

  @override
  void dispose() {
    _pinsProvider.removeListener(_onPinsChanged);
    _characterService.removeListener(_onDataChanged);
    _raceService.removeListener(_onDataChanged);
    super.dispose();
  }
}
