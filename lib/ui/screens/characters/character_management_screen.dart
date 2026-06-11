import 'dart:async';

import 'package:characterbook/data/services/relationship_service.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/providers/pins_provider.dart';
import 'package:characterbook/ui/controllers/character_management_controller.dart';
import 'package:characterbook/ui/screens/field_editor_screen.dart';
import 'package:characterbook/ui/widgets/avatar_picker_widget.dart';
import 'package:characterbook/ui/widgets/dialogs/error_dialog.dart';
import 'package:characterbook/ui/widgets/edit_relationship_bottom_sheet.dart';
import 'package:characterbook/ui/widgets/fields/custom_fields_editor.dart';
import 'package:characterbook/ui/widgets/fields/custom_text_field.dart';
import 'package:characterbook/ui/widgets/fields/gender_selector_field.dart';
import 'package:characterbook/ui/widgets/fields/race_selector_field.dart';
import 'package:characterbook/ui/widgets/overlay_notification.dart';
import 'package:characterbook/ui/widgets/reference_image_picker.dart';
import 'package:characterbook/ui/widgets/image_gallery_section.dart';
import 'package:characterbook/ui/widgets/tags_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CharacterManagementScreen extends StatefulWidget {
  final Character? character;
  final QuestionnaireTemplate? template;

  const CharacterManagementScreen({super.key, this.character, this.template});

  @override
  State<CharacterManagementScreen> createState() =>
      _CharacterManagementScreenState();
}

enum _CharacterMenuAction { addTag, favorite, delete, copyInfo }

class _CharacterManagementScreenState extends State<CharacterManagementScreen> {
  static const _sectionSpacing = 18.0;
  static const _fieldSpacing = 12.0;
  static const _maxFormWidth = 600.0;
  static const _avatarSize = 80.0;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _nameController;
  Timer? _nameDebounce;
  CharacterManagementController? _controller;

  bool _nameTouched = false;

  @override
  void initState() {
    super.initState();
    final initialName = widget.character?.name ?? '';
    _nameController = TextEditingController(text: initialName);
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _nameDebounce?.cancel();
    super.dispose();
  }

  void _onNameChanged() {
    _nameDebounce?.cancel();
    _nameDebounce = Timer(const Duration(milliseconds: 500), () {
      final controller = _controller;
      if (controller == null) return;
      controller.updateName(_nameController.text.trim());
    });
  }

  Future<void> _onSavePressed(BuildContext context) async {
    final controller = _controller;
    if (controller == null) return;

    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    FocusScope.of(context).unfocus();

    final success = await controller.save();
    if (!mounted) return;

    if (success) {
      OverlayNotification.show(
        s.changes_saved,
        type: OverlayNotificationType.success,
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) navigator.pop(true);
      });
    } else {
      final errorMsg = controller.error ?? s.error;
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: errorColor,
          ),
        );
    }
  }

  void _onSaveAttempt() {
    final controller = _controller;
    if (controller == null) return;

    final s = S.of(context);
    final nameValid = controller.character.name.trim().isNotEmpty;
    final raceValid = controller.character.race != null;

    if (!nameValid) {
      showErrorDialog(
        context: context,
        title: s.enter_name_character,
        message: s.save_error,
      );
      return;
    }
    if (!raceValid) {
      showErrorDialog(
        context: context,
        title: s.choose_race_character,
        message: s.save_error,
      );
      return;
    }
    _onSavePressed(context);
  }

  Future<void> _onCharacterMenuSelected(
     _CharacterMenuAction action,
    CharacterManagementController controller,
    PinsProvider pinsProvider,
  ) async {
    final s = S.of(context);
    switch (action) {
      case _CharacterMenuAction.addTag:
        _showTagEditor(context, controller);
        break;
      case _CharacterMenuAction.favorite:
        await pinsProvider.togglePin(controller.character.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(pinsProvider.isPinned(controller.character.id)
                    ? s.pin
                    : s.unpin)),
          );
        }
        break;
      case _CharacterMenuAction.copyInfo:
        final info = '''${controller.character.name}
${controller.character.race?.name ?? ''}
${controller.character.gender}
${controller.character.age}''';
        Clipboard.setData(ClipboardData(text: info));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.copy} ${s.character.toLowerCase()}')),
        );
        break;
      case _CharacterMenuAction.delete:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.delete}...')),
        );
        break;
    }
  }

  Future<void> _showTagEditor(
    BuildContext context,
    CharacterManagementController controller,
  ) async {
    var tags = List<String>.from(controller.tags);
    final s = S.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      s.tags,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TagsSection(
                      tags: tags,
                      onTagsChanged: (updated) => setState(() {
                        tags = List<String>.from(updated);
                      }),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        controller.setTags(tags);
                        Navigator.of(context).pop();
                      },
                      child: Text(s.ok),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterManagementController(
        characterRepo: context.read<CharacterRepository>(),
        raceRepo: context.read<RaceRepository>(),
        relationshipService: context.read<RelationshipService>(),
        character: widget.character,
        template: widget.template,
      ),
      child: Consumer<CharacterManagementController>(
        builder: (context, controller, child) {
          _controller = controller;
          final s = S.of(context);
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _onSaveAttempt,
              icon: const Icon(Icons.save),
              label: Text(s.save),
            ),
            body: PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, result) {},
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, controller, s),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxWidth: _maxFormWidth),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: _sectionSpacing),
                                _buildProfileSection(context, controller),
                                const SizedBox(height: _sectionSpacing),
                                _buildAppearanceSection(context, controller),
                                const SizedBox(height: _sectionSpacing),
                                _buildInformationSection(context, controller),
                                const SizedBox(height: _sectionSpacing),
                                _buildAdditionalSection(context, controller),
                                const SizedBox(height: 76),
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
    CharacterManagementController controller,
    S s,
  ) {
    final theme = Theme.of(context);
    final nameEmpty = _nameController.text.trim().isEmpty;
    final showNameError = nameEmpty && _nameTouched;
    final pinsProvider = context.read<PinsProvider>();
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
            controller: _nameController,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              labelText: s.character,
              hintText: widget.character == null
                  ? (widget.template == null
                      ? s.new_character
                      : s.new_character_from_template)
                  : null,
              border: InputBorder.none,
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
                s.enterName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    actions: [
      PopupMenuButton<_CharacterMenuAction>(
        icon: const Icon(Icons.more_vert_rounded),
        onSelected: (value) => _onCharacterMenuSelected(value, controller, pinsProvider),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _CharacterMenuAction.addTag,
            child: ListTile(
              leading: const Icon(Icons.label_outline),
              title: Text(s.add_tag),
            ),
          ),
         PopupMenuItem(
              value: _CharacterMenuAction.favorite,
              child: ListTile(
                leading: Icon(
                  pinsProvider.isPinned(controller.character.id)
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                ),
                title: Text(pinsProvider.isPinned(controller.character.id)
                    ? s.unpin
                    : s.pin),
              ),
            ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: _CharacterMenuAction.copyInfo,
            child: ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: Text(s.copy),
            ),
          ),
          PopupMenuItem(
            value: _CharacterMenuAction.delete,
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(s.delete),
            ),
          ),
        ],
      ),
    ],
    pinned: true,
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    final s = S.of(context);
    return _buildSectionCard(
      context,
      icon: Icons.badge_rounded,
      title: s.basic_info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_shouldShowField('race'))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RaceSelectorField(
                  initialRace: controller.character.race,
                  onChanged: (race) => controller.updateRace(race),
                ),
                if (controller.character.race == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      s.select_race,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
              ],
            ),
          if (widget.template != null) _buildTemplateChip(context),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    final s = S.of(context);
    return _buildSectionCard(
      context,
      icon: Icons.visibility_rounded,
      title: s.appearance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarSection(context, controller, size: _avatarSize),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAgeAndGenderRow(context, controller),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: _fieldSpacing),
          if (_shouldShowField('appearance'))
            _FullscreenTextField(
              label: s.appearance,
              value: controller.character.appearance,
              onTap: () => _openFullscreenEditor(
                  context, controller, 'appearance', s.appearance),
              maxLines: 3,
            ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    final s = S.of(context);
    return _buildSectionCard(
      context,
      icon: Icons.info_rounded,
      title: s.information,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._buildFullscreenFields(
            context,
            controller,
            ['biography', 'personality'],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSection(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    final s = S.of(context);
    return _buildSectionCard(
      context,
      icon: Icons.photo_library_rounded,
      title: s.details,
      subtitle: s.additional_images,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomFieldsEditor(
            initialFields: controller.customFields,
            onFieldsChanged: controller.setCustomFields,
            verticalLayout: true,
            useFullscreenEditor: true,
          ),
          const SizedBox(height: _fieldSpacing),
          ..._buildFullscreenFields(
            context,
            controller,
            ['abilities', 'other'],
          ),
          if (_shouldShowField('referenceImage') || _shouldShowField('additionalImages'))
            ...[
              const SizedBox(height: _fieldSpacing),
              _buildMediaSection(context, controller),
            ],
          const SizedBox(height: _fieldSpacing),
          _buildRelationshipList(context, controller),
        ],
      ),
    );
  }

  Widget _buildRelationshipList(
      BuildContext context, CharacterManagementController controller) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.relationships,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...controller.relationships.map((rel) {
            final otherCharId = rel.character1Id == controller.character.id
                ? rel.character2Id
                : rel.character1Id;
            final otherChar = controller.getCharacter(otherCharId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: otherChar?.imageBytes != null
                        ? MemoryImage(otherChar!.imageBytes!)
                        : null,
                    child: otherChar?.imageBytes == null
                        ? Text(otherChar?.name.isNotEmpty == true
                            ? otherChar!.name[0].toUpperCase()
                            : '?')
                        : null,
                  ),
                  title: Text(rel.name),
                  subtitle: Text(otherChar?.name ?? s.unknown),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => EditRelationshipBottomSheet(
                        relationship: rel,
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        OutlinedButton.icon(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const EditRelationshipBottomSheet(),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: Text(s.add_relationships),
        ),
      ],
    );
  }

  Widget _buildMediaSection(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    final s = S.of(context);
    final showReference = _shouldShowField('referenceImage');
    final showGallery = _shouldShowField('additionalImages');

    if (showReference && showGallery) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 136,
            child: ReferenceImagePicker(
              imageBytes: controller.character.referenceImageBytes,
              onPickImage: () => _pickReferenceImage(context, controller),
              title: s.reference_image,
            ),
          ),
          const SizedBox(width: _fieldSpacing),
          Expanded(
            child: ImageGallerySection(
              images: controller.additionalImages,
              onAddImage: () => _pickAdditionalImage(context, controller),
              onRemoveImage: (index) =>
                  _removeAdditionalImage(context, controller, index),
              title: s.additional_images,
              emptyText: s.no_additional_images,
              addTooltip: s.add_picture,
            ),
          ),
        ],
      );
    }

    if (showReference) {
      return ReferenceImagePicker(
        imageBytes: controller.character.referenceImageBytes,
        onPickImage: () => _pickReferenceImage(context, controller),
        title: s.reference_image,
      );
    }

    if (showGallery) {
      return ImageGallerySection(
        images: controller.additionalImages,
        onAddImage: () => _pickAdditionalImage(context, controller),
        onRemoveImage: (index) =>
            _removeAdditionalImage(context, controller, index),
        title: s.additional_images,
        emptyText: s.no_additional_images,
        addTooltip: s.add_picture,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTemplateChip(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: _fieldSpacing),
      child: Chip(
        label: Text(
          '${s.template}: ${widget.template!.name}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildAvatarSection(
    BuildContext context,
    CharacterManagementController controller, {
    double size = _avatarSize,
  }) {
    return AvatarPicker(
      currentAvatar: controller.character.imageBytes,
      onAvatarChanged: (bytes) {
        controller.updateMainImage(bytes);
      },
      size: size,
    );
  }

  Widget _buildAgeAndGenderRow(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_shouldShowField('age'))
          CustomTextField(
            label: s.age,
            initialValue: controller.character.age.toString(),
            isRequired: _shouldShowField('age'),
            keyboardType: TextInputType.number,
            onChanged: (value) => controller.updateAge(int.tryParse(value) ?? 0),
            validator: _shouldShowField('age')
                ? (value) {
                    if (value == null || value.isEmpty) return s.enter_age;
                    final age = int.tryParse(value);
                    if (age == null || age <= 0) return s.invalid_age;
                    return null;
                  }
                : null,
          ),
        if (_shouldShowField('age') && _shouldShowField('gender'))
          const SizedBox(height: _fieldSpacing),
        if (_shouldShowField('gender'))
          GenderSelectorField(
            initialValue: controller.character.gender,
            onChanged: (value) => controller.updateGender(value ?? ''),
            isRequired: _shouldShowField('gender'),
          ),
      ],
    );
  }

  List<Widget> _buildFullscreenFields(
    BuildContext context,
    CharacterManagementController controller,
    List<String> fieldNames,
  ) {
    final s = S.of(context);
    final fields = {
      'appearance': s.appearance,
      'personality': s.personality,
      'biography': s.biography,
      'abilities': s.abilities,
      'other': s.other,
    };

    return fieldNames
        .where((fieldName) => _shouldShowField(fieldName))
        .where(fields.containsKey)
        .map((fieldName) {
          final label = fields[fieldName]!;
          return Padding(
            padding: const EdgeInsets.only(top: _fieldSpacing),
            child: _FullscreenTextField(
              label: label,
              value: _getFieldValue(controller, fieldName) ?? '',
              onTap: () => _openFullscreenEditor(
                context,
                controller,
                fieldName,
                label,
              ),
              maxLines: 3,
            ),
          );
        })
        .toList();
  }

  String? _getFieldValue(
    CharacterManagementController controller,
    String fieldName,
  ) {
    switch (fieldName) {
      case 'appearance':
        return controller.character.appearance;
      case 'personality':
        return controller.character.personality;
      case 'biography':
        return controller.character.biography;
      case 'abilities':
        return controller.character.abilities;
      case 'other':
        return controller.character.other;
      default:
        return '';
    }
  }

  Future<void> _openFullscreenEditor(
    BuildContext context,
    CharacterManagementController controller,
    String fieldName,
    String label,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FieldEditorScreen(
          title: label,
          initialKey: 'description',
          initialValue: _getFieldValue(controller, fieldName) ?? '',
          onAutoSave: (result) {
            controller.updateTextField(fieldName, result.value);
          },
        ),
      ),
    );
    if (result != null) {
      controller.updateTextField(fieldName, result.value);
    }
  }

  void _removeAdditionalImage(
    BuildContext context,
    CharacterManagementController controller,
    int index,
  ) {
    final removedImage = controller.additionalImages[index];
    controller.removeAdditionalImage(index);
    final s = S.of(context);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.image_removed),
        action: SnackBarAction(
          label: s.undo,
          onPressed: () {
            controller.insertAdditionalImage(index, removedImage);
          },
        ),
      ),
    );
  }

  bool _shouldShowField(String fieldName) {
    return widget.template?.containsField(fieldName) ?? true;
  }

  Future<void> _pickReferenceImage(
    BuildContext context,
    CharacterManagementController controller,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final errorLabel = S.of(context).error;

    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      controller.updateReferenceImage(bytes);
    } catch (e) {
      _showError(messenger, errorColor, errorLabel, e.toString());
    }
  }

  Future<void> _pickAdditionalImage(
    BuildContext context,
    CharacterManagementController controller,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final errorLabel = S.of(context).error;

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      controller.addAdditionalImage(bytes);
    } catch (e) {
      _showError(messenger, errorColor, errorLabel, e.toString());
    }
  }

  void _showError(
    ScaffoldMessengerState messenger,
    Color errorColor,
    String errorLabel,
    String message,
  ) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('$errorLabel: $message'),
        backgroundColor: errorColor,
      ),
    );
  }
}

class _FullscreenTextField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final int? maxLines;

  const _FullscreenTextField({
    required this.label,
    required this.value,
    required this.onTap,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Icon(
                  Icons.open_in_full,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value.isEmpty ? '${s.edit}...' : value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: value.isEmpty
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                    fontStyle: value.isEmpty ? FontStyle.italic : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}