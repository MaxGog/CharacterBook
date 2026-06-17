import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/ui/widgets/items/commod_card_item.dart';
import 'package:flutter/material.dart';
import 'package:characterbook/generated/l10n.dart';

class NoteCardItem extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool enableDrag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onDuplicate;
  final VoidCallback? onSettings;

  const NoteCardItem({
    super.key,
    required this.note,
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
      id: note.id,
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.note_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    note.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      note.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (note.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: note.tags
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
