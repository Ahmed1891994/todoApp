import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/category_manager.dart'; // Add this import
import 'add_task_screen.dart';
import 'templates_screen.dart';
import 'upcoming_tasks_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  void _showCategoryManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CategoryManager();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final tasks = todoProvider.todos.where((todo) => !todo.isTemplate).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => _showCategoryManager(context),
            tooltip: 'Manage Categories',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpcomingTasksScreen()),
              );
            },
            tooltip: 'Upcoming Tasks',
          ),
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TemplatesScreen()),
              );
            },
            tooltip: 'Templates',
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to create your first task',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return TodoItem(
            key: Key(tasks[index].id),
            todo: tasks[index],
            index: index,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}