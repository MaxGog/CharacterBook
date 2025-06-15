import 'package:flutter/material.dart';
import 'package:characterbook/models/template_model.dart';
import 'package:characterbook/services/template_service.dart';

import '../../../models/custom_field_model.dart';
import '../../widgets/fields/custom_fields_editor.dart';
import '../../widgets/fields/custom_text_field.dart';

class TemplateEditPage extends StatefulWidget {
  final QuestionnaireTemplate? template;
  final VoidCallback? onSaved;

  const TemplateEditPage({
    super.key,
    this.template,
    this.onSaved,
  });

  @override
  State<TemplateEditPage> createState() => _TemplateEditPageState();
}

class _TemplateEditPageState extends State<TemplateEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TemplateService _templateService = TemplateService();

  late String _name;
  late List<String> _standardFields;
  late List<CustomField> _customFields;

  final List<String> _availableStandardFields = [
    'name',
    'age',
    'gender',
    'biography',
    'personality',
    'appearance',
    'abilities',
    'other',
    'image',
    'referenceImage',
    'additionalImages',
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.template?.name ?? '';
    _standardFields = widget.template?.standardFields.toList() ?? [];
    _customFields = widget.template?.customFields.map((f) => f.copyWith()).toList() ?? [];
  }

  Future<void> _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final template = QuestionnaireTemplate(
        name: _name,
        standardFields: _standardFields,
        customFields: _customFields,
      );

      await _templateService.saveTemplate(template);
      if (widget.onSaved != null) widget.onSaved!();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template == null ? 'Новый шаблон' : 'Редактирование'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTemplate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Название шаблона',
                initialValue: _name,
                isRequired: true,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 24),
              const Text(
                'Стандартные поля:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableStandardFields.map((field) {
                  final isSelected = _standardFields.contains(field);
                  return FilterChip(
                    label: Text(_getFieldDisplayName(field)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _standardFields.add(field);
                        } else {
                          _standardFields.remove(field);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              CustomFieldsEditor(
                initialFields: _customFields,
                onFieldsChanged: (fields) => _customFields = fields,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'name':
        return 'Имя';
      case 'age':
        return 'Возраст';
      case 'gender':
        return 'Пол';
      case 'biography':
        return 'Биография';
      case 'personality':
        return 'Характер';
      case 'appearance':
        return 'Внешность';
      case 'abilities':
        return 'Способности';
      case 'other':
        return 'Прочее';
      case 'image':
        return 'Основное изображение';
      case 'referenceImage':
        return 'Референс';
      case 'additionalImages':
        return 'Доп. изображения';
      default:
        return field;
    }
  }
}