import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/google_drive_service.dart';
import '../../generated/l10n.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settings),
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildLanguageSection(context, colorScheme, s),
          const SizedBox(height: 8),
          _buildThemeSection(context, themeProvider, colorScheme, s),
          const SizedBox(height: 8),
          _buildBackupSection(context, colorScheme, s),
          const SizedBox(height: 8),
          _buildAboutSection(context, colorScheme, s),
          const SizedBox(height: 8),
          _buildAcknowledgementsSection(context, colorScheme, s),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeProvider themeProvider, ColorScheme colorScheme, S s) {
    final accentColors = {
      s.system: Theme.of(context).colorScheme.primary,
      s.blue: Colors.blue,
      s.green: Colors.green,
      s.red: Colors.red,
      s.orange: Colors.orange,
      s.purple: Colors.purple,
      s.pink: Colors.pink,
      s.teal: Colors.teal,
      s.lightBlue: Colors.lightBlue,
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
                s.theme.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildThemeListTile(themeProvider, ThemeMode.system, s.system, Icons.phone_android),
            _buildThemeListTile(themeProvider, ThemeMode.light, s.light, Icons.light_mode),
            _buildThemeListTile(themeProvider, ThemeMode.dark, s.dark, Icons.dark_mode),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                s.accentColor.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
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

  Widget _buildBackupSection(BuildContext context, ColorScheme colorScheme, S s) {
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
                s.backup.toUpperCase(),
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
                      label: Text(s.createBackup),
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
                      label: Text(s.restoreData),
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

  Widget _buildAboutSection(BuildContext context, ColorScheme colorScheme, S s) {
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
                s.aboutApp.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
                leading: const Icon(Icons.title),
                title: Text(s.name),
                trailing: Text(
                  s.app_name,
                  style: Theme.of(context).textTheme.bodyLarge,
                )
            ),
            const SizedBox(height: 8),
            ListTile(
                leading: const Icon(Icons.developer_mode),
                title: Text(s.developer),
                trailing: Text(
                  'Максим Гоглов',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(s.version),
              trailing: FutureBuilder<String>(
                future: _getAppVersion(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '1.5.9',
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
                        s.githubRepo,
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

  Widget _buildAcknowledgementsSection(BuildContext context, ColorScheme colorScheme, S s) {
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
                s.acknowledgements.toUpperCase(),
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

  Widget _buildLanguageSection(BuildContext context, ColorScheme colorScheme, S s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                s.language.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.language,
                  color: colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              title: Text(
                s.language,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              trailing: DropdownButton<Locale>(
                value: Provider.of<LocaleProvider>(context).locale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    Provider.of<LocaleProvider>(context, listen: false)
                        .setLocale(newLocale);
                  }
                },
                items: S.delegate.supportedLocales.map((Locale locale) {
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Text(
                      _displayName(locale),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }).toList(),
                underline: Container(),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: colorScheme.surfaceContainerHigh,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurfaceVariant,
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              minLeadingWidth: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
            content: Text(S.of(context).operationCompleted),
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
            content: Text('${S.of(context).error}: ${e.toString()}'),
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

  String _displayName(Locale locale) {
    switch (locale.languageCode) {
      case 'ru': return 'Русский';
      case 'en': return 'English';
      default: return locale.languageCode;
    }
  }
}

extension ColorExtension on Color {
  Color get contrastTextColor {
    final brightness = ThemeData.estimateBrightnessForColor(this);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}