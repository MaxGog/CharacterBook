import 'package:flutter/material.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/relationship_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/services/relationship_service.dart';
import 'package:characterbook/ui/widgets/edit_relationship_bottom_sheet.dart';
import 'package:provider/provider.dart';

class RelationshipsScreen extends StatelessWidget {
  const RelationshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final characterRepo = context.watch<CharacterRepository>();
    final relationshipService = context.watch<RelationshipService>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Связи персонажей',
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: colorScheme.surface,
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

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildBody(
                  context,
                  relationships,
                  characterMap,
                  colorScheme,
                  textTheme,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRelationship(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Добавить связь'),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<Relationship> relationships,
    Map<String, Character> characterMap,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (relationships.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 88,
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
              const SizedBox(height: 24),
              Text(
                'Пока нет ни одной связи',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Нажмите на кнопку +, чтобы добавить',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: relationships.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final rel = relationships[index];
        final char1 = characterMap[rel.character1Id];
        final char2 = characterMap[rel.character2Id];
        final name1 = char1?.name ?? 'Неизвестный';
        final name2 = char2?.name ?? 'Неизвестный';

        return Dismissible(
          key: Key(rel.id),
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.errorContainer,
                  colorScheme.error,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Icon(
              Icons.delete_outline,
              color: colorScheme.onError,
              size: 28,
            ),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Удалить связь?'),
                content: Text('Вы уверены, что хотите удалить «${rel.name}»?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Отмена'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                    ),
                    child: const Text('Удалить'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) =>
              context.read<RelationshipService>().deleteRelationship(rel),
          child: Card(
            elevation: 1,
            shadowColor: colorScheme.shadow.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: colorScheme.surfaceContainerLow,
            child: ListTile(
              leading: SizedBox(
                width: 56,
                child: _buildCharacterPairAvatar(
                  char1,
                  char2,
                  colorScheme,
                ),
              ),
              title: Text(
                rel.name,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                '$name1 ${rel.directed ? '→' : '↔'} $name2',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: colorScheme.primary,
                ),
                onPressed: () => _editRelationship(context, rel),
                tooltip: 'Редактировать',
              ),
              onTap: () => _editRelationship(context, rel),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharacterPairAvatar(
    Character? char1,
    Character? char2,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAvatar(char1, colorScheme, radius: 12),
        const SizedBox(width: 2),
        _buildAvatar(char2, colorScheme, radius: 12),
      ],
    );
  }

  Widget _buildAvatar(
    Character? character,
    ColorScheme colorScheme, {
    double radius = 20,
  }) {
    final hasAvatar = character?.imageBytes != null;
    return CircleAvatar(
      radius: radius,
      backgroundColor: hasAvatar ? null : colorScheme.primaryContainer,
      backgroundImage: hasAvatar ? MemoryImage(character!.imageBytes!) : null,
      child: !hasAvatar && character != null
          ? Text(
              character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            )
          : (character == null
              ? Text(
                  '?',
                  style: TextStyle(
                    fontSize: radius * 0.8,
                    color: colorScheme.onPrimaryContainer,
                  ),
                )
              : null),
    );
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
