import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../data/models/todo_model.dart';

class TodoProvider with ChangeNotifier {
  final TodoRepository todoRepository;
  List<Todo> _todos = [];
  List<String> _categories = ['Personal', 'Work', 'Shopping', 'Health', 'Other'];
  String _filterCategory = 'All';
  String _sortBy = 'Date Created';
  bool _showCompleted = true;
  String _searchQuery = '';
  int? _filterPriority;
  DateTime? _filterDueDate;

  TodoProvider({required this.todoRepository});

  List<Todo> get todos => _todos;
  List<String> get categories => _categories;
  String get filterCategory => _filterCategory;
  String get sortBy => _sortBy;
  bool get showCompleted => _showCompleted;
  String get searchQuery => _searchQuery;
  int? get filterPriority => _filterPriority;
  DateTime? get filterDueDate => _filterDueDate;

  List<Todo> get filteredTodos {
    List<Todo> filtered = _todos.where((todo) {
      final categoryMatch = _filterCategory == 'All' || todo.category == _filterCategory;
      final completedMatch = _showCompleted || !todo.completed;
      final searchMatch = _searchQuery.isEmpty ||
          todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (todo.description != null &&
              todo.description!.toLowerCase().contains(_searchQuery.toLowerCase()));
      final priorityMatch = _filterPriority == null || todo.priority == _filterPriority;
      final dueDateMatch = _filterDueDate == null ||
          (todo.dueDate != null &&
              _isSameDay(todo.dueDate!, _filterDueDate!));

      return categoryMatch && completedMatch && searchMatch && priorityMatch && dueDateMatch;
    }).toList();

    if (_sortBy == 'Date Created') {
      filtered.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    } else if (_sortBy == 'Due Date') {
      filtered.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    } else if (_sortBy == 'Priority') {
      filtered.sort((a, b) => b.priority.compareTo(a.priority));
    }

    return filtered;
  }

  List<Todo> get templates {
    return _todos.where((todo) => todo.isTemplate).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> loadTodos() async {
    _todos = await todoRepository.getTodos();
    await loadCategories();
    _checkRecurringTasks();
    notifyListeners();
  }

  Future<void> _checkRecurringTasks() async {
    bool needsSave = false;
    final now = DateTime.now();

    for (final todo in _todos.where((t) => t.shouldRecur)) {
      final newTodo = todo.copyWith(
        id: '${todo.id}_${now.millisecondsSinceEpoch}',
        completed: false,
        dateCreated: now,
        dueDate: _calculateNextDueDate(todo),
        lastRecurrence: now,
      );

      _todos.add(newTodo);
      needsSave = true;
    }

    if (needsSave) {
      await _saveTodos();
    }
  }

  DateTime? _calculateNextDueDate(Todo todo) {
    if (todo.dueDate == null) return null;

    final currentDueDate = todo.dueDate!;
    switch (todo.recurrence) {
      case RecurrenceType.daily:
        return currentDueDate.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return currentDueDate.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        return DateTime(currentDueDate.year, currentDueDate.month + 1, currentDueDate.day);
      default:
        return null;
    }
  }

  Future<void> addTodo(Todo todo) async {
    if (todo.isTemplate) {
      // Create a completely separate template with different ID
      final templateTodo = todo.copyWith(
        id: 'template_${DateTime.now().millisecondsSinceEpoch}',
        isTemplate: true,
      );
      await todoRepository.addTodo(templateTodo);
    } else {
      await todoRepository.addTodo(todo);
    }
    await loadTodos();
  }

  Future<void> updateTodo(Todo todo) async {
    await todoRepository.updateTodo(todo);
    await loadTodos();
  }

  Future<void> deleteTodo(String id) async {
    // Only delete if it's not a template or if it's a template being deleted from template management
    final todo = _todos.firstWhere((t) => t.id == id);
    if (!todo.isTemplate) {
      _todos.removeWhere((todo) => todo.id == id);
      await _saveTodos();
      notifyListeners();
    }
  }

  // Add a separate method for deleting templates
  Future<void> deleteTemplate(String id) async {
    _todos.removeWhere((todo) => todo.id == id && todo.isTemplate);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> toggleTodo(String id) async {
    await todoRepository.toggleTodo(id);
    await loadTodos();
  }

  Future<void> reorderTodos(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Todo item = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, item);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    final todosString = json.encode(_todos.map((todo) => TodoModel.fromTodo(todo).toJson()).toList());
    // Implementation depends on your repository
  }

  bool isTemplateNameUnique(String name) {
    return !_todos.any((todo) => todo.isTemplate && todo.title == name);
  }

  Future<void> addTodoFromTemplate(Todo template) async {
    String newTitle = template.title;
    int counter = 1;

    while (_todos.any((todo) => todo.title == newTitle && !todo.isTemplate)) {
      newTitle = '${template.title} (${counter++})';
    }

    final newTodo = template.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: newTitle,
      completed: false,
      dateCreated: DateTime.now(),
      isTemplate: false,
    );

    await addTodo(newTodo);
  }

  Future<void> addCategory(String category) async {
    if (!_categories.contains(category)) {
      _categories.add(category);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('categories', _categories);
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCategories = prefs.getStringList('categories');
    if (savedCategories != null) {
      _categories = savedCategories;
      notifyListeners();
    }
  }

  Future<void> removeCategory(String category) async {
    if (_todos.any((todo) => todo.category == category)) {
      return;
    }

    _categories.remove(category);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categories', _categories);
    notifyListeners();
  }

  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void setShowCompleted(bool show) {
    _showCompleted = show;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterPriority(int? priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  void setFilterDueDate(DateTime? date) {
    _filterDueDate = date;
    notifyListeners();
  }

  void clearAllFilters() {
    _filterCategory = 'All';
    _sortBy = 'Date Created';
    _showCompleted = true;
    _searchQuery = '';
    _filterPriority = null;
    _filterDueDate = null;
    notifyListeners();
  }
}