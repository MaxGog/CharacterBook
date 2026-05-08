import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/tools_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/relationship_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/services/relationship_service.dart';
import 'package:characterbook/ui/widgets/edit_relationship_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RelationshipsScreen extends StatefulWidget {
  const RelationshipsScreen({super.key});

  @override
  State<RelationshipsScreen> createState() => _RelationshipsScreenState();
}

class _RelationshipsScreenState extends State<RelationshipsScreen> {
  void _showRelationshipContextMenu(BuildContext context, Relationship rel) {
    final s = S.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ContextMenu.relationship(
        relationship: rel,
        onEdit: () => _editRelationship(context, rel),
        onDelete: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(s.deleteRelationshipTitle),
              content: Text(s.deleteRelationshipMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(s.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(s.delete),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            context.read<RelationshipService>().deleteRelationship(rel);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.relationshipDeleted)),
            );
          }
        },
        onShare: () {
          final text = '${rel.name}: $rel.name1 → $rel.name2';
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.copiedToClipboard)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final characterRepo = context.watch<CharacterRepository>();
    final relationshipService = context.watch<RelationshipService>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRelationship(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.add_relationships),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        heroTag: 'add_relationship_fab',
      ),
      body: StreamBuilder<List<Character>>(
        stream: characterRepo.watchAll(),
        builder: (context, charSnapshot) {
          if (!charSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final characters = charSnapshot.data!;
          final characterMap = {for (var c in characters) c.id: c};

          return StreamBuilder<List<Relationship>>(
            stream: relationshipService.watchAll(),
            builder: (context, relSnapshot) {
              if (!relSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final relationships = relSnapshot.data!;

              if (relationships.isEmpty) {
                return _buildEmptyState(s, colorScheme, textTheme);
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar.large(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.relationships,
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${relationships.length} ${s.relationships.toLowerCase()}',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: colorScheme.surface,
                    floating: true,
                    pinned: true,
                    // actions больше не нужны
                  ),
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList.builder(
                      itemCount: relationships.length,
                      itemBuilder: (context, index) {
                        final rel = relationships[index];
                        return _buildRelationshipCard(
                          rel,
                          characterMap,
                          colorScheme,
                          textTheme,
                        );
                      },
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(S s, ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          s.empty_list,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          s.create,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => _addRelationship(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(s.createRelationship),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 4,
          ),
        ),
      ]),
    );
  }

  Widget _buildRelationshipCard(
    Relationship rel,
    Map<String, Character> characterMap,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final char1 = characterMap[rel.character1Id];
    final char2 = characterMap[rel.character2Id];
    final name1 = char1?.name ?? S.of(context).unknown;
    final name2 = char2?.name ?? S.of(context).unknown;

    final gradientColors =
        _generateGradientFromCharacters(char1, char2, colorScheme);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clampedValue,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Dismissible(
          key: Key(rel.id),
          background: _buildDismissBackground(colorScheme),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async => await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(S.of(context).deleteRelationshipTitle),
              content: Text(S.of(context).deleteRelationshipMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(S.of(context).cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                  ),
                  child: Text(S.of(context).delete),
                ),
              ],
            ),
          ),
          onDismissed: (_) {
            context.read<RelationshipService>().deleteRelationship(rel);
          },
          child: Card(
            elevation: 4,
            shadowColor: gradientColors.first.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _editRelationship(context, rel),
                  onLongPress: () => _showRelationshipContextMenu(context, rel),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildConnectedAvatars(
                            char1, char2, rel.directed, colorScheme),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rel.name,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$name1 ${rel.directed ? "→" : "↔"} $name2',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer
                                      .withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildTypeChip(rel.type, colorScheme),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color:
                              colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.errorContainer, colorScheme.error],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Icon(
        Icons.delete_outline,
        color: colorScheme.onError,
        size: 28,
      ),
    );
  }

  Widget _buildConnectedAvatars(
    Character? char1,
    Character? char2,
    bool directed,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: _buildAvatar(char1, colorScheme, radius: 22),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildAvatar(char2, colorScheme, radius: 22),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Icon(
                directed ? Icons.arrow_forward_rounded : Icons.sync_alt_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Character? character, ColorScheme colorScheme,
      {double radius = 22}) {
    final hasAvatar = character?.imageBytes != null;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.surface, width: 3),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: hasAvatar ? null : colorScheme.primaryContainer,
        backgroundImage: hasAvatar ? MemoryImage(character!.imageBytes!) : null,
        child: !hasAvatar && character != null
            ? Text(
                character.name.isNotEmpty
                    ? character.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              )
            : (character == null
                ? Text('?',
                    style: TextStyle(
                        fontSize: radius * 0.8,
                        color: colorScheme.onPrimaryContainer))
                : null),
      ),
    );
  }

  Widget _buildTypeChip(String? type, ColorScheme colorScheme) {
    if (type == null || type.isEmpty) return const SizedBox.shrink();
    IconData icon;
    switch (type.toLowerCase()) {
      case 'romance':
        icon = Icons.favorite_rounded;
        break;
      case 'rivalry':
        icon = Icons.flash_on_rounded;
        break;
      case 'family':
        icon = Icons.groups_rounded;
        break;
      default:
        icon = Icons.circle_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _generateGradientFromCharacters(
    Character? char1,
    Character? char2,
    ColorScheme colorScheme,
  ) {
    final hash1 = char1?.id.hashCode ?? 0;
    final hash2 = char2?.id.hashCode ?? 1;
    final primary = Color((colorScheme.primary.value + hash1) % 0xFFFFFFFF);
    final tertiary = Color((colorScheme.tertiary.value + hash2) % 0xFFFFFFFF);
    return [
      primary.withOpacity(0.25),
      tertiary.withOpacity(0.25),
    ];
  }

  void _addRelationship(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditRelationshipBottomSheet(),
    );
  }

  void _editRelationship(BuildContext context, Relationship rel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditRelationshipBottomSheet(relationship: rel),
    );
  }
}
