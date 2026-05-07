import 'package:characterbook/ui/widgets/tags/tags_input_widget.dart';
import 'package:flutter/material.dart';

class TagsSection extends StatelessWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagsSection({
    super.key,
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TagsInputWidget(
          tags: tags,
          onTagsChanged: onTagsChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}