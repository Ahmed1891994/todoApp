import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/todo_provider.dart';

class FilterDialog extends StatefulWidget {
  final String filterCategory;
  final String sortBy;
  final bool showCompleted;
  final int? filterPriority;
  final DateTime? filterDueDate;

  const FilterDialog({
    Key? key,
    required this.filterCategory,
    required this.sortBy,
    required this.showCompleted,
    required this.filterPriority,
    required this.filterDueDate,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String _filterCategory;
  late String _sortBy;
  late bool _showCompleted;
  late int? _filterPriority;
  late DateTime? _filterDueDate;

  @override
  void initState() {
    super.initState();
    _filterCategory = widget.filterCategory;
    _sortBy = widget.sortBy;
    _showCompleted = widget.showCompleted;
    _filterPriority = widget.filterPriority;
    _filterDueDate = widget.filterDueDate;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ['All', 'Personal', 'Work', 'Shopping', 'Health', 'Other'];
    final List<String> sortOptions = ['Date Created', 'Due Date', 'Priority'];

    return AlertDialog(
      title: const Text('Filter & Sort'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _filterCategory,
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _filterCategory = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _sortBy,
              items: sortOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _sortBy = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Sort By',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              value: _filterPriority,
              items: const [
                DropdownMenuItem(value: null, child: Text('All Priorities')),
                DropdownMenuItem(value: 0, child: Text('Low')),
                DropdownMenuItem(value: 1, child: Text('Medium')),
                DropdownMenuItem(value: 2, child: Text('High')),
              ],
              onChanged: (int? newValue) {
                setState(() {
                  _filterPriority = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Priority',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _filterDueDate == null
                        ? 'Any due date'
                        : 'Due: ${DateFormat.yMd().format(_filterDueDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      _filterDueDate = picked;
                    });
                  },
                  child: const Text('Set Date'),
                ),
                if (_filterDueDate != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterDueDate = null;
                      });
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show Completed'),
              value: _showCompleted,
              onChanged: (bool value) {
                setState(() {
                  _showCompleted = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Provider.of<TodoProvider>(context, listen: false).clearAllFilters();
            Navigator.of(context).pop();
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final todoProvider = Provider.of<TodoProvider>(context, listen: false);
            todoProvider.setFilterCategory(_filterCategory);
            todoProvider.setSortBy(_sortBy);
            todoProvider.setShowCompleted(_showCompleted);
            todoProvider.setFilterPriority(_filterPriority);
            todoProvider.setFilterDueDate(_filterDueDate);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}