// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(name) => "Персонаж создан из шаблона \"${name}\"";

  static String m1(name) => "Персонаж \"${name}\" успешно импортирован";

  static String m2(name) => "Файл персонажа ${name}";

  static String m3(charactersCount, notesCount, racesCount, templatesCount) =>
      "Успешно восстановлено:\n${charactersCount} персонажей\n${notesCount} заметок\n${racesCount} рас\n${templatesCount} шаблонов";

  static String m4(count) => "${count} полей";

  static String m5(error) => "Ошибка при выборе изображения: ${error}";

  static String m6(error) => "Ошибка импорта: ${error}";

  static String m7(name) => "Раса \"${name}\" успешно импортирована";

  static String m8(name) => "Файл расы ${name}";

  static String m9(name) => "Шаблон \"${name}\" успешно экспортирован";

  static String m10(name) => "Шаблон \"${name}\" успешно импортирован";

  static String m11(name) => "Шаблон \"${name}\" уже существует. Заменить его?";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "a_to_z": MessageLookupByLibrary.simpleMessage("А-Я"),
        "abilities": MessageLookupByLibrary.simpleMessage("Способности"),
        "aboutApp": MessageLookupByLibrary.simpleMessage("О приложении"),
        "accentColor": MessageLookupByLibrary.simpleMessage("Акцентный цвет"),
        "acknowledgements":
            MessageLookupByLibrary.simpleMessage("Благодарности"),
        "add_picture":
            MessageLookupByLibrary.simpleMessage("Добавить изображение"),
        "additional_images":
            MessageLookupByLibrary.simpleMessage("Доп. изображения"),
        "adults": MessageLookupByLibrary.simpleMessage("Взрослые"),
        "age": MessageLookupByLibrary.simpleMessage("Возраст"),
        "age_asc": MessageLookupByLibrary.simpleMessage("Возраст ↑"),
        "age_desc": MessageLookupByLibrary.simpleMessage("Возраст ↓"),
        "all": MessageLookupByLibrary.simpleMessage("Все"),
        "all_tags": MessageLookupByLibrary.simpleMessage("Все теги"),
        "another": MessageLookupByLibrary.simpleMessage("Другой"),
        "appLanguage": MessageLookupByLibrary.simpleMessage("Язык приложения"),
        "app_name": MessageLookupByLibrary.simpleMessage("CharacterBook"),
        "appearance": MessageLookupByLibrary.simpleMessage("Внешность"),
        "auth_cancelled":
            MessageLookupByLibrary.simpleMessage("Авторизация отменена"),
        "auth_client_error": MessageLookupByLibrary.simpleMessage(
            "Не удалось получить клиент для API"),
        "back": MessageLookupByLibrary.simpleMessage("Назад"),
        "backstory": MessageLookupByLibrary.simpleMessage("Предыстория"),
        "backup": MessageLookupByLibrary.simpleMessage("Резервное копирование"),
        "basic_info":
            MessageLookupByLibrary.simpleMessage("Основная информация"),
        "biography": MessageLookupByLibrary.simpleMessage("Биография"),
        "biology": MessageLookupByLibrary.simpleMessage("Биология"),
        "blue": MessageLookupByLibrary.simpleMessage("Синий"),
        "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
        "character": MessageLookupByLibrary.simpleMessage("Персонаж"),
        "character_avatar":
            MessageLookupByLibrary.simpleMessage("Аватар персонажа"),
        "character_created_from_template": m0,
        "character_delete_confirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить этого персонажа? Это действие нельзя отменить."),
        "character_delete_title":
            MessageLookupByLibrary.simpleMessage("Удалить персонажа?"),
        "character_deleted":
            MessageLookupByLibrary.simpleMessage("Персонаж удален"),
        "character_gallery":
            MessageLookupByLibrary.simpleMessage("Галерея персонажа"),
        "character_imported": m1,
        "character_reference":
            MessageLookupByLibrary.simpleMessage("Референс персонажа"),
        "character_share_text": m2,
        "characters": MessageLookupByLibrary.simpleMessage("Персонажи"),
        "children": MessageLookupByLibrary.simpleMessage("Дети"),
        "cloud_backup_characters_error": MessageLookupByLibrary.simpleMessage(
            "Ошибка при создании резервной копии персонажей"),
        "cloud_backup_characters_success": MessageLookupByLibrary.simpleMessage(
            "Резервная копия персонажей успешно создана"),
        "cloud_backup_error": MessageLookupByLibrary.simpleMessage(
            "Ошибка при создании резервной копии"),
        "cloud_backup_full_success": MessageLookupByLibrary.simpleMessage(
            "Полная резервная копия успешно создана в Google Drive"),
        "cloud_backup_not_found":
            MessageLookupByLibrary.simpleMessage("Резервные копии не найдены"),
        "cloud_export_error": MessageLookupByLibrary.simpleMessage(
            "Ошибка при экспорте в Google Drive"),
        "cloud_import_error": MessageLookupByLibrary.simpleMessage(
            "Ошибка при импорте из Google Drive"),
        "cloud_restore_error": MessageLookupByLibrary.simpleMessage(
            "Ошибка при восстановлении данных"),
        "cloud_restore_success": m3,
        "colorScheme": MessageLookupByLibrary.simpleMessage("Цветовая схема"),
        "copied_to_clipboard":
            MessageLookupByLibrary.simpleMessage("Скопировано в буфер обмена"),
        "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
        "copy_character":
            MessageLookupByLibrary.simpleMessage("Скопировать персонажа"),
        "copy_error":
            MessageLookupByLibrary.simpleMessage("Ошибка копирования"),
        "create": MessageLookupByLibrary.simpleMessage("Создать"),
        "createBackup":
            MessageLookupByLibrary.simpleMessage("Создать резервную копию"),
        "create_character":
            MessageLookupByLibrary.simpleMessage("Создать персонажа"),
        "create_from_template_tooltip":
            MessageLookupByLibrary.simpleMessage("Создать из шаблона"),
        "create_template_tooltip":
            MessageLookupByLibrary.simpleMessage("Создать шаблон"),
        "custom_fields":
            MessageLookupByLibrary.simpleMessage("Пользовательские поля"),
        "dark": MessageLookupByLibrary.simpleMessage("Тёмная"),
        "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
        "delete_character":
            MessageLookupByLibrary.simpleMessage("Удалить персонажа"),
        "delete_error":
            MessageLookupByLibrary.simpleMessage("Ошибка при удалении"),
        "description": MessageLookupByLibrary.simpleMessage("Описание"),
        "developer": MessageLookupByLibrary.simpleMessage("Разработчик"),
        "discard_changes": MessageLookupByLibrary.simpleMessage("Не сохранять"),
        "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
        "edit_character":
            MessageLookupByLibrary.simpleMessage("Редактировать персонажа"),
        "edit_race": MessageLookupByLibrary.simpleMessage("Редактировать расу"),
        "edit_template": MessageLookupByLibrary.simpleMessage("Редактирование"),
        "elderly": MessageLookupByLibrary.simpleMessage("Пожилые"),
        "empty_list": MessageLookupByLibrary.simpleMessage("Здесь пусто!"),
        "enter_age": MessageLookupByLibrary.simpleMessage("Введите возраст"),
        "enter_race_name":
            MessageLookupByLibrary.simpleMessage("Введите название расы"),
        "error": MessageLookupByLibrary.simpleMessage("Ошибка"),
        "error_loading_notes": MessageLookupByLibrary.simpleMessage(
            "Ошибка загрузки связанных постов"),
        "export": MessageLookupByLibrary.simpleMessage("Экспорт"),
        "export_error": MessageLookupByLibrary.simpleMessage("Ошибка экспорта"),
        "female": MessageLookupByLibrary.simpleMessage("Женский"),
        "fields_count": m4,
        "file_character":
            MessageLookupByLibrary.simpleMessage("Файл (.character)"),
        "file_pdf": MessageLookupByLibrary.simpleMessage("Документ PDF (.pdf)"),
        "file_pick_error":
            MessageLookupByLibrary.simpleMessage("Ошибка выбора файла"),
        "file_ready":
            MessageLookupByLibrary.simpleMessage("Файл готов к отправке"),
        "from_template": MessageLookupByLibrary.simpleMessage("Из шаблона"),
        "gender": MessageLookupByLibrary.simpleMessage("Гендер"),
        "githubRepo":
            MessageLookupByLibrary.simpleMessage("GitHub репозиторий"),
        "green": MessageLookupByLibrary.simpleMessage("Зеленый"),
        "image": MessageLookupByLibrary.simpleMessage("Изображение"),
        "image_picker_error": m5,
        "import_cancelled":
            MessageLookupByLibrary.simpleMessage("Импорт отменен"),
        "import_character":
            MessageLookupByLibrary.simpleMessage("Импортировать персонажа"),
        "import_error": m6,
        "import_template":
            MessageLookupByLibrary.simpleMessage("Импортировать шаблон"),
        "import_template_tooltip":
            MessageLookupByLibrary.simpleMessage("Импорт шаблона"),
        "invalid_age":
            MessageLookupByLibrary.simpleMessage("Введён неверный возраст"),
        "language": MessageLookupByLibrary.simpleMessage("Язык"),
        "last_updated": MessageLookupByLibrary.simpleMessage("Обновлено"),
        "light": MessageLookupByLibrary.simpleMessage("Светлая"),
        "lightBlue": MessageLookupByLibrary.simpleMessage("Голубой"),
        "main_image":
            MessageLookupByLibrary.simpleMessage("Основное изображение"),
        "male": MessageLookupByLibrary.simpleMessage("Мужской"),
        "markdown_bold": MessageLookupByLibrary.simpleMessage("Жирный"),
        "markdown_bullet_list":
            MessageLookupByLibrary.simpleMessage("Маркированный список"),
        "markdown_inline_code":
            MessageLookupByLibrary.simpleMessage("Код (inline)"),
        "markdown_italic": MessageLookupByLibrary.simpleMessage("Курсив"),
        "markdown_numbered_list":
            MessageLookupByLibrary.simpleMessage("Нумерованный список"),
        "markdown_quote": MessageLookupByLibrary.simpleMessage("Цитата"),
        "markdown_underline":
            MessageLookupByLibrary.simpleMessage("Подчеркнутый"),
        "my": MessageLookupByLibrary.simpleMessage("Мои"),
        "my_characters": MessageLookupByLibrary.simpleMessage("Мои персонажи"),
        "name": MessageLookupByLibrary.simpleMessage("Имя"),
        "new_character": MessageLookupByLibrary.simpleMessage("Новый персонаж"),
        "new_character_from_template":
            MessageLookupByLibrary.simpleMessage("Новый персонаж (из шаблона)"),
        "new_race": MessageLookupByLibrary.simpleMessage("Новая раса"),
        "new_template": MessageLookupByLibrary.simpleMessage("Новый шаблон"),
        "no_additional_images": MessageLookupByLibrary.simpleMessage(
            "Не добавлено ни одного изображение"),
        "no_characters": MessageLookupByLibrary.simpleMessage("Нет персонажей"),
        "no_content":
            MessageLookupByLibrary.simpleMessage("Содержание отсутствует"),
        "no_data_found":
            MessageLookupByLibrary.simpleMessage("Данные не найдены"),
        "no_description":
            MessageLookupByLibrary.simpleMessage("Описание отсутствует"),
        "no_information":
            MessageLookupByLibrary.simpleMessage("Нет информации"),
        "no_race": MessageLookupByLibrary.simpleMessage("Без расы"),
        "no_races_created":
            MessageLookupByLibrary.simpleMessage("Нет созданных рас"),
        "no_templates": MessageLookupByLibrary.simpleMessage("Нет шаблонов"),
        "not_selected": MessageLookupByLibrary.simpleMessage("Не выбрано"),
        "nothing_found": MessageLookupByLibrary.simpleMessage(
            "Ничего не найдено по запросу"),
        "ok": MessageLookupByLibrary.simpleMessage("Хорошо"),
        "operationCompleted":
            MessageLookupByLibrary.simpleMessage("Операция выполнена успешно"),
        "orange": MessageLookupByLibrary.simpleMessage("Оранжевый"),
        "other": MessageLookupByLibrary.simpleMessage("Прочее"),
        "pdf_export_success":
            MessageLookupByLibrary.simpleMessage("PDF успешно экспортирован"),
        "personality": MessageLookupByLibrary.simpleMessage("Характер"),
        "pink": MessageLookupByLibrary.simpleMessage("Розовый"),
        "posts": MessageLookupByLibrary.simpleMessage("Посты"),
        "purple": MessageLookupByLibrary.simpleMessage("Фиолетовый"),
        "race": MessageLookupByLibrary.simpleMessage("Раса"),
        "race_copied":
            MessageLookupByLibrary.simpleMessage("Раса скопирована в буфер"),
        "race_delete_confirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить эту расу?"),
        "race_delete_error_content": MessageLookupByLibrary.simpleMessage(
            "Эта раса используется персонажами. Сначала измените их расу."),
        "race_delete_error_title":
            MessageLookupByLibrary.simpleMessage("Невозможно удалить расу"),
        "race_delete_title":
            MessageLookupByLibrary.simpleMessage("Удаление расы"),
        "race_deleted": MessageLookupByLibrary.simpleMessage("Раса удалена"),
        "race_imported": m7,
        "race_management":
            MessageLookupByLibrary.simpleMessage("Управление расами"),
        "race_name": MessageLookupByLibrary.simpleMessage("Название расы"),
        "race_share_text": m8,
        "races": MessageLookupByLibrary.simpleMessage("Расы"),
        "red": MessageLookupByLibrary.simpleMessage("Красный"),
        "reference_image": MessageLookupByLibrary.simpleMessage("Референс"),
        "related_notes":
            MessageLookupByLibrary.simpleMessage("Связанные посты"),
        "replace": MessageLookupByLibrary.simpleMessage("Заменить"),
        "required_field_error":
            MessageLookupByLibrary.simpleMessage("Обязательное поле"),
        "restoreData":
            MessageLookupByLibrary.simpleMessage("Восстановить данные"),
        "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
        "save_error": MessageLookupByLibrary.simpleMessage("Ошибка сохранения"),
        "save_race": MessageLookupByLibrary.simpleMessage("Сохранить расу"),
        "save_template":
            MessageLookupByLibrary.simpleMessage("Сохранить шаблон"),
        "search": MessageLookupByLibrary.simpleMessage("Поиск"),
        "search_characters":
            MessageLookupByLibrary.simpleMessage("Поиск персонажей..."),
        "search_hint": MessageLookupByLibrary.simpleMessage(
            "Поиск по персонажам, расам, заметкам и шаблонам..."),
        "search_race_hint":
            MessageLookupByLibrary.simpleMessage("Поиск рас..."),
        "select": MessageLookupByLibrary.simpleMessage("Выбрано"),
        "select_character":
            MessageLookupByLibrary.simpleMessage("Выберите персонажа"),
        "select_gender_error":
            MessageLookupByLibrary.simpleMessage("Выберите пол"),
        "select_race": MessageLookupByLibrary.simpleMessage("Выберите расу"),
        "select_race_error":
            MessageLookupByLibrary.simpleMessage("Выберите расу"),
        "select_template":
            MessageLookupByLibrary.simpleMessage("Выберите шаблон"),
        "select_template_file":
            MessageLookupByLibrary.simpleMessage("Выберите файл шаблона"),
        "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
        "share_character":
            MessageLookupByLibrary.simpleMessage("Поделиться персонажем"),
        "short_name": MessageLookupByLibrary.simpleMessage("Короткое имя"),
        "standard_fields":
            MessageLookupByLibrary.simpleMessage("Стандартные поля"),
        "system": MessageLookupByLibrary.simpleMessage("Системная"),
        "teal": MessageLookupByLibrary.simpleMessage("Бирюзовый"),
        "template": MessageLookupByLibrary.simpleMessage("Шаблон"),
        "template_delete_confirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить этот шаблон?"),
        "template_delete_title":
            MessageLookupByLibrary.simpleMessage("Удаление шаблона"),
        "template_deleted":
            MessageLookupByLibrary.simpleMessage("Шаблон удален"),
        "template_exists":
            MessageLookupByLibrary.simpleMessage("Шаблон уже существует"),
        "template_exported": m9,
        "template_imported": m10,
        "template_name_label":
            MessageLookupByLibrary.simpleMessage("Название шаблона"),
        "template_replace_confirm": m11,
        "templates": MessageLookupByLibrary.simpleMessage("Шаблоны"),
        "templates_not_found":
            MessageLookupByLibrary.simpleMessage("Шаблоны не найдены"),
        "theme": MessageLookupByLibrary.simpleMessage("Тема"),
        "unsaved_changes_content": MessageLookupByLibrary.simpleMessage(
            "У вас есть несохраненные изменения. Хотите сохранить перед выходом?"),
        "unsaved_changes_title":
            MessageLookupByLibrary.simpleMessage("Несохраненные изменения"),
        "version": MessageLookupByLibrary.simpleMessage("Версия"),
        "web_not_supported":
            MessageLookupByLibrary.simpleMessage("Недоступно для веба"),
        "years": MessageLookupByLibrary.simpleMessage("лет"),
        "young": MessageLookupByLibrary.simpleMessage("Молодые"),
        "z_to_a": MessageLookupByLibrary.simpleMessage("Я-А")
      };
}
