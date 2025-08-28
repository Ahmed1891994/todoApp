import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/todo.dart';
import '../../core/providers/todo_provider.dart';
import 'category_manager.dart';

class TodoForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime? selectedDueDate;
  final String selectedCategory;
  final int selectedPriority;
  final RecurrenceType selectedRecurrence;
  final DateTime? selectedRecurrenceEndDate;
  final bool isTemplate;
  final Function(DateTime?) onDueDateChanged;
  final Function(String) onCategoryChanged;
  final Function(int) onPriorityChanged;
  final Function(RecurrenceType) onRecurrenceChanged;
  final Function(DateTime?) onRecurrenceEndDateChanged;
  final Function(bool) onTemplateChanged;

  const TodoForm({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedDueDate,
    required this.selectedCategory,
    required this.selectedPriority,
    required this.selectedRecurrence,
    required this.selectedRecurrenceEndDate,
    required this.isTemplate,
    required this.onDueDateChanged,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onRecurrenceChanged,
    required this.onRecurrenceEndDateChanged,
    required this.onTemplateChanged,
  }) : super(key: key);

  void _showCategoryManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CategoryManager(),
    );
  }

  // Helper method to get category icon
  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return const Icon(Icons.work, size: 18, color: Colors.blue);
      case 'Shopping':
        return const Icon(Icons.shopping_cart, size: 18, color: Colors.orange);
      case 'Health':
        return const Icon(Icons.favorite, size: 18, color: Colors.red);
      case 'Personal':
        return const Icon(Icons.person, size: 18, color: Colors.green);
      case 'Other':
        return const Icon(Icons.category, size: 18, color: Colors.grey);
      default:
        return const Icon(Icons.category, size: 18, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<TodoProvider>(context, listen: false).categories;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            _getCategoryIcon(category),
                            const SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onCategoryChanged(newValue);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(Icons.settings, size: 20),
                    onPressed: () => _showCategoryManager(context),
                    tooltip: 'Manage Categories',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: selectedPriority,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Low', style: TextStyle(color: Colors.green))),
                      DropdownMenuItem(value: 1, child: Text('Medium', style: TextStyle(color: Colors.orange))),
                      DropdownMenuItem(value: 2, child: Text('High', style: TextStyle(color: Colors.red))),
                    ],
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        onPriorityChanged(newValue);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDueDate == null
                        ? 'No due date'
                        : 'Due: ${DateFormat.yMd().format(selectedDueDate!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    onDueDateChanged(picked);
                  },
                  child: const Text('Set Due Date', style: TextStyle(fontSize: 12)),
                ),
                if (selectedDueDate != null)
                  TextButton(
                    onPressed: () {
                      onDueDateChanged(null);
                    },
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RecurrenceType>(
              value: selectedRecurrence,
              items: const [
                DropdownMenuItem(value: RecurrenceType.none, child: Text('No Recurrence')),
                DropdownMenuItem(value: RecurrenceType.daily, child: Text('Daily')),
                DropdownMenuItem(value: RecurrenceType.weekly, child: Text('Weekly')),
                DropdownMenuItem(value: RecurrenceType.monthly, child: Text('Monthly')),
              ],
              onChanged: (RecurrenceType? newValue) {
                if (newValue != null) {
                  onRecurrenceChanged(newValue);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Recurrence',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            if (selectedRecurrence != RecurrenceType.none) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedRecurrenceEndDate == null
                          ? 'Recur forever'
                          : 'Until: ${DateFormat.yMd().format(selectedRecurrenceEndDate!)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      onRecurrenceEndDateChanged(picked);
                    },
                    child: const Text('Set End Date', style: TextStyle(fontSize: 12)),
                  ),
                  if (selectedRecurrenceEndDate != null)
                    TextButton(
                      onPressed: () {
                        onRecurrenceEndDateChanged(null);
                      },
                      child: const Text('Clear', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Save as Template', style: TextStyle(fontSize: 14)),
              value: isTemplate,
              onChanged: onTemplateChanged,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}