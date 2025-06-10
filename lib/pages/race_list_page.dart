import 'dart:convert';
import 'dart:io';
import 'package:characterbook/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/character_model.dart';
import '../models/race_model.dart';
import 'race_management_page.dart';

class RaceListPage extends StatefulWidget {
  const RaceListPage({super.key});

  @override
  State<RaceListPage> createState() => _RaceListPageState();
}

class _RaceListPageState extends State<RaceListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Race> _filteredRaces = [];
  bool _isSearching = false;
  String? _selectedTag;

  List<String> _generateTags(List<Race> races) {
    final tags = <String>{};
    for (final race in races) {
      //if (race.tags.isNotEmpty) {
      //  tags.addAll(race.tags);
      //}
    }
    return tags.toList()..sort();
  }

  void _filterRaces(String query, List<Race> allRaces) {
    setState(() {
      _filteredRaces = allRaces.where((race) {
        final matchesSearch = query.isEmpty ||
            race.name.toLowerCase().contains(query.toLowerCase()) ||
            race.description.toLowerCase().contains(query.toLowerCase());

        final matchesTag = _selectedTag == null; //|| (race.tags.contains(_selectedTag));

        return matchesSearch && matchesTag;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _isRaceUsed(Race race) async {
    final characters = Hive.box<Character>('characters').values;
    return characters.any((character) => character.race?.key == race.key);
  }

  Future<void> _deleteRace(Race race) async {
    if (await _isRaceUsed(race)) {
      if (mounted) _showRaceInUseDialog();
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed ?? false) {
      await Hive.box<Race>('races').delete(race.key);
      if (mounted) _showSnackBar('Раса удалена');
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    if (!mounted) return false;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление расы'),
        content: const Text('Вы уверены, что хотите удалить эту расу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Удалить',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showRaceInUseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Невозможно удалить расу'),
        content: const Text('Эта раса используется персонажами. Сначала измените их расу.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyRaceToClipboard(Race race) async {
    await Clipboard.setData(ClipboardData(text: '${race.name}\n\n${race.description}'));
    if (mounted) _showSnackBar('Раса скопирована в буфер');
  }

  Future<void> _shareRaceAsFile(Race race) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${race.name}_race.json');
      await file.writeAsString(jsonEncode(race.toJson()));
      await Share.shareXFiles([XFile(file.path)], text: 'Файл расы ${race.name}');
    } catch (e) {
      if (mounted) _showSnackBar('Ошибка: ${e.toString()}');
    }
  }

  void _showShareQRDialog(Race race) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR-код расы ${race.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: jsonEncode(race.toJson()),
              version: QrVersions.auto,
              size: 200,
            ),
            const SizedBox(height: 16),
            const Text(
              'Отсканируйте этот код для импорта расы',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _importRaceFromFile() async {
    try {
      final filePath = await _showFileSelectionDialog();
      if (filePath == null || !mounted) return;

      final file = File(filePath);
      final race = Race.fromJson(jsonDecode(await file.readAsString()));
      await Hive.box<Race>('races').add(race);

      _showSnackBar('Раса успешно импортирована');
    } catch (e) {
      if (mounted) _showSnackBar('Ошибка импорта: ${e.toString()}');
    }
  }

  Future<String?> _showFileSelectionDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Импорт расы'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Путь к файлу',
            hintText: 'Введите путь к файлу расы',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Импорт'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<Race>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && mounted) {
      await Hive.box<Race>('races').add(result);
      _showSnackBar('Раса импортирована из QR-кода');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Поиск рас...',
            border: InputBorder.none,
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          style: textTheme.bodyLarge,
          onChanged: (query) => _filterRaces(query, Hive.box<Race>('races').values.toList()),
        )
            : Text('Расы', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _selectedTag = null;
                  _filteredRaces = [];
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Race>>(
        valueListenable: Hive.box<Race>('races').listenable(),
        builder: (context, box, _) {
          final allRaces = box.values.toList();
          final tags = _generateTags(allRaces);
          final racesToShow = _isSearching || _selectedTag != null ? _filteredRaces : allRaces;

          return Column(
            children: [
              if (tags.isNotEmpty)
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: tags.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 4),
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      return FilterChip(
                        label: Text(tag),
                        selected: _selectedTag == tag,
                        onSelected: (selected) => setState(() {
                          _selectedTag = selected ? tag : null;
                          _filterRaces(_searchController.text, allRaces);
                        }),
                        shape: StadiumBorder(side: BorderSide(color: colorScheme.outline)),
                        showCheckmark: false,
                        side: BorderSide.none,
                        selectedColor: colorScheme.secondaryContainer,
                        labelStyle: textTheme.labelLarge?.copyWith(
                          color: _selectedTag == tag
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
                ),
              Expanded(child: _buildRacesList(racesToShow)),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'import_btn',
            onPressed: _importRaceFromFile,
            mini: true,
            tooltip: 'Импорт из файла',
            child: const Icon(Icons.file_upload),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'scan_btn',
            onPressed: _scanQRCode,
            mini: true,
            tooltip: 'Сканировать QR-код',
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_btn',
            child: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const RaceManagementPage()),
              );
              if (result == true && mounted) {
                _filterRaces(_searchController.text, Hive.box<Race>('races').values.toList());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRacesList(List<Race> races) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (races.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_people, size: 48, color: colorScheme.onSurface),
            const SizedBox(height: 16),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? 'Ничего не найдено'
                  : 'Нет созданных рас',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: races.length,
      itemBuilder: (context, index) {
        final race = races[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant, width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => RaceManagementPage(race: race)),
              );
              if (result == true && mounted) {
                _filterRaces(_searchController.text, Hive.box<Race>('races').values.toList());
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildRaceAvatar(race, colorScheme),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(race.name, style: textTheme.bodyLarge),
                        Text(
                          race.description.isNotEmpty ? race.description : 'Нет описания',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: colorScheme.onSurfaceVariant),
                    onPressed: () => _deleteRace(race),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRaceAvatar(Race race, ColorScheme colorScheme) {
    return race.logo != null
        ? CircleAvatar(backgroundImage: MemoryImage(race.logo!), radius: 28)
        : CircleAvatar(
      radius: 28,
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.emoji_people, color: colorScheme.onSurfaceVariant),
    );
  }
}

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканирование QR-кода')),
      body: MobileScanner(
        controller: MobileScannerController(),
        onDetect: (capture) {
          for (final barcode in capture.barcodes) {
            try {
              final race = Race.fromJson(jsonDecode(barcode.rawValue ?? '{}'));
              Navigator.pop(context, race);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка: ${e.toString()}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            }
          }
        },
      ),
    );
  }
}