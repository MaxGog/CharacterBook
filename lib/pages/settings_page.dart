import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final s = S.of(context)!;

    final currentLocale = localeProvider.locale ?? const Locale('ru');

    final supportedLocales = S.delegate.supportedLocales;
    final effectiveLocale = supportedLocales.contains(currentLocale)
        ? currentLocale
        : const Locale('ru');

    return Scaffold(
      appBar: AppBar(
        title: Text("Параметры"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
          ),*/
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