import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/providers/pins_provider.dart';
import 'package:characterbook/ui/controllers/race_management_controller.dart';
import 'package:characterbook/ui/screens/field_editor_screen.dart';
import 'package:characterbook/ui/widgets/avatar_picker_widget.dart';
import 'package:characterbook/ui/widgets/dialogs/error_dialog.dart';
import 'package:characterbook/ui/widgets/fields/fullscreen_field_preview.dart';
import 'package:characterbook/ui/widgets/overlay_notification.dart';
import 'package:characterbook/ui/widgets/tags_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RaceManagementScreen extends StatefulWidget {
  final Race? race;

  const RaceManagementScreen({super.key, this.race});

  @override
  State<RaceManagementScreen> createState() => _RaceManagementScreenState();
}

class _RaceManagementScreenState extends State<RaceManagementScreen> {
  static const _logoSize = 120.0;
  static const _fieldSpacing = 16.0;
  static const _sectionSpacing = 24.0;
  static const _maxFormWidth = 600.0;

  final GlobalKey<FormState> _formKey = GlobalKey();
  late final TextEditingController _nameController;
  RaceManagementController? _controller;

  bool _nameTouched = false;

  @override
  void initState() {
    super.initState();
    final initialName = widget.race?.name ?? '';
    _nameController = TextEditingController(text: initialName);
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    _controller?.updateName(_nameController.text.trim());
  }

  Future<void> _onRaceSaveAttempt() async {
    final controller = _controller;
    if (controller == null) return;

    if (_nameController.text.trim().isEmpty) {
      showErrorDialog(
        context: context,
        title: S.of(context).enter_race_name,
        message: S.of(context).save_error,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final success = await controller.save();
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(controller.error ?? S.of(context).error)));
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
      create: (_) => RaceManagementController(
        raceRepo: context.read<RaceRepository>(),
        race: widget.race,
      ),
      child: Consumer<RaceManagementController>(
        builder: (context, controller, child) {
          _controller = controller;
          final s = S.of(context);
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _onRaceSaveAttempt,
              icon: const Icon(Icons.save),
              label: Text(s.save),
            ),
            body: WillPopScope(
              onWillPop: () async => true,
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, controller, s),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxWidth: _maxFormWidth),
                          child: Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: _sectionSpacing),
                                _buildFolderAndTagsSection(context, controller),
                                const SizedBox(height: _sectionSpacing),
                                Center(
                                  child: _buildLogoSection(context, controller),
                                ),
                                const SizedBox(height: _sectionSpacing),
                                _buildDescriptionField(context, controller),
                                const SizedBox(height: _fieldSpacing),
                                _buildBiologyField(context, controller),
                                const SizedBox(height: _fieldSpacing),
                                _buildBackstoryField(context, controller),
                                const SizedBox(height: _sectionSpacing),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
    RaceManagementController controller,
    S s,
  ) {
    final theme = Theme.of(context);
    final nameEmpty = _nameController.text.trim().isEmpty;
    final showNameError = nameEmpty && _nameTouched;
    return SliverAppBar.large(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(true),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      ),
      actions: [
        Consumer<PinsProvider>(
          builder: (context, pinsProvider, child) {
            final isPinned = pinsProvider.isPinned(controller.race.id);
            return IconButton(
              icon: Icon(
                  isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined),
              onPressed: () async {
                await pinsProvider.togglePin(controller.race.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(isPinned
                            ? S.of(context).unpin
                            : S.of(context).pin)),
                  );
                }
              },
              tooltip: isPinned ? S.of(context).unpin : S.of(context).pin,
            );
          },
        ),
      ],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration.collapsed(
              hintText: widget.race == null ? s.new_race : s.edit_race,
              hintStyle: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            cursorColor: theme.colorScheme.primary,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              setState(() {
                _nameTouched = true;
              });
            },
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
              setState(() {
                _nameTouched = true;
              });
            },
          ),
          if (showNameError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                s.enter_race_name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
      pinned: true,
    );
  }

  Widget _buildFolderAndTagsSection(
    BuildContext context,
    RaceManagementController controller,
  ) {
    return TagsSection(
      tags: controller.tags,
      onTagsChanged: controller.setTags,
    );
  }

  Widget _buildLogoSection(
    BuildContext context,
    RaceManagementController controller,
  ) {
    return AvatarPicker(
      currentAvatar: controller.race.logo,
      onAvatarChanged: (bytes) => controller.updateLogo(bytes),
      size: _logoSize / 2,
    );
  }

  Widget _buildDescriptionField(
    BuildContext context,
    RaceManagementController controller,
  ) {
    final s = S.of(context);
    return FullscreenFieldPreview(
      label: s.description,
      value: controller.race.description,
      onTap: () => _openFullscreenEditor(
        context,
        controller,
        s.description,
        (value) => controller.updateDescription(value),
        controller.race.description,
      ),
      maxPreviewLines: 3,
    );
  }

  Widget _buildBiologyField(
    BuildContext context,
    RaceManagementController controller,
  ) {
    final s = S.of(context);
    return FullscreenFieldPreview(
      label: s.biology,
      value: controller.race.biology,
      onTap: () => _openFullscreenEditor(
        context,
        controller,
        s.biology,
        (value) => controller.updateBiology(value),
        controller.race.biology,
      ),
      maxPreviewLines: 5,
    );
  }

  Widget _buildBackstoryField(
    BuildContext context,
    RaceManagementController controller,
  ) {
    final s = S.of(context);
    return FullscreenFieldPreview(
      label: s.backstory,
      value: controller.race.backstory,
      onTap: () => _openFullscreenEditor(
        context,
        controller,
        s.backstory,
        (value) => controller.updateBackstory(value),
        controller.race.backstory,
      ),
      maxPreviewLines: 7,
    );
  }

  Future<void> _openFullscreenEditor(
    BuildContext context,
    RaceManagementController controller,
    String label,
    Function(String) onSave,
    String initialValue,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FieldEditorScreen(
          title: label,
          initialValue: initialValue,
          onAutoSave: (result) => onSave(result.value),
          initialKey: 'description',
        ),
      ),
    );
    if (result != null && mounted) {
      onSave(result.value);
    }
  }
}
