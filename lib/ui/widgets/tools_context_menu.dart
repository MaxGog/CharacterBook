import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';

class ContextMenu extends StatelessWidget {
  final dynamic item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback onShare;
  final VoidCallback? onPin;
  final String? pinLabel;
  final IconData? pinIcon;

  const ContextMenu({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    this.onDuplicate,
    this.onPin,
    this.pinLabel,
    this.pinIcon,
  });

  factory ContextMenu.character({
    Key? key,
    required dynamic character,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onShare,
    VoidCallback? onDuplicate,
    VoidCallback? onPin,
    String? pinLabel,
    IconData? pinIcon,
  }) =>
      ContextMenu(
        key: key,
        item: character,
        onEdit: onEdit,
        onDelete: onDelete,
        onShare: onShare,
        onDuplicate: onDuplicate,
        onPin: onPin,
        pinLabel: pinLabel,
        pinIcon: pinIcon,
      );

  factory ContextMenu.race({
    Key? key,
    required dynamic race,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onShare,
    VoidCallback? onPin,
    String? pinLabel,
    IconData? pinIcon,
  }) =>
      ContextMenu(
        key: key,
        item: race,
        onEdit: onEdit,
        onDelete: onDelete,
        onShare: onShare,
        onPin: onPin,
        pinLabel: pinLabel,
        pinIcon: pinIcon,
      );

  factory ContextMenu.note({
    Key? key,
    required dynamic note,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onShare,
  }) =>
      ContextMenu(
        key: key,
        item: note,
        onEdit: onEdit,
        onDelete: onDelete,
        onShare: onShare,
      );

  factory ContextMenu.template({
    Key? key,
    required dynamic template,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onShare,
  }) =>
      ContextMenu(
        key: key,
        item: template,
        onEdit: onEdit,
        onDelete: onDelete,
        onShare: onShare,
      );

  factory ContextMenu.relationship({
    Key? key,
    required dynamic relationship,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onShare,
  }) =>
      ContextMenu(
        key: key,
        item: relationship,
        onEdit: onEdit,
        onDelete: onDelete,
        onShare: onShare,
      );

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    final List<Widget> items = [];

    items.add(_buildMenuItem(
      context: context,
      icon: Icons.edit_rounded,
      label: s.edit,
      color: colorScheme.onSurface,
      onTap: () {
        Navigator.pop(context);
        onEdit();
      },
    ));

    if (onDuplicate != null) {
      items.add(_buildMenuItem(
        context: context,
        icon: Icons.copy_all_rounded,
        label: s.duplicate,
        color: colorScheme.onSurface,
        onTap: () {
          Navigator.pop(context);
          onDuplicate!();
        },
      ));
    }

    if (onPin != null && pinLabel != null && pinIcon != null) {
      items.add(Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outlineVariant,
        indent: 16,
        endIndent: 16,
      ));
      items.add(_buildMenuItem(
        context: context,
        icon: pinIcon!,
        label: pinLabel!,
        color: colorScheme.onSurface,
        onTap: () {
          Navigator.pop(context);
          onPin!();
        },
      ));
    }

    items.add(Divider(
      height: 1,
      thickness: 1,
      color: colorScheme.outlineVariant,
      indent: 16,
      endIndent: 16,
    ));

    items.add(_buildMenuItem(
      context: context,
      icon: Icons.share_rounded,
      label: s.share,
      color: colorScheme.onSurface,
      onTap: () {
        Navigator.pop(context); // закрываем меню
        onShare(); // экран сам покажет диалог
      },
    ));

    items.add(Divider(
      height: 1,
      thickness: 1,
      color: colorScheme.outlineVariant,
      indent: 16,
      endIndent: 16,
    ));
    items.add(_buildMenuItem(
      context: context,
      icon: Icons.delete_rounded,
      label: s.delete,
      color: colorScheme.error,
      onTap: () {
        Navigator.pop(context);
        onDelete();
      },
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(28),
        color: colorScheme.surfaceContainerHigh,
        child: Column(mainAxisSize: MainAxisSize.min, children: items),
      ),
    );
  }
}
