import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/mixins/tag_mixin.dart';
import 'package:flutter/material.dart';

class TagFilter extends StatelessWidget with TagMixin {
  final List<String> tags;
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;
  final BuildContext context;
  final bool showAllOption;
  final bool isForCharacters;

  const TagFilter({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
    required this.context,
    this.showAllOption = true,
    this.isForCharacters = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    final standardTags = isForCharacters
        ? [
            s.male,
            s.female,
            s.another,
            s.children,
            s.young,
            s.adults,
            s.elderly,
            s.a_to_z,
            s.z_to_a,
            s.age_asc,
            s.age_desc,
          ]
        : [];

    final regularTags = tags
        .where((tag) =>
            !isFolderTag(tag) &&
            (!isForCharacters || !standardTags.contains(tag)))
        .toList();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (showAllOption)
          ...regularTags.map((tag) => _buildExpressiveChip(
                label: tag,
                isSelected: selectedTag == tag,
                onSelected: (selected) => onTagSelected(selected ? tag : null),
                icon: null,
                color: colorScheme.secondaryContainer,
              )),
          if (isForCharacters)
            ...standardTags.map((tag) => _buildExpressiveChip(
                  label: tag,
                  isSelected: selectedTag == tag,
                  onSelected: (selected) =>
                      onTagSelected(selected ? tag : null),
                  icon: null,
                  color: colorScheme.tertiaryContainer,
                )),
        ],
      ),
    );
  }

  Widget _buildExpressiveChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
    required Color color,
    Widget? icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: onSelected,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isSelected
              ? BorderSide.none
              : BorderSide(
                  color: colorScheme.outline.withOpacity(0.38),
                  width: 1,
                ),
        ),
        showCheckmark: false,
        selectedColor: color,
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: isSelected ? 1 : 0,
        pressElevation: 1,
        labelPadding: EdgeInsets.zero,
      ),
    );
  }
}