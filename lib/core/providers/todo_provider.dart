import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/todo.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  List<String> _categories = ['Personal', 'Work', 'Shopping', 'Health', 'Other'];
  String _filterCategory = 'All';
  String _sortBy = 'Date Created';
  bool _showCompleted = true;
  String _searchQuery = '';
  int? _filterPriority;
  DateTime? _filterDueDate;
  final Map<String, IconData> _categoryIcons = {};
  final Map<String, Color> _categoryColors = {};

  bool _isInitialized = false;

  TodoProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadCategories(); // Load categories first
    await loadTodos(); // Then load todos
    _isInitialized = true;
    notifyListeners();
  }

  List<Todo> get todos => _todos;
  List<String> get categories => _categories;
  String get filterCategory => _filterCategory;
  String get sortBy => _sortBy;
  bool get showCompleted => _showCompleted;
  String get searchQuery => _searchQuery;
  int? get filterPriority => _filterPriority;
  DateTime? get filterDueDate => _filterDueDate;
  Map<String, IconData> get categoryIcons => _categoryIcons;
  Map<String, Color> get categoryColors => _categoryColors;

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
      final notTemplate = !todo.isTemplate;

      return categoryMatch && completedMatch && searchMatch &&
          priorityMatch && dueDateMatch && notTemplate;
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
    final prefs = await SharedPreferences.getInstance();
    final todosString = prefs.getString('todos');

    if (todosString != null) {
      try {
        final List<dynamic> todosJson = json.decode(todosString);
        _todos = todosJson.map((json) => _todoFromJson(json)).toList();
      } catch (e) {
        _todos = [];
      }
    }

    _checkRecurringTasks();
    if (_isInitialized) notifyListeners();
  }

  Todo _todoFromJson(Map<String, dynamic> json) {
    return Todo(
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
    final newTodo = todo.copyWith(
      id: 'todo_${DateTime.now().millisecondsSinceEpoch}',
      dateCreated: DateTime.now(),
      // Set default due date to tomorrow if not provided
      dueDate: todo.dueDate ?? DateTime.now(),
    );

    _todos.add(newTodo);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id && !todo.isTemplate);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> deleteTemplate(String id) async {
    _todos.removeWhere((todo) => todo.id == id && todo.isTemplate);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> toggleTodoCompletion(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final todo = _todos[index];
      final now = DateTime.now();

      final bool newCompletedState = !todo.completed;

      // If we're marking the task as completed, complete all subtasks too
      // If we're uncompleting the task, uncomplete all subtasks too
      final updatedSubTasks = todo.subTasks.map((st) => st.copyWith(completed: newCompletedState)).toList();

      _todos[index] = todo.copyWith(
        completed: newCompletedState,
        completedAt: newCompletedState ? now : null,
        subTasks: updatedSubTasks,
      );

      _saveTodos();
      notifyListeners();
    }
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      await _saveTodos();
      notifyListeners();
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = _todos.map((todo) => _todoToJson(todo)).toList();
    await prefs.setString('todos', json.encode(todosJson));
  }

  Map<String, dynamic> _todoToJson(Todo todo) {
    return {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'completed': todo.completed,
      'dateCreated': todo.dateCreated.toIso8601String(),
      'dueDate': todo.dueDate?.toIso8601String(),
      'category': todo.category,
      'priority': todo.priority,
      'recurrence': todo.recurrence.index,
      'recurrenceEndDate': todo.recurrenceEndDate?.toIso8601String(),
      'isTemplate': todo.isTemplate,
      'weeklyRecurrenceDays': todo.weeklyRecurrenceDays,
      'enableReminders': todo.enableReminders,
      'subTasks': todo.subTasks.map((st) => {
        'id': st.id,
        'title': st.title,
        'completed': st.completed,
      }).toList(),
      'completedAt': todo.completedAt?.toIso8601String(),
      'lastRecurrence': todo.lastRecurrence?.toIso8601String(),
    };
  }

  Future<void> addCategory(String category) async {
    if (!_categories.contains(category)) {
      _categories.add(category);
      // Set default icon and color for new category
      _categoryIcons[category] = _getDefaultIcon(category);
      _categoryColors[category] = _getDefaultColor(category);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('categories', _categories);
      await _saveCategoryStyles();
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCategories = prefs.getStringList('categories');

    if (savedCategories != null && savedCategories.isNotEmpty) {
      _categories = savedCategories;
    } else {
      // Only set default categories if none exist
      _categories = ['Personal', 'Work', 'Shopping', 'Health', 'Other'];
      await prefs.setStringList('categories', _categories);
    }

    // Load category icons and colors
    final iconsJson = prefs.getString('categoryIcons');
    final colorsJson = prefs.getString('categoryColors');

    if (iconsJson != null) {
      final Map<String, dynamic> iconsMap = json.decode(iconsJson);
      _categoryIcons.clear();
      iconsMap.forEach((key, value) {
        _categoryIcons[key] = IconData(value, fontFamily: 'MaterialIcons');
      });
    }

    if (colorsJson != null) {
      final Map<String, dynamic> colorsMap = json.decode(colorsJson);
      _categoryColors.clear();
      colorsMap.forEach((key, value) {
        _categoryColors[key] = Color(value);
      });
    }

    // Set defaults for any missing categories
    for (final category in _categories) {
      if (!_categoryIcons.containsKey(category)) {
        _categoryIcons[category] = _getDefaultIcon(category);
      }
      if (!_categoryColors.containsKey(category)) {
        _categoryColors[category] = _getDefaultColor(category);
      }
    }

    await _saveCategoryStyles(); // Ensure styles are saved
    if (_isInitialized) notifyListeners();
  }

  IconData _getDefaultIcon(String category) {
    switch (category.toLowerCase()) {
      case 'personal': return Icons.person_outline;
      case 'work': return Icons.work_outline;
      case 'shopping': return Icons.shopping_basket;
      case 'health': return Icons.favorite_border;
      case 'other': return Icons.category;
      default: return Icons.label_outline;
    }
  }

  Color _getDefaultColor(String category) {
    switch (category.toLowerCase()) {
      case 'personal': return Colors.blue.shade700;
      case 'work': return Colors.orange.shade700;
      case 'shopping': return Colors.green.shade700;
      case 'health': return Colors.red.shade700;
      case 'other': return Colors.purple.shade700;
      default: return Colors.blue.shade400;
    }
  }

  Future<void> _saveCategoryStyles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('categoryIcons', json.encode(
        _categoryIcons.map((key, value) => MapEntry(key, value.codePoint))
    ));
    await prefs.setString('categoryColors', json.encode(
        _categoryColors.map((key, value) => MapEntry(key, value.value))
    ));
  }

  Future<void> updateCategoryStyle(String category, IconData icon, Color color) async {
    _categoryIcons[category] = icon;
    _categoryColors[category] = color;
    await _saveCategoryStyles();
    notifyListeners();
  }

  Future<void> removeCategory(String category) async {
    if (_todos.any((todo) => todo.category == category)) {
      return;
    }

    _categories.remove(category);
    _categoryIcons.remove(category);
    _categoryColors.remove(category);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categories', _categories);
    await _saveCategoryStyles();
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

  void reorderTodos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Todo item = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, item);
    _saveTodos();
    notifyListeners();
  }

  void addTodoFromTemplate(Todo template) {
    final newTodo = template.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isTemplate: false,
      dateCreated: DateTime.now(),
      // Set default due date to tomorrow if not provided
      dueDate: template.dueDate ?? DateTime.now(),
    );
    addTodo(newTodo);
  }

  // Method to check if a category can be edited (not default)
  bool canEditCategory(String category) {
    final defaultCategories = ['Personal', 'Work', 'Shopping', 'Health', 'Other'];
    return !defaultCategories.contains(category);
  }

// Method to get category edit screen
  void navigateToCategoryManagement(BuildContext context) {
    Navigator.pushNamed(context, '/categories');
  }

// Method to show add category dialog
  void showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCategoryName = '';
        IconData selectedIcon = Icons.label_outline;
        Color selectedColor = Colors.blue;

        return AlertDialog(
          title: const Text('Add New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => newCategoryName = value,
              ),
              const SizedBox(height: 16),
              // Add icon and color selection here if needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newCategoryName.isNotEmpty) {
                  addCategory(newCategoryName);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}