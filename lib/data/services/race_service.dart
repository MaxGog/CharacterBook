import 'dart:async';
import 'dart:convert';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/services/pdf_export_manager.dart';
import 'package:characterbook/services/file_share_service.dart';
import 'package:characterbook/services/word_export_manager.dart';
import 'package:characterbook/ui/widgets/dialogs/error_dialog.dart';
import 'package:characterbook/ui/widgets/dialogs/loading_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RaceService extends ChangeNotifier {
  final RaceRepository _repository;

  RaceService(this._repository);

  Future<dynamic> saveRace(Race race, {dynamic key}) async {
    final result = await _repository.save(race, key: key);
    notifyListeners();
    return result;
  }

  Future<void> deleteRace(dynamic key) async {
    await _repository.delete(key);
    notifyListeners();
  }
  
  Future<List<Race>> getAllRaces() => _repository.getAll();
  Future<Race?> getRaceById(String id) => _repository.getById(id);
  Future<Race?> getRaceByKey(dynamic key) => _repository.getByKey(key);

  Future<void> deleteRaceById(String id) async {
    final race = await _repository.getById(id);
    if (race != null) await _repository.delete(race.key);
  }

  Future<List<Race>> getRacesByName(String name) async {
    final all = await _repository.getAll();
    return all
        .where((r) => r.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  Future<List<Race>> getRacesByTags(List<String> tags) async {
    final all = await _repository.getAll();
    return all.where((r) => r.tags.any((tag) => tags.contains(tag))).toList();
  }

  Future<List<Race>> getRacesByFolderId(String folderId) async {
    final all = await _repository.getAll();
    return all.where((r) => r.folderId == folderId).toList();
  }

  Future<List<Race>> getRacesWithoutFolder() async {
    final all = await _repository.getAll();
    return all.where((r) => r.folderId == null || r.folderId!.isEmpty).toList();
  }

  Future<void> updateRaceLogo(dynamic key, Uint8List? logoBytes) async {
    final race = await _repository.getByKey(key);
    if (race != null) {
      race.logo = logoBytes;
      await _repository.save(race, key: key);
    }
  }

  Future<void> updateRaceTags(dynamic key, List<String> tags) async {
    final race = await _repository.getByKey(key);
    if (race != null) {
      race.tags = tags;
      await _repository.save(race, key: key);
    }
  }

  Future<void> updateRaceFolder(dynamic key, String? folderId) async {
    final race = await _repository.getByKey(key);
    if (race != null) {
      race.folderId = folderId;
      await _repository.save(race, key: key);
    }
  }

  Future<int> getRacesCount() async => (await _repository.getAll()).length;

  Future<int> getRacesCountInFolder(String folderId) async =>
      (await _repository.getAll()).where((r) => r.folderId == folderId).length;

  Future<List<Race>> searchRaces(String query) async {
    final all = await _repository.getAll();
    final lower = query.toLowerCase();
    return all
        .where((r) =>
            r.name.toLowerCase().contains(lower) ||
            r.description.toLowerCase().contains(lower) ||
            r.biology.toLowerCase().contains(lower) ||
            r.backstory.toLowerCase().contains(lower) ||
            r.tags.any((t) => t.toLowerCase().contains(lower)))
        .toList();
  }

  Future<Set<String>> getAllUniqueTags() async {
    final all = await _repository.getAll();
    return all.expand((r) => r.tags).toSet();
  }

  Future<Map<String, int>> getPopularTags({int limit = 10}) async {
    final all = await _repository.getAll();
    final tagCounts = <String, int>{};
    for (final race in all) {
      for (final tag in race.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    final sorted = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(limit));
  }

  Future<Map<String, dynamic>> exportRaceToJson(dynamic key) async {
    final race = await _repository.getByKey(key);
    if (race == null) throw Exception('Race not found');
    return race.toJson();
  }

  Future<int> importRaceFromJson(Map<String, dynamic> json) async {
    final race = Race.fromJson(json);
    return (await _repository.save(race)) as int;
  }

  Future<List<int>> importRacesFromJsonList(
      List<Map<String, dynamic>> jsonList) async {
    final results = <int>[];
    for (final json in jsonList) {
      try {
        final race = Race.fromJson(json);
        final key = await _repository.save(race);
        results.add(key as int);
      } catch (e) {
        if (kDebugMode) print('Ошибка импорта расы: $e');
      }
    }
    return results;
  }

  Future<void> clearAllRaces() async {
    final all = await _repository.getAll();
    for (final race in all) {
      await _repository.delete(race.key);
    }
  }

  Future<List<Race>> getRacesPaginated({
    int page = 1,
    int pageSize = 20,
    String? folderId,
    List<String>? tags,
  }) async {
    List<Race> filtered = await _repository.getAll();
    if (folderId != null) {
      filtered = filtered.where((r) => r.folderId == folderId).toList();
    } else if (tags != null && tags.isNotEmpty) {
      filtered = filtered
          .where((r) => r.tags.any((tag) => tags.contains(tag)))
          .toList();
    }
    filtered.sort((a, b) => a.name.compareTo(b.name));
    final start = (page - 1) * pageSize;
    if (start >= filtered.length) return [];
    final end = start + pageSize;
    return filtered.sublist(
        start, end > filtered.length ? filtered.length : end);
  }

  Future<bool> doesRaceExist(String name, {String? excludeId}) async {
    final all = await _repository.getAll();
    return all
        .any((r) => r.name == name && (excludeId == null || r.id != excludeId));
  }

  Future<Map<String, dynamic>> getRacesStatistics() async {
    final all = await _repository.getAll();
    final total = all.length;
    final withLogo = all.where((r) => r.logo != null).length;
    final withFolder =
        all.where((r) => r.folderId != null && r.folderId!.isNotEmpty).length;
    final withTags = all.where((r) => r.tags.isNotEmpty).length;
    final avgTags =
        total == 0 ? 0 : all.fold(0, (sum, r) => sum + r.tags.length) / total;
    final mostCommonTag = _getMostCommonTag(all);
    return {
      'totalRaces': total,
      'racesWithLogo': withLogo,
      'racesWithFolder': withFolder,
      'racesWithTags': withTags,
      'averageTagsPerRace': avgTags,
      'mostCommonTag': mostCommonTag,
    };
  }

  String? _getMostCommonTag(List<Race> races) {
    final tagCounts = <String, int>{};
    for (final race in races) {
      for (final tag in race.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    if (tagCounts.isEmpty) return null;
    return tagCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Future<void> exportToPdf(BuildContext context, Race race) async {
    await PdfExportManager.exportRaceWithDialog(
      context,
      race,
      fileName: '${race.name}.pdf',
      shareText: 'Описание расы ${race.name}',
    );
  }

  Future<void> exportToJson(BuildContext context, Race race) async {
    try {
      showLoadingDialog(context: context, message: S.of(context).creating_file);
      final jsonStr = jsonEncode(race.toJson());
      final fileName =
          '${race.name}_${DateTime.now().millisecondsSinceEpoch}.race';
      if (context.mounted) hideLoadingDialog(context);
      await FileShareService.shareFile(
        Uint8List.fromList(jsonStr.codeUnits),
        fileName,
        text: 'Раса: ${race.name}',
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
            'Экспорт в JSON занял слишком много времени'),
      );
    } on TimeoutException {
      if (context.mounted) {
        hideLoadingDialog(context);
        _showErrorDialog(
            context, 'Таймаут', 'Экспорт в JSON занял слишком много времени');
      }
    } catch (e) {
      if (context.mounted) {
        hideLoadingDialog(context);
        _showErrorDialog(context, 'Ошибка экспорта',
            'Не удалось экспортировать в JSON: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        showErrorDialog(context: context, title: title, message: message);
      }
    });
  }

  Future<void> exportToWord(BuildContext context, Race race) async {
    await WordExportManager.exportRaceWithDialog(context, race);
  }
}
