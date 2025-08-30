import 'package:flutter/material.dart';
import '../../domain/entities/todo.dart';

class TodoModel extends Todo {
  TodoModel({
    required String id,
    required String title,
    String? description,
    bool completed = false,
    required DateTime dateCreated,
    DateTime? dueDate,
    String category = 'Personal',
    int priority = 1,
    RecurrenceType recurrence = RecurrenceType.none,
    DateTime? recurrenceEndDate,
    bool isTemplate = false,
    List<int> weeklyRecurrenceDays = const [],
    bool enableReminders = false,
    List<SubTask> subTasks = const [],
    DateTime? completedAt,
    DateTime? lastRecurrence,
  }) : super(
    id: id,
    title: title,
    description: description,
    completed: completed,
    dateCreated: dateCreated,
    dueDate: dueDate,
    category: category,
    priority: priority,
    recurrence: recurrence,
    recurrenceEndDate: recurrenceEndDate,
    isTemplate: isTemplate,
    weeklyRecurrenceDays: weeklyRecurrenceDays,
    enableReminders: enableReminders,
    subTasks: subTasks,
    completedAt: completedAt,
    lastRecurrence: lastRecurrence,
  );

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'] ?? false,
      dateCreated: DateTime.parse(json['dateCreated']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      category: json['category'] ?? 'Personal',
      priority: json['priority'] ?? 1,
      recurrence: RecurrenceType.values[json['recurrence'] ?? 0],
      recurrenceEndDate: json['recurrenceEndDate'] != null ? DateTime.parse(json['recurrenceEndDate']) : null,
      isTemplate: json['isTemplate'] ?? false,
      weeklyRecurrenceDays: List<int>.from(json['weeklyRecurrenceDays'] ?? []),
      enableReminders: json['enableReminders'] ?? false,
      subTasks: List<SubTask>.from((json['subTasks'] ?? []).map((st) => SubTask(
        id: st['id'],
        title: st['title'],
        completed: st['completed'] ?? false,
      ))),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      lastRecurrence: json['lastRecurrence'] != null ? DateTime.parse(json['lastRecurrence']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'dateCreated': dateCreated.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
      'priority': priority,
      'recurrence': recurrence.index,
      'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
      'isTemplate': isTemplate,
      'weeklyRecurrenceDays': weeklyRecurrenceDays,
      'enableReminders': enableReminders,
      'subTasks': subTasks.map((st) => {
        'id': st.id,
        'title': st.title,
        'completed': st.completed,
      }).toList(),
      'completedAt': completedAt?.toIso8601String(),
      'lastRecurrence': lastRecurrence?.toIso8601String(),
    };
  }

  factory TodoModel.fromTodo(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      completed: todo.completed,
      dateCreated: todo.dateCreated,
      dueDate: todo.dueDate,
      category: todo.category,
      priority: todo.priority,
      recurrence: todo.recurrence,
      recurrenceEndDate: todo.recurrenceEndDate,
      isTemplate: todo.isTemplate,
      weeklyRecurrenceDays: todo.weeklyRecurrenceDays,
      enableReminders: todo.enableReminders,
      subTasks: todo.subTasks,
      completedAt: todo.completedAt,
      lastRecurrence: todo.lastRecurrence,
    );
  }
}