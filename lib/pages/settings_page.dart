import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../generated/l10n.dart';
import '../models/character_model.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/google_drive_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final s = S.of(context);

    final currentLocale = localeProvider.locale ?? const Locale('ru');

    final supportedLocales = S.delegate.supportedLocales;
    final effectiveLocale = supportedLocales.contains(currentLocale)
        ? currentLocale
        : const Locale('ru');

    final CloudBackupService cloudBackupService = CloudBackupService();
    bool isBackingUp = false;
    bool isRestoring = false;

    String version = '1.5.5';

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
    });

    final Map<String, Color> accentColors = {
      'Синий': Color(0xFF1E88E5),
      'Зеленый': Color(0xFF43A047),
      'Красный': Color(0xFFE53935),
      'Оранжевый': Color(0xFFFB8C00),
      'Фиолетовый': Color(0xFF8E24AA),
      'Розовый': Color(0xFFD81B60),
      'Бирюзовый': Color(0xFF00ACC1),
      'Голубой': Color(0xFF039BE5),
    };


    return Scaffold(
      appBar: AppBar(
        title: Text("Параметры"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Цветовая схема",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: Text("Системная"),
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text("Светлая"),
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text("Тёмная"),
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Divider(),
                      const SizedBox(height: 8),
                      Text(
                        "Цветовой акцент",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: accentColors.entries.map((entry) {
                          return ChoiceChip(
                            label: Text(entry.key),
                            selected: themeProvider.seedColor == entry.value,
                            onSelected: (selected) {
                              themeProvider.setSeedColor(entry.value);
                            },
                            selectedColor: entry.value,
                            labelStyle: TextStyle(
                              color: themeProvider.seedColor == entry.value
                                  ? Colors.white
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          /*Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Параметры языка",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<Locale>(
                    value: effectiveLocale,
                    isExpanded: true,
                    items: S.delegate.supportedLocales.map((locale) {
                      final languageCode = locale.languageCode;
                      final flag = _getFlag(languageCode);
                      final languageName = _getLanguageName(
                        languageCode,
                        effectiveLocale.languageCode,
                      );

                      return DropdownMenuItem<Locale>(
                        value: locale,
                        child: Row(
                          children: [
                            Text(flag),
                            const SizedBox(width: 8),
                            Text(languageName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) {
                        localeProvider.setLocale(newLocale);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),*/
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Резервное копирование",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        children: [
                          if (isBackingUp) ...[
                            const LinearProgressIndicator(),
                            const SizedBox(height: 8),
                          ],
                          OutlinedButton.icon(
                            icon: const Icon(Icons.save_alt),
                            label: const Text('Экспорт в Google Drive'),
                            onPressed: isBackingUp || isRestoring
                                ? null
                                : () async {
                              setState(() => isBackingUp = true);
                              try {
                                await cloudBackupService.exportAllToCloud(context);
                              } finally {
                                setState(() => isBackingUp = false);
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          if (isRestoring) ...[
                            const LinearProgressIndicator(),
                            const SizedBox(height: 8),
                          ],
                          OutlinedButton.icon(
                            icon: const Icon(Icons.restore),
                            label: const Text('Импорт из Google Drive'),
                            onPressed: isBackingUp || isRestoring
                                ? null
                                : () async {
                              setState(() => isRestoring = true);
                              try {
                                await cloudBackupService.importAllFromCloud(context);
                              } finally {
                                setState(() => isRestoring = false);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                  Text('Версия: $version',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _launchUrl('https://github.com/maxgog'),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: Image.asset('assets/underdeveloped.png'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                  Text('Данила Ганьков | Makoto🐼 | Максим Семенков | Артём Голубев | Евгений Стратий | '
                      'Никита Жевнерович | Участники EnA',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  String _getFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'ru':
        return '🇷🇺';
      default:
        return '🌐';
    }
  }

  String _getLanguageName(String languageCode, String currentLanguageCode) {
    switch (languageCode) {
      case 'en':
        return currentLanguageCode == 'ru' ? 'Английский' : 'English';
      case 'ru':
        return currentLanguageCode == 'ru' ? 'Русский' : 'Russian';
      default:
        return languageCode.toUpperCase();
    }
  }
}

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
  }
}