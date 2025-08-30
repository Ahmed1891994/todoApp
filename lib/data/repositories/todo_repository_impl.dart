import 'dart:convert';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final LocalDataSource localDataSource;
  final String _key = 'todos';

  TodoRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Todo>> getTodos() async {
    try {
      final todosString = await localDataSource.getString(_key);
      if (todosString.isEmpty) return [];

      final List todosJson = json.decode(todosString) as List;
      return todosJson.map((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final todos = await getTodos();

    // If it's a template, make sure it doesn't conflict with task IDs
    if (todo.isTemplate) {
      // Remove any existing template with the same title to avoid duplicates
      todos.removeWhere((t) => t.isTemplate && t.title == todo.title);
    }

    todos.add(TodoModel.fromTodo(todo));
    await _saveTodos(todos);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final todos = await getTodos();
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = TodoModel.fromTodo(todo);
      await _saveTodos(todos);
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    final todos = await getTodos();
    todos.removeWhere((todo) => todo.id == id);
    await _saveTodos(todos);
  }

  @override
  Future<void> toggleTodo(String id) async {
    final todos = await getTodos();
    final index = todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final todo = todos[index];
      todos[index] = todo.copyWith(completed: !todo.completed);
      await _saveTodos(todos);
    }
  }

  Future<void> _saveTodos(List<Todo> todos) async {
    try {
      final todosString = json.encode(todos.map((todo) => TodoModel.fromTodo(todo).toJson()).toList());
      await localDataSource.setString(_key, todosString);
    } catch (e) {
      print('Error saving todos: $e');
    }
  }
}