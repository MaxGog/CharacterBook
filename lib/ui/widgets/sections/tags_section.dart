import 'package:characterbook/data/models/folder_model.dart';
import 'package:characterbook/data/services/folder_service.dart';
import 'package:characterbook/ui/widgets/folders/folder_selector_widget.dart';
import 'package:characterbook/ui/widgets/tags/tags_input_widget.dart';
import 'package:flutter/material.dart';

class TagsSection extends StatelessWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final FolderService folderService;
  final FolderType folderType;
  final Folder? selectedFolder;
  final ValueChanged<Folder?> onFolderSelected;
  final List<Folder> folders;

  const TagsSection({
    super.key,
    required this.tags,
    required this.onTagsChanged,
    required this.folderService,
    required this.folderType,
    required this.selectedFolder,
    required this.onFolderSelected,
    required this.folders,
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
        if (folders.isNotEmpty) ...[
          /*FolderSelectorWidget(
            selectedFolder: selectedFolder,
            onFolderSelected: onFolderSelected,
            folderService: folderService,
            folderType: folderType,
          ),*/
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}