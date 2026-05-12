import 'package:characterbook/data/models/custom_event_model.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';

class CustomEventCardItem extends StatelessWidget {
  final CustomEvent event;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomEventCardItem({
    super.key,
    required this.event,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shadowColor: Colors.transparent,
      surfaceTintColor: colorScheme.tertiaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.event_rounded,
                  color: colorScheme.onTertiaryContainer, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description,
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
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
              onPressed: onEdit,
              tooltip: s.edit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outlined, color: colorScheme.error),
              onPressed: onDelete,
              tooltip: s.delete,
            ),
          ],
        ),
      ),
    );
  }
}
