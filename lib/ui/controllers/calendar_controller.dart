import 'package:characterbook/data/enums/calendar_event_type_enum.dart';
import 'package:characterbook/data/models/calendar_event_model.dart';
import 'package:characterbook/data/models/custom_event_model.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/custom_event_service.dart';
import 'package:characterbook/data/services/note_service.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/services/device_calendar_service.dart';
import 'package:characterbook/services/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends ChangeNotifier {
  final CharacterService _characterService;
  final RaceService _raceService;
  final NoteService _noteService;
  final CustomEventService _customEventService;
  final DeviceCalendarService _deviceCalendarService;
  final LocalNotificationService _notificationService;

  CalendarController({
    required CharacterService characterService,
    required RaceService raceService,
    required NoteService noteService,
    required CustomEventService customEventService,
    required DeviceCalendarService deviceCalendarService,
    required LocalNotificationService notificationService,
  })  : _characterService = characterService,
        _raceService = raceService,
        _noteService = noteService,
        _customEventService = customEventService,
        _deviceCalendarService = deviceCalendarService,
        _notificationService = notificationService;

  Map<DateTime, List<CalendarEventModel>> _eventsByDay = {};
  Map<DateTime, List<CalendarEventModel>> _filteredEventsByDay = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  CalendarEventType? _selectedFilter;

  Map<DateTime, List<CalendarEventModel>> get filteredEventsByDay =>
      _filteredEventsByDay;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  CalendarFormat get calendarFormat => _calendarFormat;
  CalendarEventType? get selectedFilter => _selectedFilter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final characters = await _characterService.getAllCharacters();
      final races = await _raceService.getAllRaces();
      final notes = await _noteService.getAllNotes();
      

      final Map<DateTime, List<CalendarEventModel>> events = {};

      for (final character in characters) {
        final date = _normalizeDate(character.lastEdited);
        events[date] = [
          ...events[date] ?? [],
          CalendarEventModel.character(character.lastEdited, character),
        ];
      }

      for (final race in races) {
        final date = _normalizeDate(race.lastEdited);
        events[date] = [
          ...events[date] ?? [],
          CalendarEventModel.race(race.lastEdited, race),
        ];
      }

      for (final note in notes) {
        final date = _normalizeDate(note.updatedAt);
        events[date] = [
          ...events[date] ?? [],
          CalendarEventModel.note(note.updatedAt, note),
        ];
      }

      final customEvents = await _customEventService.getAll();
      for (final event in customEvents) {
        final date = _normalizeDate(event.date);
        events[date] = [
          ...events[date] ?? [],
          CalendarEventModel.custom(event.date, event)
        ];
      }

      _eventsByDay = events;
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCustomEvent(CustomEvent event) async {
    await _customEventService.save(event);

    if (event.hasReminder) {
      await _notificationService.scheduleNotification(
        title: event.title,
        body: event.description.isNotEmpty
            ? event.description
            : 'Напоминание о событии',
        eventDate: event.date,
        minutesBefore: event.reminderMinutesBefore,
      );
    }

    if (event.addedToDeviceCalendar) {
      final eventId = await _deviceCalendarService.addEvent(
        title: event.title,
        description: event.description,
        startDate: event.date,
        endDate: event.date.add(const Duration(hours: 1)),
      );
      if (eventId != null) {
        event.copyWith(deviceCalendarEventId: eventId);
        await _customEventService.save(event);
      }
    }

    await loadEvents();
  }

  Future<void> deleteCustomEvent(String id) async {
    final event = await _customEventService.getById(id);
    if (event == null) return;

    if (event.hasReminder) {
      await _notificationService.cancelForEvent(event.title, event.date);
    }

    if (event.addedToDeviceCalendar && event.deviceCalendarEventId != null) {
      await _deviceCalendarService.deleteEvent(event.deviceCalendarEventId!);
    }

    await _customEventService.delete(id);
    await loadEvents();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _applyFilter() {
    if (_selectedFilter == null) {
      _filteredEventsByDay = Map.from(_eventsByDay);
      return;
    }

    final filtered = <DateTime, List<CalendarEventModel>>{};
    for (final entry in _eventsByDay.entries) {
      final filteredList =
          entry.value.where((event) => event.type == _selectedFilter).toList();
      if (filteredList.isNotEmpty) {
        filtered[entry.key] = filteredList;
      }
    }
    _filteredEventsByDay = filtered;
    notifyListeners();
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    notifyListeners();
  }

  /// Смена месяца/недели.
  void changePage(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  /// Смена формата календаря.
  void changeFormat(CalendarFormat format) {
    _calendarFormat = format;
    notifyListeners();
  }

  /// Установка фильтра.
  void setFilter(CalendarEventType? filter) {
    _selectedFilter = filter;
    _applyFilter();
  }

  List<CalendarEventModel> getEventsForDay(DateTime day) {
    final normalized = _normalizeDate(day);
    return _filteredEventsByDay[normalized] ?? [];
  }
}
