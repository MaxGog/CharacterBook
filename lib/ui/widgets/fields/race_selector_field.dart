import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/data/models/race_model.dart';
import 'package:characterbook/ui/screens/races/race_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  Race? _selectedRace;

  @override
  void initState() {
    super.initState();
    _selectedRace = widget.initialRace;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return ValueListenableBuilder(
      valueListenable: Hive.box<Race>('races').listenable(),
      builder: (context, Box<Race> box, _) {
        final races = box.values.toList();

        if (_selectedRace != null) {
          final found = races.cast<Race?>().firstWhere(
                (r) => r!.id == _selectedRace!.id,
                orElse: () => null,
              );
          if (found != _selectedRace) {
            _selectedRace =
                found;
          }
        }

        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Race>(
                value: _selectedRace,
                decoration: InputDecoration(
                  labelText: s.race,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  if (!widget.isRequired)
                    DropdownMenuItem<Race>(
                      value: null,
                      child: Text(s.not_selected,
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ...races.map((race) => DropdownMenuItem<Race>(
                        value: race,
                        child: Text(race.name),
                      )),
                ],
                onChanged: (race) {
                  setState(() => _selectedRace = race);
                  widget.onChanged?.call(race);
                },
                validator: widget.isRequired && _selectedRace == null
                    ? (value) => s.select_race_error
                    : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RaceManagementScreen()),
                );
              },
              tooltip: s.race_management,
            ),
          ],
        );
      },
    );
  }
}
