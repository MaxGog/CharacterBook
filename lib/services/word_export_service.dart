import 'dart:typed_data';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/models/template_model.dart';
import 'package:docs_gee/docs_gee.dart';
import 'package:characterbook/data/models/character_model.dart';

class WordExportService {
  final Character character;

  const WordExportService(this.character);

  Future<Uint8List> generate() async {
    final doc = Document(
      title: character.name,
      author: 'CharacterBook',
      includeTableOfContents: true,
      tocTitle: 'Содержание',
      tocMaxLevel: 2,
    );

    doc.addParagraph(Paragraph.heading(character.name, level: 1));

    final rows = <TableRow>[
      TableRow(cells: [
        TableCell.text('Возраст', backgroundColor: 'E0E0E0'),
        TableCell.text(character.age.toString()),
      ]),
      TableRow(cells: [
        TableCell.text('Пол', backgroundColor: 'E0E0E0'),
        TableCell.text(character.gender),
      ]),
      if (character.race != null)
        TableRow(cells: [
          TableCell.text('Раса', backgroundColor: 'E0E0E0'),
          TableCell.text(character.race!.name),
        ]),
    ];

    doc.addTable(Table(
      borders: TableBorders.all(),
      rows: rows,
    ));
    doc.addParagraph(Paragraph.text(''));

    _addSection(doc, 'Биография', character.biography);
    _addSection(doc, 'Характер', character.personality);
    _addSection(doc, 'Внешность', character.appearance);
    _addSection(doc, 'Способности', character.abilities);
    _addSection(doc, 'Другое', character.other);

    if (character.customFields.isNotEmpty) {
      doc.addParagraph(Paragraph.heading('Дополнительные поля', level: 2));
      for (final field in character.customFields) {
        doc.addParagraph(Paragraph.text('${field.key}: ${field.value}'));
      }
    }

    return DocxGenerator().generate(doc);
  }

  void _addSection(Document doc, String title, String content) {
    if (content.isEmpty) return;
    doc.addParagraph(Paragraph.heading(title, level: 2));
    doc.addParagraph(Paragraph.text(content));
    doc.addParagraph(Paragraph.text(''));
  }
}

class RaceWordExportService {
  final Race race;

  const RaceWordExportService(this.race);

  Future<Uint8List> generate() async {
    final doc = Document(
      title: race.name,
      author: 'CharacterBook',
      includeTableOfContents: true,
      tocTitle: 'Содержание',
      tocMaxLevel: 2,
    );

    doc.addParagraph(Paragraph.heading(race.name, level: 1));

    _addSection(doc, 'Описание', race.description);
    _addSection(doc, 'Биология', race.biology);
    _addSection(doc, 'История', race.backstory);

    if (race.tags.isNotEmpty) {
      doc.addParagraph(Paragraph.heading('Теги', level: 2));
      doc.addParagraph(Paragraph.text(race.tags.join(', ')));
    }

    return DocxGenerator().generate(doc);
  }

  void _addSection(Document doc, String title, String content) {
    if (content.isEmpty) return;
    doc.addParagraph(Paragraph.heading(title, level: 2));
    doc.addParagraph(Paragraph.text(content));
    doc.addParagraph(Paragraph.text(''));
  }
}

class TemplateWordExportService {
  final QuestionnaireTemplate template;

  const TemplateWordExportService(this.template);

  Future<Uint8List> generate() async {
    final doc = Document(
      title: template.name,
      author: 'CharacterBook',
      includeTableOfContents: false,
    );

    doc.addParagraph(Paragraph.heading(template.name, level: 1));

    if (template.standardFields.isNotEmpty) {
      doc.addParagraph(Paragraph.heading('Стандартные поля', level: 2));
      doc.addParagraph(Paragraph.text(template.standardFields.join(', ')));
    }

    if (template.customFields.isNotEmpty) {
      doc.addParagraph(Paragraph.heading('Дополнительные поля', level: 2));
      for (final field in template.customFields) {
        doc.addParagraph(Paragraph.text(
            '${field.key}: ${field.value.isNotEmpty ? field.value : "—"}'));
      }
    }

    return DocxGenerator().generate(doc);
  }
}
