import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _themeMode = ThemeMode.system;
  String _currentLanguage = 'ru';

  final Map<String, String> _supportedLanguages = const {
    'ru': 'Русский',
    'en': 'English',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
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
                  const Text(
                    'Цветовая схема',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<ThemeMode>(
                          title: const Text('Системная'),
                          value: ThemeMode.system,
                          groupValue: _themeMode,
                          onChanged: (value) {
                            setState(() {
                              _themeMode = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<ThemeMode>(
                          title: const Text('Светлая'),
                          value: ThemeMode.light,
                          groupValue: _themeMode,
                          onChanged: (value) {
                            setState(() {
                              _themeMode = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<ThemeMode>(
                          title: const Text('Тёмная'),
                          value: ThemeMode.dark,
                          groupValue: _themeMode,
                          onChanged: (value) {
                            setState(() {
                              _themeMode = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Язык приложения',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _currentLanguage,
                    isExpanded: true,
                    items: _supportedLanguages.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (String? newLanguage) {
                      if (newLanguage != null) {
                        setState(() {
                          _currentLanguage = newLanguage;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'О приложении',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Это приложение разработано для демонстрации возможностей Flutter. '
                        'Здесь вы можете настроить внешний вид приложения под свои предпочтения.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _launchUrl('https://github.com/yourusername/yourrepository'),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/underdeveloped.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'GitHub проекта',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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