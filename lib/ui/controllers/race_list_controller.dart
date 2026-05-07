import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:characterbook/data/enums/race_sort_enum.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/services/clipboard_service.dart';
import 'package:characterbook/services/pdf_export_manager.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class RaceListController extends ChangeNotifier {
  final RaceRepository _repository;
  List<Race> _all = [];
  List<Race> _filtered = [];
  String _searchQuery = '';
  String? _selectedTag;
  RaceSort _sort = RaceSort.nameAsc;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  RaceListController(this._repository) {
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

  List<Race> get filteredItems => _filtered;
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

  void setSort(RaceSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    _filtered = _all.where(_matchesSearchAndTag).toList();
    _sortItems();
    notifyListeners();
  }

  bool _matchesSearchAndTag(Race r) {
    final queryLower = _searchQuery.toLowerCase();
    final matchesSearch = _searchQuery.isEmpty ||
        r.name.toLowerCase().contains(queryLower) ||
        r.description.toLowerCase().contains(queryLower) ||
        r.tags.any((t) => t.toLowerCase().contains(queryLower));
    final matchesTag = _selectedTag == null || r.tags.contains(_selectedTag);
    return matchesSearch && matchesTag;
  }

  void _sortItems() {
    switch (_sort) {
      case RaceSort.nameAsc:
        _filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case RaceSort.nameDesc:
        _filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
  }

  Set<String> get allTags => _all.expand((r) => r.tags).toSet();

  Future<void> deleteRace(dynamic key) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.delete(key);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> raceClipboardText(Race race, BuildContext context) async {
    await ClipboardService.copyRaceToClipboard(
      context: context,
      name: race.name,
      description: race.description,
      biology: race.biology,
      backstory: race.backstory,
    );
  }

  Future<void> shareRaceAsFile(Race race) async {
    final fileName = '${race.name}.race';
    final content = jsonEncode(race.toJson());
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: race.name,
    );
  }

  Future<Race?> importRace(
    Future<Race?> Function() pickFile,
    RaceService service,
  ) async {
    final race = await pickFile();
    if (race != null) {
      await service.saveRace(race);
    }
    return race;
  }

  Future<void> exportRaceToPdf(Race race, BuildContext context) async {
    await PdfExportManager.exportRaceWithDialog(context, race);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    try {
      await _repository.reorder(oldIndex, newIndex);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
