import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/todo_provider.dart';
import '../../domain/entities/todo.dart';
import '../widgets/category_manager.dart';

class TodoForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime? selectedDueDate;
  final String selectedCategory;
  final int selectedPriority;
  final RecurrenceType selectedRecurrence;
  final DateTime? selectedRecurrenceEndDate;
  final bool isTemplate;
  final List<int> weeklyRecurrenceDays;
  final bool enableReminders;
  final List<SubTask> subTasks;
  final ValueChanged<DateTime?> onDueDateChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<int> onPriorityChanged;
  final ValueChanged<RecurrenceType> onRecurrenceChanged;
  final ValueChanged<DateTime?> onRecurrenceEndDateChanged;
  final ValueChanged<bool> onTemplateChanged;
  final ValueChanged<List<int>> onWeeklyRecurrenceDaysChanged;
  final ValueChanged<bool> onEnableRemindersChanged;
  final ValueChanged<List<SubTask>> onSubTasksChanged;

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
    required this.weeklyRecurrenceDays,
    required this.enableReminders,
    required this.subTasks,
    required this.onDueDateChanged,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onRecurrenceChanged,
    required this.onRecurrenceEndDateChanged,
    required this.onTemplateChanged,
    required this.onWeeklyRecurrenceDaysChanged,
    required this.onEnableRemindersChanged,
    required this.onSubTasksChanged,
  }) : super(key: key);

  @override
  _TodoFormState createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final TextEditingController _subTaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.titleController,
          decoration: const InputDecoration(
            labelText: 'Title *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    widget.onDueDateChanged(pickedDate);
                  }
                },
                child: Text(
                  widget.selectedDueDate != null
                      ? 'Due: ${_formatDate(widget.selectedDueDate!)}'
                      : 'Set Due Date',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Consumer<TodoProvider>(
                builder: (context, todoProvider, child) {
                  return DropdownButtonFormField<String>(
                    value: widget.selectedCategory,
                    items: todoProvider.categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              todoProvider.categoryIcons[category] ?? _getDefaultIcon(category),
                              color: todoProvider.categoryColors[category] ?? _getDefaultColor(category),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        widget.onCategoryChanged(newValue);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            // ADD THIS BUTTON TO MANAGE CATEGORIES:
            IconButton(
              icon: const Icon(Icons.settings, size: 24),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const CategoryManager();
                  },
                );
              },
              tooltip: 'Manage Categories',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: widget.selectedPriority,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text('Low'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.remove, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('Medium'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                        SizedBox(width: 4),
                        Text('High'),
                      ],
                    ),
                  ),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    widget.onPriorityChanged(newValue);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Recurrence Options
        ExpansionTile(
          title: const Text('Recurrence Options'),
          initiallyExpanded: false,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: DropdownButtonFormField<RecurrenceType>(
                initialValue: widget.selectedRecurrence,
                items: const [
                  DropdownMenuItem(
                    value: RecurrenceType.none,
                    child: Text('None'),
                  ),
                  DropdownMenuItem(
                    value: RecurrenceType.daily,
                    child: Text('Daily'),
                  ),
                  DropdownMenuItem(
                    value: RecurrenceType.weekly,
                    child: Text('Weekly'),
                  ),
                  DropdownMenuItem(
                    value: RecurrenceType.monthly,
                    child: Text('Monthly'),
                  ),
                ],
                onChanged: (RecurrenceType? newValue) {
                  if (newValue != null) {
                    widget.onRecurrenceChanged(newValue);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Recurrence Pattern',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                isExpanded: true,
              ),
            ),
            const SizedBox(height: 16),

            // Weekly recurrence days (only show if weekly is selected)
            if (widget.selectedRecurrence == RecurrenceType.weekly)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text('Repeat on days:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (int day = 1; day <= 7; day++)
                          FilterChip(
                            label: Text(_getDayName(day)),
                            selected: widget.weeklyRecurrenceDays.contains(day),
                            onSelected: (selected) {
                              final newDays = List<int>.from(widget.weeklyRecurrenceDays);
                              if (selected) {
                                newDays.add(day);
                              } else {
                                newDays.remove(day);
                              }
                              widget.onWeeklyRecurrenceDaysChanged(newDays);
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Recurrence end date
            if (widget.selectedRecurrence != RecurrenceType.none)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: TextButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: widget.selectedRecurrenceEndDate ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          widget.onRecurrenceEndDateChanged(pickedDate);
                        }
                      },
                      child: Text(
                        widget.selectedRecurrenceEndDate != null
                            ? 'Recur until: ${_formatDate(widget.selectedRecurrenceEndDate!)}'
                            : 'Set Recurrence End Date',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Subtasks Section
        ExpansionTile(
          title: const Text('Subtasks'),
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subTaskController,
                        decoration: const InputDecoration(
                          labelText: 'Add subtask',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_subTaskController.text.isNotEmpty) {
                          final newSubTasks = List<SubTask>.from(widget.subTasks);
                          newSubTasks.add(SubTask(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: _subTaskController.text,
                          ));
                          widget.onSubTasksChanged(newSubTasks);
                          _subTaskController.clear();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.subTasks.isNotEmpty)
                  Column(
                    children: widget.subTasks.map((subTask) {
                      return ListTile(
                        leading: Checkbox(
                          value: subTask.completed,
                          onChanged: (value) {
                            final newSubTasks = widget.subTasks.map((st) {
                              if (st.id == subTask.id) {
                                return st.copyWith(completed: value ?? false);
                              }
                              return st;
                            }).toList();
                            widget.onSubTasksChanged(newSubTasks);
                          },
                        ),
                        title: Text(subTask.title),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            final newSubTasks = widget.subTasks.where((st) => st.id != subTask.id).toList();
                            widget.onSubTasksChanged(newSubTasks);
                          },
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: widget.isTemplate,
              onChanged: (value) {
                widget.onTemplateChanged(value ?? false);
              },
            ),
            const Text('Save as Template'),
            const Spacer(),
            Checkbox(
              value: widget.enableReminders,
              onChanged: (value) {
                widget.onEnableRemindersChanged(value ?? false);
              },
            ),
            const Text('Enable Reminders'),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  IconData _getDefaultIcon(String category) {
    switch (category.toLowerCase()) {
      case 'personal': return Icons.person_outline;
      case 'work': return Icons.work_outline;
      case 'shopping': return Icons.shopping_basket;
      case 'health': return Icons.favorite_border;
      case 'other': return Icons.category;
      default: return Icons.label_outline;
    }
  }

  Color _getDefaultColor(String category) {
    switch (category.toLowerCase()) {
      case 'personal': return Colors.blue.shade700;
      case 'work': return Colors.orange.shade700;
      case 'shopping': return Colors.green.shade700;
      case 'health': return Colors.red.shade700;
      case 'other': return Colors.purple.shade700;
      default: return Colors.blue.shade400;
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}