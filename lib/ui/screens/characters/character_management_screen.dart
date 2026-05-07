import 'dart:async';

import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:characterbook/data/repositories/character_repository.dart';
import 'package:characterbook/data/repositories/race_repository.dart';
import 'package:characterbook/ui/controllers/character_management_controller.dart';
import 'package:characterbook/ui/screens/field_editor_screen.dart';
import 'package:characterbook/ui/widgets/avatar_picker_widget.dart';
import 'package:characterbook/ui/widgets/fields/custom_fields_editor.dart';
import 'package:characterbook/ui/widgets/fields/custom_text_field.dart';
import 'package:characterbook/ui/widgets/fields/gender_selector_field.dart';
import 'package:characterbook/ui/widgets/fields/race_selector_field.dart';
import 'package:characterbook/ui/widgets/reference_image_picker.dart';
import 'package:characterbook/ui/widgets/sections/image_gallery_section.dart';
import 'package:characterbook/ui/widgets/sections/tags_section.dart';
import 'package:flutter/material.dart';
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

class _CharacterManagementScreenState extends State<CharacterManagementScreen> {
  static const _sectionSpacing = 24.0;
  static const _fieldSpacing = 16.0;
  static const _maxFormWidth = 600.0;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _nameController;
  Timer? _nameDebounce;
  CharacterManagementController? _controller;

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
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && newName != controller.character.name) {
        controller.updateName(newName);
      }
    });
  }

  Future<void> _onSavePressed(BuildContext context) async {
    final controller = _controller;
    if (controller == null) return;

    FocusScope.of(context).unfocus();

    final success = await controller.save();
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      final errorMsg = controller.error ?? S.of(context).error;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterManagementController(
        characterRepo: context.read<CharacterRepository>(),
        raceRepo: context.read<RaceRepository>(),
        character: widget.character,
        template: widget.template,
      ),
      child: Consumer<CharacterManagementController>(
        builder: (context, controller, child) {
          _controller = controller;
          final s = S.of(context);
          if (_nameController.text != (controller.character.name)) {
            _nameController.text = controller.character.name;
          }
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _onSavePressed(context),
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
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                                _buildFolderAndTagsSection(context, controller),
                                if (widget.template != null)
                                  _buildTemplateChip(context),
                                const SizedBox(height: _sectionSpacing),
                                Center(
                                  child: _buildAvatarSection(context, controller),
                                ),
                                const SizedBox(height: _sectionSpacing),
                                _buildBasicInfoSection(context, controller),
                                const SizedBox(height: _sectionSpacing),
                                _buildDetailsSection(context, controller),
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
    CharacterManagementController controller,
    S s,
  ) {
    final theme = Theme.of(context);
    return SliverAppBar.large(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(true),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      ),
      title: TextField(
        controller: _nameController,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration.collapsed(
          hintText: widget.character == null
              ? (widget.template == null
                  ? s.new_character
                  : '${s.new_character} (${s.from_template})')
              : s.edit_character,
          hintStyle: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        cursorColor: theme.colorScheme.primary,
        maxLines: 1,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
      ),
      pinned: true,
    );
  }

  Widget _buildFolderAndTagsSection(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    return TagsSection(
      tags: controller.tags,
      onTagsChanged: controller.setTags,
    );
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
    CharacterManagementController controller,
  ) {
    return AvatarPicker(
      currentAvatar: controller.character.imageBytes,
      onAvatarChanged: (bytes) {
        controller.updateMainImage(bytes);
      },
    );
  }

  Widget _buildBasicInfoSection(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAgeAndGenderRow(context, controller),
        if (_shouldShowField('race'))
          Padding(
            padding: const EdgeInsets.only(top: _fieldSpacing),
            child: RaceSelectorField(
              initialRace: controller.character.race,
              onChanged: (race) => controller.updateRace(race),
            ),
          ),
        if (_shouldShowField('referenceImage'))
          Padding(
            padding: const EdgeInsets.only(top: _fieldSpacing),
            child: ReferenceImagePicker(
              imageBytes: controller.character.referenceImageBytes,
              onPickImage: () => _pickReferenceImage(context, controller),
              title: s.reference_image,
            ),
          ),
      ],
    );
  }

  Widget _buildAgeAndGenderRow(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    final s = S.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_shouldShowField('age'))
          Expanded(
            child: CustomTextField(
              label: s.age,
              initialValue: controller.character.age.toString(),
              isRequired: _shouldShowField('age'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  controller.updateAge(int.tryParse(value) ?? 0),
              validator: _shouldShowField('age')
                  ? (value) {
                      if (value == null || value.isEmpty) return s.enter_age;
                      final age = int.tryParse(value);
                      if (age == null || age <= 0) return s.invalid_age;
                      return null;
                    }
                  : null,
            ),
          ),
        if (_shouldShowField('age') && _shouldShowField('gender'))
          const SizedBox(width: _fieldSpacing),
        if (_shouldShowField('gender'))
          Expanded(
            child: GenderSelectorField(
              initialValue: controller.character.gender,
              onChanged: (value) => controller.updateGender(value ?? ''),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomFieldsEditor(
          initialFields: controller.customFields,
          onFieldsChanged: controller.setCustomFields,
          verticalLayout: true,
          useFullscreenEditor: true,
        ),
        if (_shouldShowField('additionalImages'))
          Padding(
            padding: const EdgeInsets.only(top: _fieldSpacing),
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
        ..._buildFullscreenFields(context, controller),
      ],
    );
  }

  List<Widget> _buildFullscreenFields(
    BuildContext context,
    CharacterManagementController controller,
  ) {
    final s = S.of(context);
    final fields = [
      ('appearance', s.appearance),
      ('personality', s.personality),
      ('biography', s.biography),
      ('abilities', s.abilities),
      ('other', s.other),
    ];

    return fields
        .where((e) => _shouldShowField(e.$1))
        .map((entry) => Padding(
              padding: const EdgeInsets.only(top: _fieldSpacing),
              child: _FullscreenTextField(
                label: entry.$2,
                value: _getFieldValue(controller, entry.$1) ?? '',
                onTap: () => _openFullscreenEditor(
                    context, controller, entry.$1, entry.$2),
                maxLines: 3,
              ),
            ))
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
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      controller.updateReferenceImage(bytes);
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _pickAdditionalImage(
    BuildContext context,
    CharacterManagementController controller,
  ) async {
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
      _showError(context, e.toString());
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${S.of(context).error}: $message'),
        backgroundColor: Theme.of(context).colorScheme.error,
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