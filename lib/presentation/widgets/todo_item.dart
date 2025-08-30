import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/todo_provider.dart';
import '../../domain/entities/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final int index;

  const TodoItem({
    Key? key,
    required this.todo,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Dismissible(
      key: Key(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        todoProvider.deleteTodo(todo.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) {
              todoProvider.toggleTodoCompletion(todo.id);
            },
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.completed ? TextDecoration.lineThrough : null,
              color: todo.completed ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description != null)
                Text(
                  todo.description!,
                  style: TextStyle(
                    decoration: todo.completed ? TextDecoration.lineThrough : null,
                    color: todo.completed ? Colors.grey : null,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'Category: ${todo.category}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (todo.subTasks.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Subtasks: ${todo.subTasks.where((st) => st.completed).length}/${todo.subTasks.length} completed',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    LinearProgressIndicator(
                      value: todo.completionProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        todo.completionProgress == 1.0 ? Colors.green : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Show individual subtasks
                    ...todo.subTasks.map((subTask) {
                      return GestureDetector(
                        onTap: () {
                          _toggleSubTaskCompletion(context, todo, subTask);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Icon(
                                subTask.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                                size: 16,
                                color: subTask.completed ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  subTask.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    decoration: subTask.completed ? TextDecoration.lineThrough : null,
                                    color: subTask.completed ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (todo.dueDate != null)
                Text(
                  _formatDate(todo.dueDate!),
                  style: TextStyle(
                    color: todo.isOverdue ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: todo.getPriorityColor(),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  todo.getPriorityText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            if (todo.completed) {
              // Show a message that completed tasks can't be edited
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Completed tasks cannot be edited. Please uncomplete the task first.'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            _showEditDialog(context, todo);
          },
        ),
      ),
    );
  }

  void _toggleSubTaskCompletion(BuildContext context, Todo todo, SubTask subTask) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    // If the task is completed, uncomplete the whole task and toggle the specific subtask
    if (todo.completed) {
      final updatedSubTasks = todo.subTasks.map((st) {
        if (st.id == subTask.id) {
          return st.copyWith(completed: !st.completed);
        }
        return st.copyWith(completed: false); // Uncomplete all other subtasks
      }).toList();

      final updatedTodo = todo.copyWith(
        completed: false,
        subTasks: updatedSubTasks,
      );

      todoProvider.updateTodo(updatedTodo);
      return;
    }

    // Normal subtask toggling when task is not completed
    final updatedSubTasks = todo.subTasks.map((st) {
      if (st.id == subTask.id) {
        return st.copyWith(completed: !st.completed);
      }
      return st;
    }).toList();

    // Check if all subtasks are completed
    final allSubTasksCompleted = updatedSubTasks.every((st) => st.completed);

    final updatedTodo = todo.copyWith(
      subTasks: updatedSubTasks,
      completed: allSubTasksCompleted,
    );

    todoProvider.updateTodo(updatedTodo);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Today';
    } else if (dateDay == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  void _showEditDialog(BuildContext context, Todo todo) {
    final TextEditingController titleController = TextEditingController(text: todo.title);
    final TextEditingController descriptionController = TextEditingController(text: todo.description ?? '');
    DateTime? dueDate = todo.dueDate;
    String category = todo.category;
    int priority = todo.priority;
    RecurrenceType recurrence = todo.recurrence;
    DateTime? recurrenceEndDate = todo.recurrenceEndDate;
    List<int> weeklyRecurrenceDays = List.from(todo.weeklyRecurrenceDays);
    List<SubTask> subTasks = List.from(todo.subTasks);
    final TextEditingController _subTaskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<TodoProvider>(
          builder: (context, todoProvider, child) {
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
                              child: TextButton(
                                onPressed: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: dueDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      dueDate = pickedDate;
                                    });
                                  }
                                },
                                child: Text(
                                  dueDate != null
                                      ? 'Due: ${_formatDate(dueDate!)}'
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
                              child: DropdownButtonFormField<String>(
                                initialValue: category,
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
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: priority,
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
                                initialValue: recurrence,
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

                        final updatedTodo = todo.copyWith(
                          title: titleController.text,
                          description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                          dueDate: dueDate,
                          category: category,
                          priority: priority,
                          recurrence: recurrence,
                          recurrenceEndDate: recurrenceEndDate,
                          weeklyRecurrenceDays: weeklyRecurrenceDays,
                          subTasks: subTasks,
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
      },
    );
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