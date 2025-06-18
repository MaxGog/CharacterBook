import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../generated/l10n.dart';
import '../../../models/race_model.dart';
import '../../pages/races/race_management_page.dart';

class RaceSelectorField extends StatefulWidget {
  final Race? initialRace;
  final ValueChanged<Race?>? onChanged;
  final bool isRequired;

  const RaceSelectorField({
    super.key,
    this.initialRace,
    this.onChanged,
    this.isRequired = true,
  });

  @override
  State<RaceSelectorField> createState() => _RaceSelectorFieldState();
}

class _RaceSelectorFieldState extends State<RaceSelectorField> {
  late Race? _selectedRace;
  late List<Race> _races;

  @override
  void initState() {
    super.initState();
    _selectedRace = widget.initialRace;
    _loadRaces();
  }

  Future<void> _loadRaces() async {
    final raceBox = Hive.box<Race>('races');
    setState(() {
      _races = raceBox.values.toList();
      if (_selectedRace != null) {
        _selectedRace = _races.firstWhere(
              (r) => r.name == _selectedRace?.name,
          orElse: () => Race.empty(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Race>(
                value: _selectedRace,
                decoration: InputDecoration(
                  labelText: s.race,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  if (!widget.isRequired)
                    DropdownMenuItem<Race>(
                      value: null,
                      child: Text(s.not_selected, style: TextStyle(color: Colors.grey)),
                    ),
                  ..._races.map((race) => DropdownMenuItem<Race>(
                    value: race,
                    child: Text(race.name),
                  )),
                ],
                onChanged: (race) {
                  setState(() => _selectedRace = race);
                  widget.onChanged?.call(race);
                },
                validator: (value) => widget.isRequired && value == null
                    ? s.select_race_error
                    : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RaceManagementPage()),
                );
                if (result == true) await _loadRaces();
              },
              tooltip: s.race_management,
            ),
          ],
        ),
        if (_selectedRace != null) ...[
          const SizedBox(height: 8),
          Text(_selectedRace!.description, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}