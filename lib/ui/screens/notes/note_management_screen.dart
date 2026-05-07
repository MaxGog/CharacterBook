import 'dart:async';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/data/services/note_service.dart';
import 'package:characterbook/ui/controllers/note_management_controller.dart';
import 'package:characterbook/ui/widgets/avatar_widget.dart';
import 'package:characterbook/ui/widgets/fields/custom_text_field.dart';
import 'package:characterbook/ui/widgets/markdown_context_menu.dart';
import 'package:characterbook/ui/widgets/sections/tags_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class NoteManagementScreen extends StatefulWidget {
  final Note? note;
  final bool isCopyMode;

  const NoteManagementScreen({super.key, this.note, this.isCopyMode = false});

  @override
  State<NoteManagementScreen> createState() => _NoteManagementScreenState();
}

class _NoteManagementScreenState extends State<NoteManagementScreen> {
  static const _fieldSpacing = 16.0;
  
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  Timer? _titleDebounce;
  Timer? _contentDebounce;
  NoteManagementController? _controller;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _titleController.addListener(_onTitleChanged);
    _contentController.addListener(_onContentChanged);
    _contentController.addListener(_generateAutoTitle);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _contentController.removeListener(_onContentChanged);
    _contentController.removeListener(_generateAutoTitle);
    _titleController.dispose();
    _contentController.dispose();
    _titleDebounce?.cancel();
    _contentDebounce?.cancel();
    super.dispose();
  }

  void _onTitleChanged() {
    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 500), () {
      final controller = _controller;
      if (controller == null) return;
      final newTitle = _titleController.text.trim();
      if (newTitle.isNotEmpty && newTitle != controller.title) {
        controller.updateTitle(newTitle);
      }
    });
  }

  void _onContentChanged() {
    _contentDebounce?.cancel();
    _contentDebounce = Timer(const Duration(seconds: 1), () {
      final controller = _controller;
      if (controller == null) return;
      final newContent = _contentController.text;
      if (newContent != controller.content) {
        controller.updateContent(newContent);
      }
    });
  }

  void _generateAutoTitle() {
    final controller = _controller;
    if (controller == null || !controller.autoGenerateTitle) return;
    if (_titleController.text.trim().isNotEmpty) return;
    final text = _contentController.text.trim();
    if (text.isNotEmpty) {
      final words = text.split(' ');
      final title = words.take(4).join(' ');
      _titleController.text = title;
    }
  }

  void _togglePreviewMode() {
    setState(() => _isPreviewMode = !_isPreviewMode);
  }

  void _showMetadataSheet(BuildContext context) {
    final controller = _controller!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(ctx).settings,
              style: Theme.of(ctx).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      label: S.of(ctx).name,
                      isRequired: true,
                    ),
                    const SizedBox(height: _fieldSpacing),
                    TagsSection(
                      tags: controller.tags,
                      onTagsChanged: controller.setTags,
                    ),
                    const SizedBox(height: _fieldSpacing),
                    _CharacterSelectorSection(
                      selectedCharacterIds: controller.selectedCharacterIds,
                      onAddCharacter: controller.addCharacterId,
                      onRemoveCharacter: controller.removeCharacterId,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(S.of(ctx).close),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteManagementController(
        noteRepo: context.read<NoteRepository>(),
        noteService: context.read<NoteService>(),
        note: widget.note,
        isCopyMode: widget.isCopyMode,
      ),
      child: Consumer<NoteManagementController>(
        builder: (context, controller, child) {
          _controller = controller;
          if (_titleController.text != controller.title) {
            _titleController.text = controller.title;
          }
          if (_contentController.text != controller.content) {
            _contentController.text = controller.content;
          }

          final s = S.of(context);
          return Scaffold(
            body: WillPopScope(
              onWillPop: () async => true,
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, controller, s),
                  if (!_isPreviewMode)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextFormField(
                          controller: _contentController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: s.start_writing,
                            hintStyle: const TextStyle(fontSize: 16),
                            contentPadding: EdgeInsets.zero,
                          ),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                          contextMenuBuilder: (context, editableTextState) {
                            return MarkdownContextMenu(
                              controller: _contentController,
                              editableTextState: editableTextState,
                            );
                          },
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: MarkdownBody(
                          data: _contentController.text,
                          styleSheet:
                              MarkdownStyleSheet.fromTheme(Theme.of(context)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (controller.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else ...[
                    IconButton(
                      onPressed: () => controller.share(context),
                      icon: const Icon(Icons.share_rounded),
                      tooltip: s.share,
                    ),
                    IconButton(
                      onPressed: () => controller.copyToClipboard(context),
                      icon: const Icon(Icons.copy_rounded),
                      tooltip: s.copy,
                    ),
                    IconButton(
                      onPressed: () => _showMetadataSheet(context),
                      icon: const Icon(Icons.edit_note_rounded),
                      tooltip: s.settings,
                    ),
                    IconButton(
                      onPressed: _togglePreviewMode,
                      tooltip: _isPreviewMode ? s.edit : s.grid_view,
                      icon: Icon(_isPreviewMode
                          ? Icons.edit_rounded
                          : Icons.preview_rounded),
                    ),
                    const Spacer(),
                    FloatingActionButton.extended(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.save),
                      label: Text(s.save),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    NoteManagementController controller,
    S s,
  ) {
    final theme = Theme.of(context);
    return SliverAppBar.large(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(true),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      ),
      title: TextField(
        controller: _titleController,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration.collapsed(
          hintText: widget.note == null
              ? s.create
              : (widget.isCopyMode
                  ? '${s.copy} ${s.posts.toLowerCase()}'
                  : s.edit),
          hintStyle: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        cursorColor: theme.colorScheme.primary,
        maxLines: 1,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
      ),
      pinned: true,
    );
  }
}

class _CharacterSelectorSection extends StatelessWidget {
  final List<String> selectedCharacterIds;
  final ValueChanged<String> onAddCharacter;
  final ValueChanged<String> onRemoveCharacter;

  const _CharacterSelectorSection({
    required this.selectedCharacterIds,
    required this.onAddCharacter,
    required this.onRemoveCharacter,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Character>('characters').listenable(),
      builder: (context, Box<Character> box, _) {
        final entries = box.keys
            .map((key) {
              final character = box.get(key);
              return MapEntry(key.toString(), character);
            })
            .where((entry) => entry.value != null)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: null,
              decoration: InputDecoration(
                labelText:
                    '${S.of(context).choose_character} ${S.of(context).character.toLowerCase()}',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              dropdownColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              style: Theme.of(context).textTheme.bodyLarge,
              borderRadius: BorderRadius.circular(12),
              items: entries.map((entry) {
                final character = entry.value!;
                final characterKey = entry.key;
                final isSelected = selectedCharacterIds.contains(characterKey);
                return DropdownMenuItem<String>(
                  value: characterKey,
                  child: Row(
                    children: [
                      if (isSelected)
                        Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20),
                      const SizedBox(width: 8),
                      AvatarWidget.character(
                        imageBytes: character.imageBytes,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        character.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  if (selectedCharacterIds.contains(value)) {
                    onRemoveCharacter(value);
                  } else {
                    onAddCharacter(value);
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            if (selectedCharacterIds.isNotEmpty)
              _buildSelectedCharactersChips(
                  context, selectedCharacterIds, box, onRemoveCharacter),
          ],
        );
      },
    );
  }

  Widget _buildSelectedCharactersChips(
    BuildContext context,
    List<String> selectedIds,
    Box<Character> charactersBox,
    ValueChanged<String> onRemove,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedIds.map((characterId) {
        dynamic actualKey;
        try {
          actualKey = int.parse(characterId);
        } catch (_) {
          actualKey = characterId;
        }
        final character = charactersBox.get(actualKey);
        return character != null
            ? InputChip(
                avatar: AvatarWidget.character(
                  imageBytes: character.imageBytes,
                  size: 20,
                ),
                label: Text(character.name),
                onDeleted: () => onRemove(characterId),
                deleteIcon: Icon(
                  Icons.close,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            : const SizedBox();
      }).toList(),
    );
  }
}
