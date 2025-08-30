import 'package:flutter/material.dart';

class WeeklyRecurrenceSelector extends StatefulWidget {
  final List<int> selectedDays;
  final Function(List<int>) onDaysChanged;

  const WeeklyRecurrenceSelector({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  @override
  State<WeeklyRecurrenceSelector> createState() => _WeeklyRecurrenceSelectorState();
}

class _WeeklyRecurrenceSelectorState extends State<WeeklyRecurrenceSelector> {
  late List<bool> _daySelections;

  @override
  void initState() {
    super.initState();
    _daySelections = List.generate(7, (index) => widget.selectedDays.contains(index + 1));
  }

  @override
  void didUpdateWidget(WeeklyRecurrenceSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays) {
      _daySelections = List.generate(7, (index) => widget.selectedDays.contains(index + 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select days of the week:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(7, (index) {
            return ChoiceChip(
              label: Text(dayNames[index], style: const TextStyle(fontSize: 12)),
              selected: _daySelections[index],
              onSelected: (selected) {
                setState(() {
                  _daySelections[index] = selected;
                });

                final selectedDays = <int>[];
                for (int i = 0; i < _daySelections.length; i++) {
                  if (_daySelections[i]) {
                    selectedDays.add(i + 1);
                  }
                }
                widget.onDaysChanged(selectedDays);
              },
              selectedColor: Colors.blue[100],
              labelStyle: TextStyle(
                color: _daySelections[index] ? Colors.blue[800] : Colors.black,
              ),
            );
          }),
        ),
      ],
    );
  }
}