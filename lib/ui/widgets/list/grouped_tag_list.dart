import 'package:flutter/material.dart';

class GroupedTagList<T> extends StatefulWidget {
  final List<T> items;
  final List<String> Function(T) getItemTags;
  final Widget Function(BuildContext, T) itemBuilder;
  final ScrollController scrollController;

  const GroupedTagList({
    super.key,
    required this.items,
    required this.getItemTags,
    required this.itemBuilder,
    required this.scrollController,
  });

  @override
  State<GroupedTagList> createState() => _GroupedTagListState<T>();
}

class _GroupedTagListState<T> extends State<GroupedTagList<T>> {
  final Map<String, bool> _expanded = {};

  List<String> _getAllTags() {
    final tags = <String>{};
    for (final item in widget.items) {
      tags.addAll(widget.getItemTags(item));
    }
    return tags.toList()..sort();
  }

  List<T> _itemsWithoutTags() {
    return widget.items
        .where((item) => widget.getItemTags(item).isEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final allTags = _getAllTags();
    final untaggedItems = _itemsWithoutTags();
    final theme = Theme.of(context);

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: allTags.length + 1, // +1 для секции "без тегов"
      itemBuilder: (context, index) {
        if (index == allTags.length) {
          // Секция "без тегов"
          if (untaggedItems.isEmpty) return const SizedBox.shrink();
          return _TagSection<T>(
            title: 'Без тегов', // локализуй
            items: untaggedItems,
            initiallyExpanded: true,
            itemBuilder: widget.itemBuilder,
          );
        }
        final tag = allTags[index];
        final itemsWithTag = widget.items
            .where((item) => widget.getItemTags(item).contains(tag))
            .toList();
        if (itemsWithTag.isEmpty) return const SizedBox.shrink();
        return _TagSection<T>(
          title: tag,
          items: itemsWithTag,
          initiallyExpanded: false,
          itemBuilder: widget.itemBuilder,
        );
      },
    );
  }
}

class _TagSection<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final bool initiallyExpanded;
  final Widget Function(BuildContext, T) itemBuilder;

  const _TagSection({
    required this.title,
    required this.items,
    required this.initiallyExpanded,
    required this.itemBuilder,
  });

  @override
  State<_TagSection> createState() => _TagSectionState<T>();
}

class _TagSectionState<T> extends State<_TagSection<T>> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(_expanded ? Icons.folder_open : Icons.folder_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text('${widget.items.length}',
                    style: theme.textTheme.labelMedium),
                const SizedBox(width: 8),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.items.map((item) => widget.itemBuilder(context, item)),
        const Divider(height: 1),
      ],
    );
  }
}
