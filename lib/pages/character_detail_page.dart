import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:docx_template/docx_template.dart' as docx;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../generated/l10n.dart';

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

      final file = await File(filePath).writeAsBytes((docxDoc) as List<int>);
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

  Future<void> _copyToClipboard(BuildContext context) async {

    final characterInfo = '${S.of(context).name}: ${character.name}\n'
        '${S.of(context).age}: ${character.age}\n'
        '${S.of(context).gender}: ${character.gender}\n'
        '${S.of(context).biography}: ${character.biography}\n'
        '${S.of(context).appearance}: ${character.appearance}\n'
        '${S.of(context).personality}: ${character.personality}\n';

    await Clipboard.setData(ClipboardData(text: characterInfo));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Информация скопирована в буфер обмена')),
      );
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
            tooltip: S.of(context).export,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(context),
            tooltip: S.of(context).copy,
          )
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
                backgroundImage: MemoryImage(character.imageBytes!),
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
            const SizedBox(height: 16),
            _buildSectionTitle('Способности'),
            _buildSectionContent(character.abilities),
            const SizedBox(height: 16),
            _buildSectionTitle('Прочее'),
            _buildSectionContent(character.other),
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