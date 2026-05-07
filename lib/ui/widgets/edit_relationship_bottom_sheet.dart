import 'package:flutter/material.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/relationship_model.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/relationship_service.dart';
import 'package:provider/provider.dart';

class EditRelationshipBottomSheet extends StatefulWidget {
  final Relationship? relationship;

  const EditRelationshipBottomSheet({super.key, this.relationship});

  @override
  State<EditRelationshipBottomSheet> createState() =>
      _EditRelationshipBottomSheetState();
}

class _EditRelationshipBottomSheetState
    extends State<EditRelationshipBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final String _initialName;
  late final String _initialDescription;
  late final String _initialType;
  late final bool _initialDirected;

  late String _name;
  late String _description;
  late String _type;
  late bool _directed;

  Character? _character1;
  Character? _character2;
  List<Character>? _characters;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final rel = widget.relationship;
    _initialName = rel?.name ?? '';
    _initialDescription = rel?.description ?? '';
    _initialType = rel?.type ?? '';
    _initialDirected = rel?.directed ?? false;

    _name = _initialName;
    _description = _initialDescription;
    _type = _initialType;
    _directed = _initialDirected;

    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final characterService =
        Provider.of<CharacterService>(context, listen: false);
    final characters = await characterService.getAllCharacters();

    if (!mounted) return;

    final unique = characters.toSet().toList();

    setState(() {
      _characters = unique;
      _isLoading = false;

      final rel = widget.relationship;
      if (rel != null) {
        _character1 = unique.cast<Character?>().firstWhere(
              (c) => c!.id == rel.character1Id,
              orElse: () => null,
            );
        _character2 = unique.cast<Character?>().firstWhere(
              (c) => c!.id == rel.character2Id,
              orElse: () => null,
            );
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_character1 == null || _character2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите обоих персонажей')),
      );
      return;
    }

    if (_character1!.id == _character2!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Нельзя создать связь персонажа с самим собой')),
      );
      return;
    }

    final relationshipService =
        Provider.of<RelationshipService>(context, listen: false);

    if (widget.relationship == null) {
      final exists = await relationshipService.relationshipExists(
        _character1!.id,
        _character2!.id,
      );
      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Такая связь уже существует')),
          );
        }
        return;
      }
    }

    final relationship = Relationship(
      id: widget.relationship?.id,
      character1Id: _character1!.id,
      character2Id: _character2!.id,
      name: _name.trim(),
      description: _description.trim(),
      type: _type.trim().isEmpty ? null : _type.trim(),
      directed: _directed,
    );

    await relationshipService.saveRelationship(
      relationship,
      key: widget.relationship?.key,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Заголовок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                widget.relationship == null
                    ? 'Создание связи'
                    : 'Редактирование связи',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Form(
                  key: _formKey,
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCharacterDropdown(
                              label: 'Персонаж 1',
                              value: _character1,
                              onChanged: (val) {
                                setState(() {
                                  _character1 = val;
                                  if (_character2 != null &&
                                      val != null &&
                                      _character2!.id == val.id) {
                                    _character2 = null;
                                  }
                                });
                              },
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                            const SizedBox(height: 12),
                            _buildCharacterDropdown(
                              label: 'Персонаж 2',
                              value: _character2,
                              onChanged: (val) {
                                setState(() {
                                  _character2 = val;
                                  if (_character1 != null &&
                                      val != null &&
                                      _character1!.id == val.id) {
                                    _character1 = null;
                                  }
                                });
                              },
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: _initialName,
                              decoration: InputDecoration(
                                labelText: 'Название связи',
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: colorScheme.primary, width: 2),
                                ),
                              ),
                              style: textTheme.bodyLarge,
                              onSaved: (val) => _name = val ?? '',
                              validator: (val) => val?.trim().isEmpty == true
                                  ? 'Введите название'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: _initialDescription,
                              decoration: InputDecoration(
                                labelText: 'Описание',
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: colorScheme.primary, width: 2),
                                ),
                              ),
                              maxLines: 3,
                              style: textTheme.bodyLarge,
                              onSaved: (val) => _description = val ?? '',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: _initialType,
                              decoration: InputDecoration(
                                labelText: 'Тип (необязательно)',
                                border: const OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: colorScheme.primary, width: 2),
                                ),
                              ),
                              style: textTheme.bodyLarge,
                              onSaved: (val) => _type = val ?? '',
                            ),
                            const SizedBox(height: 4),
                            CheckboxListTile(
                              title: Text(
                                'Направленная связь',
                                style: textTheme.bodyLarge,
                              ),
                              value: _directed,
                              onChanged: (val) =>
                                  setState(() => _directed = val ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              activeColor: colorScheme.primary,
                              checkColor: colorScheme.onPrimary,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(color: colorScheme.outline),
                    ),
                    child: const Text('Отмена'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterDropdown({
    required String label,
    required Character? value,
    required void Function(Character?) onChanged,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return DropdownButtonFormField<Character>(
      value: value,
      isExpanded: true,
      items: _characters?.map((c) {
            return DropdownMenuItem<Character>(
              key: ValueKey(c.id),
              value: c,
              child: Row(
                children: [
                  _buildCharacterAvatar(c, colorScheme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      c.name,
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          }).toList() ??
          [],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      validator: (value) => value == null ? 'Выберите персонажа' : null,
      dropdownColor: colorScheme.surfaceContainerHigh,
      icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
    );
  }

  Widget _buildCharacterAvatar(Character character, ColorScheme colorScheme) {
    final hasAvatar = character.imageBytes != null;
    return CircleAvatar(
      radius: 14,
      backgroundColor: hasAvatar ? null : colorScheme.primaryContainer,
      backgroundImage: hasAvatar ? MemoryImage(character.imageBytes!) : null,
      child: !hasAvatar
          ? Text(
              character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
