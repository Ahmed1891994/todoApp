import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/todo_provider.dart';
import '../../../domain/entities/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final int index;

  const TodoItem({Key? key, required this.todo, required this.index}) : super(key: key);

  // Helper method to get category icon
  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return const Icon(Icons.work, size: 16, color: Colors.blue);
      case 'Shopping':
        return const Icon(Icons.shopping_cart, size: 16, color: Colors.orange);
      case 'Health':
        return const Icon(Icons.favorite, size: 16, color: Colors.red);
      case 'Personal':
        return const Icon(Icons.person, size: 16, color: Colors.green);
      case 'Other':
        return const Icon(Icons.category, size: 16, color: Colors.grey);
      default:
        return const Icon(Icons.category, size: 16, color: Colors.grey);
    }
  }

  void _editTodo(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final TextEditingController titleController = TextEditingController(text: todo.title);
    final TextEditingController descriptionController = TextEditingController(text: todo.description ?? '');
    DateTime? dueDate = todo.dueDate;
    String category = todo.category;
    int priority = todo.priority;
    RecurrenceType recurrence = todo.recurrence;
    DateTime? recurrenceEndDate = todo.recurrenceEndDate;
    bool isTemplate = todo.isTemplate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Todo'),
              content: SingleChildScrollView(
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
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
                          child: DropdownButtonFormField<String>(
                            value: category,
                            items: const [
                              DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                              DropdownMenuItem(value: 'Work', child: Text('Work')),
                              DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
                              DropdownMenuItem(value: 'Health', child: Text('Health')),
                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                category = newValue!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: priority,
                            items: const [
                              DropdownMenuItem(value: 0, child: Text('Low', style: TextStyle(color: Colors.green))),
                              DropdownMenuItem(value: 1, child: Text('Medium', style: TextStyle(color: Colors.orange))),
                              DropdownMenuItem(value: 2, child: Text('High', style: TextStyle(color: Colors.red))),
                            ],
                            onChanged: (int? newValue) {
                              setState(() {
                                priority = newValue!;
                              });
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dueDate == null
                                ? 'No due date'
                                : 'Due: ${DateFormat.yMd().format(dueDate!)}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: dueDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            setState(() {
                              dueDate = picked;
                            });
                          },
                          child: const Text('Set Due Date'),
                        ),
                        if (dueDate != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                dueDate = null;
                              });
                            },
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RecurrenceType>(
                      value: recurrence,
                      items: const [
                        DropdownMenuItem(value: RecurrenceType.none, child: Text('No Recurrence')),
                        DropdownMenuItem(value: RecurrenceType.daily, child: Text('Daily')),
                        DropdownMenuItem(value: RecurrenceType.weekly, child: Text('Weekly')),
                        DropdownMenuItem(value: RecurrenceType.monthly, child: Text('Monthly')),
                      ],
                      onChanged: (RecurrenceType? newValue) {
                        setState(() {
                          recurrence = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Recurrence',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (recurrence != RecurrenceType.none) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recurrenceEndDate == null
                                  ? 'Recur forever'
                                  : 'Until: ${DateFormat.yMd().format(recurrenceEndDate!)}',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: recurrenceEndDate ?? DateTime.now().add(Duration(days: 30)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              setState(() {
                                recurrenceEndDate = picked;
                              });
                            },
                            child: const Text('Set End Date'),
                          ),
                          if (recurrenceEndDate != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  recurrenceEndDate = null;
                                });
                              },
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Save as Template'),
                      value: isTemplate,
                      onChanged: (value) {
                        setState(() {
                          isTemplate = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedTodo = todo.copyWith(
                      title: titleController.text,
                      description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                      dueDate: dueDate,
                      category: category,
                      priority: priority,
                      recurrence: recurrence,
                      recurrenceEndDate: recurrenceEndDate,
                      isTemplate: isTemplate,
                    );
                    todoProvider.updateTodo(updatedTodo);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    return Card(
      key: Key(todo.id),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (value) => todoProvider.toggleTodo(todo.id),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description != null) Text(todo.description!),
            if (todo.dueDate != null)
              Text(
                'Due: ${DateFormat.yMd().format(todo.dueDate!)}',
                style: TextStyle(
                  color: todo.isOverdue ? Colors.red : null,
                ),
              ),
            if (todo.recurrence != RecurrenceType.none)
              Text(
                'Recurring: ${todo.getRecurrenceText()}',
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(todo.category),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  avatar: _getCategoryIcon(todo.category),
                ),
                Chip(
                  label: Text(
                    todo.getPriorityText(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: todo.getPriorityColor(),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editTodo(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => todoProvider.deleteTodo(todo.id),
            ),
          ],
        ),
      ),
    );
  }
}