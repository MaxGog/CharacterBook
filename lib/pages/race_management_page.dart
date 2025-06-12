import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../models/race_model.dart';

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
  final _picker = ImagePicker();
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
  }

  @override
  void dispose() {
    _nameController.removeListener(() {});
    _descriptionController.removeListener(() {});
    _biologyController.removeListener(() {});
    _backstoryController.removeListener(() {});
    super.dispose();
  }

  void _setupControllers() {
    _nameController.addListener(() => setState(() => _hasUnsavedChanges = true));
    _descriptionController.addListener(() => setState(() => _hasUnsavedChanges = true));
    _biologyController.addListener(() => setState(() => _hasUnsavedChanges = true));
    _backstoryController.addListener(() => setState(() => _hasUnsavedChanges = true));
  }

  Future<void> _pickLogo() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      setState(() {
        _logoBytes = bytes;
        _hasUnsavedChanges = true;
      });
    } catch (e) {
      _showError('Ошибка при выборе изображения: $e');
    }
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

  Future<bool> _checkUnsavedChanges() async {
    if (!_hasUnsavedChanges) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Несохраненные изменения'),
        content: const Text('У вас есть несохраненные изменения. Хотите сохранить перед выходом?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Не сохранять'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              _saveRace();
            },
            child: const Text('Сохранить'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
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

  Widget _buildLogoPicker() {
    final theme = Theme.of(context);
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(_logoSize / 2),
        onTap: _pickLogo,
        child: Ink(
          width: _logoSize,
          height: _logoSize,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(_logoSize / 2),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: _logoBytes != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(_logoSize / 2),
            child: Image.memory(
              _logoBytes!,
              fit: BoxFit.cover,
            ),
          )
              : Icon(
            Icons.add_photo_alternate,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          alignLabelWithHint: maxLines > 1,
        ),
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: maxLines,
        validator: isRequired
            ? (value) => value?.isEmpty ?? true ? 'Обязательное поле' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        return await _checkUnsavedChanges();
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
                _buildLogoPicker(),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nameController,
                  label: 'Название расы',
                  isRequired: true,
                ),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Описание',
                  maxLines: 3,
                ),
                _buildTextField(
                  controller: _biologyController,
                  label: 'Биология',
                  maxLines: 5,
                ),
                _buildTextField(
                  controller: _backstoryController,
                  label: 'Предыстория',
                  maxLines: 7,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: _buttonHeight,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_borderRadius),
                      ),
                    ),
                    onPressed: _saveRace,
                    child: Text(
                      'Сохранить',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}