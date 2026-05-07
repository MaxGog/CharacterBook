import 'package:characterbook/ui/widgets/easter_egg_helper.dart';
import 'package:characterbook/ui/widgets/sections/about_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/controllers/settings_controller.dart';
import 'package:characterbook/ui/widgets/sections/settings_section.dart';
import 'package:characterbook/services/file_picker_service.dart';
import 'package:characterbook/services/backup_service.dart';
import 'package:characterbook/providers/locale_provider.dart';
import 'package:characterbook/providers/theme_provider.dart';
import 'package:flutter/services.dart';

import 'export_pdf_settings_screen.dart';
import 'swipe_action_settings_screen.dart';
import 'theme_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController _controller;
  bool _showEasterEgg = false;

  @override
  void initState() {
    super.initState();
    final localeProvider = context.read<LocaleProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final filePickerService = context.read<FilePickerService>();
    final cloudBackupService = context.read<CloudBackupService>();
    final localBackupService = context.read<LocalBackupService>();

    _controller = SettingsController(
      localeProvider: localeProvider,
      themeProvider: themeProvider,
      filePickerService: filePickerService,
      cloudBackupService: cloudBackupService,
      localBackupService: localBackupService,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: ChangeNotifierProvider.value(
          value: _controller,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar.large(
                    title: Text(s.settings),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _LanguageSection(),
                          const SizedBox(height: 8),
                          _ThemeSection(),
                          const SizedBox(height: 8),
                          _SwipeActionsSection(),
                          const SizedBox(height: 8),
                          _ExportPdfSettingsSection(),
                          const SizedBox(height: 8),
                          _BackupSection(),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showEasterEgg = true;
                              });
                            },
                            child: _buildAboutSection(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_showEasterEgg)
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: EasterEggHelper(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final s = S.of(context);
    return SettingsSection(title: s.about, children: [AboutSection()]);
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SettingsSection(
      title: s.appLanguage,
      children: const [_LanguageSelector()],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return ListTile(
      leading: Icon(Icons.language, color: colorScheme.onSurfaceVariant),
      title: Text(s.language),
      trailing: SizedBox(
        width: 120,
        child: DropdownButton<Locale>(
          value: controller.locale,
          onChanged: (Locale? newLocale) {
            if (newLocale != null) controller.setLocale(newLocale);
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
          selectedItemBuilder: (BuildContext context) {
            return S.delegate.supportedLocales.map<Widget>((Locale locale) {
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _displayName(locale),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          isExpanded: true,
          underline: Container(),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: colorScheme.surfaceContainerHigh,
          icon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.arrow_drop_down,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          iconSize: 24,
          alignment: Alignment.centerRight,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

String _displayName(Locale locale) {
  switch (locale.languageCode) {
    case 'ru':
      return 'Русский';
    case 'en':
      return 'English';
    default:
      return locale.languageCode;
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsSection(
      title: s.theme,
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.palette_outlined,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(s.customize_theme),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _SwipeActionsSection extends StatelessWidget {
  const _SwipeActionsSection();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SettingsSection(
      title: s.swipeActions,
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.swipe,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            s.configureSwipeActions,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SwipeActionSettingsScreen(),
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _BackupSection extends StatelessWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SettingsSection(
      title: s.backup,
      children: const [_BackupButtons()],
    );
  }
}

class _BackupButtons extends StatelessWidget {
  const _BackupButtons();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final s = S.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.backup_to_file, style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: controller.isLocalBackupExporting
                    ? null
                    : controller.exportLocalBackup,
                icon: controller.isLocalBackupExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.backup),
                label: Text(s.export),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: controller.isLocalBackupImporting
                    ? null
                    : controller.importLocalBackup,
                icon: controller.isLocalBackupImporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.restore),
                label: Text(s.import),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(s.backup_to_cloud, style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: controller.isCloudBackupExporting
                    ? null
                    : controller.exportCloudBackup,
                icon: controller.isCloudBackupExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload),
                label: Text(s.export),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: controller.isCloudBackupImporting
                    ? null
                    : controller.importCloudBackup,
                icon: controller.isCloudBackupImporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_download),
                label: Text(s.import),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExportPdfSettingsSection extends StatelessWidget {
  const _ExportPdfSettingsSection();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsSection(
      title: s.export_pdf_settings,
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            s.export_pdf_settings,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExportPdfSettingsScreen()),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
