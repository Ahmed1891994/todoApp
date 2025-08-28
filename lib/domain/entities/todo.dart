import 'package:flutter/material.dart';

enum RecurrenceType { none, daily, weekly, monthly }

class Todo {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime dateCreated;
  final DateTime? dueDate;
  final String category;
  final int priority;
  final RecurrenceType recurrence;
  final DateTime? recurrenceEndDate;
  final bool isTemplate;
  final DateTime? lastRecurrence;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.completed = false,
    required this.dateCreated,
    this.dueDate,
    this.category = 'Personal',
    this.priority = 1,
    this.recurrence = RecurrenceType.none,
    this.recurrenceEndDate,
    this.isTemplate = false,
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
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      default:
        return 'None';
    }
  }

  bool get isOverdue {
    if (dueDate == null || completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get shouldRecur {
    if (recurrence == RecurrenceType.none || !completed) return false;
    if (recurrenceEndDate != null && DateTime.now().isAfter(recurrenceEndDate!)) {
      return false;
    }

    final now = DateTime.now();
    if (lastRecurrence == null) return true;

    switch (recurrence) {
      case RecurrenceType.daily:
        return now.isAfter(lastRecurrence!.add(Duration(days: 1)));
      case RecurrenceType.weekly:
        return now.isAfter(lastRecurrence!.add(Duration(days: 7)));
      case RecurrenceType.monthly:
        return now.isAfter(DateTime(lastRecurrence!.year, lastRecurrence!.month + 1, lastRecurrence!.day));
      default:
        return false;
    }
  }
}