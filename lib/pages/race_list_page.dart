import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:characterbook/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
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

        final matchesTag = _selectedTag == null; //||
            //(race.tags.contains(_selectedTag));

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
    final charactersBox = Hive.box<Character>('characters');
    final characters = charactersBox.values.toList();
    return characters.any((character) => character.race?.key == race.key);
  }

  Future<void> _deleteRace(Race race) async {
    final isUsed = await _isRaceUsed(race);
    if (isUsed) {
      _showRaceInUseDialog();
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed ?? false) {
      final box = Hive.box<Race>('races');
      await box.delete(race.key);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Раса удалена'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Удалить',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
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
    final text = '${race.name}\n\n${race.description}';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Раса скопирована в буфер'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _shareRaceAsFile(Race race) async {
    try {
      final jsonStr = jsonEncode(race.toJson());
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${race.name}_race.json');
      await file.writeAsString(jsonStr);
      await Share.shareXFiles([XFile(file.path)], text: 'Файл расы ${race.name}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
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
            Text(
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
      if (filePath == null) return;

      final file = File(filePath);
      final jsonStr = await file.readAsString();
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final race = Race.fromJson(jsonMap);

      final box = Hive.box<Race>('races');
      await box.add(race);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Раса успешно импортирована'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка импорта: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && result is Race) {
      final box = Hive.box<Race>('races');
      await box.add(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Раса импортирована из QR-кода'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          onChanged: (query) {
            final box = Hive.box<Race>('races');
            final allRaces = box.values.toList().cast<Race>();
            _filterRaces(query, allRaces);
          },
        )
            : Text(
          'Расы',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Race>>(
        valueListenable: Hive.box<Race>('races').listenable(),
        builder: (context, box, _) {
          final allRaces = box.values.toList().cast<Race>();
          final tags = _generateTags(allRaces);

          return Column(
            children: [
              if (tags.isNotEmpty)
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(tag),
                          selected: _selectedTag == tag,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTag = selected ? tag : null;
                              _filterRaces(_searchController.text, allRaces);
                            });
                          },
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: colorScheme.outline,
                            ),
                          ),
                          showCheckmark: false,
                          side: BorderSide.none,
                          selectedColor: colorScheme.secondaryContainer,
                          labelStyle: textTheme.labelLarge?.copyWith(
                            color: _selectedTag == tag
                                ? colorScheme.onSecondaryContainer
                                : colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Expanded(
                child: _buildRacesList(
                  _isSearching || _selectedTag != null
                      ? _filteredRaces
                      : allRaces,
                ),
              ),
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
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RaceManagementPage(),
                ),
              );
              if (result == true && mounted) {
                final box = Hive.box<Race>('races');
                final allRaces = box.values.toList().cast<Race>();
                _filterRaces(_searchController.text, allRaces);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRacesList(List<Race> races) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (races.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_people,
              size: 48,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? 'Ничего не найдено'
                  : 'Нет созданных рас',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
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
            side: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RaceManagementPage(race: race),
                ),
              );
              if (result == true && mounted) {
                final box = Hive.box<Race>('races');
                final allRaces = box.values.toList().cast<Race>();
                _filterRaces(_searchController.text, allRaces);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  race.logo != null
                      ? CircleAvatar(
                    backgroundImage: MemoryImage(race.logo!),
                    radius: 28,
                  )
                      : CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.emoji_people,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          race.name,
                          style: textTheme.bodyLarge,
                        ),
                        Text(
                          race.description.isNotEmpty
                              ? race.description
                              : 'Нет описания',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: colorScheme.onSurfaceVariant,
                    ),
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
          final barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            try {
              final jsonStr = barcode.rawValue ?? '';
              final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
              final race = Race.fromJson(jsonMap);
              Navigator.pop(context, race);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка: ${e.toString()}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}