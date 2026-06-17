import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/ui/widgets/avatar_widget.dart';
import 'package:characterbook/ui/widgets/items/commod_card_item.dart';
import 'package:flutter/material.dart';
import 'package:characterbook/generated/l10n.dart';

class RaceCardItem extends StatelessWidget {
  final Race race;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool enableDrag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onDuplicate;
  final VoidCallback? onSettings;

  const RaceCardItem({
    super.key,
    required this.race,
    this.isSelected = false,
    required this.onTap,
    this.enableDrag = false,
    this.onLongPress,
    required this.onEdit,
    required this.onDelete,
    this.onShare,
    this.onDuplicate,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    return CommonCardItem(
      id: race.id,
      isSelected: isSelected,
      onTap: onTap,
      onLongPress: enableDrag ? null : onLongPress,
      onEdit: onEdit,
      onDelete: onDelete,
      onShare: onShare,
      onDuplicate: onDuplicate,
      onSettings: onSettings,
      deleteConfirmationMessage: s.deleteConfirmation,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AvatarWidget.race(
              imageBytes: race.logo,
              size: 34,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    race.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (race.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      race.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (race.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: race.tags
                          .map((tag) => _buildTagChip(tag, colorScheme))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
