import 'package:characterbook/generated/l10n.dart';
import 'package:flutter/material.dart';

class TagsInputWidget extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagsInputWidget({
    super.key,
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  State<TagsInputWidget> createState() => _TagsInputWidgetState();
}

class _TagsInputWidgetState extends State<TagsInputWidget> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<String> _currentTags;

  @override
  void initState() {
    super.initState();
    _currentTags = List.from(widget.tags);
  }

  @override
  void didUpdateWidget(TagsInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(oldWidget.tags, widget.tags)) {
      setState(() {
        _currentTags = List.from(widget.tags);
      });
    }
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_currentTags.contains(trimmedTag)) {
      setState(() {
        _currentTags = [..._currentTags, trimmedTag];
      });
      widget.onTagsChanged(_currentTags);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _currentTags = _currentTags.where((t) => t != tag).toList();
    });
    widget.onTagsChanged(_currentTags);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ..._currentTags.map((tag) => _buildExpressiveTag(tag, context)),
                  _buildTagInputField(context),
                ],
              ),
              
              if (_currentTags.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  s.add_tag,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpressiveTag(String tag, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Chip(
            label: Text(tag),
            deleteIcon: Icon(Icons.close_rounded, size: 18),
            onDeleted: () => _removeTag(tag),
            side: BorderSide.none,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: colorScheme.secondaryContainer,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  Widget _buildTagInputField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SizedBox(
      width: _currentTags.isNotEmpty ? 120 : double.infinity,
      child: TextField(
        controller: _tagController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: S.of(context).add_tag,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        onSubmitted: _addTag,
        cursorColor: colorScheme.primary,
      ),
    );
  }
}