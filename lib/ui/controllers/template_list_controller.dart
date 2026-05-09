import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:characterbook/data/enums/template_sort_enum.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/repositories/template_repository.dart';
import 'package:characterbook/services/word_export_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class TemplateListController extends ChangeNotifier {
  final TemplateRepository _repository;
  List<QuestionnaireTemplate> _all = [];
  List<QuestionnaireTemplate> _filtered = [];
  String _searchQuery = '';
  String? _selectedTag;
  TemplateSort _sort = TemplateSort.nameAsc;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _subscription;

  TemplateListController(this._repository) {
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

  List<QuestionnaireTemplate> get filteredItems => _filtered;
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

  void setSort(TemplateSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    _filtered = _all.where(_matchesSearchAndTag).toList();
    _sortItems();
    notifyListeners();
  }

  bool _matchesSearchAndTag(QuestionnaireTemplate t) {
    final queryLower = _searchQuery.toLowerCase();
    final matchesSearch = _searchQuery.isEmpty ||
        t.name.toLowerCase().contains(queryLower) ||
        t.standardFields.any((f) => f.toLowerCase().contains(queryLower)) ||
        t.customFields.any((f) =>
            f.key.toLowerCase().contains(queryLower) ||
            f.value.toLowerCase().contains(queryLower));
    final matchesTag = _selectedTag == null || true;
    return matchesSearch && matchesTag;
  }

  void _sortItems() {
    switch (_sort) {
      case TemplateSort.nameAsc:
        _filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case TemplateSort.nameDesc:
        _filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case TemplateSort.fieldsAsc:
        _filtered.sort((a, b) =>
            (a.standardFields.length + a.customFields.length)
                .compareTo(b.standardFields.length + b.customFields.length));
        break;
      case TemplateSort.fieldsDesc:
        _filtered.sort((a, b) =>
            (b.standardFields.length + b.customFields.length)
                .compareTo(a.standardFields.length + a.customFields.length));
        break;
    }
  }

  Set<String> get allTags =>
      const {};

  Future<void> deleteTemplate(QuestionnaireTemplate template) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.delete(template.name);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> templateClipboardText(QuestionnaireTemplate template, BuildContext context) async {
    final buffer = StringBuffer();
    buffer.writeln('Template: ${template.name}');
    buffer.writeln('Standard fields: ${template.standardFields.join(", ")}');
    buffer.writeln(
        'Custom fields: ${template.customFields.map((f) => "${f.key}: ${f.value}").join(", ")}');
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  Future<void> shareTemplateAsFile(QuestionnaireTemplate template) async {
    final fileName = '${template.name}.chax';
    final content = jsonEncode(template.toJson());
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: template.name,
    );
  }

  Future<void> exportTemplateToWord(QuestionnaireTemplate template, BuildContext context) async {
    await WordExportManager.exportTemplateWithDialog(context, template);
  }


  Future<void> reorder(int oldIndex, int newIndex) async {

  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
