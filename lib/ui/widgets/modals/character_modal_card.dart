import 'dart:typed_data';

import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/services/clipboard_service.dart';
import 'package:characterbook/data/services/note_service.dart';
import 'package:characterbook/ui/controllers/character_modal_controller.dart';
import 'package:characterbook/ui/screens/characters/character_management_screen.dart';
import 'package:characterbook/ui/screens/notes/note_management_screen.dart';
import 'package:characterbook/ui/widgets/dialogs/share_options_dialog.dart';
import 'package:characterbook/ui/widgets/items/note_card_item.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'common_modal.dart';

class CharacterModalCard extends StatelessWidget {
  final Character character;

  const CharacterModalCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterModalController(
        character: character,
        characterRepo: context.read<CharacterRepository>(),
        noteRepo: context.read<NoteRepository>(),
        characterService: context.read<CharacterService>(),
        noteService: context.read<NoteService>(),
        clipboardService: context.read<ClipboardService>(),
      ),
      child: Consumer<CharacterModalController>(
        builder: (context, controller, child) {
          final s = S.of(context);

          final chips = _buildChips(context, controller);

          final menuItems = _buildMenuItems(context, controller);

          return ModalScaffold(
            title: character.name,
            menuItems: menuItems,
            onMenuItemSelected: (value) =>
                _onMenuItemSelected(context, controller, value),
            onClose: () => Navigator.pop(context),
            onEdit: () => _navigateToEdit(context),
            heroSection: HeroSection(
              avatarBytes: character.imageBytes,
              name: character.name,
              chips: chips,
              onAvatarTap: character.imageBytes != null
                  ? () => showFullImage(
                      context, character.imageBytes!, s.character_avatar)
                  : null,
              heroTag: 'character-avatar-${character.key}',
            ),
            contentSections: _buildContentSections(context, controller),
          );
        },
      ),
    );
  }

  List<Widget> _buildChips(
      BuildContext context, CharacterModalController controller) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final chips = <Widget>[
      if (character.age > 0)
        _buildChip(
          icon: Icons.cake_rounded,
          label: '${character.age} ${s.years}',
          color: colorScheme.tertiaryContainer,
        ),
      _buildChip(
        icon: _getGenderIcon(character.gender),
        label: _getLocalizedGender(character.gender, s),
        color: _getGenderColor(character.gender, colorScheme),
      ),
      if (character.race != null)
        _buildChip(
          icon: Icons.people_rounded,
          label: character.race!.name,
          color: colorScheme.surfaceContainerHigh,
        ),
      _buildChip(
        icon: Icons.update_rounded,
        label: DateFormat('dd.MM.yyyy').format(character.lastEdited),
        color: colorScheme.surfaceContainerHigh,
      ),
      ...character.tags.map((tag) => _buildChip(
            icon: Icons.label_outline_rounded,
            label: tag,
            color: colorScheme.surfaceContainerHighest,
          )),
    ];
    return chips;
  }

  Widget _buildChip(
      {required IconData icon, required String label, required Color color}) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label),
      backgroundColor: color,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  String _getLocalizedGender(String gender, S s) {
    return switch (gender) {
      'male' => s.male,
      'female' => s.female,
      'another' => s.another,
      _ => gender,
    };
  }

  Color _getGenderColor(String gender, ColorScheme colorScheme) {
    return switch (gender) {
      'male' => colorScheme.primaryContainer,
      'female' => colorScheme.tertiaryContainer,
      'another' => colorScheme.secondaryContainer,
      _ => colorScheme.surfaceContainerHighest,
    };
  }

  IconData _getGenderIcon(String gender) {
    return switch (gender) {
      'male' => Icons.male_rounded,
      'female' => Icons.female_rounded,
      _ => Icons.transgender_rounded,
    };
  }

  List<PopupMenuEntry<String>> _buildMenuItems(
      BuildContext context, CharacterModalController controller) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return [
      PopupMenuItem(
        value: 'share',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading:
              Icon(Icons.share_outlined, color: colorScheme.onSurfaceVariant),
          title: Text(s.share_character),
        ),
      ),
      PopupMenuItem(
        value: 'duplicate',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading:
              Icon(Icons.copy_all_rounded, color: colorScheme.onSurfaceVariant),
          title: Text(s.duplicate_character),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'delete',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.delete_rounded, color: colorScheme.error),
          title: Text(s.delete_character,
              style: TextStyle(color: colorScheme.error)),
        ),
      ),
    ];
  }

  Future<void> _onMenuItemSelected(BuildContext context,
      CharacterModalController controller, String value) async {
    switch (value) {
      case 'share':
        _showShareMenu(context, controller);
        break;
      case 'duplicate':
        await _handleDuplicate(context, controller);
        break;
      case 'delete':
        await _handleDelete(context, controller);
        break;
    }
  }

  void _showShareMenu(BuildContext context, CharacterModalController controller) {
    var s = S.of(context);
    ShareOptionsDialog.show(context,
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
    );
  }

  Future<void> _handleExportPdf(
      BuildContext context, CharacterModalController controller) async {
    try {
      await controller.exportToPdf(context);
      _showSnackBar(context, S.of(context).pdf_export_success, isError: false);
    } catch (e) {
      _showSnackBar(context, '${S.of(context).export_error}: ${e.toString()}');
    }
  }

  Future<void> _handleExportJson(
      BuildContext context, CharacterModalController controller) async {
    try {
      await controller.exportToJson(context);
      _showSnackBar(context, S.of(context).file_ready, isError: false);
    } catch (e) {
      _showSnackBar(context, '${S.of(context).export_error}: ${e.toString()}');
    }
  }

  Future<void> _handleCopy(
      BuildContext context, CharacterModalController controller) async {
    try {
      await controller.copyToClipboard(context);
      _showSnackBar(context, S.of(context).copied_to_clipboard, isError: false);
    } catch (e) {
      _showSnackBar(context, '${S.of(context).copy_error}: ${e.toString()}');
    }
  }

  Future<void> _handleDuplicate(
      BuildContext context, CharacterModalController controller) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await controller.duplicateCharacter();
      if (context.mounted) {
        Navigator.pop(context); // закрыть индикатор
        _showSnackBar(context, S.of(context).character_duplicated,
            isError: false);
        Navigator.pop(context); // закрыть модалку
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showSnackBar(
          context, '${S.of(context).duplicate_error}: ${e.toString()}');
    }
  }

  Future<void> _handleDelete(
      BuildContext context, CharacterModalController controller) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: S.of(context).character_delete_title,
      message: S.of(context).character_delete_confirm,
      confirmText: S.of(context).delete,
      isDestructive: true,
    );
    if (confirmed == true) {
      try {
        await controller.deleteCharacter();
        if (context.mounted) {
          _showSnackBar(context, S.of(context).character_deleted,
              isError: false);
          Navigator.pop(context);
        }
      } catch (e) {
        _showSnackBar(
            context, '${S.of(context).delete_error}: ${e.toString()}');
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
      MaterialPageRoute(
          builder: (context) => CharacterManagementScreen(character: character)),
    );
  }

  Widget _buildContentSections(
      BuildContext context, CharacterModalController controller) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Uint8List> allImages = [];
    if (character.referenceImageBytes != null) {
      allImages.add(character.referenceImageBytes!);
    }
    allImages.addAll(character.additionalImages);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allImages.isNotEmpty) ...[
          ExpandableSection(
            title: s.character_gallery,
            icon: Icons.photo_library_rounded,
            isExpanded: controller.expandedSections['gallery']!,
            onToggle: (_) => controller.toggleSection('gallery'),
            child: GallerySection(
              images: allImages,
              onImageTap: (bytes, title) =>
                  showFullImage(context, bytes, title),
              referenceImageLabel: character.referenceImageBytes != null
                  ? s.reference_image
                  : null,
            ),
          ),
        ],
        if (character.customFields.isNotEmpty) ...[
          ExpandableSection(
            title: s.custom_fields,
            icon: Icons.list_alt_rounded,
            isExpanded: controller.expandedSections['customFields']!,
            onToggle: (_) => controller.toggleSection('customFields'),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: character.customFields
                  .map((field) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(field.key,
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            SelectableText(field.value,
                                style: theme.textTheme.bodyLarge),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
        _buildExpandableTextSection(
            context,
            controller,
            'appearance',
            s.appearance,
            Icons.face_retouching_natural_rounded,
            character.appearance),
        _buildExpandableTextSection(context, controller, 'personality',
            s.personality, Icons.psychology_rounded, character.personality),
        _buildExpandableTextSection(context, controller, 'biography',
            s.biography, Icons.history_edu_rounded, character.biography),
        _buildExpandableTextSection(context, controller, 'abilities',
            s.abilities, Icons.auto_awesome_rounded, character.abilities),
        _buildExpandableTextSection(context, controller, 'other', s.other,
            Icons.more_horiz_rounded, character.other),
        if (controller.relatedNotes.isNotEmpty) ...[
          ExpandableSection(
            title: s.related_notes,
            icon: Icons.note_rounded,
            isExpanded: controller.expandedSections['notes']!,
            onToggle: (_) => controller.toggleSection('notes'),
            child: Column(
              children: controller.relatedNotes
                  .map((note) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: NoteCardItem(
                          key: ValueKey(note.id),
                          note: note,
                          onTap: () => _openNoteForEditing(context, note),
                          onEdit: () => _openNoteForEditing(context, note),
                          onDelete: () =>
                              _deleteNote(context, controller, note),
                          enableDrag: false,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
        if (controller.isLoading)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )),
      ],
    );
  }

  Widget _buildExpandableTextSection(
    BuildContext context,
    CharacterModalController controller,
    String key,
    String title,
    IconData icon,
    String content,
  ) {
    if (content.isEmpty) return const SizedBox.shrink();
    return ExpandableSection(
      title: title,
      icon: icon,
      isExpanded: controller.expandedSections[key]!,
      onToggle: (_) => controller.toggleSection(key),
      child:
          SelectableText(content, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  Future<void> _deleteNote(BuildContext context,
      CharacterModalController controller, Note note) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: S.of(context).delete,
      message: S.of(context).delete,
      confirmText: S.of(context).delete,
      isDestructive: true,
    );
    if (confirmed == true) {
      try {
        await controller.deleteNote(note);
        _showSnackBar(context, S.of(context).delete, isError: false);
      } catch (e) {
        _showSnackBar(
            context, '${S.of(context).delete_error}: ${e.toString()}');
      }
    }
  }

  Future<void> _openNoteForEditing(BuildContext context, Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteManagementScreen(note: note)),
    );
    if (result == true) {
      context.read<CharacterModalController>().refreshNotes();
    }
  }
}
