import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/controllers/home_controller.dart';
import 'package:characterbook/ui/widgets/items/home_item.dart';
import 'package:characterbook/ui/widgets/items/pinned_card_item.dart';
import 'package:flutter/material.dart';

class PinnedSection extends StatefulWidget {
  const PinnedSection({
    super.key, 
    required this.items,
    required this.allCharactersAndRaces,
    required this.controller,
    required this.onCharacterTap,
    required this.onCharacterContextMenu,
    required this.onRaceTap,
    required this.onRaceContextMenu,
  });

  final List<HomeItem> items;
  final List<HomeItem> allCharactersAndRaces;
  final HomeController controller;
  final void Function(CharacterHomeItem) onCharacterTap;
  final void Function(CharacterHomeItem) onCharacterContextMenu;
  final void Function(RaceHomeItem) onRaceTap;
  final void Function(RaceHomeItem) onRaceContextMenu;

  @override
  State<PinnedSection> createState() => _PinnedSectionState();
}

class _PinnedSectionState extends State<PinnedSection> {
  bool _isEditing = false;

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _addPin(HomeItem item) {
    widget.controller.togglePin(item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.push_pin, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      s.pinned,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
                onPressed: _toggleEditMode,
                tooltip: _isEditing ? s.done : s.edit_pins,
                iconSize: 22,
                splashRadius: 20,
              ),
            ],
          ),
        ),
        if (widget.items.isEmpty && !_isEditing)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              s.no_pinned_items,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (_isEditing)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.allCharactersAndRaces.map((item) {
                final isPinned = widget.controller.isPinned(item);
                final name = (item is CharacterHomeItem)
                    ? item.character.name
                    : (item as RaceHomeItem).race.name;
                return InputChip(
                  label: Text(name),
                  selected: isPinned,
                  onSelected: (_) => _addPin(item),
                );
              }).toList(),
            ),
          )
        else if (widget.items.isNotEmpty)
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: PinnedItemCard(
                    item: item,
                    onTap: () {
                      if (item is CharacterHomeItem) {
                        widget.onCharacterTap(item);
                      } else if (item is RaceHomeItem) {
                        widget.onRaceTap(item);
                      }
                    },
                    onContextMenu: () {
                      if (item is CharacterHomeItem) {
                        widget.onCharacterContextMenu(item);
                      } else if (item is RaceHomeItem) {
                        widget.onRaceContextMenu(item);
                      }
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
