import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Параметры"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSettingsCard(context, themeProvider),
          const SizedBox(height: 16),
          _buildBackupSettingsCard(context),
          const SizedBox(height: 16),
          _buildAboutCard(context),
          const SizedBox(height: 16),
          _buildAcknowledgementsCard(context),
        ],
      ),
    );
  }

  Widget _buildThemeSettingsCard(BuildContext context, ThemeProvider themeProvider) {
    final accentColors = const {
      'Синий': Color(0xFF1E88E5),
      'Зеленый': Color(0xFF43A047),
      'Красный': Color(0xFFE53935),
      'Оранжевый': Color(0xFFFB8C00),
      'Фиолетовый': Color(0xFF8E24AA),
      'Розовый': Color(0xFFD81B60),
      'Бирюзовый': Color(0xFF00ACC1),
      'Голубой': Color(0xFF039BE5),
    };

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Цветовая схема",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                _buildThemeRadioTile(themeProvider, ThemeMode.system, "Системная"),
                _buildThemeRadioTile(themeProvider, ThemeMode.light, "Светлая"),
                _buildThemeRadioTile(themeProvider, ThemeMode.dark, "Тёмная"),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  "Цветовой акцент",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: accentColors.entries.map((entry) => _buildColorChip(themeProvider, entry)).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  RadioListTile<ThemeMode> _buildThemeRadioTile(
      ThemeProvider themeProvider, ThemeMode mode, String title) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: mode,
      groupValue: themeProvider.themeMode,
      onChanged: (value) {
        if (value != null) themeProvider.setThemeMode(value);
      },
    );
  }

  ChoiceChip _buildColorChip(
      ThemeProvider themeProvider, MapEntry<String, Color> entry) {
    return ChoiceChip(
      label: Text(entry.key),
      selected: themeProvider.seedColor == entry.value,
      onSelected: (_) => themeProvider.setSeedColor(entry.value),
      selectedColor: entry.value,
      labelStyle: TextStyle(
        color: themeProvider.seedColor == entry.value ? Colors.white : null,
      ),
    );
  }

  Widget _buildBackupSettingsCard(BuildContext context) {
    final cloudBackupService = CloudBackupService();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Резервное копирование",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setState) {
                bool isBackingUp = false;
                bool isRestoring = false;

                return Column(
                  children: [
                    if (isBackingUp) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                    ],
                    OutlinedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Резервное копирование в Google Drive'),
                      onPressed: isBackingUp || isRestoring
                          ? null
                          : () => _handleBackupAction(
                          context, cloudBackupService.exportAllToCloud, setState, (v) => isBackingUp = v),
                    ),
                    const SizedBox(height: 8),
                    if (isRestoring) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                    ],
                    OutlinedButton.icon(
                      icon: const Icon(Icons.restore),
                      label: const Text('Восстановить из Google Drive'),
                      onPressed: isBackingUp || isRestoring
                          ? null
                          : () => _handleBackupAction(
                          context, cloudBackupService.importAllFromCloud, setState, (v) => isRestoring = v),
                    ),
                  ],
                );
              },
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
    } finally {
      setState(() => stateUpdater(false));
    }
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'О приложении',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: _getAppVersion(),
              builder: (context, snapshot) {
                return Text(
                  'Версия: ${snapshot.data ?? '1.5.6'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              },
            ),
            const SizedBox(height: 24),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _launchUrl('https://github.com/MaxGog/CharacterBook'),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Image.asset('assets/underdeveloped.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Widget _buildAcknowledgementsCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Благодарность',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Данила Ганьков | Makoto🐼 | Максим Семенков | Артём Голубев | '
                  'Евгений Стратий | Никита Жевнерович | Участники EnA',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}