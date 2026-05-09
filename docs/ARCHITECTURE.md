# Архитектура приложения CharacterBook

```
<корневой каталог проекта>
├── .github/                  # Конфигурация GitHub Actions
│   └── workflows/
│       └── dart.yml          # CI/CD пайплайн
├── assets/                   # Статические ресурсы приложения
│   ├── fonts/                # Шрифты
│   └── ...                   # Изображения и иконки
├── lib/                      # Основная кодовая база на Dart
│   ├── adapters/             # Адаптеры для Hive
│   │   └── custom_field_adapter.dart
│   ├── core/                 # Ядро приложения, базовые сущности
│   │   └── base_entity.dart
│   ├── data/                 # Слой данных
│   │   ├── enums/            # Перечисления
│   │   │   ├── calendar_event_type_enum.dart
│   │   │   ├── character_sort_enum.dart
│   │   │   ├── home_content_type_enum.dart
│   │   │   ├── note_sort_enum.dart
│   │   │   ├── template_sort_enum.dart
│   │   │   └── race_sort_enum.dart
│   │   ├── models/           # Модели данных
│   │   │   ├── calendar_event_model.dart
│   │   │   ├── character_model.dart
│   │   │   ├── ... (другие модели)
│   │   │   └── relationship_model.dart
│   │   ├── repositories/     # Репозитории для доступа к данным
│   │   │   ├── character_repository.dart
│   │   │   ├── ... (другие репозитории)
│   │   │   └── template_repository.dart
│   │   └── services/         # Сервисы для работы с данными
│   │       ├── character_service.dart
│   │       ├── ... (другие сервисы)
│   │       └── template_service.dart
│   ├── extensions/           # Расширения для встроенных классов
│   │   └── color_extension.dart
│   ├── gen/                  # Сгенерированные файлы (assets)
│   │   └── assets.gen.dart
│   ├── generated/            # Сгенерированные файлы локализации
│   │   └── intl/
│   │       ├── messages_all.dart
│   │       ├── messages_en.dart
│   │       ├── messages_ru.dart
│   │       └── l10n.dart
│   ├── handlers/             # Обработчики файлов для разных платформ
│   │   ├── desktop_file_handler.dart
│   │   ├── file_handler.dart
│   │   ├── file_handler_wrapper.dart
│   │   └── web_file_handler.dart
│   ├── interfaces/           # Интерфейсы (контракты)
│   │   └── file_handler_interface.dart
│   ├── l10n/                 # Исходные файлы локализации
│   │   ├── intl_en.arb
│   │   └── intl_ru.arb
│   ├── providers/            # Провайдеры состояния
│   │   ├── locale_provider.dart
│   │   ├── swipe_action_settings_provider.dart
│   │   └── theme_provider.dart
│   ├── services/             # Внешние сервисы и утилиты
│   │   ├── backup_service.dart
│   │   ├── clipboard_service.dart
│   │   ├── cloud_backup_service.dart   # Облачное резервное копирование
│   │   ├── date_formatter.dart
│   │   ├── notification_service.dart   # Локальные уведомления
│   │   ├── ... (другие сервисы)
│   │   └── pdf_export_service.dart
│   └── ui/                   # Компоненты пользовательского интерфейса
│       ├── controllers/      # Контроллеры для экранов
│       ├── navigation/       # Навигационные компоненты
│       ├── screens/          # Основные экраны
│       │   ├── settings/
│       │   ├── characters/
│       │   ├── races/
│       │   ├── notes/
│       │   ├── templates/
│       │   ├── calendar/     # Экран календаря
│       │   └── ...
│       └── widgets/          # Переиспользуемые виджеты
├── test/                     # Модульные и виджет-тесты
│   ├── unit/                 # Unit-тесты сервисов и репозиториев
│   └── widget/               # Виджет-тесты экранов
├── web/                      # Конфигурация для Web
├── android/                  # Конфигурация для Android
├── ios/                      # Конфигурация для iOS
├── linux/                    # Конфигурация для Linux
├── macos/                    # Конфигурация для macOS
└── windows/                  # Конфигурация для Windows

main.dart                     # Точка входа в приложение
```

## Технологический стек

### Основные технологии
- Flutter 3.13+ — кроссплатформенный UI фреймворк
- Dart 3.7.2+ — язык программирования

### Управление состоянием
- Provider — основной инструмент для управления состоянием (используется `ChangeNotifierProvider`, `ProxyProvider`, `MultiProvider`)
- Flutter Bloc ^9.1.1 — для более сложных сценариев управления состоянием

### Генерация кода
- json_serializable, build_runner — для сериализации JSON
- hive_generator — генерация адаптеров Hive
- flutter_gen — генерация типизированных ассетов
- intl_utils — для локализации

### Локальное хранилище
- Hive 2.2.3 — быстрая NoSQL база данных для хранения моделей
- Shared Preferences — для хранения пользовательских настроек

### Работа с файловой системой
- file_picker — выбор файлов
- share_plus — шаринг файлов
- clipboard — работа с буфером обмена

### Генерация PDF
- pdf — создание PDF-документов
- printing — печать
- docs_gee — создание DOCX-файлов (Word)

### Интеграция с платформой
- url_launcher — открытие внешних ссылок
- dynamic_color — поддержка динамических цветов Material You

### Взаимодействие с платформой и облаком
- google_sign_in — аутентификация Google
- googleapis — работа с Google Drive API
- extension_google_sign_in_as_googleapis_auth — адаптер для использования токенов
- image_picker — выбор изображений
- crop_image — обрезка изображений
- open_filex — открытие файлов

### Календарь и уведомления
- table_calendar — виджет календаря
- flutter_local_notifications — локальные напоминания о событиях

### Форматирование
- flutter_markdown — отображение Markdown в описаниях

## Модульная структура
Приложение следует принципам чистой архитектуры с разделением на слои:
- Ядро (`core/`) — базовые сущности предметной области.
- Данные (`data/`) — модели, репозитории, сервисы для работы с данными.
- Обработчики (`handlers/`) — платформозависимая работа с файлами.
- Интерфейсы (`interfaces/`) — контракты для реализации функций.
- Сервисы (`services/`) — бизнес-логика верхнего уровня, работа с внешними сервисами.
- Провайдеры (`providers/`) — управление состоянием приложения (тема, язык, настройки).
- UI (`ui/`) — представление данных, экраны, виджеты, контроллеры.

Такое разделение обеспечивает тестируемость, переиспользование кода и упрощает поддержку.

## Модели данных (из `lib/data/models/`)

### Character (Персонаж)
- Тип Hive: `typeId: 0`
- Назначение: Основная сущность приложения для хранения данных о персонажах.
- Ключевые поля: `id`, `name`, `age`, `gender`, `biography`, `personality`, `appearance`, `imageBytes`, `referenceImageBytes`, `additionalImages`, `customFields`, `race`, `tags` (вместо `folderId` используется система тегов).

### Race (Раса)
- Тип Hive: `typeId: 3`
- Назначение: Хранение данных о расах персонажей.
- Ключевые поля: `name`, `description`, `biology`, `backstory`, `logo`, `tags`.

### Note (Заметка)
- Тип Hive: `typeId: 2`
- Назначение: Система заметок, связанных с персонажами.
- Ключевые поля: `title`, `content`, `characterIds`, `tags`.

### QuestionnaireTemplate (Шаблон анкеты)
- Тип Hive: `typeId: 4`
- Назначение: Шаблоны для быстрого создания персонажей.
- Ключевые поля: `name`, `standardFields`, `customFields`.

### Relationship (Связь)
- Тип Hive: `typeId: 6`
- Назначение: Хранение связей между персонажами.
- Ключевые поля: `fromCharacterId`, `toCharacterId`, `type`, `description`.

### ExportPdfSettings (Настройки экспорта PDF)
- Тип Hive: `typeId: 7`
- Назначение: Настройки для генерации PDF.
- Ключевые поля: `paperSize`, `orientation`, `includeImages`, `template`.

### CustomField (Пользовательское поле)
- Тип Hive: `typeId: 1`
- Назначение: Хранение пользовательских полей типа ключ-значение.
- Ключевые поля: `key`, `value`.

### CalendarEvent (Событие календаря)
- Тип Hive: `typeId: 11`
- Назначение: Планирование событий, связанных с персонажами или кампанией.
- Ключевые поля: `title`, `description`, `date`, `characterIds`, `type`, `reminder` (время напоминания).

### SwipeAction (Жесты свайпа)
- Тип Hive: `typeId: 12`
- Назначение: Хранение настроек действий по свайпу для списков.
- Ключевые поля: `leftAction`, `rightAction`, `enabled`.

> **Примечание:** Модель `Folder` была удалена. Организация контента теперь полностью осуществляется через систему **тегов**. Теги можно назначать персонажам, расам и заметкам, а затем фильтровать по ним.

## Жизненный цикл приложения

### Инициализация
- `WidgetsFlutterBinding.ensureInitialized()`
- Инициализация Hive через `HiveService.initHive()`
- Регистрация адаптеров Hive (например, `RelationshipAdapter`)
- Открытие всех боксов с повторными попытками (`_openBoxWithRetry`)
- Инициализация `FileHandler.initialize()`
- Инициализация `NotificationService` (настройка каналов уведомлений для Android)
- Запуск `runApp` с `CharacterBookApp`
- В `CharacterBookApp` создаётся `MultiProvider` с репозиториями, сервисами и провайдерами состояния
- В `_AppContent` настраивается метод-канал (`MenuChannel`) и проверяется успешность инициализации Hive

### Управление состоянием
- `ThemeProvider` — управление светлой/тёмной темой
- `LocaleProvider` — управление локализацией
- `SwipeActionSettingsProvider` — настройки жестов свайпа
- `NotificationService` — управление уведомлениями (через `ScaffoldMessenger` и `flutter_local_notifications`)

### Работа с данными
- Репозитории (`*Repository`) инкапсулируют доступ к Hive боксам.
- Сервисы (`*Service`) используют репозитории для бизнес-логики.
- Провайдеры связывают UI с состоянием (например, `HomeController` использует сервисы для загрузки данных).

### CloudBackupService (Облачное резервное копирование)
- Аутентификация через Google Sign-In.
- Загрузка и скачивание резервных копий в/из папки приложения на Google Drive.
- Отображение списка доступных бэкапов.
- Автоматическое создание бэкапов (опционально) с помощью планировщика (если реализовано).

### NotificationService
- Отображает SnackBar уведомления через глобальный `ScaffoldMessengerKey`.
- Управляет локальными уведомлениями: планирование напоминаний для событий календаря (`CalendarEvent.reminder`), показ уведомлений в заданное время.

### MenuChannelService
- Обработка вызовов из нативного меню (например, открытие файла, создание персонажа).
- Интеграция с `MethodChannel` для десктопных платформ.

## Десктоп-специфичные функции
- Кастомная панель заголовка (управление окном) — реализована через `window_manager`.
- Кнопки управления окном (свернуть/развернуть/закрыть).
- Автоматическое определение платформы и адаптация UI.
- Поддержка нативных диалогов выбора файлов через `file_selector`.
- Интеграция с системным меню через `MenuChannelService`.

## Облачная синхронизация
- Google Drive используется для хранения резервных копий.
- Сервис `CloudBackupService` управляет аутентификацией и загрузкой/скачиванием файлов.
- Резервные копии хранятся в папке приложения на Google Drive пользователя.
- Планируется поддержка iCloud (iOS) и OneDrive.

## Календарь и напоминания
- Экран календаря (`ui/screens/calendar/`) построен на виджете `table_calendar`.
- События (`CalendarEvent`) отображаются на календаре с цветовой индикацией по типу.
- При создании/редактировании события можно установить время напоминания (через `flutter_local_notifications`).
- В указанное время приложение показывает уведомление даже в фоновом режиме (на платформах, где это поддерживается).

## Ключевые компоненты UI
### Экран «Главный» (HomeScreen)
- Отображает сетку последних персонажей, рас и инструментов.
- Использует `HomeController` для загрузки данных и управления поиском.
- Плавающая кнопка `HomeFloatingMenu` для быстрого создания нового контента.
- Контекстное меню для элементов (через `tools_context_menu.dart`).

### Навигация
- `AppNavigationBar` — главная навигационная панель (нижняя на мобильных, боковая на десктопе).
- `MenuContent` — содержимое бокового меню.

### Модальные окна
- `CharacterModalCard` — детальный просмотр персонажа.
- `RaceModalCard` — детальный просмотр расы.
- `EventModalCard` — детальный просмотр/редактирование события календаря.

### Виджеты списков
- `CharacterKeepCardItem` — карточка персонажа на главном экране.
- `RaceKeepCardItem` — карточка расы.
- `ToolKeepCardItem` — карточка инструмента.

## Тестирование
- **Unit-тесты** (`test/unit/`) — покрывают бизнес-логику сервисов (`BackupService`, `CloudBackupService`, `NotificationService`, репозитории).
- **Виджет-тесты** (`test/widget/`) — проверяют ключевые экраны: `HomeScreen`, `CharacterScreen`, `CalendarScreen`, а также переиспользуемые виджеты.
- **Интеграционные тесты** (`integration_test/`) — проверяют сквозные сценарии (импорт/экспорт, синхронизация с облаком).

Для запуска тестов:
```bash
flutter test
flutter test --coverage
```