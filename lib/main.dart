import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/todo_provider.dart';
import 'core/themes/app_themes.dart';
import 'data/datasources/local_data_source.dart';
import 'data/repositories/todo_repository_impl.dart';
import 'domain/repositories/todo_repository.dart';
import 'presentation/pages/todo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final LocalDataSource localDataSource = LocalDataSourceImpl(sharedPreferences: sharedPreferences);
  final TodoRepository todoRepository = TodoRepositoryImpl(localDataSource: localDataSource);

  runApp(MyApp(todoRepository: todoRepository));
}

class MyApp extends StatefulWidget {
  final TodoRepository todoRepository;

  const MyApp({Key? key, required this.todoRepository}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
    });
  }

  Future<void> _setThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = TodoProvider(todoRepository: widget.todoRepository);
        provider.loadTodos();
        provider.loadCategories(); // Load categories
        return provider;
      },
      child: MaterialApp(
        title: 'Enhanced Todo App',
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: _themeMode,
        home: TodoScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}