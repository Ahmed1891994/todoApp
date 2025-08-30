import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/providers/todo_provider.dart';
import '../../domain/entities/todo.dart';
import '../widgets/todo_item.dart';

class UpcomingTasksScreen extends StatelessWidget {
  const UpcomingTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    // Get all non-completed tasks with due dates (excluding templates)
    final todos = todoProvider.todos.where((todo) =>
    !todo.completed &&
        !todo.isTemplate &&
        todo.dueDate != null
    ).toList();

    // Get tasks for today, tomorrow, and the rest of the week
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = today.add(const Duration(days: 7));

    // Group tasks by day
    final Map<DateTime, List<Todo>> tasksByDay = {};

    for (final todo in todos) {
      final dueDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);

      // Skip past dates
      if (dueDate.isBefore(today)) continue;

      if (!tasksByDay.containsKey(dueDate)) {
        tasksByDay[dueDate] = [];
      }
      tasksByDay[dueDate]!.add(todo);
    }

    // Sort days
    final sortedDays = tasksByDay.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: sortedDays.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No upcoming tasks',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tasks with due dates will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView(
        children: [
          // Today
          if (tasksByDay.containsKey(today))
            _buildDaySection('Today', today, tasksByDay[today]!),

          // Tomorrow
          if (tasksByDay.containsKey(tomorrow))
            _buildDaySection('Tomorrow', tomorrow, tasksByDay[tomorrow]!),

          // This week (excluding today and tomorrow)
          for (final day in sortedDays)
            if (day != today && day != tomorrow && day.isBefore(endOfWeek))
              _buildDaySection(DateFormat('EEEE, MMM d').format(day), day, tasksByDay[day]!),

          // Next week and beyond
          for (final day in sortedDays)
            if (day.isAfter(endOfWeek.subtract(const Duration(days: 1)))) // Include last day of current week
              _buildDaySection(DateFormat('EEE, MMM d, yyyy').format(day), day, tasksByDay[day]!),
        ],
      ),
    );
  }

  Widget _buildDaySection(String title, DateTime day, List<Todo> dayTasks) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _isToday(day) ? Colors.blue : null,
        ),
      ),
      subtitle: Text('${dayTasks.length} task${dayTasks.length != 1 ? 's' : ''}'),
      initiallyExpanded: _isToday(day),
      children: [
        for (final task in dayTasks)
          TodoItem(
            key: Key(task.id),
            todo: task,
            index: dayTasks.indexOf(task),
          ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.year == date.year && tomorrow.month == date.month && tomorrow.day == date.day;
  }
}