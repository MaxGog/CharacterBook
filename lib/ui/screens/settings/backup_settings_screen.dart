import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/providers/auto_backup_provider.dart';
import 'package:characterbook/services/app_navigator.dart';
import 'package:characterbook/services/backup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  bool _isExportingLocal = false;
  bool _isImportingLocal = false;
  bool _isExportingCloud = false;
  bool _isImportingCloud = false;

  Future<bool> _hasData() async {
    final backupManager = context.read<BackupManager>();
    final data = await backupManager.getBackupData();
    return data.values.any((list) => list.isNotEmpty);
  }

  Future<void> _exportLocal() async {
    if (_isExportingLocal) return;
    setState(() => _isExportingLocal = true);
    try {
      final hasData = await _hasData();
      if (!hasData) {
        AppNavigator.showInfo(S.of(context).no_data_for_backup);
        return;
      }
      await context.read<LocalBackupService>().exportData();
    } catch (e) {
      AppNavigator.showError('${S.of(context).export_failed}: $e');
    } finally {
      if (mounted) setState(() => _isExportingLocal = false);
    }
  }

  Future<void> _exportCloud() async {
    if (_isExportingCloud) return;
    setState(() => _isExportingCloud = true);
    try {
      final hasData = await _hasData();
      if (!hasData) {
        AppNavigator.showInfo(S.of(context).no_data_for_backup);
        return;
      }
      await context.read<CloudBackupService>().exportData();
    } catch (e) {
      AppNavigator.showError('${S.of(context).export_failed}: $e');
    } finally {
      if (mounted) setState(() => _isExportingCloud = false);
    }
  }

  Future<void> _importLocal() async {
    if (_isImportingLocal) return;
    final confirmed = await _showRestoreWarning();
    if (confirmed != true) return;

    setState(() => _isImportingLocal = true);
    try {
      await context.read<LocalBackupService>().importData();
    } catch (e) {
      AppNavigator.showError('${S.of(context).import_failed}: $e');
    } finally {
      if (mounted) setState(() => _isImportingLocal = false);
    }
  }

  Future<void> _importCloud() async {
    if (_isImportingCloud) return;
    final confirmed = await _showRestoreWarning();
    if (confirmed != true) return;

    setState(() => _isImportingCloud = true);
    try {
      await context.read<CloudBackupService>().importData();
    } catch (e) {
      AppNavigator.showError('${S.of(context).import_failed}: $e');
    } finally {
      if (mounted) setState(() => _isImportingCloud = false);
    }
  }

  Future<bool?> _showRestoreWarning() {
    final s = S.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.restore_warning_title),
        content: Text(s.restore_warning_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.restore_confirm),
          ),
        ],
      ),
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
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(s.backup),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _BackupInfoCard(),
                    const SizedBox(height: 16),
                    _AutoBackupToggle(),
                    const SizedBox(height: 16),
                    _BackupActionsCard(
                      isExportingLocal: _isExportingLocal,
                      isImportingLocal: _isImportingLocal,
                      isExportingCloud: _isExportingCloud,
                      isImportingCloud: _isImportingCloud,
                      onExportLocal: _exportLocal,
                      onImportLocal: _importLocal,
                      onExportCloud: _exportCloud,
                      onImportCloud: _importCloud,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(s.backup_info_title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              s.backup_info_description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              s.backup_info_restore_warning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoBackupToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AutoBackupProvider>();
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(Icons.cloud_sync, color: theme.colorScheme.primary),
        title: Text(S.of(context).auto_cloud_backup_title),
        subtitle: Text(S.of(context).auto_cloud_backup_subtitle),
        value: provider.isEnabled,
        onChanged: (val) => provider.setEnabled(val),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _BackupActionsCard extends StatelessWidget {
  final bool isExportingLocal;
  final bool isImportingLocal;
  final bool isExportingCloud;
  final bool isImportingCloud;
  final VoidCallback onExportLocal;
  final VoidCallback onImportLocal;
  final VoidCallback onExportCloud;
  final VoidCallback onImportCloud;

  const _BackupActionsCard({
    required this.isExportingLocal,
    required this.isImportingLocal,
    required this.isExportingCloud,
    required this.isImportingCloud,
    required this.onExportLocal,
    required this.onImportLocal,
    required this.onExportCloud,
    required this.onImportCloud,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.local_backup,
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isExportingLocal ? null : onExportLocal,
                    icon: isExportingLocal
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_upload),
                    label: Text(s.export_to_file),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isImportingLocal ? null : onImportLocal,
                    icon: isImportingLocal
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download),
                    label: Text(s.import_from_file),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(s.cloud_backup,
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isExportingCloud ? null : onExportCloud,
                    icon: isExportingCloud
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(s.export_to_cloud),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isImportingCloud ? null : onImportCloud,
                    icon: isImportingCloud
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download),
                    label: Text(s.import_from_cloud),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
