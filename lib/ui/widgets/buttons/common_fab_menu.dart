import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';

enum FabColorScheme {
  primary,
  secondary,
  tertiary,
}

enum SingleFabType {
  regular,

  extended,

}

class CommonListFloatingButtons extends StatefulWidget {
  final VoidCallback? onImport;
  final VoidCallback? onAdd;
  final VoidCallback? onTemplate;
  final bool showImportButton;

  final String? importTooltip;
  final String? addTooltip;
  final String? templateTooltip;
  final String? createFromScratchTooltip;

  final String heroTag;

  final FabColorScheme fabColorScheme;

  final SingleFabType? singleFabType;

  final String? extendedLabel;

  const CommonListFloatingButtons({
    super.key,
    this.onImport,
    this.onAdd,
    this.onTemplate,
    this.showImportButton = true,
    this.importTooltip,
    this.addTooltip,
    this.templateTooltip,
    this.createFromScratchTooltip,
    required this.heroTag,
    this.fabColorScheme = FabColorScheme.primary,
    this.singleFabType,
    this.extendedLabel,
  });

  @override
  State<CommonListFloatingButtons> createState() =>
      _CommonListFloatingButtonsState();
}

class _CommonListFloatingButtonsState extends State<CommonListFloatingButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  int get _actionCount {
    int count = 0;
    if (widget.onAdd != null) count++;
    if (widget.onImport != null && widget.showImportButton) count++;
    if (widget.onTemplate != null) count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleAction(VoidCallback? action) {
    _toggleExpanded();
    if (action != null) {
      action();
    }
  }

  Widget _buildSingleAction() {
    final s = S.of(context);

    VoidCallback? onPressed;
    IconData icon;
    String tooltip;
    String? label;

    if (widget.onAdd != null) {
      onPressed = widget.onAdd;
      icon = Icons.create_rounded;
      tooltip = widget.addTooltip ?? s.create;
      label = widget.createFromScratchTooltip ?? s.create;
    } else if (widget.onImport != null && widget.showImportButton) {
      onPressed = widget.onImport;
      icon = Icons.download_rounded;
      tooltip = widget.importTooltip ?? s.import;
      label = widget.importTooltip ?? s.import;
    } else if (widget.onTemplate != null) {
      onPressed = widget.onTemplate;
      icon = Icons.library_books_rounded;
      tooltip = widget.templateTooltip ?? s.template;
      label = widget.templateTooltip ?? s.template;
    } else {
      return const SizedBox.shrink();
    }

    final useExtended = widget.singleFabType == SingleFabType.extended ||
        (widget.singleFabType == null && false);

    if (useExtended) {
      return FloatingActionButton.extended(
        heroTag: '${widget.heroTag}_extended',
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(widget.extendedLabel ?? label),
        tooltip: tooltip,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
    } else {
      return FloatingActionButton(
        heroTag: '${widget.heroTag}_single',
        onPressed: onPressed,
        tooltip: tooltip,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon),
      );
    }
  }

  Widget _buildFabMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IgnorePointer(
          ignoring: !_isExpanded,
          child: _buildMenuItems(),
        ),
        const SizedBox(height: 8),
        _buildMainFab(),
      ],
    );
  }

  Widget _buildMainFab() {
    final theme = Theme.of(context);
    final colorScheme = _getColorScheme(theme);

    return FloatingActionButton(
      heroTag: '${widget.heroTag}_main',
      onPressed: _toggleExpanded,
      tooltip: widget.addTooltip ?? S.of(context).create,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor:
          _isExpanded ? colorScheme.secondary : colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _isExpanded
            ? const Icon(Icons.close_rounded, key: ValueKey('close'))
            : const Icon(Icons.add_rounded, key: ValueKey('add')),
      ),
    );
  }

  Widget _buildMenuItems() {
    final s = S.of(context);

    final items = <Widget>[];

    if (widget.onAdd != null) {
      items.add(_buildMenuItem(
        icon: Icons.create_rounded,
        label: widget.createFromScratchTooltip ?? s.create,
        tooltip: widget.createFromScratchTooltip ?? s.create,
        onTap: () => _handleAction(widget.onAdd),
        index: 0,
      ));
    }

    if (widget.showImportButton && widget.onImport != null) {
      items.add(_buildMenuItem(
        icon: Icons.download_rounded,
        label: widget.importTooltip ?? s.import,
        tooltip: widget.importTooltip ?? s.import_template_tooltip,
        onTap: () => _handleAction(widget.onImport),
        index: 1,
      ));
    }

    if (widget.onTemplate != null) {
      items.add(_buildMenuItem(
        icon: Icons.library_books_rounded,
        label: widget.templateTooltip ?? s.template,
        tooltip: widget.templateTooltip ?? s.create_from_template_tooltip,
        onTap: () => _handleAction(widget.onTemplate),
        index: 2,
      ));
    }

    assert(items.length <= 6, 'FAB menu should contain 2–6 items');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: items.reversed.toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback onTap,
    required int index,
  }) {
    final theme = Theme.of(context);
    final colorScheme = _getColorScheme(theme);

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.1 + (0.2 * index),
        1.0,
        curve: Curves.easeOut,
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0.2),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(28),
              splashColor: colorScheme.secondary.withOpacity(0.1),
              highlightColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: colorScheme.secondary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ({Color onPrimary, Color onSecondary, Color primary, Color secondary, Color surfaceContainer}) _getColorScheme(ThemeData theme) {
    final base = theme.colorScheme;

    switch (widget.fabColorScheme) {
      case FabColorScheme.primary:
        return (
          primary: base.primary,
          onPrimary: base.onPrimary,
          secondary: base.secondary,
          onSecondary: base.onSecondary,
          surfaceContainer: base.surfaceContainer,
        );
      case FabColorScheme.secondary:
        return (
          primary: base.secondary,
          onPrimary: base.onSecondary,
          secondary: base.tertiary,
          onSecondary: base.onTertiary,
          surfaceContainer: base.surfaceContainer,
        );
      case FabColorScheme.tertiary:
        return (
          primary: base.tertiary,
          onPrimary: base.onTertiary,
          secondary: base.primary,
          onSecondary: base.onPrimary,
          surfaceContainer: base.surfaceContainer,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_actionCount == 0) return const SizedBox.shrink();

    if (_actionCount == 1) {
      return _buildSingleAction();
    }

    return _buildFabMenu();
  }
}
