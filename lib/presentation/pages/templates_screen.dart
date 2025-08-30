import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/todo_provider.dart';
import '../../domain/entities/todo.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  _TemplatesScreenState createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final Set<String> _selectedTemplates = {};

  void _toggleSelectAll(bool selectAll, List<Todo> templates) {
    setState(() {
      if (selectAll) {
        _selectedTemplates.addAll(templates.map((t) => t.id));
      } else {
        _selectedTemplates.clear();
      }
    });
  }

  void _deleteSelectedTemplates(TodoProvider todoProvider) {
    for (final id in _selectedTemplates) {
      todoProvider.deleteTemplate(id);
    }
    setState(() {
      _selectedTemplates.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final templates = todoProvider.templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (_selectedTemplates.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSelectedTemplates(todoProvider),
              tooltip: 'Delete Selected',
            ),
        ],
      ),
      body: templates.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No templates yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create templates from the task form',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          CheckboxListTile(
            title: const Text('Select All'),
            value: _selectedTemplates.length == templates.length,
            onChanged: (value) => _toggleSelectAll(value ?? false, templates),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                final extraTasks = template.subTasks.length - 3;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: Checkbox(
                      value: _selectedTemplates.contains(template.id),
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedTemplates.add(template.id);
                          } else {
                            _selectedTemplates.remove(template.id);
                          }
                        });
                      },
                    ),
                    title: Text(template.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${template.category}'),
                        if (template.description != null)
                          Text(
                            template.description!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (template.subTasks.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Subtasks: ${template.subTasks.length}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          ...template.subTasks.take(3).map((subTask) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                              child: Text(
                                '• ${subTask.title}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          if (template.subTasks.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                              child: Text(
                                '... and $extraTasks more',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTemplate(context, template),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => todoProvider.deleteTemplate(template.id),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showTemplateDetails(context, template);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTemplateDetails(BuildContext context, Todo template) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(template.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (template.description != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(template.description!),
                  ),
                Text('Category: ${template.category}'),
                Text('Priority: ${template.getPriorityText()}'),
                if (template.recurrence != RecurrenceType.none)
                  Text('Recurrence: ${template.getRecurrenceText()}'),

                if (template.subTasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Subtasks:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...template.subTasks.map((subTask) {
                    return ListTile(
                      leading: Icon(
                        subTask.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 16,
                        color: subTask.completed ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        subTask.title,
                        style: TextStyle(
                          fontSize: 14,
                          decoration: subTask.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                final todoProvider = Provider.of<TodoProvider>(context, listen: false);
                todoProvider.addTodoFromTemplate(template);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Task created from "${template.title}" template')),
                );
              },
              child: const Text('Use Template'),
            ),
          ],
        );
      },
    );
  }

  void _editTemplate(BuildContext context, Todo template) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final TextEditingController titleController = TextEditingController(text: template.title);
    final TextEditingController descriptionController = TextEditingController(text: template.description ?? '');
    String category = template.category;
    int priority = template.priority;
    RecurrenceType recurrence = template.recurrence;
    DateTime? recurrenceEndDate = template.recurrenceEndDate;
    List<int> weeklyRecurrenceDays = List.from(template.weeklyRecurrenceDays);
    List<SubTask> subTasks = List.from(template.subTasks);
    final TextEditingController _subTaskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Template'),
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
                          child: Consumer<TodoProvider>(
                            builder: (context, todoProvider, child) {
                              return DropdownButtonFormField<String>(
                                value: category,
                                items: todoProvider.categories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Row(
                                      children: [
                                        Icon(
                                          todoProvider.categoryIcons[cat] ?? Icons.category,
                                          color: todoProvider.categoryColors[cat] ?? Colors.blue,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(cat),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    category = newValue!;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: priority,
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

                    // Recurrence Options
                    ExpansionTile(
                      title: const Text('Recurrence Options'),
                      initiallyExpanded: false,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                          child: DropdownButtonFormField<RecurrenceType>(
                            value: recurrence,
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
                                setState(() {
                                  recurrence = newValue;
                                });
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
                        if (recurrence == RecurrenceType.weekly)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Repeat on days:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  for (int day = 1; day <= 7; day++)
                                    FilterChip(
                                      label: Text(_getDayName(day)),
                                      selected: weeklyRecurrenceDays.contains(day),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            weeklyRecurrenceDays.add(day);
                                          } else {
                                            weeklyRecurrenceDays.remove(day);
                                          }
                                        });
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // Recurrence end date
                        if (recurrence != RecurrenceType.none)
                          Column(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: recurrenceEndDate ?? DateTime.now().add(const Duration(days: 30)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      recurrenceEndDate = pickedDate;
                                    });
                                  }
                                },
                                child: Text(
                                  recurrenceEndDate != null
                                      ? 'Recur until: ${_formatDate(recurrenceEndDate!)}'
                                      : 'Set Recurrence End Date',
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
                                      setState(() {
                                        subTasks.add(SubTask(
                                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                                          title: _subTaskController.text,
                                        ));
                                        _subTaskController.clear();
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (subTasks.isNotEmpty)
                              Column(
                                children: subTasks.map((subTask) {
                                  return ListTile(
                                    leading: Checkbox(
                                      value: subTask.completed,
                                      onChanged: (value) {
                                        setState(() {
                                          final index = subTasks.indexWhere((st) => st.id == subTask.id);
                                          if (index != -1) {
                                            subTasks[index] = subTask.copyWith(completed: value ?? false);
                                          }
                                        });
                                      },
                                    ),
                                    title: Text(subTask.title),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          subTasks.removeWhere((st) => st.id == subTask.id);
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ],
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
                    if (titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Title is required')),
                      );
                      return;
                    }

                    final updatedTemplate = template.copyWith(
                      title: titleController.text,
                      description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                      category: category,
                      priority: priority,
                      recurrence: recurrence,
                      recurrenceEndDate: recurrenceEndDate,
                      weeklyRecurrenceDays: weeklyRecurrenceDays,
                      subTasks: subTasks,
                      // Ensure template-specific fields are cleared
                      dueDate: null,
                      enableReminders: false,
                      isTemplate: true,
                    );
                    todoProvider.updateTodo(updatedTemplate);
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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