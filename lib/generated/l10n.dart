// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Characterbook`
  String get app_name {
    return Intl.message(
      'Characterbook',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Назад`
  String get back {
    return Intl.message(
      'Назад',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Отмена`
  String get cancel {
    return Intl.message(
      'Отмена',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Создать`
  String get create {
    return Intl.message(
      'Создать',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Удалить`
  String get delete {
    return Intl.message(
      'Удалить',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Править`
  String get edit {
    return Intl.message(
      'Править',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка`
  String get error {
    return Intl.message(
      'Ошибка',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `ОК`
  String get ok {
    return Intl.message(
      'ОК',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить`
  String get save {
    return Intl.message(
      'Сохранить',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Поиск`
  String get search {
    return Intl.message(
      'Поиск',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Выбрано`
  String get select {
    return Intl.message(
      'Выбрано',
      name: 'select',
      desc: '',
      args: [],
    );
  }

  /// `Настройки`
  String get settings {
    return Intl.message(
      'Настройки',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Версия`
  String get version {
    return Intl.message(
      'Версия',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Копировать`
  String get copy {
    return Intl.message(
      'Копировать',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Импорт`
  String get import {
    return Intl.message(
      'Импорт',
      name: 'import',
      desc: '',
      args: [],
    );
  }

  /// `Экспорт`
  String get export {
    return Intl.message(
      'Экспорт',
      name: 'export',
      desc: '',
      args: [],
    );
  }

  /// `Заменить`
  String get replace {
    return Intl.message(
      'Заменить',
      name: 'replace',
      desc: '',
      args: [],
    );
  }

  /// `Загрузка…`
  String get processing {
    return Intl.message(
      'Загрузка…',
      name: 'processing',
      desc: '',
      args: [],
    );
  }

  /// `Готово`
  String get operationCompleted {
    return Intl.message(
      'Готово',
      name: 'operationCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Скопировано`
  String get copied_to_clipboard {
    return Intl.message(
      'Скопировано',
      name: 'copied_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Обязательное поле`
  String get required_field_error {
    return Intl.message(
      'Обязательное поле',
      name: 'required_field_error',
      desc: '',
      args: [],
    );
  }

  /// `Не выбрано`
  String get not_selected {
    return Intl.message(
      'Не выбрано',
      name: 'not_selected',
      desc: '',
      args: [],
    );
  }

  /// `Нет`
  String get none {
    return Intl.message(
      'Нет',
      name: 'none',
      desc: '',
      args: [],
    );
  }

  /// `Все`
  String get all {
    return Intl.message(
      'Все',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `шт.`
  String get items {
    return Intl.message(
      'шт.',
      name: 'items',
      desc: '',
      args: [],
    );
  }

  /// `Поделиться`
  String get share {
    return Intl.message(
      'Поделиться',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Персонаж`
  String get character {
    return Intl.message(
      'Персонаж',
      name: 'character',
      desc: '',
      args: [],
    );
  }

  /// `Персонажи`
  String get characters {
    return Intl.message(
      'Персонажи',
      name: 'characters',
      desc: '',
      args: [],
    );
  }

  /// `Мои персонажи`
  String get my_characters {
    return Intl.message(
      'Мои персонажи',
      name: 'my_characters',
      desc: '',
      args: [],
    );
  }

  /// `Новый персонаж`
  String get new_character {
    return Intl.message(
      'Новый персонаж',
      name: 'new_character',
      desc: '',
      args: [],
    );
  }

  /// `Персонажи`
  String get character_management {
    return Intl.message(
      'Персонажи',
      name: 'character_management',
      desc: '',
      args: [],
    );
  }

  /// `Изменить персонажа`
  String get edit_character {
    return Intl.message(
      'Изменить персонажа',
      name: 'edit_character',
      desc: '',
      args: [],
    );
  }

  /// `Удалить персонажа`
  String get delete_character {
    return Intl.message(
      'Удалить персонажа',
      name: 'delete_character',
      desc: '',
      args: [],
    );
  }

  /// `Копировать персонажа`
  String get copy_character {
    return Intl.message(
      'Копировать персонажа',
      name: 'copy_character',
      desc: '',
      args: [],
    );
  }

  /// `Поделиться персонажем`
  String get share_character {
    return Intl.message(
      'Поделиться персонажем',
      name: 'share_character',
      desc: '',
      args: [],
    );
  }

  /// `Выбрать персонажа`
  String get select_character {
    return Intl.message(
      'Выбрать персонажа',
      name: 'select_character',
      desc: '',
      args: [],
    );
  }

  /// `Раса`
  String get race {
    return Intl.message(
      'Раса',
      name: 'race',
      desc: '',
      args: [],
    );
  }

  /// `Расы`
  String get races {
    return Intl.message(
      'Расы',
      name: 'races',
      desc: '',
      args: [],
    );
  }

  /// `Новая раса`
  String get new_race {
    return Intl.message(
      'Новая раса',
      name: 'new_race',
      desc: '',
      args: [],
    );
  }

  /// `Расы`
  String get race_management {
    return Intl.message(
      'Расы',
      name: 'race_management',
      desc: '',
      args: [],
    );
  }

  /// `Изменить расы`
  String get edit_race {
    return Intl.message(
      'Изменить расы',
      name: 'edit_race',
      desc: '',
      args: [],
    );
  }

  /// `Импорт расы`
  String get import_race {
    return Intl.message(
      'Импорт расы',
      name: 'import_race',
      desc: '',
      args: [],
    );
  }

  /// `Шаблон`
  String get template {
    return Intl.message(
      'Шаблон',
      name: 'template',
      desc: '',
      args: [],
    );
  }

  /// `Шаблоны`
  String get templates {
    return Intl.message(
      'Шаблоны',
      name: 'templates',
      desc: '',
      args: [],
    );
  }

  /// `Новый шаблон`
  String get new_template {
    return Intl.message(
      'Новый шаблон',
      name: 'new_template',
      desc: '',
      args: [],
    );
  }

  /// `Изменить шаблон`
  String get edit_template {
    return Intl.message(
      'Изменить шаблон',
      name: 'edit_template',
      desc: '',
      args: [],
    );
  }

  /// `Создать шаблон`
  String get create_template {
    return Intl.message(
      'Создать шаблон',
      name: 'create_template',
      desc: '',
      args: [],
    );
  }

  /// `Выбрать шаблон`
  String get select_template {
    return Intl.message(
      'Выбрать шаблон',
      name: 'select_template',
      desc: '',
      args: [],
    );
  }

  /// `Папка`
  String get folder {
    return Intl.message(
      'Папка',
      name: 'folder',
      desc: '',
      args: [],
    );
  }

  /// `Папки`
  String get folders {
    return Intl.message(
      'Папки',
      name: 'folders',
      desc: '',
      args: [],
    );
  }

  /// `Новая папка`
  String get new_folder {
    return Intl.message(
      'Новая папка',
      name: 'new_folder',
      desc: '',
      args: [],
    );
  }

  /// `Править папку`
  String get edit_folder {
    return Intl.message(
      'Править папку',
      name: 'edit_folder',
      desc: '',
      args: [],
    );
  }

  /// `Название`
  String get folder_name {
    return Intl.message(
      'Название',
      name: 'folder_name',
      desc: '',
      args: [],
    );
  }

  /// `Цвет папки`
  String get folder_color {
    return Intl.message(
      'Цвет папки',
      name: 'folder_color',
      desc: '',
      args: [],
    );
  }

  /// `Выбрать папку`
  String get select_folder {
    return Intl.message(
      'Выбрать папку',
      name: 'select_folder',
      desc: '',
      args: [],
    );
  }

  /// `Заметки`
  String get posts {
    return Intl.message(
      'Заметки',
      name: 'posts',
      desc: '',
      args: [],
    );
  }

  /// `Связанные заметки`
  String get related_notes {
    return Intl.message(
      'Связанные заметки',
      name: 'related_notes',
      desc: '',
      args: [],
    );
  }

  /// `Начните писать…`
  String get start_writing {
    return Intl.message(
      'Начните писать…',
      name: 'start_writing',
      desc: '',
      args: [],
    );
  }

  /// `Выбранные персонажи`
  String get choose_character {
    return Intl.message(
      'Выбранные персонажи',
      name: 'choose_character',
      desc: '',
      args: [],
    );
  }

  /// `Имя`
  String get name {
    return Intl.message(
      'Имя',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Краткое имя`
  String get short_name {
    return Intl.message(
      'Краткое имя',
      name: 'short_name',
      desc: '',
      args: [],
    );
  }

  /// `Возраст`
  String get age {
    return Intl.message(
      'Возраст',
      name: 'age',
      desc: '',
      args: [],
    );
  }

  /// `лет`
  String get years {
    return Intl.message(
      'лет',
      name: 'years',
      desc: '',
      args: [],
    );
  }

  /// `Пол`
  String get gender {
    return Intl.message(
      'Пол',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Мужской`
  String get male {
    return Intl.message(
      'Мужской',
      name: 'male',
      desc: '',
      args: [],
    );
  }

  /// `Женский`
  String get female {
    return Intl.message(
      'Женский',
      name: 'female',
      desc: '',
      args: [],
    );
  }

  /// `Другой`
  String get another {
    return Intl.message(
      'Другой',
      name: 'another',
      desc: '',
      args: [],
    );
  }

  /// `Описание`
  String get description {
    return Intl.message(
      'Описание',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Биография`
  String get biography {
    return Intl.message(
      'Биография',
      name: 'biography',
      desc: '',
      args: [],
    );
  }

  /// `Характер`
  String get personality {
    return Intl.message(
      'Характер',
      name: 'personality',
      desc: '',
      args: [],
    );
  }

  /// `Внешность`
  String get appearance {
    return Intl.message(
      'Внешность',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  /// `Способности`
  String get abilities {
    return Intl.message(
      'Способности',
      name: 'abilities',
      desc: '',
      args: [],
    );
  }

  /// `Другое`
  String get other {
    return Intl.message(
      'Другое',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `Биология`
  String get biology {
    return Intl.message(
      'Биология',
      name: 'biology',
      desc: '',
      args: [],
    );
  }

  /// `История`
  String get backstory {
    return Intl.message(
      'История',
      name: 'backstory',
      desc: '',
      args: [],
    );
  }

  /// `Теги`
  String get tags {
    return Intl.message(
      'Теги',
      name: 'tags',
      desc: '',
      args: [],
    );
  }

  /// `Добавить тег`
  String get add_tag {
    return Intl.message(
      'Добавить тег',
      name: 'add_tag',
      desc: '',
      args: [],
    );
  }

  /// `Изображение`
  String get image {
    return Intl.message(
      'Изображение',
      name: 'image',
      desc: '',
      args: [],
    );
  }

  /// `Основное`
  String get main_image {
    return Intl.message(
      'Основное',
      name: 'main_image',
      desc: '',
      args: [],
    );
  }

  /// `Референс`
  String get reference_image {
    return Intl.message(
      'Референс',
      name: 'reference_image',
      desc: '',
      args: [],
    );
  }

  /// `Доп. изображения`
  String get additional_images {
    return Intl.message(
      'Доп. изображения',
      name: 'additional_images',
      desc: '',
      args: [],
    );
  }

  /// `Добавить`
  String get add_picture {
    return Intl.message(
      'Добавить',
      name: 'add_picture',
      desc: '',
      args: [],
    );
  }

  /// `Аватар`
  String get character_avatar {
    return Intl.message(
      'Аватар',
      name: 'character_avatar',
      desc: '',
      args: [],
    );
  }

  /// `Референс`
  String get character_reference {
    return Intl.message(
      'Референс',
      name: 'character_reference',
      desc: '',
      args: [],
    );
  }

  /// `Галерея`
  String get character_gallery {
    return Intl.message(
      'Галерея',
      name: 'character_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Обрезка аватара`
  String get avatar_crop_title {
    return Intl.message(
      'Обрезка аватара',
      name: 'avatar_crop_title',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить`
  String get avatar_crop_save {
    return Intl.message(
      'Сохранить',
      name: 'avatar_crop_save',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка размера виджета`
  String get avatar_crop_widget_size_error {
    return Intl.message(
      'Ошибка размера виджета',
      name: 'avatar_crop_widget_size_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка координат обрезки`
  String get avatar_crop_coordinates_error {
    return Intl.message(
      'Ошибка координат обрезки',
      name: 'avatar_crop_coordinates_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка обрезки: {error}`
  String avatar_crop_error(Object error) {
    return Intl.message(
      'Ошибка обрезки: $error',
      name: 'avatar_crop_error',
      desc: '',
      args: [error],
    );
  }

  /// `Ошибка: {error}`
  String avatar_picker_error(Object error) {
    return Intl.message(
      'Ошибка: $error',
      name: 'avatar_picker_error',
      desc: '',
      args: [error],
    );
  }

  /// `Название`
  String get template_name_label {
    return Intl.message(
      'Название',
      name: 'template_name_label',
      desc: '',
      args: [],
    );
  }

  /// `Основные характеристики`
  String get standard_fields {
    return Intl.message(
      'Основные характеристики',
      name: 'standard_fields',
      desc: '',
      args: [],
    );
  }

  /// `Доп. поля`
  String get custom_fields {
    return Intl.message(
      'Доп. поля',
      name: 'custom_fields',
      desc: '',
      args: [],
    );
  }

  /// `Доп. характеристики`
  String get custom_fields_editor_title {
    return Intl.message(
      'Доп. характеристики',
      name: 'custom_fields_editor_title',
      desc: '',
      args: [],
    );
  }

  /// `Добавить характеристику`
  String get add_field {
    return Intl.message(
      'Добавить характеристику',
      name: 'add_field',
      desc: '',
      args: [],
    );
  }

  /// `Нет доп. характеристик`
  String get no_custom_fields {
    return Intl.message(
      'Нет доп. характеристик',
      name: 'no_custom_fields',
      desc: '',
      args: [],
    );
  }

  /// `Имя характеристики`
  String get field_name {
    return Intl.message(
      'Имя характеристики',
      name: 'field_name',
      desc: '',
      args: [],
    );
  }

  /// `Название характеристики`
  String get field_name_hint {
    return Intl.message(
      'Название характеристики',
      name: 'field_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Значение`
  String get field_value {
    return Intl.message(
      'Значение',
      name: 'field_value',
      desc: '',
      args: [],
    );
  }

  /// `Значение характеристики`
  String get field_value_hint {
    return Intl.message(
      'Значение характеристики',
      name: 'field_value_hint',
      desc: '',
      args: [],
    );
  }

  /// `основных`
  String get standard {
    return Intl.message(
      'основных',
      name: 'standard',
      desc: '',
      args: [],
    );
  }

  /// `доп.`
  String get custom {
    return Intl.message(
      'доп.',
      name: 'custom',
      desc: '',
      args: [],
    );
  }

  /// `{count} характ.`
  String fields_count(Object count) {
    return Intl.message(
      '$count характ.',
      name: 'fields_count',
      desc: '',
      args: [count],
    );
  }

  /// `ещё {count}`
  String more_fields(Object count) {
    return Intl.message(
      'ещё $count',
      name: 'more_fields',
      desc: '',
      args: [count],
    );
  }

  /// `Дети`
  String get children {
    return Intl.message(
      'Дети',
      name: 'children',
      desc: '',
      args: [],
    );
  }

  /// `Молодые`
  String get young {
    return Intl.message(
      'Молодые',
      name: 'young',
      desc: '',
      args: [],
    );
  }

  /// `Взрослые`
  String get adults {
    return Intl.message(
      'Взрослые',
      name: 'adults',
      desc: '',
      args: [],
    );
  }

  /// `Пожилые`
  String get elderly {
    return Intl.message(
      'Пожилые',
      name: 'elderly',
      desc: '',
      args: [],
    );
  }

  /// `Фиолетовый`
  String get color_purple {
    return Intl.message(
      'Фиолетовый',
      name: 'color_purple',
      desc: '',
      args: [],
    );
  }

  /// `Бирюзовый`
  String get color_teal {
    return Intl.message(
      'Бирюзовый',
      name: 'color_teal',
      desc: '',
      args: [],
    );
  }

  /// `Красный`
  String get color_red {
    return Intl.message(
      'Красный',
      name: 'color_red',
      desc: '',
      args: [],
    );
  }

  /// `Розовый`
  String get color_pink {
    return Intl.message(
      'Розовый',
      name: 'color_pink',
      desc: '',
      args: [],
    );
  }

  /// `Тёмный`
  String get color_dark {
    return Intl.message(
      'Тёмный',
      name: 'color_dark',
      desc: '',
      args: [],
    );
  }

  /// `Зелёный`
  String get color_green {
    return Intl.message(
      'Зелёный',
      name: 'color_green',
      desc: '',
      args: [],
    );
  }

  /// `Синий`
  String get color_blue {
    return Intl.message(
      'Синий',
      name: 'color_blue',
      desc: '',
      args: [],
    );
  }

  /// `Коричневый`
  String get color_brown {
    return Intl.message(
      'Коричневый',
      name: 'color_brown',
      desc: '',
      args: [],
    );
  }

  /// `Оранжевый`
  String get color_orange {
    return Intl.message(
      'Оранжевый',
      name: 'color_orange',
      desc: '',
      args: [],
    );
  }

  /// `Серый`
  String get color_grey {
    return Intl.message(
      'Серый',
      name: 'color_grey',
      desc: '',
      args: [],
    );
  }

  /// `Акцент`
  String get accentColor {
    return Intl.message(
      'Акцент',
      name: 'accentColor',
      desc: '',
      args: [],
    );
  }

  /// `Цветовая схема`
  String get colorScheme {
    return Intl.message(
      'Цветовая схема',
      name: 'colorScheme',
      desc: '',
      args: [],
    );
  }

  /// `Тема`
  String get theme {
    return Intl.message(
      'Тема',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Настроить тему`
  String get customize_theme {
    return Intl.message(
      'Настроить тему',
      name: 'customize_theme',
      desc: '',
      args: [],
    );
  }

  /// `Предпросмотр`
  String get preview {
    return Intl.message(
      'Предпросмотр',
      name: 'preview',
      desc: '',
      args: [],
    );
  }

  /// `Системные цвета`
  String get use_system_colors {
    return Intl.message(
      'Системные цвета',
      name: 'use_system_colors',
      desc: '',
      args: [],
    );
  }

  /// `Только для Android 12+`
  String get use_system_colors_unavailable {
    return Intl.message(
      'Только для Android 12+',
      name: 'use_system_colors_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Свой цвет`
  String get custom_color {
    return Intl.message(
      'Свой цвет',
      name: 'custom_color',
      desc: '',
      args: [],
    );
  }

  /// `Material You`
  String get material_you {
    return Intl.message(
      'Material You',
      name: 'material_you',
      desc: '',
      args: [],
    );
  }

  /// `Системные цвета обоев`
  String get material_you_status_system {
    return Intl.message(
      'Системные цвета обоев',
      name: 'material_you_status_system',
      desc: '',
      args: [],
    );
  }

  /// `Сгенерированные цвета Material You`
  String get material_you_status_generated {
    return Intl.message(
      'Сгенерированные цвета Material You',
      name: 'material_you_status_generated',
      desc: '',
      args: [],
    );
  }

  /// `Палитра`
  String get color_style {
    return Intl.message(
      'Палитра',
      name: 'color_style',
      desc: '',
      args: [],
    );
  }

  /// `Спецификация`
  String get color_spec {
    return Intl.message(
      'Спецификация',
      name: 'color_spec',
      desc: '',
      args: [],
    );
  }

  /// `2021`
  String get color_spec_2021 {
    return Intl.message(
      '2021',
      name: 'color_spec_2021',
      desc: '',
      args: [],
    );
  }

  /// `2025`
  String get color_spec_2025 {
    return Intl.message(
      '2025',
      name: 'color_spec_2025',
      desc: '',
      args: [],
    );
  }

  /// `Контраст`
  String get contrast {
    return Intl.message(
      'Контраст',
      name: 'contrast',
      desc: '',
      args: [],
    );
  }

  /// `Тёмная`
  String get dark {
    return Intl.message(
      'Тёмная',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Светлая`
  String get light {
    return Intl.message(
      'Светлая',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Системная`
  String get system {
    return Intl.message(
      'Системная',
      name: 'system',
      desc: '',
      args: [],
    );
  }

  /// `Язык`
  String get language {
    return Intl.message(
      'Язык',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Язык`
  String get appLanguage {
    return Intl.message(
      'Язык',
      name: 'appLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Главная`
  String get home {
    return Intl.message(
      'Главная',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Инструменты D&D`
  String get dnd_tools {
    return Intl.message(
      'Инструменты D&D',
      name: 'dnd_tools',
      desc: '',
      args: [],
    );
  }

  /// `Ещё`
  String get more_options {
    return Intl.message(
      'Ещё',
      name: 'more_options',
      desc: '',
      args: [],
    );
  }

  /// `О приложении`
  String get aboutApp {
    return Intl.message(
      'О приложении',
      name: 'aboutApp',
      desc: '',
      args: [],
    );
  }

  /// `Благодарности`
  String get acknowledgements {
    return Intl.message(
      'Благодарности',
      name: 'acknowledgements',
      desc: '',
      args: [],
    );
  }

  /// `Разработчик`
  String get developer {
    return Intl.message(
      'Разработчик',
      name: 'developer',
      desc: '',
      args: [],
    );
  }

  /// `GitHub`
  String get githubRepo {
    return Intl.message(
      'GitHub',
      name: 'githubRepo',
      desc: '',
      args: [],
    );
  }

  /// `Лицензии`
  String get licenses {
    return Intl.message(
      'Лицензии',
      name: 'licenses',
      desc: '',
      args: [],
    );
  }

  /// `Библиотеки`
  String get usedLibraries {
    return Intl.message(
      'Библиотеки',
      name: 'usedLibraries',
      desc: '',
      args: [],
    );
  }

  /// `Лицензия Flutter`
  String get flutterLicense {
    return Intl.message(
      'Лицензия Flutter',
      name: 'flutterLicense',
      desc: '',
      args: [],
    );
  }

  /// `Лицензия Characterbook`
  String get characterbookLicense {
    return Intl.message(
      'Лицензия Characterbook',
      name: 'characterbookLicense',
      desc: '',
      args: [],
    );
  }

  /// `Настройки PDF`
  String get export_pdf_settings {
    return Intl.message(
      'Настройки PDF',
      name: 'export_pdf_settings',
      desc: '',
      args: [],
    );
  }

  /// `Резервное копирование`
  String get backup {
    return Intl.message(
      'Резервное копирование',
      name: 'backup',
      desc: '',
      args: [],
    );
  }

  /// `Создать копию`
  String get createBackup {
    return Intl.message(
      'Создать копию',
      name: 'createBackup',
      desc: '',
      args: [],
    );
  }

  /// `Создание копии…`
  String get creatingBackup {
    return Intl.message(
      'Создание копии…',
      name: 'creatingBackup',
      desc: '',
      args: [],
    );
  }

  /// `Восстановление…`
  String get restoringBackup {
    return Intl.message(
      'Восстановление…',
      name: 'restoringBackup',
      desc: '',
      args: [],
    );
  }

  /// `Восстановить данные`
  String get restoreData {
    return Intl.message(
      'Восстановить данные',
      name: 'restoreData',
      desc: '',
      args: [],
    );
  }

  /// `Варианты копии`
  String get backup_options {
    return Intl.message(
      'Варианты копии',
      name: 'backup_options',
      desc: '',
      args: [],
    );
  }

  /// `Варианты восстановления`
  String get restore_options {
    return Intl.message(
      'Варианты восстановления',
      name: 'restore_options',
      desc: '',
      args: [],
    );
  }

  /// `В облако`
  String get backup_to_cloud {
    return Intl.message(
      'В облако',
      name: 'backup_to_cloud',
      desc: '',
      args: [],
    );
  }

  /// `В файл`
  String get backup_to_file {
    return Intl.message(
      'В файл',
      name: 'backup_to_file',
      desc: '',
      args: [],
    );
  }

  /// `Из облака`
  String get restore_from_cloud {
    return Intl.message(
      'Из облака',
      name: 'restore_from_cloud',
      desc: '',
      args: [],
    );
  }

  /// `Из файла`
  String get restore_from_file {
    return Intl.message(
      'Из файла',
      name: 'restore_from_file',
      desc: '',
      args: [],
    );
  }

  /// `Файл (.character)`
  String get file_character {
    return Intl.message(
      'Файл (.character)',
      name: 'file_character',
      desc: '',
      args: [],
    );
  }

  /// `PDF (.pdf)`
  String get file_pdf {
    return Intl.message(
      'PDF (.pdf)',
      name: 'file_pdf',
      desc: '',
      args: [],
    );
  }

  /// `Файл готов`
  String get file_ready {
    return Intl.message(
      'Файл готов',
      name: 'file_ready',
      desc: '',
      args: [],
    );
  }

  /// `Создание PDF…`
  String get creating_pdf {
    return Intl.message(
      'Создание PDF…',
      name: 'creating_pdf',
      desc: '',
      args: [],
    );
  }

  /// `Создание файла…`
  String get creating_file {
    return Intl.message(
      'Создание файла…',
      name: 'creating_file',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка сохранения`
  String get save_error {
    return Intl.message(
      'Ошибка сохранения',
      name: 'save_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка удаления`
  String get delete_error {
    return Intl.message(
      'Ошибка удаления',
      name: 'delete_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка копирования`
  String get copy_error {
    return Intl.message(
      'Ошибка копирования',
      name: 'copy_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка экспорта`
  String get export_error {
    return Intl.message(
      'Ошибка экспорта',
      name: 'export_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка импорта: {error}`
  String import_error(Object error) {
    return Intl.message(
      'Ошибка импорта: $error',
      name: 'import_error',
      desc: '',
      args: [error],
    );
  }

  /// `Импорт отменён`
  String get import_cancelled {
    return Intl.message(
      'Импорт отменён',
      name: 'import_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка выбора файла`
  String get file_pick_error {
    return Intl.message(
      'Ошибка выбора файла',
      name: 'file_pick_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка выбора фото: {error}`
  String image_picker_error(Object error) {
    return Intl.message(
      'Ошибка выбора фото: $error',
      name: 'image_picker_error',
      desc: '',
      args: [error],
    );
  }

  /// `Авторизация отменена`
  String get auth_cancelled {
    return Intl.message(
      'Авторизация отменена',
      name: 'auth_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка клиента API`
  String get auth_client_error {
    return Intl.message(
      'Ошибка клиента API',
      name: 'auth_client_error',
      desc: '',
      args: [],
    );
  }

  /// `Недоступно в вебе`
  String get web_not_supported {
    return Intl.message(
      'Недоступно в вебе',
      name: 'web_not_supported',
      desc: '',
      args: [],
    );
  }

  /// `Неверный возраст`
  String get invalid_age {
    return Intl.message(
      'Неверный возраст',
      name: 'invalid_age',
      desc: '',
      args: [],
    );
  }

  /// `Выберите пол`
  String get select_gender_error {
    return Intl.message(
      'Выберите пол',
      name: 'select_gender_error',
      desc: '',
      args: [],
    );
  }

  /// `Выберите расу`
  String get select_race_error {
    return Intl.message(
      'Выберите расу',
      name: 'select_race_error',
      desc: '',
      args: [],
    );
  }

  /// `Файл пуст`
  String get empty_file_error {
    return Intl.message(
      'Файл пуст',
      name: 'empty_file_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка резервного копирования`
  String get cloud_backup_error {
    return Intl.message(
      'Ошибка резервного копирования',
      name: 'cloud_backup_error',
      desc: '',
      args: [],
    );
  }

  /// `Копия создана`
  String get cloud_backup_success {
    return Intl.message(
      'Копия создана',
      name: 'cloud_backup_success',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка копирования персонажей`
  String get cloud_backup_characters_error {
    return Intl.message(
      'Ошибка копирования персонажей',
      name: 'cloud_backup_characters_error',
      desc: '',
      args: [],
    );
  }

  /// `Персонажи скопированы`
  String get cloud_backup_characters_success {
    return Intl.message(
      'Персонажи скопированы',
      name: 'cloud_backup_characters_success',
      desc: '',
      args: [],
    );
  }

  /// `Полная копия на Google Диске`
  String get cloud_backup_full_success {
    return Intl.message(
      'Полная копия на Google Диске',
      name: 'cloud_backup_full_success',
      desc: '',
      args: [],
    );
  }

  /// `Копии не найдены`
  String get cloud_backup_not_found {
    return Intl.message(
      'Копии не найдены',
      name: 'cloud_backup_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка экспорта в Drive`
  String get cloud_export_error {
    return Intl.message(
      'Ошибка экспорта в Drive',
      name: 'cloud_export_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка импорта из Drive`
  String get cloud_import_error {
    return Intl.message(
      'Ошибка импорта из Drive',
      name: 'cloud_import_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка восстановления`
  String get cloud_restore_error {
    return Intl.message(
      'Ошибка восстановления',
      name: 'cloud_restore_error',
      desc: '',
      args: [],
    );
  }

  /// `Восстановлено: {charactersCount} перс., {notesCount} зам., {racesCount} рас, {templatesCount} шабл., {foldersCount} пап.`
  String cloud_restore_success(Object charactersCount, Object notesCount,
      Object racesCount, Object templatesCount, Object foldersCount) {
    return Intl.message(
      'Восстановлено: $charactersCount перс., $notesCount зам., $racesCount рас, $templatesCount шабл., $foldersCount пап.',
      name: 'cloud_restore_success',
      desc: '',
      args: [
        charactersCount,
        notesCount,
        racesCount,
        templatesCount,
        foldersCount
      ],
    );
  }

  /// `Копия создана`
  String get local_backup_success {
    return Intl.message(
      'Копия создана',
      name: 'local_backup_success',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка создания копии`
  String get local_backup_error {
    return Intl.message(
      'Ошибка создания копии',
      name: 'local_backup_error',
      desc: '',
      args: [],
    );
  }

  /// `Данные восстановлены`
  String get local_restore_success {
    return Intl.message(
      'Данные восстановлены',
      name: 'local_restore_success',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка восстановления`
  String get local_restore_error {
    return Intl.message(
      'Ошибка восстановления',
      name: 'local_restore_error',
      desc: '',
      args: [],
    );
  }

  /// `Создан из шаблона "{name}"`
  String character_created_from_template(Object name) {
    return Intl.message(
      'Создан из шаблона "$name"',
      name: 'character_created_from_template',
      desc: '',
      args: [name],
    );
  }

  /// `"{name}" экспортирован в PDF`
  String character_exported(Object name) {
    return Intl.message(
      '"$name" экспортирован в PDF',
      name: 'character_exported',
      desc: '',
      args: [name],
    );
  }

  /// `"{name}" импортирован`
  String character_imported(Object name) {
    return Intl.message(
      '"$name" импортирован',
      name: 'character_imported',
      desc: '',
      args: [name],
    );
  }

  /// `Персонаж удалён`
  String get character_deleted {
    return Intl.message(
      'Персонаж удалён',
      name: 'character_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Раса "{name}" импортирована`
  String race_imported(Object name) {
    return Intl.message(
      'Раса "$name" импортирована',
      name: 'race_imported',
      desc: '',
      args: [name],
    );
  }

  /// `Раса удалена`
  String get race_deleted {
    return Intl.message(
      'Раса удалена',
      name: 'race_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Раса скопирована`
  String get race_copied {
    return Intl.message(
      'Раса скопирована',
      name: 'race_copied',
      desc: '',
      args: [],
    );
  }

  /// `Шаблон "{name}" экспортирован`
  String template_exported(Object name) {
    return Intl.message(
      'Шаблон "$name" экспортирован',
      name: 'template_exported',
      desc: '',
      args: [name],
    );
  }

  /// `Шаблон "{name}" импортирован`
  String template_imported(Object name) {
    return Intl.message(
      'Шаблон "$name" импортирован',
      name: 'template_imported',
      desc: '',
      args: [name],
    );
  }

  /// `Шаблон удалён`
  String get template_deleted {
    return Intl.message(
      'Шаблон удалён',
      name: 'template_deleted',
      desc: '',
      args: [],
    );
  }

  /// `PDF экспортирован`
  String get pdf_export_success {
    return Intl.message(
      'PDF экспортирован',
      name: 'pdf_export_success',
      desc: '',
      args: [],
    );
  }

  /// `Несохранённые изменения`
  String get unsaved_changes_title {
    return Intl.message(
      'Несохранённые изменения',
      name: 'unsaved_changes_title',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить изменения перед выходом?`
  String get unsaved_changes_content {
    return Intl.message(
      'Сохранить изменения перед выходом?',
      name: 'unsaved_changes_content',
      desc: '',
      args: [],
    );
  }

  /// `Удалить персонажа?`
  String get character_delete_title {
    return Intl.message(
      'Удалить персонажа?',
      name: 'character_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `Удалить безвозвратно?`
  String get character_delete_confirm {
    return Intl.message(
      'Удалить безвозвратно?',
      name: 'character_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Удалить расу?`
  String get race_delete_title {
    return Intl.message(
      'Удалить расу?',
      name: 'race_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `Удалить эту расу?`
  String get race_delete_confirm {
    return Intl.message(
      'Удалить эту расу?',
      name: 'race_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Нельзя удалить`
  String get race_delete_error_title {
    return Intl.message(
      'Нельзя удалить',
      name: 'race_delete_error_title',
      desc: '',
      args: [],
    );
  }

  /// `Раса используется персонажами. Измените расу.`
  String get race_delete_error_content {
    return Intl.message(
      'Раса используется персонажами. Измените расу.',
      name: 'race_delete_error_content',
      desc: '',
      args: [],
    );
  }

  /// `Удалить шаблон?`
  String get template_delete_title {
    return Intl.message(
      'Удалить шаблон?',
      name: 'template_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `Удалить этот шаблон?`
  String get template_delete_confirm {
    return Intl.message(
      'Удалить этот шаблон?',
      name: 'template_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Шаблон "{name}" уже есть. Заменить?`
  String template_replace_confirm(Object name) {
    return Intl.message(
      'Шаблон "$name" уже есть. Заменить?',
      name: 'template_replace_confirm',
      desc: '',
      args: [name],
    );
  }

  /// `Отменить изменения`
  String get discard_changes {
    return Intl.message(
      'Отменить изменения',
      name: 'discard_changes',
      desc: '',
      args: [],
    );
  }

  /// `Пусто!`
  String get empty_list {
    return Intl.message(
      'Пусто!',
      name: 'empty_list',
      desc: '',
      args: [],
    );
  }

  /// `Нет данных`
  String get no_data_found {
    return Intl.message(
      'Нет данных',
      name: 'no_data_found',
      desc: '',
      args: [],
    );
  }

  /// `Ничего не найдено`
  String get nothing_found {
    return Intl.message(
      'Ничего не найдено',
      name: 'nothing_found',
      desc: '',
      args: [],
    );
  }

  /// `Нет персонажей`
  String get no_characters {
    return Intl.message(
      'Нет персонажей',
      name: 'no_characters',
      desc: '',
      args: [],
    );
  }

  /// `Нет рас`
  String get no_races_created {
    return Intl.message(
      'Нет рас',
      name: 'no_races_created',
      desc: '',
      args: [],
    );
  }

  /// `Нет шаблонов`
  String get no_templates {
    return Intl.message(
      'Нет шаблонов',
      name: 'no_templates',
      desc: '',
      args: [],
    );
  }

  /// `Нет содержания`
  String get no_content {
    return Intl.message(
      'Нет содержания',
      name: 'no_content',
      desc: '',
      args: [],
    );
  }

  /// `Нет описания`
  String get no_description {
    return Intl.message(
      'Нет описания',
      name: 'no_description',
      desc: '',
      args: [],
    );
  }

  /// `Нет информации`
  String get no_information {
    return Intl.message(
      'Нет информации',
      name: 'no_information',
      desc: '',
      args: [],
    );
  }

  /// `Раса не выбрана`
  String get no_race {
    return Intl.message(
      'Раса не выбрана',
      name: 'no_race',
      desc: '',
      args: [],
    );
  }

  /// `Нет доп. изображений`
  String get no_additional_images {
    return Intl.message(
      'Нет доп. изображений',
      name: 'no_additional_images',
      desc: '',
      args: [],
    );
  }

  /// `Папка не выбрана`
  String get no_folder_selected {
    return Intl.message(
      'Папка не выбрана',
      name: 'no_folder_selected',
      desc: '',
      args: [],
    );
  }

  /// `Пока пусто`
  String get no_content_home {
    return Intl.message(
      'Пока пусто',
      name: 'no_content_home',
      desc: '',
      args: [],
    );
  }

  /// `Создайте персонажа или расу`
  String get create_first_content {
    return Intl.message(
      'Создайте персонажа или расу',
      name: 'create_first_content',
      desc: '',
      args: [],
    );
  }

  /// `Поиск персонажей…`
  String get search_characters {
    return Intl.message(
      'Поиск персонажей…',
      name: 'search_characters',
      desc: '',
      args: [],
    );
  }

  /// `Поиск рас…`
  String get search_race_hint {
    return Intl.message(
      'Поиск рас…',
      name: 'search_race_hint',
      desc: '',
      args: [],
    );
  }

  /// `Поиск по персонажам, расам, заметкам, шаблонам…`
  String get search_hint {
    return Intl.message(
      'Поиск по персонажам, расам, заметкам, шаблонам…',
      name: 'search_hint',
      desc: '',
      args: [],
    );
  }

  /// `Поиск…`
  String get search_home {
    return Intl.message(
      'Поиск…',
      name: 'search_home',
      desc: '',
      args: [],
    );
  }

  /// `Все теги`
  String get all_tags {
    return Intl.message(
      'Все теги',
      name: 'all_tags',
      desc: '',
      args: [],
    );
  }

  /// `Основное`
  String get basic_info {
    return Intl.message(
      'Основное',
      name: 'basic_info',
      desc: '',
      args: [],
    );
  }

  /// `А-Я`
  String get a_to_z {
    return Intl.message(
      'А-Я',
      name: 'a_to_z',
      desc: '',
      args: [],
    );
  }

  /// `Я-А`
  String get z_to_a {
    return Intl.message(
      'Я-А',
      name: 'z_to_a',
      desc: '',
      args: [],
    );
  }

  /// `Возраст ↑`
  String get age_asc {
    return Intl.message(
      'Возраст ↑',
      name: 'age_asc',
      desc: '',
      args: [],
    );
  }

  /// `Возраст ↓`
  String get age_desc {
    return Intl.message(
      'Возраст ↓',
      name: 'age_desc',
      desc: '',
      args: [],
    );
  }

  /// `Полей ↑`
  String get fields_asc {
    return Intl.message(
      'Полей ↑',
      name: 'fields_asc',
      desc: '',
      args: [],
    );
  }

  /// `Полей ↓`
  String get fields_desc {
    return Intl.message(
      'Полей ↓',
      name: 'fields_desc',
      desc: '',
      args: [],
    );
  }

  /// `Обновлено`
  String get last_updated {
    return Intl.message(
      'Обновлено',
      name: 'last_updated',
      desc: '',
      args: [],
    );
  }

  /// `{years} г. назад`
  String years_ago(Object years) {
    return Intl.message(
      '$years г. назад',
      name: 'years_ago',
      desc: '',
      args: [years],
    );
  }

  /// `{months} мес. назад`
  String months_ago(Object months) {
    return Intl.message(
      '$months мес. назад',
      name: 'months_ago',
      desc: '',
      args: [months],
    );
  }

  /// `{days} дн. назад`
  String days_ago(Object days) {
    return Intl.message(
      '$days дн. назад',
      name: 'days_ago',
      desc: '',
      args: [days],
    );
  }

  /// `{hours} ч. назад`
  String hours_ago(Object hours) {
    return Intl.message(
      '$hours ч. назад',
      name: 'hours_ago',
      desc: '',
      args: [hours],
    );
  }

  /// `Только что`
  String get just_now {
    return Intl.message(
      'Только что',
      name: 'just_now',
      desc: '',
      args: [],
    );
  }

  /// `Сетка`
  String get grid_view {
    return Intl.message(
      'Сетка',
      name: 'grid_view',
      desc: '',
      args: [],
    );
  }

  /// `Список`
  String get list_view {
    return Intl.message(
      'Список',
      name: 'list_view',
      desc: '',
      args: [],
    );
  }

  /// `Подробно`
  String get detailed {
    return Intl.message(
      'Подробно',
      name: 'detailed',
      desc: '',
      args: [],
    );
  }

  /// `Мои`
  String get my {
    return Intl.message(
      'Мои',
      name: 'my',
      desc: '',
      args: [],
    );
  }

  /// `Из шаблона`
  String get create_from_template_tooltip {
    return Intl.message(
      'Из шаблона',
      name: 'create_from_template_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Создать шаблон`
  String get create_template_tooltip {
    return Intl.message(
      'Создать шаблон',
      name: 'create_template_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Импорт шаблона`
  String get import_template {
    return Intl.message(
      'Импорт шаблона',
      name: 'import_template',
      desc: '',
      args: [],
    );
  }

  /// `Импорт шаблона`
  String get import_template_tooltip {
    return Intl.message(
      'Импорт шаблона',
      name: 'import_template_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Из шаблона`
  String get from_template {
    return Intl.message(
      'Из шаблона',
      name: 'from_template',
      desc: '',
      args: [],
    );
  }

  /// `Новый персонаж (шаблон)`
  String get new_character_from_template {
    return Intl.message(
      'Новый персонаж (шаблон)',
      name: 'new_character_from_template',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить`
  String get save_template {
    return Intl.message(
      'Сохранить',
      name: 'save_template',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить`
  String get save_race {
    return Intl.message(
      'Сохранить',
      name: 'save_race',
      desc: '',
      args: [],
    );
  }

  /// `Возраст`
  String get enter_age {
    return Intl.message(
      'Возраст',
      name: 'enter_age',
      desc: '',
      args: [],
    );
  }

  /// `Название расы`
  String get enter_race_name {
    return Intl.message(
      'Название расы',
      name: 'enter_race_name',
      desc: '',
      args: [],
    );
  }

  /// `Выберите файл шаблона`
  String get select_template_file {
    return Intl.message(
      'Выберите файл шаблона',
      name: 'select_template_file',
      desc: '',
      args: [],
    );
  }

  /// `Моя резервная копия CharacterBook`
  String get share_backup_file {
    return Intl.message(
      'Моя резервная копия CharacterBook',
      name: 'share_backup_file',
      desc: '',
      args: [],
    );
  }

  /// `Персонаж {name}`
  String character_share_text(Object name) {
    return Intl.message(
      'Персонаж $name',
      name: 'character_share_text',
      desc: '',
      args: [name],
    );
  }

  /// `Раса {name}`
  String race_share_text(Object name) {
    return Intl.message(
      'Раса $name',
      name: 'race_share_text',
      desc: '',
      args: [name],
    );
  }

  /// `Жирный`
  String get markdown_bold {
    return Intl.message(
      'Жирный',
      name: 'markdown_bold',
      desc: '',
      args: [],
    );
  }

  /// `Курсив`
  String get markdown_italic {
    return Intl.message(
      'Курсив',
      name: 'markdown_italic',
      desc: '',
      args: [],
    );
  }

  /// `Подчёркнутый`
  String get markdown_underline {
    return Intl.message(
      'Подчёркнутый',
      name: 'markdown_underline',
      desc: '',
      args: [],
    );
  }

  /// `Список`
  String get markdown_bullet_list {
    return Intl.message(
      'Список',
      name: 'markdown_bullet_list',
      desc: '',
      args: [],
    );
  }

  /// `Нумер. список`
  String get markdown_numbered_list {
    return Intl.message(
      'Нумер. список',
      name: 'markdown_numbered_list',
      desc: '',
      args: [],
    );
  }

  /// `Цитата`
  String get markdown_quote {
    return Intl.message(
      'Цитата',
      name: 'markdown_quote',
      desc: '',
      args: [],
    );
  }

  /// `Код`
  String get markdown_inline_code {
    return Intl.message(
      'Код',
      name: 'markdown_inline_code',
      desc: '',
      args: [],
    );
  }

  /// `Коллекция персонажей и рас`
  String get home_subtitle {
    return Intl.message(
      'Коллекция персонажей и рас',
      name: 'home_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Шаблон уже есть`
  String get template_exists {
    return Intl.message(
      'Шаблон уже есть',
      name: 'template_exists',
      desc: '',
      args: [],
    );
  }

  /// `Шаблоны не найдены`
  String get templates_not_found {
    return Intl.message(
      'Шаблоны не найдены',
      name: 'templates_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка загрузки заметок`
  String get error_loading_notes {
    return Intl.message(
      'Ошибка загрузки заметок',
      name: 'error_loading_notes',
      desc: '',
      args: [],
    );
  }

  /// `Генератор чисел`
  String get randomNumberGenerator {
    return Intl.message(
      'Генератор чисел',
      name: 'randomNumberGenerator',
      desc: '',
      args: [],
    );
  }

  /// `ВЫБЕРИТЕ ДИАПАЗОН`
  String get selectRange {
    return Intl.message(
      'ВЫБЕРИТЕ ДИАПАЗОН',
      name: 'selectRange',
      desc: '',
      args: [],
    );
  }

  /// `От`
  String get from {
    return Intl.message(
      'От',
      name: 'from',
      desc: '',
      args: [],
    );
  }

  /// `До`
  String get to {
    return Intl.message(
      'До',
      name: 'to',
      desc: '',
      args: [],
    );
  }

  /// `Сгенерировать`
  String get generateNumber {
    return Intl.message(
      'Сгенерировать',
      name: 'generateNumber',
      desc: '',
      args: [],
    );
  }

  /// `Генерация…`
  String get generating {
    return Intl.message(
      'Генерация…',
      name: 'generating',
      desc: '',
      args: [],
    );
  }

  /// `Календарь`
  String get calendar {
    return Intl.message(
      'Календарь',
      name: 'calendar',
      desc: '',
      args: [],
    );
  }

  /// `Календарь событий`
  String get event_calendar {
    return Intl.message(
      'Календарь событий',
      name: 'event_calendar',
      desc: '',
      args: [],
    );
  }

  /// `Все события`
  String get all_events {
    return Intl.message(
      'Все события',
      name: 'all_events',
      desc: '',
      args: [],
    );
  }

  /// `События персонажей`
  String get character_events {
    return Intl.message(
      'События персонажей',
      name: 'character_events',
      desc: '',
      args: [],
    );
  }

  /// `События рас`
  String get race_events {
    return Intl.message(
      'События рас',
      name: 'race_events',
      desc: '',
      args: [],
    );
  }

  /// `События заметок`
  String get note_events {
    return Intl.message(
      'События заметок',
      name: 'note_events',
      desc: '',
      args: [],
    );
  }

  /// `Нет событий на день`
  String get no_events {
    return Intl.message(
      'Нет событий на день',
      name: 'no_events',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка загрузки событий`
  String get events_loading_error {
    return Intl.message(
      'Ошибка загрузки событий',
      name: 'events_loading_error',
      desc: '',
      args: [],
    );
  }

  /// `Событие`
  String get event {
    return Intl.message(
      'Событие',
      name: 'event',
      desc: '',
      args: [],
    );
  }

  /// `События`
  String get events {
    return Intl.message(
      'События',
      name: 'events',
      desc: '',
      args: [],
    );
  }

  /// `Сегодня`
  String get today {
    return Intl.message(
      'Сегодня',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Месяц`
  String get month {
    return Intl.message(
      'Месяц',
      name: 'month',
      desc: '',
      args: [],
    );
  }

  /// `Неделя`
  String get week {
    return Intl.message(
      'Неделя',
      name: 'week',
      desc: '',
      args: [],
    );
  }

  /// `День`
  String get day {
    return Intl.message(
      'День',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `Вид`
  String get calendar_view {
    return Intl.message(
      'Вид',
      name: 'calendar_view',
      desc: '',
      args: [],
    );
  }

  /// `Тип`
  String get event_type {
    return Intl.message(
      'Тип',
      name: 'event_type',
      desc: '',
      args: [],
    );
  }

  /// `Создано`
  String get created {
    return Intl.message(
      'Создано',
      name: 'created',
      desc: '',
      args: [],
    );
  }

  /// `Обновлено`
  String get updated {
    return Intl.message(
      'Обновлено',
      name: 'updated',
      desc: '',
      args: [],
    );
  }

  /// `Перейти`
  String get go_to_event {
    return Intl.message(
      'Перейти',
      name: 'go_to_event',
      desc: '',
      args: [],
    );
  }

  /// `Фильтр`
  String get filter_events {
    return Intl.message(
      'Фильтр',
      name: 'filter_events',
      desc: '',
      args: [],
    );
  }

  /// `Статистика`
  String get calendar_statistics {
    return Intl.message(
      'Статистика',
      name: 'calendar_statistics',
      desc: '',
      args: [],
    );
  }

  /// `Всего`
  String get total_events {
    return Intl.message(
      'Всего',
      name: 'total_events',
      desc: '',
      args: [],
    );
  }

  /// `За месяц`
  String get events_this_month {
    return Intl.message(
      'За месяц',
      name: 'events_this_month',
      desc: '',
      args: [],
    );
  }

  /// `Сегодня`
  String get events_today {
    return Intl.message(
      'Сегодня',
      name: 'events_today',
      desc: '',
      args: [],
    );
  }

  /// `Активность`
  String get activity_timeline {
    return Intl.message(
      'Активность',
      name: 'activity_timeline',
      desc: '',
      args: [],
    );
  }

  /// `Шаблоны`
  String get template_management {
    return Intl.message(
      'Шаблоны',
      name: 'template_management',
      desc: '',
      args: [],
    );
  }

  /// `Инструменты`
  String get tool_management {
    return Intl.message(
      'Инструменты',
      name: 'tool_management',
      desc: '',
      args: [],
    );
  }

  /// `Создать персонажа`
  String get create_character {
    return Intl.message(
      'Создать персонажа',
      name: 'create_character',
      desc: '',
      args: [],
    );
  }

  /// `Создать расу`
  String get create_race {
    return Intl.message(
      'Создать расу',
      name: 'create_race',
      desc: '',
      args: [],
    );
  }

  /// `Импорт`
  String get import_character {
    return Intl.message(
      'Импорт',
      name: 'import_character',
      desc: '',
      args: [],
    );
  }

  /// `Недавнее`
  String get recent_activity {
    return Intl.message(
      'Недавнее',
      name: 'recent_activity',
      desc: '',
      args: [],
    );
  }

  /// `Быстрые действия`
  String get quick_actions {
    return Intl.message(
      'Быстрые действия',
      name: 'quick_actions',
      desc: '',
      args: [],
    );
  }

  /// `Все`
  String get view_all {
    return Intl.message(
      'Все',
      name: 'view_all',
      desc: '',
      args: [],
    );
  }

  /// `Статистика`
  String get statistics {
    return Intl.message(
      'Статистика',
      name: 'statistics',
      desc: '',
      args: [],
    );
  }

  /// `Всего: {count}`
  String total_count(Object count) {
    return Intl.message(
      'Всего: $count',
      name: 'total_count',
      desc: '',
      args: [count],
    );
  }

  /// `Недавние правки`
  String get recently_edited {
    return Intl.message(
      'Недавние правки',
      name: 'recently_edited',
      desc: '',
      args: [],
    );
  }

  /// `Популярные`
  String get most_popular {
    return Intl.message(
      'Популярные',
      name: 'most_popular',
      desc: '',
      args: [],
    );
  }

  /// `По расам`
  String get by_race {
    return Intl.message(
      'По расам',
      name: 'by_race',
      desc: '',
      args: [],
    );
  }

  /// `По тегам`
  String get by_tags {
    return Intl.message(
      'По тегам',
      name: 'by_tags',
      desc: '',
      args: [],
    );
  }

  /// `Нет активности`
  String get no_recent_activity {
    return Intl.message(
      'Нет активности',
      name: 'no_recent_activity',
      desc: '',
      args: [],
    );
  }

  /// `С возвращением!`
  String get welcome_back {
    return Intl.message(
      'С возвращением!',
      name: 'welcome_back',
      desc: '',
      args: [],
    );
  }

  /// `Коллекция`
  String get your_collection {
    return Intl.message(
      'Коллекция',
      name: 'your_collection',
      desc: '',
      args: [],
    );
  }

  /// `Обзор`
  String get collection_overview {
    return Intl.message(
      'Обзор',
      name: 'collection_overview',
      desc: '',
      args: [],
    );
  }

  /// `Персонажей: {count}`
  String characters_count(Object count) {
    return Intl.message(
      'Персонажей: $count',
      name: 'characters_count',
      desc: '',
      args: [count],
    );
  }

  /// `Рас: {count}`
  String races_count(Object count) {
    return Intl.message(
      'Рас: $count',
      name: 'races_count',
      desc: '',
      args: [count],
    );
  }

  /// `Заметок: {count}`
  String notes_count(Object count) {
    return Intl.message(
      'Заметок: $count',
      name: 'notes_count',
      desc: '',
      args: [count],
    );
  }

  /// `Шаблонов: {count}`
  String templates_count(Object count) {
    return Intl.message(
      'Шаблонов: $count',
      name: 'templates_count',
      desc: '',
      args: [count],
    );
  }

  /// `Папок: {count}`
  String folders_count(Object count) {
    return Intl.message(
      'Папок: $count',
      name: 'folders_count',
      desc: '',
      args: [count],
    );
  }

  /// `Последнее создано`
  String get last_created {
    return Intl.message(
      'Последнее создано',
      name: 'last_created',
      desc: '',
      args: [],
    );
  }

  /// `Последнее изменено`
  String get last_edited {
    return Intl.message(
      'Последнее изменено',
      name: 'last_edited',
      desc: '',
      args: [],
    );
  }

  /// `Часто изменяемое`
  String get most_edited {
    return Intl.message(
      'Часто изменяемое',
      name: 'most_edited',
      desc: '',
      args: [],
    );
  }

  /// `Недавние персонажи`
  String get recent_characters {
    return Intl.message(
      'Недавние персонажи',
      name: 'recent_characters',
      desc: '',
      args: [],
    );
  }

  /// `Недавние расы`
  String get recent_races {
    return Intl.message(
      'Недавние расы',
      name: 'recent_races',
      desc: '',
      args: [],
    );
  }

  /// `Недавние заметки`
  String get recent_notes {
    return Intl.message(
      'Недавние заметки',
      name: 'recent_notes',
      desc: '',
      args: [],
    );
  }

  /// `Популярные теги`
  String get popular_tags {
    return Intl.message(
      'Популярные теги',
      name: 'popular_tags',
      desc: '',
      args: [],
    );
  }

  /// `Облако тегов`
  String get tag_cloud {
    return Intl.message(
      'Облако тегов',
      name: 'tag_cloud',
      desc: '',
      args: [],
    );
  }

  /// `Поиск по коллекции…`
  String get search_collection {
    return Intl.message(
      'Поиск по коллекции…',
      name: 'search_collection',
      desc: '',
      args: [],
    );
  }

  /// `Фильтр`
  String get filter_by {
    return Intl.message(
      'Фильтр',
      name: 'filter_by',
      desc: '',
      args: [],
    );
  }

  /// `Сортировка`
  String get sort_by {
    return Intl.message(
      'Сортировка',
      name: 'sort_by',
      desc: '',
      args: [],
    );
  }

  /// `Все`
  String get all_categories {
    return Intl.message(
      'Все',
      name: 'all_categories',
      desc: '',
      args: [],
    );
  }

  /// `Избранное`
  String get favorites {
    return Intl.message(
      'Избранное',
      name: 'favorites',
      desc: '',
      args: [],
    );
  }

  /// `Архив`
  String get archived {
    return Intl.message(
      'Архив',
      name: 'archived',
      desc: '',
      args: [],
    );
  }

  /// `Недавно просмотрено`
  String get recently_viewed {
    return Intl.message(
      'Недавно просмотрено',
      name: 'recently_viewed',
      desc: '',
      args: [],
    );
  }

  /// `Рекомендации`
  String get suggested_actions {
    return Intl.message(
      'Рекомендации',
      name: 'suggested_actions',
      desc: '',
      args: [],
    );
  }

  /// `Быстрое создание`
  String get quick_create {
    return Intl.message(
      'Быстрое создание',
      name: 'quick_create',
      desc: '',
      args: [],
    );
  }

  /// `Шаблоны`
  String get browse_templates {
    return Intl.message(
      'Шаблоны',
      name: 'browse_templates',
      desc: '',
      args: [],
    );
  }

  /// `Импорт`
  String get import_data {
    return Intl.message(
      'Импорт',
      name: 'import_data',
      desc: '',
      args: [],
    );
  }

  /// `Экспорт`
  String get export_data {
    return Intl.message(
      'Экспорт',
      name: 'export_data',
      desc: '',
      args: [],
    );
  }

  /// `Резервная копия`
  String get backup_data {
    return Intl.message(
      'Резервная копия',
      name: 'backup_data',
      desc: '',
      args: [],
    );
  }

  /// `Восстановить`
  String get restore_data {
    return Intl.message(
      'Восстановить',
      name: 'restore_data',
      desc: '',
      args: [],
    );
  }

  /// `Тур по приложению`
  String get app_tour {
    return Intl.message(
      'Тур по приложению',
      name: 'app_tour',
      desc: '',
      args: [],
    );
  }

  /// `Помощь`
  String get help_and_support {
    return Intl.message(
      'Помощь',
      name: 'help_and_support',
      desc: '',
      args: [],
    );
  }

  /// `Сообщество`
  String get community {
    return Intl.message(
      'Сообщество',
      name: 'community',
      desc: '',
      args: [],
    );
  }

  /// `Отзыв`
  String get feedback {
    return Intl.message(
      'Отзыв',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `Оценить`
  String get rate_app {
    return Intl.message(
      'Оценить',
      name: 'rate_app',
      desc: '',
      args: [],
    );
  }

  /// `Поделиться`
  String get share_app {
    return Intl.message(
      'Поделиться',
      name: 'share_app',
      desc: '',
      args: [],
    );
  }

  /// `О приложении`
  String get about {
    return Intl.message(
      'О приложении',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Конфиденциальность`
  String get privacy_policy {
    return Intl.message(
      'Конфиденциальность',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Условия`
  String get terms_of_service {
    return Intl.message(
      'Условия',
      name: 'terms_of_service',
      desc: '',
      args: [],
    );
  }

  /// `Версия`
  String get version_info {
    return Intl.message(
      'Версия',
      name: 'version_info',
      desc: '',
      args: [],
    );
  }

  /// `Обновления`
  String get check_for_updates {
    return Intl.message(
      'Обновления',
      name: 'check_for_updates',
      desc: '',
      args: [],
    );
  }

  /// `Что нового`
  String get whats_new {
    return Intl.message(
      'Что нового',
      name: 'whats_new',
      desc: '',
      args: [],
    );
  }

  /// `Сброс`
  String get reset_settings {
    return Intl.message(
      'Сброс',
      name: 'reset_settings',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить настройки`
  String get save_settings {
    return Intl.message(
      'Сохранить настройки',
      name: 'save_settings',
      desc: '',
      args: [],
    );
  }

  /// `Разделы`
  String get sections_to_include {
    return Intl.message(
      'Разделы',
      name: 'sections_to_include',
      desc: '',
      args: [],
    );
  }

  /// `Шрифты`
  String get font_settings {
    return Intl.message(
      'Шрифты',
      name: 'font_settings',
      desc: '',
      args: [],
    );
  }

  /// `Цвета`
  String get color_settings {
    return Intl.message(
      'Цвета',
      name: 'color_settings',
      desc: '',
      args: [],
    );
  }

  /// `Заголовок`
  String get title_font_size {
    return Intl.message(
      'Заголовок',
      name: 'title_font_size',
      desc: '',
      args: [],
    );
  }

  /// `Текст`
  String get body_font_size {
    return Intl.message(
      'Текст',
      name: 'body_font_size',
      desc: '',
      args: [],
    );
  }

  /// `Цвет заголовка`
  String get title_color {
    return Intl.message(
      'Цвет заголовка',
      name: 'title_color',
      desc: '',
      args: [],
    );
  }

  /// `Цвет текста`
  String get body_color {
    return Intl.message(
      'Цвет текста',
      name: 'body_color',
      desc: '',
      args: [],
    );
  }

  /// `Настройки сохранены`
  String get settings_saved {
    return Intl.message(
      'Настройки сохранены',
      name: 'settings_saved',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка загрузки настроек PDF`
  String get settings_load_error {
    return Intl.message(
      'Ошибка загрузки настроек PDF',
      name: 'settings_load_error',
      desc: '',
      args: [],
    );
  }

  /// `Размер шрифта`
  String get font_size {
    return Intl.message(
      'Размер шрифта',
      name: 'font_size',
      desc: '',
      args: [],
    );
  }

  /// `Выбор цвета`
  String get color_picker {
    return Intl.message(
      'Выбор цвета',
      name: 'color_picker',
      desc: '',
      args: [],
    );
  }

  /// `Экспорт`
  String get export_options {
    return Intl.message(
      'Экспорт',
      name: 'export_options',
      desc: '',
      args: [],
    );
  }

  /// `Макет`
  String get page_layout {
    return Intl.message(
      'Макет',
      name: 'page_layout',
      desc: '',
      args: [],
    );
  }

  /// `Размер`
  String get page_size {
    return Intl.message(
      'Размер',
      name: 'page_size',
      desc: '',
      args: [],
    );
  }

  /// `Поля`
  String get page_margins {
    return Intl.message(
      'Поля',
      name: 'page_margins',
      desc: '',
      args: [],
    );
  }

  /// `Изображения`
  String get include_images {
    return Intl.message(
      'Изображения',
      name: 'include_images',
      desc: '',
      args: [],
    );
  }

  /// `Качество`
  String get image_quality {
    return Intl.message(
      'Качество',
      name: 'image_quality',
      desc: '',
      args: [],
    );
  }

  /// `Высокое`
  String get high_quality {
    return Intl.message(
      'Высокое',
      name: 'high_quality',
      desc: '',
      args: [],
    );
  }

  /// `Среднее`
  String get medium_quality {
    return Intl.message(
      'Среднее',
      name: 'medium_quality',
      desc: '',
      args: [],
    );
  }

  /// `Низкое`
  String get low_quality {
    return Intl.message(
      'Низкое',
      name: 'low_quality',
      desc: '',
      args: [],
    );
  }

  /// `Сжатие`
  String get compression {
    return Intl.message(
      'Сжатие',
      name: 'compression',
      desc: '',
      args: [],
    );
  }

  /// `Ориентация`
  String get page_orientation {
    return Intl.message(
      'Ориентация',
      name: 'page_orientation',
      desc: '',
      args: [],
    );
  }

  /// `Портрет`
  String get portrait {
    return Intl.message(
      'Портрет',
      name: 'portrait',
      desc: '',
      args: [],
    );
  }

  /// `Альбом`
  String get landscape {
    return Intl.message(
      'Альбом',
      name: 'landscape',
      desc: '',
      args: [],
    );
  }

  /// `Авто`
  String get auto_layout {
    return Intl.message(
      'Авто',
      name: 'auto_layout',
      desc: '',
      args: [],
    );
  }

  /// `Свой`
  String get custom_layout {
    return Intl.message(
      'Свой',
      name: 'custom_layout',
      desc: '',
      args: [],
    );
  }

  /// `Нумерация`
  String get page_numbering {
    return Intl.message(
      'Нумерация',
      name: 'page_numbering',
      desc: '',
      args: [],
    );
  }

  /// `Колонтитулы`
  String get headers_footers {
    return Intl.message(
      'Колонтитулы',
      name: 'headers_footers',
      desc: '',
      args: [],
    );
  }

  /// `Оглавление`
  String get table_of_contents {
    return Intl.message(
      'Оглавление',
      name: 'table_of_contents',
      desc: '',
      args: [],
    );
  }

  /// `Водяной знак`
  String get watermark {
    return Intl.message(
      'Водяной знак',
      name: 'watermark',
      desc: '',
      args: [],
    );
  }

  /// `Безопасность`
  String get security_options {
    return Intl.message(
      'Безопасность',
      name: 'security_options',
      desc: '',
      args: [],
    );
  }

  /// `Пароль`
  String get password_protection {
    return Intl.message(
      'Пароль',
      name: 'password_protection',
      desc: '',
      args: [],
    );
  }

  /// `Разрешения`
  String get permissions {
    return Intl.message(
      'Разрешения',
      name: 'permissions',
      desc: '',
      args: [],
    );
  }

  /// `Печать`
  String get allow_printing {
    return Intl.message(
      'Печать',
      name: 'allow_printing',
      desc: '',
      args: [],
    );
  }

  /// `Копирование`
  String get allow_copying {
    return Intl.message(
      'Копирование',
      name: 'allow_copying',
      desc: '',
      args: [],
    );
  }

  /// `Изменения`
  String get allow_modifications {
    return Intl.message(
      'Изменения',
      name: 'allow_modifications',
      desc: '',
      args: [],
    );
  }

  /// `Метаданные`
  String get metadata {
    return Intl.message(
      'Метаданные',
      name: 'metadata',
      desc: '',
      args: [],
    );
  }

  /// `Автор`
  String get author {
    return Intl.message(
      'Автор',
      name: 'author',
      desc: '',
      args: [],
    );
  }

  /// `Тема`
  String get subject {
    return Intl.message(
      'Тема',
      name: 'subject',
      desc: '',
      args: [],
    );
  }

  /// `Ключевые слова`
  String get keywords {
    return Intl.message(
      'Ключевые слова',
      name: 'keywords',
      desc: '',
      args: [],
    );
  }

  /// `Расширенные`
  String get advanced_settings {
    return Intl.message(
      'Расширенные',
      name: 'advanced_settings',
      desc: '',
      args: [],
    );
  }

  /// `Образец`
  String get generate_sample {
    return Intl.message(
      'Образец',
      name: 'generate_sample',
      desc: '',
      args: [],
    );
  }

  /// `По умолчанию`
  String get default_settings {
    return Intl.message(
      'По умолчанию',
      name: 'default_settings',
      desc: '',
      args: [],
    );
  }

  /// `Пресет`
  String get export_preset {
    return Intl.message(
      'Пресет',
      name: 'export_preset',
      desc: '',
      args: [],
    );
  }

  /// `Свой пресет`
  String get custom_preset {
    return Intl.message(
      'Свой пресет',
      name: 'custom_preset',
      desc: '',
      args: [],
    );
  }

  /// `Сохранить`
  String get save_preset {
    return Intl.message(
      'Сохранить',
      name: 'save_preset',
      desc: '',
      args: [],
    );
  }

  /// `Загрузить`
  String get load_preset {
    return Intl.message(
      'Загрузить',
      name: 'load_preset',
      desc: '',
      args: [],
    );
  }

  /// `Удалить`
  String get delete_preset {
    return Intl.message(
      'Удалить',
      name: 'delete_preset',
      desc: '',
      args: [],
    );
  }

  /// `Название`
  String get preset_name {
    return Intl.message(
      'Название',
      name: 'preset_name',
      desc: '',
      args: [],
    );
  }

  /// `Пресет сохранён`
  String get preset_saved {
    return Intl.message(
      'Пресет сохранён',
      name: 'preset_saved',
      desc: '',
      args: [],
    );
  }

  /// `Пресет загружен`
  String get preset_loaded {
    return Intl.message(
      'Пресет загружен',
      name: 'preset_loaded',
      desc: '',
      args: [],
    );
  }

  /// `Пресет удалён`
  String get preset_deleted {
    return Intl.message(
      'Пресет удалён',
      name: 'preset_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка сервиса персонажа`
  String get service_creation_error {
    return Intl.message(
      'Ошибка сервиса персонажа',
      name: 'service_creation_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка сервиса расы`
  String get race_service_creation_error {
    return Intl.message(
      'Ошибка сервиса расы',
      name: 'race_service_creation_error',
      desc: '',
      args: [],
    );
  }

  /// `Тип не поддерживается для PDF`
  String get unsupported_model_type {
    return Intl.message(
      'Тип не поддерживается для PDF',
      name: 'unsupported_model_type',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка создания PDF`
  String get pdf_generation_error {
    return Intl.message(
      'Ошибка создания PDF',
      name: 'pdf_generation_error',
      desc: '',
      args: [],
    );
  }

  /// `Таймаут загрузки шрифта`
  String get font_load_timeout {
    return Intl.message(
      'Таймаут загрузки шрифта',
      name: 'font_load_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка сохранения настроек PDF`
  String get settings_save_error {
    return Intl.message(
      'Ошибка сохранения настроек PDF',
      name: 'settings_save_error',
      desc: '',
      args: [],
    );
  }

  /// `Профиль персонажа`
  String get character_profile_title {
    return Intl.message(
      'Профиль персонажа',
      name: 'character_profile_title',
      desc: '',
      args: [],
    );
  }

  /// `Профиль расы`
  String get race_profile_title {
    return Intl.message(
      'Профиль расы',
      name: 'race_profile_title',
      desc: '',
      args: [],
    );
  }

  /// `Таймаут создания PDF`
  String get pdf_creation_timeout {
    return Intl.message(
      'Таймаут создания PDF',
      name: 'pdf_creation_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Таймаут генерации PDF`
  String get pdf_generation_timeout {
    return Intl.message(
      'Таймаут генерации PDF',
      name: 'pdf_generation_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Таймаут отправки`
  String get file_sharing_timeout {
    return Intl.message(
      'Таймаут отправки',
      name: 'file_sharing_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Таймаут операции`
  String get operation_timeout {
    return Intl.message(
      'Таймаут операции',
      name: 'operation_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка PDF`
  String get pdf_creation_failed {
    return Intl.message(
      'Ошибка PDF',
      name: 'pdf_creation_failed',
      desc: '',
      args: [],
    );
  }

  /// `Таймаут`
  String get timeout_error {
    return Intl.message(
      'Таймаут',
      name: 'timeout_error',
      desc: '',
      args: [],
    );
  }

  /// `PDF готов`
  String get export_success {
    return Intl.message(
      'PDF готов',
      name: 'export_success',
      desc: '',
      args: [],
    );
  }

  /// `"{name}" экспортирована в PDF`
  String race_exported(Object name) {
    return Intl.message(
      '"$name" экспортирована в PDF',
      name: 'race_exported',
      desc: '',
      args: [name],
    );
  }

  /// `Инициализация`
  String get initialization {
    return Intl.message(
      'Инициализация',
      name: 'initialization',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка инициализации`
  String get initialization_error {
    return Intl.message(
      'Ошибка инициализации',
      name: 'initialization_error',
      desc: '',
      args: [],
    );
  }

  /// `Критическая ошибка`
  String get critical_error {
    return Intl.message(
      'Критическая ошибка',
      name: 'critical_error',
      desc: '',
      args: [],
    );
  }

  /// `Данные сброшены для восстановления работы`
  String get initialization_reset_warning {
    return Intl.message(
      'Данные сброшены для восстановления работы',
      name: 'initialization_reset_warning',
      desc: '',
      args: [],
    );
  }

  /// `Часть данных могла быть утеряна`
  String get critical_error_warning {
    return Intl.message(
      'Часть данных могла быть утеряна',
      name: 'critical_error_warning',
      desc: '',
      args: [],
    );
  }

  /// `Понятно`
  String get understood {
    return Intl.message(
      'Понятно',
      name: 'understood',
      desc: '',
      args: [],
    );
  }

  /// `Подробнее`
  String get details {
    return Intl.message(
      'Подробнее',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  /// `Закрыть приложение`
  String get close_app {
    return Intl.message(
      'Закрыть приложение',
      name: 'close_app',
      desc: '',
      args: [],
    );
  }

  /// `Продолжить`
  String get continue_text {
    return Intl.message(
      'Продолжить',
      name: 'continue_text',
      desc: '',
      args: [],
    );
  }

  /// `Детали ошибки`
  String get error_details {
    return Intl.message(
      'Детали ошибки',
      name: 'error_details',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка при запуске. Техническая информация:`
  String get error_details_description {
    return Intl.message(
      'Ошибка при запуске. Техническая информация:',
      name: 'error_details_description',
      desc: '',
      args: [],
    );
  }

  /// `Технические детали`
  String get technical_details {
    return Intl.message(
      'Технические детали',
      name: 'technical_details',
      desc: '',
      args: [],
    );
  }

  /// `Приложение попыталось восстановиться. При повторе ошибки переустановите приложение.`
  String get recovery_advice {
    return Intl.message(
      'Приложение попыталось восстановиться. При повторе ошибки переустановите приложение.',
      name: 'recovery_advice',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка базы данных`
  String get hive_initialization_error {
    return Intl.message(
      'Ошибка базы данных',
      name: 'hive_initialization_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка менеджера окон`
  String get window_manager_initialization_error {
    return Intl.message(
      'Ошибка менеджера окон',
      name: 'window_manager_initialization_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка инициализации данных`
  String get data_initialization_error {
    return Intl.message(
      'Ошибка инициализации данных',
      name: 'data_initialization_error',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка сервиса`
  String get service_initialization_error {
    return Intl.message(
      'Ошибка сервиса',
      name: 'service_initialization_error',
      desc: '',
      args: [],
    );
  }

  /// `Готово`
  String get initialization_success {
    return Intl.message(
      'Готово',
      name: 'initialization_success',
      desc: '',
      args: [],
    );
  }

  /// `Сбой инициализации`
  String get initialization_failed {
    return Intl.message(
      'Сбой инициализации',
      name: 'initialization_failed',
      desc: '',
      args: [],
    );
  }

  /// `Повторить`
  String get retry_initialization {
    return Intl.message(
      'Повторить',
      name: 'retry_initialization',
      desc: '',
      args: [],
    );
  }

  /// `Запуск…`
  String get initialization_progress {
    return Intl.message(
      'Запуск…',
      name: 'initialization_progress',
      desc: '',
      args: [],
    );
  }

  /// `Загрузка данных…`
  String get loading_data {
    return Intl.message(
      'Загрузка данных…',
      name: 'loading_data',
      desc: '',
      args: [],
    );
  }

  /// `Подготовка сервисов…`
  String get preparing_services {
    return Intl.message(
      'Подготовка сервисов…',
      name: 'preparing_services',
      desc: '',
      args: [],
    );
  }

  /// `Проверка зависимостей…`
  String get checking_dependencies {
    return Intl.message(
      'Проверка зависимостей…',
      name: 'checking_dependencies',
      desc: '',
      args: [],
    );
  }

  /// `Таймаут запуска`
  String get initialization_timeout {
    return Intl.message(
      'Таймаут запуска',
      name: 'initialization_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Запуск занял много времени. Проверьте интернет и повторите.`
  String get initialization_timeout_message {
    return Intl.message(
      'Запуск занял много времени. Проверьте интернет и повторите.',
      name: 'initialization_timeout_message',
      desc: '',
      args: [],
    );
  }

  /// `Мало места`
  String get low_storage_warning {
    return Intl.message(
      'Мало места',
      name: 'low_storage_warning',
      desc: '',
      args: [],
    );
  }

  /// `Осталось мало места. Приложение может работать нестабильно.`
  String get low_storage_message {
    return Intl.message(
      'Осталось мало места. Приложение может работать нестабильно.',
      name: 'low_storage_message',
      desc: '',
      args: [],
    );
  }

  /// `Нужно разрешение`
  String get permission_required {
    return Intl.message(
      'Нужно разрешение',
      name: 'permission_required',
      desc: '',
      args: [],
    );
  }

  /// `Нужен доступ к хранилищу.`
  String get storage_permission_message {
    return Intl.message(
      'Нужен доступ к хранилищу.',
      name: 'storage_permission_message',
      desc: '',
      args: [],
    );
  }

  /// `Разрешить`
  String get grant_permission {
    return Intl.message(
      'Разрешить',
      name: 'grant_permission',
      desc: '',
      args: [],
    );
  }

  /// `Пропустить`
  String get skip_for_now {
    return Intl.message(
      'Пропустить',
      name: 'skip_for_now',
      desc: '',
      args: [],
    );
  }

  /// `Готово`
  String get initialization_complete {
    return Intl.message(
      'Готово',
      name: 'initialization_complete',
      desc: '',
      args: [],
    );
  }

  /// `Приложение готово`
  String get ready_to_use {
    return Intl.message(
      'Приложение готово',
      name: 'ready_to_use',
      desc: '',
      args: [],
    );
  }

  /// `Добро пожаловать!`
  String get welcome_message {
    return Intl.message(
      'Добро пожаловать!',
      name: 'welcome_message',
      desc: '',
      args: [],
    );
  }

  /// `Настройка окружения…`
  String get configuring_environment {
    return Intl.message(
      'Настройка окружения…',
      name: 'configuring_environment',
      desc: '',
      args: [],
    );
  }

  /// `Загрузка ресурсов…`
  String get loading_resources {
    return Intl.message(
      'Загрузка ресурсов…',
      name: 'loading_resources',
      desc: '',
      args: [],
    );
  }

  /// `Проверка целостности…`
  String get verifying_integrity {
    return Intl.message(
      'Проверка целостности…',
      name: 'verifying_integrity',
      desc: '',
      args: [],
    );
  }

  /// `Миграция…`
  String get migration_in_progress {
    return Intl.message(
      'Миграция…',
      name: 'migration_in_progress',
      desc: '',
      args: [],
    );
  }

  /// `Резервное копирование…`
  String get backup_creation {
    return Intl.message(
      'Резервное копирование…',
      name: 'backup_creation',
      desc: '',
      args: [],
    );
  }

  /// `Очистка кэша…`
  String get cache_clearing {
    return Intl.message(
      'Очистка кэша…',
      name: 'cache_clearing',
      desc: '',
      args: [],
    );
  }

  /// `Оптимизация…`
  String get optimizing_performance {
    return Intl.message(
      'Оптимизация…',
      name: 'optimizing_performance',
      desc: '',
      args: [],
    );
  }

  /// `Завершение…`
  String get finalizing_setup {
    return Intl.message(
      'Завершение…',
      name: 'finalizing_setup',
      desc: '',
      args: [],
    );
  }

  /// `Закрыть`
  String get close {
    return Intl.message(
      'Закрыть',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Файл расы (.race)`
  String get file_race {
    return Intl.message(
      'Файл расы (.race)',
      name: 'file_race',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка дублирования`
  String get duplicate_error {
    return Intl.message(
      'Ошибка дублирования',
      name: 'duplicate_error',
      desc: '',
      args: [],
    );
  }

  /// `Дублировать персонажа`
  String get duplicate_character {
    return Intl.message(
      'Дублировать персонажа',
      name: 'duplicate_character',
      desc: '',
      args: [],
    );
  }

  /// `Персонаж продублирован`
  String get character_duplicated {
    return Intl.message(
      'Персонаж продублирован',
      name: 'character_duplicated',
      desc: '',
      args: [],
    );
  }

  /// `Персонажи и расы`
  String get characters_and_races {
    return Intl.message(
      'Персонажи и расы',
      name: 'characters_and_races',
      desc: '',
      args: [],
    );
  }

  /// `Дублировать`
  String get duplicate {
    return Intl.message(
      'Дублировать',
      name: 'duplicate',
      desc: '',
      args: [],
    );
  }

  /// `Информация`
  String get information {
    return Intl.message(
      'Информация',
      name: 'information',
      desc: '',
      args: [],
    );
  }

  /// `Удалить выбранное?`
  String get deleteConfirmation {
    return Intl.message(
      'Удалить выбранное?',
      name: 'deleteConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Голубой`
  String get color_light_blue {
    return Intl.message(
      'Голубой',
      name: 'color_light_blue',
      desc: '',
      args: [],
    );
  }

  /// `Выберите цвет`
  String get choose_color {
    return Intl.message(
      'Выберите цвет',
      name: 'choose_color',
      desc: '',
      args: [],
    );
  }

  /// `Экспорт занял слишком много времени. Попробуйте ещё раз.`
  String get export_timeout {
    return Intl.message(
      'Экспорт занял слишком много времени. Попробуйте ещё раз.',
      name: 'export_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Действия смахивания`
  String get swipeActions {
    return Intl.message(
      'Действия смахивания',
      name: 'swipeActions',
      desc: '',
      args: [],
    );
  }

  /// `Смахивание влево`
  String get leftSwipeAction {
    return Intl.message(
      'Смахивание влево',
      name: 'leftSwipeAction',
      desc: '',
      args: [],
    );
  }

  /// `Смахивание вправо`
  String get rightSwipeAction {
    return Intl.message(
      'Смахивание вправо',
      name: 'rightSwipeAction',
      desc: '',
      args: [],
    );
  }

  /// `Настроить смахивания`
  String get configureSwipeActions {
    return Intl.message(
      'Настроить смахивания',
      name: 'configureSwipeActions',
      desc: '',
      args: [],
    );
  }

  /// `Отменить`
  String get undo {
    return Intl.message(
      'Отменить',
      name: 'undo',
      desc: '',
      args: [],
    );
  }

  /// `Изображение удалено`
  String get image_removed {
    return Intl.message(
      'Изображение удалено',
      name: 'image_removed',
      desc: '',
      args: [],
    );
  }

  /// `Поле удалено`
  String get field_removed {
    return Intl.message(
      'Поле удалено',
      name: 'field_removed',
      desc: '',
      args: [],
    );
  }

  /// `Изменения сохранены`
  String get changes_saved {
    return Intl.message(
      'Изменения сохранены',
      name: 'changes_saved',
      desc: '',
      args: [],
    );
  }

  /// `Готово`
  String get done {
    return Intl.message(
      'Готово',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Закреплённые`
  String get edit_pins {
    return Intl.message(
      'Закреплённые',
      name: 'edit_pins',
      desc: '',
      args: [],
    );
  }

  /// `Закреплённые`
  String get pinned {
    return Intl.message(
      'Закреплённые',
      name: 'pinned',
      desc: '',
      args: [],
    );
  }

  /// `Нет закреплённых`
  String get no_pinned_items {
    return Intl.message(
      'Нет закреплённых',
      name: 'no_pinned_items',
      desc: '',
      args: [],
    );
  }

  /// `Закрепить`
  String get pin {
    return Intl.message(
      'Закрепить',
      name: 'pin',
      desc: '',
      args: [],
    );
  }

  /// `Открепить`
  String get unpin {
    return Intl.message(
      'Открепить',
      name: 'unpin',
      desc: '',
      args: [],
    );
  }

  /// `Папки`
  String get folder_mode {
    return Intl.message(
      'Папки',
      name: 'folder_mode',
      desc: '',
      args: [],
    );
  }

  /// `Список`
  String get list_mode {
    return Intl.message(
      'Список',
      name: 'list_mode',
      desc: '',
      args: [],
    );
  }

  /// `Новая заметка`
  String get new_note {
    return Intl.message(
      'Новая заметка',
      name: 'new_note',
      desc: '',
      args: [],
    );
  }

  /// `Файл приложения`
  String get file_app {
    return Intl.message(
      'Файл приложения',
      name: 'file_app',
      desc: '',
      args: [],
    );
  }

  /// `Cвязи между персонажами`
  String get relationships {
    return Intl.message(
      'Cвязи между персонажами',
      name: 'relationships',
      desc: '',
      args: [],
    );
  }

  /// `Удалить связь?`
  String get deleteRelationshipTitle {
    return Intl.message(
      'Удалить связь?',
      name: 'deleteRelationshipTitle',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите удалить конкретно эту связь?`
  String get deleteRelationshipMessage {
    return Intl.message(
      'Вы уверены, что хотите удалить конкретно эту связь?',
      name: 'deleteRelationshipMessage',
      desc: '',
      args: [],
    );
  }

  /// `Связь удалена`
  String get relationshipDeleted {
    return Intl.message(
      'Связь удалена',
      name: 'relationshipDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Скопировано в буфер обмена`
  String get copiedToClipboard {
    return Intl.message(
      'Скопировано в буфер обмена',
      name: 'copiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Добавить связь`
  String get add_relationships {
    return Intl.message(
      'Добавить связь',
      name: 'add_relationships',
      desc: '',
      args: [],
    );
  }

  /// `Неизвестно`
  String get unknown {
    return Intl.message(
      'Неизвестно',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `Создание связи`
  String get createRelationship {
    return Intl.message(
      'Создание связи',
      name: 'createRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Редактирование связи`
  String get editRelationship {
    return Intl.message(
      'Редактирование связи',
      name: 'editRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Персонаж 1`
  String get character1 {
    return Intl.message(
      'Персонаж 1',
      name: 'character1',
      desc: '',
      args: [],
    );
  }

  /// `Персонаж 2`
  String get character2 {
    return Intl.message(
      'Персонаж 2',
      name: 'character2',
      desc: '',
      args: [],
    );
  }

  /// `Название связи`
  String get relationshipName {
    return Intl.message(
      'Название связи',
      name: 'relationshipName',
      desc: '',
      args: [],
    );
  }

  /// `Тип (необязательно)`
  String get typeOptional {
    return Intl.message(
      'Тип (необязательно)',
      name: 'typeOptional',
      desc: '',
      args: [],
    );
  }

  /// `Направленная связь`
  String get directedRelationship {
    return Intl.message(
      'Направленная связь',
      name: 'directedRelationship',
      desc: '',
      args: [],
    );
  }

  /// `Выберите обоих персонажей`
  String get selectBothCharacters {
    return Intl.message(
      'Выберите обоих персонажей',
      name: 'selectBothCharacters',
      desc: '',
      args: [],
    );
  }

  /// `Нельзя создать связь персонажа с самим собой`
  String get cannotRelateToItself {
    return Intl.message(
      'Нельзя создать связь персонажа с самим собой',
      name: 'cannotRelateToItself',
      desc: '',
      args: [],
    );
  }

  /// `Такая связь уже существует`
  String get relationshipAlreadyExists {
    return Intl.message(
      'Такая связь уже существует',
      name: 'relationshipAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `Введите название`
  String get enterName {
    return Intl.message(
      'Введите название',
      name: 'enterName',
      desc: '',
      args: [],
    );
  }

  /// `Нет данных для резервного копирования. Добавьте хотя бы один элемент (персонажа, заметку, расу и т.д.) перед экспортом.`
  String get no_data_for_backup {
    return Intl.message(
      'Нет данных для резервного копирования. Добавьте хотя бы один элемент (персонажа, заметку, расу и т.д.) перед экспортом.',
      name: 'no_data_for_backup',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка экспорта`
  String get export_failed {
    return Intl.message(
      'Ошибка экспорта',
      name: 'export_failed',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка импорта`
  String get import_failed {
    return Intl.message(
      'Ошибка импорта',
      name: 'import_failed',
      desc: '',
      args: [],
    );
  }

  /// `⚠️ Заменить все данные?`
  String get restore_warning_title {
    return Intl.message(
      '⚠️ Заменить все данные?',
      name: 'restore_warning_title',
      desc: '',
      args: [],
    );
  }

  /// `Все текущие данные будут безвозвратно удалены и заменены резервной копией. Это действие нельзя отменить. Продолжить?`
  String get restore_warning_message {
    return Intl.message(
      'Все текущие данные будут безвозвратно удалены и заменены резервной копией. Это действие нельзя отменить. Продолжить?',
      name: 'restore_warning_message',
      desc: '',
      args: [],
    );
  }

  /// `Заменить все данные`
  String get restore_confirm {
    return Intl.message(
      'Заменить все данные',
      name: 'restore_confirm',
      desc: '',
      args: [],
    );
  }

  /// `О резервном копировании`
  String get backup_info_title {
    return Intl.message(
      'О резервном копировании',
      name: 'backup_info_title',
      desc: '',
      args: [],
    );
  }

  /// `Резервные копии сохраняются в виде одного JSON-файла со всеми данными.\nОблачное хранилище — ваш личный Google Drive. Экспортированные файлы можно передавать и импортировать на других устройствах.`
  String get backup_info_description {
    return Intl.message(
      'Резервные копии сохраняются в виде одного JSON-файла со всеми данными.\nОблачное хранилище — ваш личный Google Drive. Экспортированные файлы можно передавать и импортировать на других устройствах.',
      name: 'backup_info_description',
      desc: '',
      args: [],
    );
  }

  /// `При восстановлении все существующие данные в приложении будут безвозвратно удалены.`
  String get backup_info_restore_warning {
    return Intl.message(
      'При восстановлении все существующие данные в приложении будут безвозвратно удалены.',
      name: 'backup_info_restore_warning',
      desc: '',
      args: [],
    );
  }

  /// `Автоматическое облачное копирование`
  String get auto_cloud_backup_title {
    return Intl.message(
      'Автоматическое облачное копирование',
      name: 'auto_cloud_backup_title',
      desc: '',
      args: [],
    );
  }

  /// `Создавать резервную копию в Google Drive при запуске приложения`
  String get auto_cloud_backup_subtitle {
    return Intl.message(
      'Создавать резервную копию в Google Drive при запуске приложения',
      name: 'auto_cloud_backup_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Локальная копия (файл)`
  String get local_backup {
    return Intl.message(
      'Локальная копия (файл)',
      name: 'local_backup',
      desc: '',
      args: [],
    );
  }

  /// `Облачная копия (Google Drive)`
  String get cloud_backup {
    return Intl.message(
      'Облачная копия (Google Drive)',
      name: 'cloud_backup',
      desc: '',
      args: [],
    );
  }

  /// `Экспорт в файл`
  String get export_to_file {
    return Intl.message(
      'Экспорт в файл',
      name: 'export_to_file',
      desc: '',
      args: [],
    );
  }

  /// `Импорт из файла`
  String get import_from_file {
    return Intl.message(
      'Импорт из файла',
      name: 'import_from_file',
      desc: '',
      args: [],
    );
  }

  /// `Экспорт в облако`
  String get export_to_cloud {
    return Intl.message(
      'Экспорт в облако',
      name: 'export_to_cloud',
      desc: '',
      args: [],
    );
  }

  /// `Импорт из облака`
  String get import_from_cloud {
    return Intl.message(
      'Импорт из облака',
      name: 'import_from_cloud',
      desc: '',
      args: [],
    );
  }

  /// `Выберите расу`
  String get select_race {
    return Intl.message(
      'Выберите расу',
      name: 'select_race',
      desc: '',
      args: [],
    );
  }

  /// `Введите имя персонажа`
  String get enter_name_character {
    return Intl.message(
      'Введите имя персонажа',
      name: 'enter_name_character',
      desc: '',
      args: [],
    );
  }

  /// `Выберите расу персонажа`
  String get choose_race_character {
    return Intl.message(
      'Выберите расу персонажа',
      name: 'choose_race_character',
      desc: '',
      args: [],
    );
  }

  /// `Введите название заметки`
  String get enter_title_note {
    return Intl.message(
      'Введите название заметки',
      name: 'enter_title_note',
      desc: '',
      args: [],
    );
  }

  /// `Введите название шаблона`
  String get enter_title_template {
    return Intl.message(
      'Введите название шаблона',
      name: 'enter_title_template',
      desc: '',
      args: [],
    );
  }

  /// `Своё событие`
  String get custom_event {
    return Intl.message(
      'Своё событие',
      name: 'custom_event',
      desc: '',
      args: [],
    );
  }

  /// `Добавить событие`
  String get add_event {
    return Intl.message(
      'Добавить событие',
      name: 'add_event',
      desc: '',
      args: [],
    );
  }

  /// `Новое событие`
  String get new_event {
    return Intl.message(
      'Новое событие',
      name: 'new_event',
      desc: '',
      args: [],
    );
  }

  /// `Редактировать событие`
  String get edit_event {
    return Intl.message(
      'Редактировать событие',
      name: 'edit_event',
      desc: '',
      args: [],
    );
  }

  /// `Название`
  String get event_title {
    return Intl.message(
      'Название',
      name: 'event_title',
      desc: '',
      args: [],
    );
  }

  /// `Описание`
  String get event_description {
    return Intl.message(
      'Описание',
      name: 'event_description',
      desc: '',
      args: [],
    );
  }

  /// `Дата`
  String get date {
    return Intl.message(
      'Дата',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Время`
  String get time {
    return Intl.message(
      'Время',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `мин`
  String get minutes {
    return Intl.message(
      'мин',
      name: 'minutes',
      desc: '',
      args: [],
    );
  }

  /// `Напомнить за`
  String get minutes_before {
    return Intl.message(
      'Напомнить за',
      name: 'minutes_before',
      desc: '',
      args: [],
    );
  }

  /// `Введите название события`
  String get enter_event_title {
    return Intl.message(
      'Введите название события',
      name: 'enter_event_title',
      desc: '',
      args: [],
    );
  }

  /// `Напоминание`
  String get reminder {
    return Intl.message(
      'Напоминание',
      name: 'reminder',
      desc: '',
      args: [],
    );
  }

  /// `Добавить в системный календарь`
  String get add_to_calendar {
    return Intl.message(
      'Добавить в системный календарь',
      name: 'add_to_calendar',
      desc: '',
      args: [],
    );
  }

  /// `Word документ`
  String get file_word {
    return Intl.message(
      'Word документ',
      name: 'file_word',
      desc: '',
      args: [],
    );
  }

  /// `Word документ успешно экспортирован`
  String get word_export_success {
    return Intl.message(
      'Word документ успешно экспортирован',
      name: 'word_export_success',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка экспорта в Word`
  String get word_export_error {
    return Intl.message(
      'Ошибка экспорта в Word',
      name: 'word_export_error',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
