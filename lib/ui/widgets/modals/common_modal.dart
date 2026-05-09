import 'dart:typed_data';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {bool isError = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor:
          isError ? Theme.of(context).colorScheme.errorContainer : null,
    ),
  );
}

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  bool isDestructive = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(S.of(context).cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmText,
            style: TextStyle(color: isDestructive ? colorScheme.error : null),
          ),
        ),
      ],
    ),
  );
}

void showFullImage(BuildContext context, Uint8List imageBytes, String title) {
  final colorScheme = Theme.of(context).colorScheme;
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.1,
            maxScale: 4.0,
            child: Image.memory(imageBytes),
          ),
        ),
      ),
    ),
  );
}

void showShareMenu({
  required BuildContext context,
  required String title,
  required VoidCallback onJsonExport,
  required VoidCallback onPdfExport,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Divider(
              height: 1,
              color: colorScheme.outlineVariant,
              indent: 16,
              endIndent: 16),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.insert_drive_file_rounded,
                  color: colorScheme.onPrimaryContainer),
            ),
            title:
                Text(S.of(context).file_character, style: textTheme.bodyLarge),
            trailing: Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.pop(context);
              onJsonExport();
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: colorScheme.outlineVariant),
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.picture_as_pdf_rounded,
                  color: colorScheme.onPrimaryContainer),
            ),
            title: Text(S.of(context).file_pdf, style: textTheme.bodyLarge),
            trailing: Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.pop(context);
              onPdfExport();
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                side: BorderSide(color: colorScheme.outline),
              ),
              child: Text(S.of(context).cancel),
            ),
          ),
        ],
      ),
    ),
  );
}

class ModalScaffold extends StatelessWidget {
  final String title;
  final List<PopupMenuEntry<String>> menuItems;
  final void Function(String) onMenuItemSelected;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final Widget heroSection;
  final Widget contentSections;

  const ModalScaffold({
    super.key,
    required this.title,
    required this.menuItems,
    required this.onMenuItemSelected,
    required this.onClose,
    required this.onEdit,
    required this.heroSection,
    required this.contentSections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surfaceContainerLow,
                colorScheme.surfaceContainerLowest,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton.extended(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: Text(S.of(context).edit),
                elevation: 4,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
            ),
            body: Column(
              children: [
                // Ручка для захвата
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        _buildAppBar(context),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              heroSection,
                              const SizedBox(height: 24),
                              contentSections,
                              const SizedBox(height: 32),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.close_rounded, color: colorScheme.onSurface),
        ),
        onPressed: onClose,
        tooltip: S.of(context).close,
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        title: Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surfaceContainerLow.withOpacity(0.5),
                colorScheme.surfaceContainerLowest,
              ],
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurface),
          position: PopupMenuPosition.under,
          surfaceTintColor: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          itemBuilder: (context) => menuItems,
          onSelected: onMenuItemSelected,
        ),
      ],
    );
  }
}

class HeroSection extends StatelessWidget {
  final Uint8List? avatarBytes;
  final String name;
  final List<Widget> chips;
  final VoidCallback? onAvatarTap;
  final String heroTag;

  const HeroSection({
    super.key,
    required this.avatarBytes,
    required this.name,
    required this.chips,
    this.onAvatarTap,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.secondaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: onAvatarTap,
                borderRadius: BorderRadius.circular(50),
                child: Hero(
                  tag: heroTag,
                  child: AvatarWidget(
                    imageBytes: avatarBytes,
                    size: 100,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips,
          ),
        ],
      ),
    );
  }
}

class ExpandableSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isExpanded;
  final ValueChanged<bool> onToggle;
  final Widget child;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => widget.onToggle(!widget.isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: widget.isExpanded
                  ? LinearGradient(
                      colors: [
                        colorScheme.primaryContainer.withOpacity(0.2),
                        colorScheme.secondaryContainer.withOpacity(0.2),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Icon(widget.icon, color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: widget.isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: widget.child,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class GallerySection extends StatelessWidget {
  final List<Uint8List> images;
  final Function(Uint8List, String) onImageTap;
  final String?
      referenceImageLabel;

  const GallerySection({
    super.key,
    required this.images,
    required this.onImageTap,
    this.referenceImageLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final isReference = referenceImageLabel != null && index == 0;
              final label = isReference
                  ? referenceImageLabel!
                  : '${S.of(context).character_gallery} ${images.length > 1 ? index + 1 : ''}';
              return Padding(
                padding:
                    EdgeInsets.only(right: index == images.length - 1 ? 0 : 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onImageTap(images[index], label.trim()),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.memory(images[index],
                            width: 100, height: 100, fit: BoxFit.cover),
                        if (isReference)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                S.of(context).reference_image,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      fontSize: 9,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
