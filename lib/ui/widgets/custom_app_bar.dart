import 'package:flutter/material.dart';

import '../pages/settings_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final TextEditingController? searchController;
  final VoidCallback onSearchToggle;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget>? additionalActions;
  final VoidCallback? onTemplatesPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.isSearching,
    this.searchController,
    required this.onSearchToggle,
    this.searchHint,
    this.onSearchChanged,
    this.additionalActions,
    this.onTemplatesPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: isSearching
          ? TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: searchHint ?? 'Поиск...',
          border: InputBorder.none,
          hintStyle: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        style: textTheme.bodyLarge,
        onChanged: onSearchChanged,
      )
          : Text(
        title,
        style: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        if (!isSearching && onTemplatesPressed != null)
          IconButton(
            icon: const Icon(Icons.library_books_outlined),
            onPressed: onTemplatesPressed,
            tooltip: 'Шаблоны персонажей',
          ),
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: onSearchToggle,
        ),
        ...?additionalActions,
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}