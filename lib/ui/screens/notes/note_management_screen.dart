import 'dart:async';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/repositories/note_repository.dart';
import 'package:characterbook/data/services/note_service.dart';
import 'package:characterbook/ui/controllers/note_management_controller.dart';
import 'package:characterbook/ui/widgets/avatar_widget.dart';
import 'package:characterbook/ui/widgets/markdown_context_menu.dart';
import 'package:characterbook/ui/widgets/overlay_notification.dart';
import 'package:characterbook/ui/widgets/tags_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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

  late final TextEditingController _contentController;
  late final TextEditingController _titleController;
  Timer? _titleDebounce;
  Timer? _contentDebounce;
  NoteManagementController? _controller;
  bool _isPreviewMode = false;
  bool _metadataExpanded = true;
  bool _titleTouched = false;
  bool _initialized = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _titleController.addListener(_onTitleChanged);
    _contentController.addListener(_onContentChanged);

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _contentController.removeListener(_onContentChanged);
    _titleController.dispose();
    _contentController.dispose();
    _titleDebounce?.cancel();
    _contentDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && _metadataExpanded) {
      setState(() => _metadataExpanded = false);
    } else if (_scrollController.offset <= 0 && !_metadataExpanded) {
      setState(() => _metadataExpanded = true);
    }
  }

  void _onTitleChanged() {
    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 500), () {
      final controller = _controller;
      if (controller == null) return;
      controller.updateTitle(_titleController.text.trim());
    });
  }

  void _onContentChanged() {
    _contentDebounce?.cancel();
    _contentDebounce = Timer(const Duration(milliseconds: 500), () {
      final controller = _controller;
      if (controller == null) return;
      final newContent = _contentController.text;
      if (newContent != controller.content) {
        controller.updateContent(newContent);
      }
    });
  }

  void _togglePreviewMode() {
    setState(() => _isPreviewMode = !_isPreviewMode);
  }

  void _toggleMetadata() {
    setState(() => _metadataExpanded = !_metadataExpanded);
  }

  void _onNoteSaveAttempt() {
    if (_titleController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(S.of(ctx).enter_title_note),
          content: Text(S.of(ctx).save_error),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(ctx).ok),
            ),
          ],
        ),
      );
      return;
    }
    OverlayNotification.show(
      S.of(context).changes_saved,
      type: OverlayNotificationType.success,
    );
    Navigator.of(context).pop(true);
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
          final s = S.of(context);
          if (!_initialized) {
            _titleController.text = controller.title;
            _contentController.text = controller.content;
            _initialized = true;
          }

          return Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(context, controller, s),
                SliverToBoxAdapter(
                  child: _buildMetadataSection(context, controller, s),
                ),
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
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontSize: 16, height: 1.5),
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
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
            bottomNavigationBar: _buildBottomBar(context, controller, s),
          );
        },
      ),
    );
  }

  Widget _buildMetadataSection(
    BuildContext context,
    NoteManagementController controller,
    S s,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(
            _metadataExpanded ? Icons.expand_less : Icons.expand_more,
            color: colorScheme.primary,
          ),
          title: Text(
            s.settings,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: _toggleMetadata,
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _metadataExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 8),
              ],
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
        const Divider(height: 1),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    NoteManagementController controller,
    S s,
  ) {
    final theme = Theme.of(context);
    final titleEmpty = _titleController.text.trim().isEmpty;
    final showTitleError = titleEmpty && _titleTouched;

    return SliverAppBar.large(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(true),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
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
            onChanged: (_) => setState(() => _titleTouched = true),
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
              setState(() => _titleTouched = true);
            },
          ),
          if (showTitleError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                s.enterName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
      pinned: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            switch (value) {
              case 'share':
                controller.share(context);
                break;
              case 'copy':
                controller.copyToClipboard(context);
                break;
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  const Icon(Icons.share_rounded),
                  const SizedBox(width: 8),
                  Text(s.share),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'copy',
              child: Row(
                children: [
                  const Icon(Icons.copy_rounded),
                  const SizedBox(width: 8),
                  Text(s.copy),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    NoteManagementController controller,
    S s,
  ) {
    return BottomAppBar(
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
              onPressed: _togglePreviewMode,
              tooltip: _isPreviewMode ? s.edit : s.grid_view,
              icon: Icon(
                  _isPreviewMode ? Icons.edit_rounded : Icons.preview_rounded),
            ),
            const Spacer(),
            FloatingActionButton.extended(
              onPressed: _onNoteSaveAttempt,
              icon: const Icon(Icons.save),
              label: Text(s.save),
            ),
          ],
        ],
      ),
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
        Character? character = charactersBox.get(characterId);
        if (character == null) {
          final intKey = int.tryParse(characterId);
          if (intKey != null) {
            character = charactersBox.get(intKey);
          }
        }
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
