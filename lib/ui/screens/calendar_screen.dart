import 'package:characterbook/data/enums/calendar_event_type_enum.dart';
import 'package:characterbook/data/models/custom_event_model.dart';
import 'package:characterbook/data/services/custom_event_service.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/calendar_event_model.dart';
import 'package:characterbook/data/models/character_model.dart';
import 'package:characterbook/data/models/note_model.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/data/services/character_service.dart';
import 'package:characterbook/data/services/note_service.dart';
import 'package:characterbook/data/services/race_service.dart';
import 'package:characterbook/services/device_calendar_service.dart';
import 'package:characterbook/services/local_notification_service.dart';
import 'package:characterbook/ui/widgets/modals/character_modal_card.dart';
import 'package:characterbook/ui/widgets/modals/custom_event_modal.dart';
import 'package:characterbook/ui/widgets/modals/race_modal_card.dart';
import 'package:characterbook/ui/controllers/calendar_controller.dart';
import 'package:characterbook/ui/screens/notes/note_management_screen.dart';
import 'package:characterbook/ui/widgets/appbar/common_edit_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final characterService = context.read<CharacterService>();
    final raceService = context.read<RaceService>();
    final noteService = context.read<NoteService>();
    final customEventService = context.read<CustomEventService>();
    final deviceCalendarService = context.read<DeviceCalendarService>();
    final localNotificationService = context.read<LocalNotificationService>();

    return ChangeNotifierProvider(
      create: (_) => CalendarController(
        characterService: characterService,
        raceService: raceService,
        noteService: noteService,
        customEventService: customEventService,
        deviceCalendarService: deviceCalendarService,
        notificationService: localNotificationService,
      )..loadEvents(),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  void _showCreateEventModal(BuildContext context) {
    final controller = context.read<CalendarController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomEventModal(
        initialDate: controller.selectedDay ?? DateTime.now(),
        onSave: (event) {
          controller.addCustomEvent(event);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editCustomEvent(BuildContext context, CustomEvent event) {
    final controller = context.read<CalendarController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomEventModal(
        initialDate: event.date,
        existingEvent: event,
        onSave: (updatedEvent) {
          controller.loadEvents();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CalendarController>(context);
    final s = S.of(context);

    return Scaffold(
      appBar: CommonEditAppBar(
        title: s.event_calendar,
        additionalActions: [
          _FilterButton(
            selectedFilter: controller.selectedFilter,
            onFilterChanged: controller.setFilter,
          ),
        ],
        onSave: null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventModal(context),
        icon: const Icon(Icons.add),
        label: Text(S.of(context).add_event),
      ),
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : controller.errorMessage != null
                ? _ErrorView(
                    message: controller.errorMessage!,
                    onRetry: controller.loadEvents,
                  )
                : Column(
                    children: [
                      _CalendarHeader(
                        controller: controller,
                      ),
                      Expanded(
                        child: _EventList(
                          controller: controller,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final CalendarController controller;

  const _CalendarHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: controller.focusedDay,
        selectedDayPredicate: (day) =>
            day.year == controller.selectedDay?.year &&
            day.month == controller.selectedDay?.month &&
            day.day == controller.selectedDay?.day,
        onDaySelected: controller.selectDay,
        onPageChanged: controller.changePage,
        calendarFormat: controller.calendarFormat,
        onFormatChanged: (format) => controller.changeFormat(format),
        eventLoader: controller.getEventsForDay,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          outsideDaysVisible: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: Theme.of(context).textTheme.bodyMedium!,
          titleTextStyle: Theme.of(context).textTheme.titleLarge!,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Theme.of(context).colorScheme.primary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
          CalendarFormat.week: 'Week',
          CalendarFormat.twoWeeks: '2 Weeks',
        },
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  final CalendarController controller;

  const _EventList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final selectedDay = controller.selectedDay;
    if (selectedDay == null) return const SizedBox.shrink();

    final events = controller.getEventsForDay(selectedDay);
    if (events.isEmpty) {
      return _EmptyEvents();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                S.of(context).events,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  events.length.toString(),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventCard(event: event);
            },
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEventModel event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shadowColor: event.getColor(context).withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.getColor(context).withOpacity(0.15),
          child: Icon(event.icon, color: event.getColor(context)),
        ),
        title: Text(
          event.getTitle(context),
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          event.getSubtitle(context),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: event.type == CalendarEventType.custom
            ? PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') {
                    _editCustomEvent(context, event.customEvent!);
                  } else if (action == 'delete') {
                    _deleteCustomEvent(context, event.customEvent!);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text(S.of(context).edit)),
                  PopupMenuItem(
                      value: 'delete', child: Text(S.of(context).delete)),
                ],
              )
            : null,
        onTap: () => _navigateToEvent(context, event),
      ),
    );
  }

  void _deleteCustomEvent(BuildContext context, CustomEvent event) {
    context.read<CalendarController>().deleteCustomEvent(event.id);
  }

  void _editCustomEvent(BuildContext context, CustomEvent event) {
    _editCustomEvent(context, event);
  }

  void _navigateToEvent(BuildContext context, CalendarEventModel event) {
    switch (event.type) {
      case CalendarEventType.character:
        _showCharacterModal(context, event.character!);
        break;
      case CalendarEventType.race:
        _showRaceModal(context, event.race!);
        break;
      case CalendarEventType.note:
        _openNote(context, event.note!);
        break;
      case CalendarEventType.custom:
        _editCustomEvent(context, event.customEvent!);
        break;
        
    }
  }

  void _showCharacterModal(BuildContext context, Character character) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CharacterModalCard(character: character),
    );
  }

  void _showRaceModal(BuildContext context, Race race) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RaceModalCard(race: race),
    );
  }

  void _openNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteManagementScreen(note: note),
      ),
    ).then((_) {
      context.read<CalendarController>().loadEvents();
    });
  }
}

class _EmptyEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).no_events,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(S.of(context).retry_initialization),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final CalendarEventType? selectedFilter;
  final ValueChanged<CalendarEventType?> onFilterChanged;

  const _FilterButton({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PopupMenuButton<CalendarEventType?>(
      onSelected: onFilterChanged,
      initialValue: selectedFilter,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: Row(
            children: [
              const Icon(Icons.all_inclusive, size: 20),
              const SizedBox(width: 8),
              Text(s.all_events),
              if (selectedFilter == null) const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        PopupMenuItem(
          value: CalendarEventType.character,
          child: Row(
            children: [
              const Icon(Icons.person, size: 20),
              const SizedBox(width: 8),
              Text(s.character_events),
              if (selectedFilter == CalendarEventType.character)
                const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        PopupMenuItem(
          value: CalendarEventType.race,
          child: Row(
            children: [
              const Icon(Icons.flag, size: 20),
              const SizedBox(width: 8),
              Text(s.race_events),
              if (selectedFilter == CalendarEventType.race)
                const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        PopupMenuItem(
          value: CalendarEventType.note,
          child: Row(
            children: [
              const Icon(Icons.note, size: 20),
              const SizedBox(width: 8),
              Text(s.note_events),
              if (selectedFilter == CalendarEventType.note)
                const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        PopupMenuItem(
          value: CalendarEventType.custom,
          child: Row(
            children: [
              const Icon(Icons.event, size: 20),
              const SizedBox(width: 8),
              Text(s.custom_event),
              if (selectedFilter == CalendarEventType.custom)
                const Icon(Icons.check, size: 16),
            ],
          ),
        ),
      ],
      icon: const Icon(Icons.filter_list),
    );
  }
}
