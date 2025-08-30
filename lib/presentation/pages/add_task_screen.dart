import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/todo_provider.dart';
import '../../domain/entities/todo.dart';
import '../widgets/todo_form.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  String _selectedCategory = 'Personal';
  int _selectedPriority = 1;
  RecurrenceType _selectedRecurrence = RecurrenceType.none;
  DateTime? _selectedRecurrenceEndDate;
  bool _isTemplate = false;
  List<int> _weeklyRecurrenceDays = [];
  bool _enableReminders = false;
  List<SubTask> _subTasks = [];

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

      // Navigate back to tasks screen
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for your task')),
      );
    }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearForm,
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.save),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}