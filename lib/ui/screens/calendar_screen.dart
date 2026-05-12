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
import 'package:characterbook/services/notification_service.dart';
import 'package:characterbook/ui/widgets/modals/character_modal_card.dart';
import 'package:characterbook/ui/widgets/modals/custom_event_modal.dart';
import 'package:characterbook/ui/widgets/modals/race_modal_card.dart';
import 'package:characterbook/ui/controllers/calendar_controller.dart';
import 'package:characterbook/ui/screens/notes/note_management_screen.dart';
import 'package:characterbook/ui/widgets/items/character_card_item.dart';
import 'package:characterbook/ui/widgets/items/note_card_item.dart';
import 'package:characterbook/ui/widgets/items/race_card_item.dart';
import 'package:characterbook/ui/widgets/items/custom_event_card_item.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventModal(context),
        icon: const Icon(Icons.add),
        label: Text(s.add_event),
        elevation: 2,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SafeArea(
        child: controller.isLoading
            ? _LoadingView()
            : controller.errorMessage != null
                ? _ErrorView(
                    message: controller.errorMessage!,
                    onRetry: controller.loadEvents,
                  )
                : CustomScrollView(
                    slivers: [
                      SliverAppBar.large(
                        title: Text(s.event_calendar),
                        actions: [
                          _FilterButton(
                            selectedFilter: controller.selectedFilter,
                            onFilterChanged: controller.setFilter,
                          ),
                        ],
                        pinned: true,
                      ),
                      SliverToBoxAdapter(
                        child: _CalendarHeader(controller: controller),
                      ),
                      ..._buildEventsSection(context, controller),
                    ],
                  ),
      ),
    );
  }

  List<Widget> _buildEventsSection(
      BuildContext context, CalendarController controller) {
    final selectedDay = controller.selectedDay;
    if (selectedDay == null) return [];

    final events = controller.getEventsForDay(selectedDay);
    final s = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (events.isEmpty) {
      return [
        SliverFillRemaining(child: const _EmptyEvents()),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                s.events,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  events.length.toString(),
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _EventListItem(event: events[index]),
          childCount: events.length,
        ),
      ),
      // Дополнительный отступ снизу, чтобы FAB не перекрывал последний элемент
      const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
    ];
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _CalendarHeader extends StatelessWidget {
  final CalendarController controller;
  const _CalendarHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
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
          onFormatChanged: controller.changeFormat,
          eventLoader: controller.getEventsForDay,
          availableGestures: AvailableGestures.horizontalSwipe,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
            markerSize: 6,
            outsideDaysVisible: false,
            todayTextStyle: TextStyle(color: colorScheme.onPrimaryContainer),
            selectedTextStyle: TextStyle(color: colorScheme.onPrimary),
            defaultTextStyle: textTheme.bodyLarge!,
            weekendTextStyle: textTheme.bodyLarge!.copyWith(
              color: colorScheme.error,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            formatButtonTextStyle: textTheme.labelLarge!.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            titleTextStyle: textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            leftChevronIcon:
                Icon(Icons.chevron_left, color: colorScheme.primary),
            rightChevronIcon:
                Icon(Icons.chevron_right, color: colorScheme.primary),
          ),
          availableCalendarFormats: const {
            CalendarFormat.week: '2',
            CalendarFormat.twoWeeks: '1',
          },
        ),
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final CalendarEventModel event;
  const _EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    switch (event.type) {
      case CalendarEventType.character:
        return CharacterCardItem(
          character: event.character!,
          isSelected: false,
          onTap: () => _showCharacterModal(context, event.character!),
          onLongPress: () {},
          onEdit: () {},
          onDelete: () {},
        );
      case CalendarEventType.race:
        return RaceCardItem(
          race: event.race!,
          isSelected: false,
          onTap: () => _showRaceModal(context, event.race!),
          onLongPress: () {},
        );
      case CalendarEventType.note:
        return NoteCardItem(
          note: event.note!,
          onTap: () => _openNote(context, event.note!),
          onEdit: () => _openNote(context, event.note!),
          onDelete: () {},
        );
      case CalendarEventType.custom:
        return CustomEventCardItem(
          event: event.customEvent!,
          onTap: () => _editCustomEvent(context, event.customEvent!),
          onEdit: () => _editCustomEvent(context, event.customEvent!),
          onDelete: () => _deleteCustomEvent(context, event.customEvent!),
        );
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
      MaterialPageRoute(builder: (_) => NoteManagementScreen(note: note)),
    ).then((_) {
      context.read<CalendarController>().loadEvents();
    });
  }

  void _deleteCustomEvent(BuildContext context, CustomEvent event) {
    context.read<CalendarController>().deleteCustomEvent(event.id);
  }

  void _editCustomEvent(BuildContext context, CustomEvent event) {
    final view = context.findAncestorWidgetOfExactType<_CalendarView>();
    view?._editCustomEvent(context, event);
  }
}

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 80,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 24),
            Text(
              s.no_events,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.add_event,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () {
                final view =
                    context.findAncestorWidgetOfExactType<_CalendarView>();
                view?._showCreateEventModal(context);
              },
              icon: const Icon(Icons.add),
              label: Text(s.add_event),
            ),
          ],
        ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<CalendarEventType?>(
      onSelected: onFilterChanged,
      icon: Icon(Icons.filter_list, color: colorScheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        _buildFilterItem(
          context,
          value: CalendarEventType.character,
          icon: Icons.person,
          label: s.character_events,
          isSelected: selectedFilter == CalendarEventType.character,
        ),
        _buildFilterItem(
          context,
          value: CalendarEventType.race,
          icon: Icons.flag,
          label: s.race_events,
          isSelected: selectedFilter == CalendarEventType.race,
        ),
        _buildFilterItem(
          context,
          value: CalendarEventType.note,
          icon: Icons.note,
          label: s.note_events,
          isSelected: selectedFilter == CalendarEventType.note,
        ),
        _buildFilterItem(
          context,
          value: CalendarEventType.custom,
          icon: Icons.event,
          label: s.custom_event,
          isSelected: selectedFilter == CalendarEventType.custom,
        ),
      ],
    );
  }

  PopupMenuItem<CalendarEventType?> _buildFilterItem(
    BuildContext context, {
    required CalendarEventType? value,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuItem<CalendarEventType?>(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.check, size: 18, color: colorScheme.primary),
            ),
        ],
      ),
    );
  }
}
