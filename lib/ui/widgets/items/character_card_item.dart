import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/ui/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

import 'commod_card_item.dart';

class CharacterCardItem extends StatelessWidget {
  final Character character;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onDuplicate;
  final VoidCallback? onSettings;
  final bool enableDrag;

  const CharacterCardItem({
    super.key,
    required this.character,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
    this.onShare,
    this.onDuplicate,
    this.onSettings,
    this.enableDrag = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    return CommonCardItem(
      id: character.id,
      isSelected: isSelected,
      onTap: onTap,
      onLongPress: enableDrag ? null : onLongPress,
      onEdit: onEdit,
      onDelete: onDelete,
      onDuplicate: onDuplicate,
      onSettings: onSettings,
      onShare: onShare,
      deleteConfirmationMessage: s.deleteConfirmation,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'list-character-avatar-${character.key ?? character.id}',
                  child: AvatarWidget.character(
                    imageBytes: character.imageBytes,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildInfoChip(
                            context,
                            icon: Icons.cake_rounded,
                            label: '${character.age} ${s.years}',
                            color: colorScheme.tertiaryContainer,
                          ),
                          _buildInfoChip(
                            context,
                            icon: _getGenderIcon(character.gender),
                            label: _getLocalizedGender(
                                context, character.gender),
                            color: _getGenderColor(context, character.gender),
                          ),
                          ...character.tags.map(
                            (tag) => _buildInfoChip(
                              context,
                              label: tag,
                              color: colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context,
      {IconData? icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 14, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _getLocalizedGender(BuildContext context, String genderKey) {
    final s = S.of(context);
    return switch (genderKey) {
      'male' => s.male,
      'female' => s.female,
      'another' => s.another,
      _ => genderKey,
    };
  }

  IconData _getGenderIcon(String genderKey) {
    return switch (genderKey) {
      'male' => Icons.male_rounded,
      'female' => Icons.female_rounded,
      _ => Icons.transgender_rounded,
    };
  }

  Color _getGenderColor(BuildContext context, String genderKey) {
    final theme = Theme.of(context);
    return switch (genderKey) {
      'male' => theme.colorScheme.primaryContainer,
      'female' => theme.colorScheme.errorContainer,
      _ => theme.colorScheme.secondaryContainer,
    };
  }

}
