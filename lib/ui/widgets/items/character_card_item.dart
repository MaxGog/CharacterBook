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
  final bool animateHero;

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
    this.animateHero = true,
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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.tertiaryContainer.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.4),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            HeroMode(
              enabled: animateHero,
              child: Hero(
                tag: 'character-avatar-${character.key ?? character.id}',
                child: AvatarWidget.character(
                  imageBytes: character.imageBytes,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    character.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (character.age > 0)
                        _buildInfoChip(
                          context,
                          icon: Icons.cake_rounded,
                          label: '${character.age} ${s.years}',
                          color: colorScheme.tertiaryContainer,
                        ),
                      _buildInfoChip(
                        context,
                        icon: _getGenderIcon(character.gender),
                        label: _getLocalizedGender(context, character.gender),
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
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context,
      {IconData? icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          width: 0.5,
        ),
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
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
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
