import 'package:flutter/material.dart';

enum RecurrenceType { none, daily, weekly, monthly }

class SubTask {
  final String id;
  final String title;
  final bool completed;

  SubTask({
    required this.id,
    required this.title,
    this.completed = false,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? completed,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

class Todo {
  final String id;
  final String title;
  final String? description;
  final bool completed; // Added this field
  final DateTime dateCreated;
  final DateTime? dueDate;
  final String category;
  final int priority;
  final RecurrenceType recurrence;
  final DateTime? recurrenceEndDate;
  final bool isTemplate;
  final List<int> weeklyRecurrenceDays;
  final bool enableReminders;
  final List<SubTask> subTasks;
  final DateTime? completedAt;
  final DateTime? lastRecurrence;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    required this.completed, // Added this parameter
    required this.dateCreated,
    this.dueDate,
    this.category = 'Personal',
    this.priority = 1,
    this.recurrence = RecurrenceType.none,
    this.recurrenceEndDate,
    this.isTemplate = false,
    this.weeklyRecurrenceDays = const [],
    this.enableReminders = false,
    this.subTasks = const [],
    this.completedAt,
    this.lastRecurrence,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? dateCreated,
    DateTime? dueDate,
    String? category,
    int? priority,
    RecurrenceType? recurrence,
    DateTime? recurrenceEndDate,
    bool? isTemplate,
    List<int>? weeklyRecurrenceDays,
    bool? enableReminders,
    List<SubTask>? subTasks,
    DateTime? completedAt,
    DateTime? lastRecurrence,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      dateCreated: dateCreated ?? this.dateCreated,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      isTemplate: isTemplate ?? this.isTemplate,
      weeklyRecurrenceDays: weeklyRecurrenceDays ?? this.weeklyRecurrenceDays,
      enableReminders: enableReminders ?? this.enableReminders,
      subTasks: subTasks ?? this.subTasks,
      completedAt: completedAt ?? this.completedAt,
      lastRecurrence: lastRecurrence ?? this.lastRecurrence,
    );
  }

  Color getPriorityColor() {
    switch (priority) {
      case 0:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String getPriorityText() {
    switch (priority) {
      case 0:
        return 'Low';
      case 2:
        return 'High';
      default:
        return 'Medium';
    }
  }

  String getRecurrenceText() {
    switch (recurrence) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly (${_getWeeklyDaysText()})';
      case RecurrenceType.monthly:
        return 'Monthly';
      default:
        return 'None';
    }
  }

  String _getWeeklyDaysText() {
    if (weeklyRecurrenceDays.isEmpty) return 'No days selected';

    final dayNames = {
      1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'
    };

    final sortedDays = weeklyRecurrenceDays.toList()..sort();
    final selectedDayNames = sortedDays
        .map((day) => dayNames[day])
        .where((dayName) => dayName != null)
        .map((dayName) => dayName!)
        .toList();

    return selectedDayNames.isNotEmpty ? selectedDayNames.join(', ') : 'No days selected';
  }

  bool get isOverdue {
    if (dueDate == null || completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get shouldRecur {
    if (recurrence == RecurrenceType.none || completed) return false;
    if (recurrenceEndDate != null && DateTime.now().isAfter(recurrenceEndDate!)) {
      return false;
    }

    final now = DateTime.now();
    if (lastRecurrence == null) return true;

    switch (recurrence) {
      case RecurrenceType.daily:
        return now.isAfter(lastRecurrence!.add(const Duration(days: 1)));
      case RecurrenceType.weekly:
        final currentWeekday = now.weekday;
        return weeklyRecurrenceDays.contains(currentWeekday) &&
            now.isAfter(lastRecurrence!);
      case RecurrenceType.monthly:
        return now.isAfter(DateTime(lastRecurrence!.year, lastRecurrence!.month + 1, lastRecurrence!.day));
      default:
        return false;
    }
  }

  double get completionProgress {
    if (subTasks.isEmpty) return completed ? 1.0 : 0.0;
    final completedCount = subTasks.where((task) => task.completed).length;
    return completedCount / subTasks.length;
  }

  bool get allSubTasksCompleted {
    return subTasks.isNotEmpty && subTasks.every((task) => task.completed);
  }
}