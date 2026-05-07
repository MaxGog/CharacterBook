import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:flutter/material.dart';

import 'commod_card_item.dart';
class NoteCardItem extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool enableDrag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCardItem({
    super.key,
    required this.note,
    this.isSelected = false,
    required this.onTap,
    this.enableDrag = false,
    this.onLongPress,
    required this.onEdit,
    required this.onDelete,
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
      onLongPress: onLongPress,
      onEdit: onEdit,
      onDelete: onDelete,
      deleteConfirmationMessage: s.delete,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (note.content.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          note.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
}
