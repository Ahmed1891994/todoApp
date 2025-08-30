import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/todo_provider.dart';
import '../../../domain/entities/todo.dart';
import '../widgets/todo_form.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/todo_item.dart';
import '../widgets/template_dialog.dart';
import '../widgets/category_manager.dart';
import 'upcoming_tasks_screen.dart';
import 'tasks_screen.dart';
import 'templates_screen.dart';
import 'category_management_screen.dart'; // Add this import

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => __TodoScreenState();
}

class __TodoScreenState extends State<TodoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDueDate;
  String _selectedCategory = 'Personal';
  int _selectedPriority = 1;
  RecurrenceType _selectedRecurrence = RecurrenceType.none;
  DateTime? _selectedRecurrenceEndDate;
  bool _isTemplate = false;
  List<int> _weeklyRecurrenceDays = [];
  bool _enableReminders = false;
  List<SubTask> _subTasks = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Provider.of<TodoProvider>(context, listen: false)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDueDate = null;
      _selectedCategory = 'Personal';
      _selectedPriority = 1;
      _selectedRecurrence = RecurrenceType.none;
      _selectedRecurrenceEndDate = null;
      _isTemplate = false;
      _weeklyRecurrenceDays = [];
      _enableReminders = false;
      _subTasks = [];
    });

    Provider.of<TodoProvider>(context, listen: false).setSearchQuery('');
    _searchController.clear();
  }

  void _addTodo() {
    if (_titleController.text.isNotEmpty) {
      final newTodo = Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        completed: false,
        dateCreated: DateTime.now(),
        dueDate: _selectedDueDate,
        category: _selectedCategory,
        priority: _selectedPriority,
        recurrence: _selectedRecurrence,
        recurrenceEndDate: _selectedRecurrenceEndDate,
        isTemplate: _isTemplate,
        weeklyRecurrenceDays: _weeklyRecurrenceDays,
        enableReminders: _enableReminders,
        subTasks: _subTasks,
      );

      Provider.of<TodoProvider>(context, listen: false).addTodo(newTodo);

      // Reset form to default values
      _clearForm();
      setState(() {
        _selectedCategory = 'Personal';
        _selectedPriority = 1;
        _selectedRecurrence = RecurrenceType.none;
        _selectedRecurrenceEndDate = null;
        _isTemplate = false;
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          filterCategory: Provider.of<TodoProvider>(context).filterCategory,
          sortBy: Provider.of<TodoProvider>(context).sortBy,
          showCompleted: Provider.of<TodoProvider>(context).showCompleted,
          filterPriority: Provider.of<TodoProvider>(context).filterPriority,
          filterDueDate: Provider.of<TodoProvider>(context).filterDueDate,
        );
      },
    );
  }

  void _showTemplatesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const TemplateDialog();
      },
    );
  }

  void _showCategoryManager() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CategoryManager();
      },
    );
  }

  void _navigateToCategoryManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryManagementScreen()),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    Provider.of<TodoProvider>(context, listen: false)
        .reorderTodos(oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TasksScreen()),
              );
            },
            tooltip: 'View Tasks',
          ),
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TemplatesScreen()),
              );
            },
            tooltip: 'View Templates',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UpcomingTasksScreen()),
              );
            },
            tooltip: 'Upcoming Tasks',
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: _navigateToCategoryManagement, // Changed to use the new method
            tooltip: 'Manage Categories',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter & Sort',
          ),
          IconButton(
            icon: const Icon(Icons.library_add_check),
            onPressed: _showTemplatesDialog,
            tooltip: 'Templates',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<TodoProvider>(context, listen: false)
                        .setSearchQuery('');
                  },
                )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, todoProvider, child) {
                final filteredTodos = todoProvider.filteredTodos;

                if (filteredTodos.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No todos found.\nAdd a new todo to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ReorderableListView(
                  onReorder: _onReorder,
                  children: [
                    for (int index = 0; index < filteredTodos.length; index++)
                      TodoItem(
                        key: Key(filteredTodos[index].id),
                        todo: filteredTodos[index],
                        index: index,
                      ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          ExpansionTile(
            title: const Text('Add New Task', style: TextStyle(fontWeight: FontWeight.bold)),
            initiallyExpanded: false,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TodoForm(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      selectedDueDate: _selectedDueDate,
                      selectedCategory: _selectedCategory,
                      selectedPriority: _selectedPriority,
                      selectedRecurrence: _selectedRecurrence,
                      selectedRecurrenceEndDate: _selectedRecurrenceEndDate,
                      isTemplate: _isTemplate,
                      weeklyRecurrenceDays: _weeklyRecurrenceDays,
                      enableReminders: _enableReminders,
                      subTasks: _subTasks,
                      onDueDateChanged: (DateTime? date) {
                        setState(() {
                          _selectedDueDate = date;
                        });
                      },
                      onCategoryChanged: (String category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      onPriorityChanged: (int priority) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      },
                      onRecurrenceChanged: (RecurrenceType recurrence) {
                        setState(() {
                          _selectedRecurrence = recurrence;
                        });
                      },
                      onRecurrenceEndDateChanged: (DateTime? date) {
                        setState(() {
                          _selectedRecurrenceEndDate = date;
                        });
                      },
                      onTemplateChanged: (bool isTemplate) {
                        setState(() {
                          _isTemplate = isTemplate;
                        });
                      },
                      onWeeklyRecurrenceDaysChanged: (List<int> days) {
                        setState(() {
                          _weeklyRecurrenceDays = days;
                        });
                      },
                      onEnableRemindersChanged: (bool enabled) {
                        setState(() {
                          _enableReminders = enabled;
                        });
                      },
                      onSubTasksChanged: (List<SubTask> subTasks) {
                        setState(() {
                          _subTasks = subTasks;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addTodo,
                    child: const Text('Add Todo'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}