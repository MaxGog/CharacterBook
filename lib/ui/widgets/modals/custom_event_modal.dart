import 'package:flutter/material.dart';
import 'package:characterbook/data/models/custom_event_model.dart';
import 'package:characterbook/generated/l10n.dart';
import 'package:intl/intl.dart';

class CustomEventModal extends StatefulWidget {
  final DateTime initialDate;
  final CustomEvent? existingEvent;
  final ValueChanged<CustomEvent> onSave;

  const CustomEventModal({
    super.key,
    required this.initialDate,
    this.existingEvent,
    required this.onSave,
  });

  @override
  State<CustomEventModal> createState() => _CustomEventModalState();
}

class _CustomEventModalState extends State<CustomEventModal> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime eventDate;
  late TimeOfDay eventTime;
  bool hasReminder = false;
  int reminderMinutes = 15;
  bool addToDeviceCalendar = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingEvent;
    titleController = TextEditingController(text: existing?.title ?? '');
    descriptionController =
        TextEditingController(text: existing?.description ?? '');
    eventDate = existing?.date ?? widget.initialDate;
    eventTime = TimeOfDay.fromDateTime(eventDate);
    hasReminder = existing?.hasReminder ?? false;
    reminderMinutes = existing?.reminderMinutesBefore ?? 15;
    addToDeviceCalendar = existing?.addedToDeviceCalendar ?? false;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  DateTime get combinedDateTime => DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        eventTime.hour,
        eventTime.minute,
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: eventDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => eventDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: eventTime,
    );
    if (picked != null) {
      setState(() => eventTime = picked);
    }
  }

  Widget _buildDateField(BuildContext context) {
    final s = S.of(context);
    final dateFormatted =
        DateFormat.yMMMd(Localizations.localeOf(context).toString())
            .format(eventDate);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today),
      title: Text(s.date),
      subtitle: Text(dateFormatted),
      onTap: _pickDate,
    );
  }

  Widget _buildTimeField(BuildContext context) {
    final s = S.of(context);
    final timeFormatted = eventTime.format(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.access_time),
      title: Text(s.time),
      subtitle: Text(timeFormatted),
      onTap: _pickTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.existingEvent != null ? s.edit_event : s.new_event,
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: s.event_title,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: s.event_description,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),
            // Дата и время
            _buildDateField(context),
            _buildTimeField(context),
            const SizedBox(height: 16),
            // Напоминание
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.notifications_active,
                color: hasReminder
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              title: Text(s.reminder),
              value: hasReminder,
              onChanged: (val) => setState(() => hasReminder = val),
            ),
            if (hasReminder)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(s.minutes_before),
                    Expanded(
                      child: Slider(
                        value: reminderMinutes.toDouble(),
                        min: 5,
                        max: 120,
                        divisions: 23, // Шаг 5 минут
                        label: '$reminderMinutes ${s.minutes}',
                        onChanged: (val) =>
                            setState(() => reminderMinutes = val.round()),
                      ),
                    ),
                    Text('$reminderMinutes ${s.minutes}'),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.calendar_month,
                color: addToDeviceCalendar
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              title: Text(s.add_to_calendar),
              value: addToDeviceCalendar,
              onChanged: (val) => setState(() => addToDeviceCalendar = val),
            ),
            const SizedBox(height: 24),
            // Кнопка сохранения
            FilledButton.icon(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.enter_event_title)),
                  );
                  return;
                }
                final event = CustomEvent(
                  id: widget.existingEvent?.id,
                  title: title,
                  description: descriptionController.text.trim(),
                  date: combinedDateTime,
                  hasReminder: hasReminder,
                  reminderMinutesBefore: reminderMinutes,
                  addedToDeviceCalendar: addToDeviceCalendar,
                  deviceCalendarEventId:
                      widget.existingEvent?.deviceCalendarEventId,
                );
                widget.onSave(event);
              },
              icon: const Icon(Icons.save),
              label: Text(s.save),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
