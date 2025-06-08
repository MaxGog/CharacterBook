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
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _biologyController;
  late TextEditingController _backstoryController;
  late Uint8List? _logoBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.race?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.race?.description ?? '');
    _biologyController = TextEditingController(text: widget.race?.biology ?? '');
    _backstoryController =
        TextEditingController(text: widget.race?.backstory ?? '');
    _logoBytes = widget.race?.logo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _biologyController.dispose();
    _backstoryController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _logoBytes = bytes;
        });
      }
    } catch (e) {
      _showError('Ошибка при выборе изображения: ${e.toString()}');
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
      final race = widget.race ?? Race(name: _nameController.text);

      race
        ..name = _nameController.text
        ..description = _descriptionController.text
        ..biology = _biologyController.text
        ..backstory = _backstoryController.text
        ..logo = _logoBytes;

      if (widget.race == null) {
        await raceBox.add(race);
      } else {
        await race.save();
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Ошибка сохранения: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.race == null ? 'Новая раса' : 'Редактировать расу',
          style: textTheme.titleLarge,
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
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(60),
                  onTap: _pickLogo,
                  child: Ink(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: _logoBytes != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.memory(
                        _logoBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(
                      Icons.add_photo_alternate,
                      size: 40,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Название расы',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: textTheme.bodyLarge,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Введите название расы' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                style: textTheme.bodyLarge,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _biologyController,
                decoration: InputDecoration(
                  labelText: 'Биология',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                style: textTheme.bodyLarge,
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _backstoryController,
                decoration: InputDecoration(
                  labelText: 'Предыстория',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                style: textTheme.bodyLarge,
                maxLines: 7,
              ),
              const SizedBox(height: 32),

              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveRace,
                child: Text(
                  'Сохранить',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}