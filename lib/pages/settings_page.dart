import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../providers/theme_provider.dart';
import '../services/google_drive_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildThemeSection(context, themeProvider, colorScheme),
          const SizedBox(height: 8),
          _buildBackupSection(context, colorScheme),
          const SizedBox(height: 8),
          _buildAboutSection(context, colorScheme),
          const SizedBox(height: 8),
          _buildAcknowledgementsSection(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeProvider themeProvider, ColorScheme colorScheme) {
    final accentColors = {
      'Системный': Theme.of(context).colorScheme.primary,
      'Синий': Colors.blue,
      'Зеленый': Colors.green,
      'Красный': Colors.red,
      'Оранжевый': Colors.orange,
      'Фиолетовый': Colors.purple,
      'Розовый': Colors.pink,
      'Бирюзовый': Colors.teal,
      'Голубой': Colors.lightBlue,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "ТЕМА",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildThemeListTile(themeProvider, ThemeMode.system, "Системная", Icons.phone_android),
            _buildThemeListTile(themeProvider, ThemeMode.light, "Светлая", Icons.light_mode),
            _buildThemeListTile(themeProvider, ThemeMode.dark, "Тёмная", Icons.dark_mode),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "АКЦЕНТНЫЙ ЦВЕТ",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: accentColors.entries.map((entry) =>
                  _buildColorChoiceChip(themeProvider, entry, colorScheme)
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeListTile(
      ThemeProvider themeProvider,
      ThemeMode mode,
      String title,
      IconData icon
      ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Radio<ThemeMode>(
        value: mode,
        groupValue: themeProvider.themeMode,
        onChanged: (value) {
          if (value != null) themeProvider.setThemeMode(value);
        },
      ),
      onTap: () => themeProvider.setThemeMode(mode),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildColorChoiceChip(
      ThemeProvider themeProvider,
      MapEntry<String, Color> entry,
      ColorScheme colorScheme
      ) {
    return ChoiceChip(
      label: Text(entry.key),
      selected: themeProvider.seedColor == entry.value,
      onSelected: (_) => themeProvider.setSeedColor(entry.value),
      selectedColor: entry.value,
      labelStyle: TextStyle(
        color: themeProvider.seedColor == entry.value ?
        entry.value.contrastTextColor : colorScheme.onSurface,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      pressElevation: 0,
    );
  }

  Widget _buildBackupSection(BuildContext context, ColorScheme colorScheme) {
    final cloudBackupService = CloudBackupService();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "РЕЗЕРВНОЕ КОПИРОВАНИЕ",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                bool isBackingUp = false;
                bool isRestoring = false;

                return Column(
                  children: [
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Создать резервную копию'),
                      onPressed: isBackingUp || isRestoring
                          ? null
                          : () => _handleBackupAction(
                          context,
                          cloudBackupService.exportAllToCloud,
                          setState,
                              (v) => isBackingUp = v
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Восстановить данные'),
                      onPressed: isBackingUp || isRestoring
                          ? null
                          : () => _handleBackupAction(
                          context,
                          cloudBackupService.importAllFromCloud,
                          setState,
                              (v) => isRestoring = v
                      ),
                    ),
                    if (isBackingUp || isRestoring) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        color: colorScheme.primary,
                        backgroundColor: colorScheme.primaryContainer,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "О ПРИЛОЖЕНИИ",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('Название'),
              trailing: Text(
                'CharacterBook',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.developer_mode),
              title: const Text('Разработчик'),
              trailing: Text(
                'Максим Гоглов Алексеевич',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Версия'),
              trailing: FutureBuilder<String>(
                future: _getAppVersion(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '1.5.8',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _launchUrl('https://github.com/MaxGog/CharacterBook'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Image.asset('assets/underdeveloped.png'),
                      const SizedBox(height: 8),
                      Text(
                        'GitHub репозиторий',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcknowledgementsSection(BuildContext context, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "БЛАГОДАРНОСТИ",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Данила Ганьков | Makoto🐼 | Максим Семенков | Артём Голубев | '
                    'Евгений Стратий | Никита Жевнерович | Участники EnA',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBackupAction(
      BuildContext context,
      Future Function(BuildContext) action,
      StateSetter setState,
      Function(bool) stateUpdater,
      ) async {
    setState(() => stateUpdater(true));
    try {
      await action(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Операция выполнена успешно'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
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
    } finally {
      setState(() => stateUpdater(false));
    }
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

extension ColorExtension on Color {
  Color get contrastTextColor {
    final brightness = ThemeData.estimateBrightnessForColor(this);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}