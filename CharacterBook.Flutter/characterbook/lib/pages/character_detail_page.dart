import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:docx_template/docx_template.dart' as docx;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'character_edit_page.dart';
import '../models/character_model.dart';

class CharacterDetailPage extends StatelessWidget {
  final Character character;

  const CharacterDetailPage({super.key, required this.character});

  Future<void> _exportToDocx(BuildContext context) async {
    try {
      final docxDoc = await docx.DocxTemplate.fromBytes(Uint8List(0));

      final data = {
        'name': character.name,
        'age': character.age.toString(),
        'gender': character.gender,
        'biography': character.biography,
        'personality': character.personality,
        'appearance': character.appearance,
      };

      await docxDoc.generate(data as docx.Content);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${character.name}_character.docx';

      final file = await File(filePath).writeAsBytes((await docxDoc) as List<int>);
      await OpenFile.open(file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Персонаж экспортирован в $filePath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при экспорте: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CharacterEditPage(character: character),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportToDocx(context),
            tooltip: 'Экспорт в DOCX',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: character.imageBytes != null
                  ? CircleAvatar(
                backgroundImage: MemoryImage(character.imageBytes! as Uint8List),
                radius: 80,
              )
                  : const CircleAvatar(
                radius: 80,
                child: Icon(Icons.person, size: 60),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Имя', character.name),
            _buildInfoRow('Возраст', '${character.age} лет'),
            _buildInfoRow('Пол', character.gender),
            const SizedBox(height: 16),
            _buildSectionTitle('Биография'),
            _buildSectionContent(character.biography),
            const SizedBox(height: 16),
            _buildSectionTitle('Характер'),
            _buildSectionContent(character.personality),
            const SizedBox(height: 16),
            _buildSectionTitle('Внешность'),
            _buildSectionContent(character.appearance),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(fontSize: 16),
    );
  }
}