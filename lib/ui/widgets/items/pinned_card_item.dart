import 'dart:typed_data';

import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/items/home_item.dart';
import 'package:flutter/material.dart';

class PinnedItemCard extends StatelessWidget {
  const PinnedItemCard({super.key, 
    required this.item,
    required this.onTap,
    required this.onContextMenu,
  });

  final HomeItem item;
  final VoidCallback onTap;
  final VoidCallback onContextMenu;

  Uint8List? _getImage() {
    if (item is CharacterHomeItem) {
      return (item as CharacterHomeItem).character.imageBytes;
    } else if (item is RaceHomeItem) {
      return (item as RaceHomeItem).race.logo;
    }
    return null;
  }

  String _getTitle() {
    if (item is CharacterHomeItem) {
      return (item as CharacterHomeItem).character.name;
    } else if (item is RaceHomeItem) {
      return (item as RaceHomeItem).race.name;
    }
    return '';
  }

  String _getSubtitle(BuildContext context) {
    if (item is CharacterHomeItem) {
      final race = (item as CharacterHomeItem).character.race;
      return race?.name ?? S.of(context).character;
    } else if (item is RaceHomeItem) {
      return S.of(context).race;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final image = _getImage();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onContextMenu,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image.memory(image, fit: BoxFit.cover)
            else
              Container(color: colorScheme.primaryContainer),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getTitle(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSubtitle(context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
