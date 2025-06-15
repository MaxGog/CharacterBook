import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../models/race_model.dart';
import '../../widgets/avatar_picker_widget.dart';
import '../../widgets/fields/custom_text_field.dart';
import '../../widgets/save_button_widget.dart';
import '../../widgets/unsaved_changes_dialog.dart';

class RaceManagementPage extends StatefulWidget {
  final Race? race;

  const RaceManagementPage({super.key, this.race});

  @override
  State<RaceManagementPage> createState() => _RaceManagementPageState();
}

class _RaceManagementPageState extends State<RaceManagementPage> {
  static const _logoSize = 120.0;
  static const _borderRadius = 12.0;
  static const _buttonHeight = 50.0;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _biologyController;
  late final TextEditingController _backstoryController;
  Uint8List? _logoBytes;

  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    final race = widget.race;
    _nameController = TextEditingController(text: race?.name ?? '');
    _descriptionController = TextEditingController(text: race?.description ?? '');
    _biologyController = TextEditingController(text: race?.biology ?? '');
    _backstoryController = TextEditingController(text: race?.backstory ?? '');
    _logoBytes = race?.logo;
    _hasUnsavedChanges = widget.race == null;
    _setupControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _biologyController.dispose();
    _backstoryController.dispose();
    super.dispose();
  }

  void _setupControllers() {
    _nameController.addListener(() => setState(() => _hasUnsavedChanges = true));
    _descriptionController.addListener(() => setState(() => _hasUnsavedChanges = true));
    _biologyController.addListener(() => setState(() => _hasUnsavedChanges = true));
    _backstoryController.addListener(() => setState(() => _hasUnsavedChanges = true));
  }

  Future<void> _saveRace() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nameController.text.isEmpty) {
      _showError('Введите название расы');
      return;
    }

    try {
      final raceBox = Hive.box<Race>('races');
      final race = widget.race ?? Race(name: _nameController.text)
        ..name = _nameController.text
        ..description = _descriptionController.text
        ..biology = _biologyController.text
        ..backstory = _backstoryController.text
        ..logo = _logoBytes;

      widget.race == null ? await raceBox.add(race) : await race.save();

      setState(() => _hasUnsavedChanges = false);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Ошибка сохранения: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (!_hasUnsavedChanges) return true;
        final shouldSave = await UnsavedChangesDialog(
          saveText: 'Сохранить расу',
        ).show(context);
        if (shouldSave == null) return false;
        if (shouldSave) await _saveRace();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.race == null ? 'Новая раса' : 'Редактировать расу',
            style: theme.textTheme.titleLarge,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveRace,
              tooltip: 'Сохранить',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarPicker(
                  imageBytes: _logoBytes,
                  onImageSelected: (bytes) {
                    setState(() {
                      _logoBytes = bytes;
                      _hasUnsavedChanges = true;
                    });
                  },
                  radius: _logoSize / 2,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  placeholderIcon: Icons.add_photo_alternate,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  label: 'Название расы',
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Описание',
                  maxLines: 3,
                  alignLabel: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _biologyController,
                  label: 'Биология',
                  maxLines: 5,
                  alignLabel: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _backstoryController,
                  label: 'Предыстория',
                  maxLines: 7,
                  alignLabel: true,
                ),
                const SizedBox(height: 32),
                SaveButton(
                  onPressed: _saveRace,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}