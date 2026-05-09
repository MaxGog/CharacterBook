import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/services/app_navigator.dart';
import 'package:characterbook/services/clipboard_service.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/ui/controllers/race_modal_card_controller.dart';
import 'package:characterbook/ui/screens/races/race_management_screen.dart';
import 'package:characterbook/ui/widgets/dialogs/share_options_dialog.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'common_modal.dart';

class RaceModalCard extends StatelessWidget {
  final Race race;

  const RaceModalCard({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RaceModalController(
        race: race,
        raceRepo: context.read<RaceRepository>(),
        raceService: context.read<RaceService>(),
        clipboardService: context.read<ClipboardService>(),
      ),
      child: Consumer<RaceModalController>(
        builder: (context, controller, child) {
          return ModalScaffold(
            title: race.name,
            menuItems: _buildMenuItems(context, controller),
            onMenuItemSelected: (value) =>
                _onMenuItemSelected(context, controller, value),
            onClose: () => Navigator.pop(context),
            onEdit: () => _navigateToEdit(context),
            heroSection: HeroSection(
              avatarBytes: race.logo,
              name: race.name,
              chips: _buildChips(context, controller),
              onAvatarTap: race.logo != null
                  ? () => showFullImage(context, race.logo!, race.name)
                  : null,
              heroTag: 'modal-race-logo-${race.key}',
            ),
            contentSections: _buildContentSections(context, controller),
          );
        },
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(
      BuildContext context, RaceModalController controller) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return [
      PopupMenuItem(
        value: 'share',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading:
              Icon(Icons.share_outlined, color: colorScheme.onSurfaceVariant),
          title: Text(s.share),
        ),
      ),
      PopupMenuItem(
        value: 'copy',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading:
              Icon(Icons.copy_rounded, color: colorScheme.onSurfaceVariant),
          title: Text(s.copy),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'delete',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.delete_rounded, color: colorScheme.error),
          title: Text(s.delete, style: TextStyle(color: colorScheme.error)),
        ),
      ),
    ];
  }

  Future<void> _onMenuItemSelected(BuildContext context,
      RaceModalController controller, String value) async {
    switch (value) {
      case 'share':
        _showShareMenu(context, controller);
        break;
      case 'copy':
        await _handleCopy(context, controller);
        break;
      case 'delete':
        await _handleDelete(context, controller);
        break;
    }
  }

  void _showShareMenu(BuildContext context, RaceModalController controller) {
    var s = S.of(context);
    ShareOptionsDialog.show(
      context,
      onCopy: () async {
        try {
          await _handleCopy(context, controller);
          if (context.mounted) showSnackBar(context, s.copied_to_clipboard);
        } catch (e) {
          if (context.mounted) showSnackBar(context, '${s.copy_error}: $e');
        }
      },
      onShareFile: () async {
        try {
          await _handleExportJson(context, controller);
        } catch (e) {
          if (context.mounted) showSnackBar(context, '${s.error}: $e');
        }
      },
      onExportPdf: () async {
        try {
          await _handleExportPdf(context, controller);
        } catch (e) {
          if (context.mounted) showSnackBar(context, '${s.export_error}: $e');
        }
      },
      onExportWord: () async {
        try {
          await controller.exportRaceToWord(race, context);
        } catch (e) {
          if (context.mounted) AppNavigator.showError('${s.export_error}: $e');
        }
      },
    );
  }

  Future<void> _handleExportPdf(
      BuildContext context, RaceModalController controller) async {
    try {
      await controller.exportToPdf(context);
      _showSnackBar(context, S.of(context).pdf_export_success, isError: false);
    } catch (e) {
      _showSnackBar(context, '${S.of(context).export_error}: ${e.toString()}');
    }
  }

  Future<void> _handleExportJson(
      BuildContext context, RaceModalController controller) async {
    try {
      await controller.exportToJson(context);
      _showSnackBar(context, S.of(context).file_ready, isError: false);
    } catch (e) {
      _showSnackBar(context, '${S.of(context).export_error}: ${e.toString()}');
    }
  }

  Future<void> _handleCopy(
      BuildContext context, RaceModalController controller) async {
    try {
      await controller.copyToClipboard(context);
      _showSnackBar(context, S.of(context).copied_to_clipboard, isError: false);
    } catch (e) {
      _showSnackBar(context, '${S.of(context).copy_error}: ${e.toString()}');
    }
  }

  Future<void> _handleDelete(
      BuildContext context, RaceModalController controller) async {
    final s = S.of(context);
    final confirmed = await showConfirmationDialog(
      context: context,
      title: s.race_delete_title,
      message: s.race_delete_confirm,
      confirmText: s.delete,
      isDestructive: true,
    );
    if (confirmed == true) {
      try {
        await controller.deleteRace();
        if (context.mounted) {
          _showSnackBar(context, s.race_deleted, isError: false);
          Navigator.pop(context);
        }
      } catch (e) {
        _showSnackBar(context, '${s.delete_error}: ${e.toString()}');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RaceManagementScreen(race: race)),
    );
  }

  List<Widget> _buildChips(BuildContext context, RaceModalController controller) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      _buildChip(
        icon: Icons.update_rounded,
        label: DateFormat('dd.MM.yyyy').format(race.lastEdited),
        color: colorScheme.surfaceContainerHigh,
      ),
      ...race.tags.map((tag) => _buildChip(
            icon: Icons.label_outline_rounded,
            label: tag,
            color: colorScheme.surfaceContainerHighest,
          )),
    ];
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: SelectableText(label),
      backgroundColor: color,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildContentSections(
      BuildContext context, RaceModalController controller) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (race.description.isNotEmpty)
          ExpandableSection(
            title: s.description,
            icon: Icons.description_rounded,
            isExpanded: controller.expandedSections['description']!,
            onToggle: (_) => controller.toggleSection('description'),
            child: SelectableText(race.description,
                style: theme.textTheme.bodyLarge),
          ),
        if (race.biology.isNotEmpty)
          ExpandableSection(
            title: s.biology,
            icon: Icons.science_rounded,
            isExpanded: controller.expandedSections['biology']!,
            onToggle: (_) => controller.toggleSection('biology'),
            child:
                SelectableText(race.biology, style: theme.textTheme.bodyLarge),
          ),
        if (race.backstory.isNotEmpty)
          ExpandableSection(
            title: s.backstory,
            icon: Icons.history_edu_rounded,
            isExpanded: controller.expandedSections['backstory']!,
            onToggle: (_) => controller.toggleSection('backstory'),
            child: SelectableText(race.backstory,
                style: theme.textTheme.bodyLarge),
          ),
        if (controller.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
