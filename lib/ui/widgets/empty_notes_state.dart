import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/screens/notes/note_management_screen.dart';
import 'package:flutter/material.dart';

class NotesEmptyState extends StatelessWidget {
  final bool isSearching;
  
  const NotesEmptyState({super.key, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 64,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? S.of(context).nothing_found
                : '${S.of(context).empty_list} ${S.of(context).posts.toLowerCase()}',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NoteManagementScreen()),
                ),
                child: Text(S.of(context).create),
              ),
            ),
        ],
      ),
    );
  }
}