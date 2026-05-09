import 'dart:math';

import 'package:flutter/material.dart';
import 'package:characterbook/generated/l10n.dart';
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
    extends State<EditRelationshipBottomSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _typeController;

  Character? _character1;
  Character? _character2;
  List<Character>? _characters;
  bool _isLoading = true;
  bool _directed = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final rel = widget.relationship;
    _nameController = TextEditingController(text: rel?.name ?? '');
    _descriptionController =
        TextEditingController(text: rel?.description ?? '');
    _typeController = TextEditingController(text: rel?.type ?? '');
    _directed = rel?.directed ?? false;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation =
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    _loadCharacters();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _pulseController.dispose();
    super.dispose();
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

    final s = S.of(context);
    if (_character1 == null || _character2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.selectBothCharacters)),
      );
      return;
    }
    if (_character1!.id == _character2!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.cannotRelateToItself)),
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
            SnackBar(content: Text(s.relationshipAlreadyExists)),
          );
        }
        return;
      }
    }

    final relationship = Relationship(
      id: widget.relationship?.id,
      character1Id: _character1!.id,
      character2Id: _character2!.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _typeController.text.trim().isEmpty
          ? null
          : _typeController.text.trim(),
      directed: _directed,
    );

    await relationshipService.saveRelationship(
      relationship,
      key: widget.relationship?.key,
    );

    if (mounted) Navigator.pop(context);
  }

  Widget _buildTypeChip(String label, IconData icon, ColorScheme colorScheme) {
    final isSelected = _typeController.text.trim() == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _typeController.text = isSelected ? '' : label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      widget.relationship == null
                          ? s.createRelationship
                          : s.editRelationship,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildConnectionCanvas(colorScheme, textTheme),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: s.relationshipName,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: colorScheme.primary, width: 2),
                                ),
                              ),
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: s.description,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: colorScheme.primary, width: 2),
                                ),
                              ),
                              maxLines: 2,
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              s.typeOptional,
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildTypeChip('Romance',
                                    Icons.favorite_rounded, colorScheme),
                                _buildTypeChip('Rivalry',
                                    Icons.flash_on_rounded, colorScheme),
                                _buildTypeChip('Family', Icons.groups_rounded,
                                    colorScheme),
                                _buildTypeChip('Friendship',
                                    Icons.handshake_rounded, colorScheme),
                                _buildTypeChip(
                                    'Other', Icons.circle_rounded, colorScheme),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s.directedRelationship,
                                    style: textTheme.bodyLarge,
                                  ),
                                ),
                                Switch(
                                  value: _directed,
                                  onChanged: (val) =>
                                      setState(() => _directed = val),
                                  activeColor: colorScheme.primary,
                                ),
                              ],
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(s.cancel),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(s.save),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildConnectionCanvas(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.4),
            colorScheme.tertiaryContainer.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            top: 40,
            child: _buildCharacterSelector(
              0,
              _character1,
              (char) => setState(() => _character1 = char),
              colorScheme,
              textTheme,
            ),
          ),
          Positioned(
            right: 20,
            bottom: 40,
            child: _buildCharacterSelector(
              1,
              _character2,
              (char) => setState(() => _character2 = char),
              colorScheme,
              textTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSelector(
    int index,
    Character? current,
    ValueChanged<Character?> onSelected,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showCharacterPicker(index, current, onSelected),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 3),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: current?.imageBytes != null
                  ? MemoryImage(current!.imageBytes!)
                  : null,
              child: current?.imageBytes == null
                  ? Text(
                      current?.name.isNotEmpty == true
                          ? current!.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          current?.name ?? '?',
          style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }

  void _showCharacterPicker(
    int index,
    Character? current,
    ValueChanged<Character?> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Выберите персонажа',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _characters!.length,
                  itemBuilder: (_, i) {
                    final char = _characters![i];
                    final isSelected = current?.id == char.id;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: char.imageBytes != null
                            ? MemoryImage(char.imageBytes!)
                            : null,
                        child: char.imageBytes == null
                            ? Text(char.name[0].toUpperCase())
                            : null,
                      ),
                      title: Text(char.name),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        onSelected(char);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
