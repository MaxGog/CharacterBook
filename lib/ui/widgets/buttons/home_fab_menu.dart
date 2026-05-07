import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeFloatingMenu extends StatefulWidget {
  final VoidCallback onCreateCharacter;
  final VoidCallback onCreateRace;
  final VoidCallback onCreateNote;

  const HomeFloatingMenu({
    super.key,
    required this.onCreateCharacter,
    required this.onCreateRace,
    required this.onCreateNote,
  });

  @override
  State<HomeFloatingMenu> createState() => _HomeFloatingMenuState();
}

class _HomeFloatingMenuState extends State<HomeFloatingMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

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

  void _handleAction(VoidCallback action) {
    _toggleExpanded();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildMenuItems(),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'home_fab_menu',
          onPressed: _toggleExpanded,
          tooltip: s.create,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor:
              _isExpanded ? colorScheme.secondary : colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: _isExpanded
                ? const Icon(Icons.close_rounded, key: ValueKey('close'))
                : const Icon(Icons.add_rounded, key: ValueKey('add')),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    final s = S.of(context);
    final theme = Theme.of(context);

    final menuItems = [
      _MenuItemData(
        icon: Icons.person_add_rounded,
        label: s.new_character,
        onTap: () => _handleAction(widget.onCreateCharacter),
      ),
      _MenuItemData(
        icon: Icons.group_add_rounded,
        label: s.new_race,
        onTap: () => _handleAction(widget.onCreateRace),
      ),
      _MenuItemData(
        icon: Icons.note_add_rounded,
        label: s.new_note,
        onTap: () => _handleAction(widget.onCreateNote),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: menuItems
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final item = entry.value;

            final animation = CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.1 +
                    (0.2 * index),
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
                  child: _buildMenuItem(item, theme),
                ),
              ),
            );
          })
          .toList()
          .reversed
          .toList(),
    );
  }

  Widget _buildMenuItem(_MenuItemData item, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: theme.colorScheme.secondary.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
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
              Icon(item.icon, color: theme.colorScheme.secondary, size: 20),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItemData({required this.icon, required this.label, required this.onTap});
}
