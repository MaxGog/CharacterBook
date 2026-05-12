import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/services/app_navigator.dart';
import 'package:characterbook/ui/screens/templates/template_list_screen.dart';
import 'package:characterbook/ui/widgets/about_section_widget.dart';
import 'package:flutter/material.dart';

class MenuContent extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onAboutTap;
  final int? selectedIndex;
  final ScrollController? scrollController;

  const MenuContent({
    super.key,
    this.onSettingsTap,
    this.onHelpTap,
    this.onAboutTap,
    this.selectedIndex,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(context, colorScheme, theme),
        const SizedBox(height: 16),
        _buildMainSection(context),
        const SizedBox(height: 16),
        _buildSettingsSection(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    final s = S.of(context);
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(32)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.person, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            s.welcome_back,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainSection(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            s.characters,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                context,
                icon: Icons.library_books_outlined,
                label: s.templates,
                index: 4,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TemplatesListScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            s.settings,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                context,
                icon: Icons.settings_outlined,
                label: s.settings,
                index: 5,
                onTap: () {
                  Navigator.pop(context);
                  if (onSettingsTap != null) {
                    onSettingsTap!();
                  } else {
                    AppNavigator.openSettings();
                  }
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                label: s.help_and_support,
                index: 6,
                onTap: () {
                  Navigator.pop(context);
                  if (onHelpTap != null) {
                    onHelpTap!();
                  } else {
                    AppNavigator.openTemplates();
                  }
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                label: s.about,
                index: 7,
                onTap: () {
                  Navigator.pop(context);
                  if (onAboutTap != null) {
                    onAboutTap!();
                  } else {
                    _showAboutDialog(context);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isSelected
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : null,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 24,
        visualDensity: VisualDensity.standard,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).aboutApp),
          content: SingleChildScrollView(
            child: AboutSection(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).close),
            ),
          ],
        );
      },
    );
  }
}
