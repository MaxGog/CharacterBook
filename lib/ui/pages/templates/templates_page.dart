import 'package:flutter/material.dart';
import 'package:characterbook/ui/pages/templates/template_edit_page.dart';
import 'package:characterbook/models/template_model.dart';
import 'package:characterbook/services/template_service.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  final TemplateService _templateService = TemplateService();
  late Future<List<QuestionnaireTemplate>> _templatesFuture;

  @override
  void initState() {
    super.initState();
    _templatesFuture = _templateService.getAllTemplates();
  }

  void _refreshTemplates() {
    setState(() {
      _templatesFuture = _templateService.getAllTemplates();
    });
  }

  Future<void> _deleteTemplate(String name) async {
    await _templateService.deleteTemplate(name);
    _refreshTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Шаблоны анкет'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TemplateEditPage(
                    onSaved: _refreshTemplates,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<QuestionnaireTemplate>>(
        future: _templatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final templates = snapshot.data ?? [];

          if (templates.isEmpty) {
            return const Center(
              child: Text('Нет сохранённых шаблонов'),
            );
          }

          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return ListTile(
                title: Text(template.name),
                subtitle: Text(
                  'Поля: ${template.standardFields.length + template.customFields.length}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TemplateEditPage(
                              template: template,
                              onSaved: _refreshTemplates,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteTemplate(template.name),
                    ),
                  ],
                ),
                onTap: () {
                  // Применение шаблона к новому персонажу
                  Navigator.pop(context, template);
                },
              );
            },
          );
        },
      ),
    );
  }
}