import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:flutter/material.dart';

class TemplateCardItem extends StatelessWidget {
  final QuestionnaireTemplate template;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMenuPressed;
  final bool enableDrag;
  final VoidCallback? onShare;
  final VoidCallback? onDuplicate;
  final VoidCallback? onSettings;

  const TemplateCardItem({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onMenuPressed,
    this.enableDrag = false,
    this.onShare,
    this.onDuplicate,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);
    final totalFields =
        template.standardFields.length + template.customFields.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withOpacity(0.25),
              colorScheme.tertiaryContainer.withOpacity(0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: enableDrag ? null : onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTemplateIcon(colorScheme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.fields_count(totalFields),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildFieldChip(
                            icon: Icons.checklist_rounded,
                            label:
                                '${template.standardFields.length} ${s.standard}',
                            containerColor: colorScheme.primaryContainer,
                            onContainerColor: colorScheme.onPrimaryContainer,
                          ),
                          _buildFieldChip(
                            icon: Icons.edit_rounded,
                            label:
                                '${template.customFields.length} ${s.custom}',
                            containerColor: colorScheme.tertiaryContainer,
                            onContainerColor: colorScheme.onTertiaryContainer,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert_rounded,
                      color: colorScheme.onSurfaceVariant),
                  onPressed: onMenuPressed,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateIcon(ColorScheme colorScheme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.library_books_rounded,
          color: colorScheme.primary, size: 20),
    );
  }

  Widget _buildFieldChip({
    required IconData icon,
    required String label,
    required Color containerColor,
    required Color onContainerColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: containerColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: onContainerColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: onContainerColor,
            ),
          ),
        ],
      ),
    );
  }
}
