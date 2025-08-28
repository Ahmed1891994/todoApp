import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/todo_provider.dart';

class CategoryManager extends StatefulWidget {
  const CategoryManager({Key? key}) : super(key: key);

  @override
  _CategoryManagerState createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  final TextEditingController _categoryController = TextEditingController();

  // Helper method to get category icon
  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return const Icon(Icons.work, color: Colors.blue);
      case 'Shopping':
        return const Icon(Icons.shopping_cart, color: Colors.orange);
      case 'Health':
        return const Icon(Icons.favorite, color: Colors.red);
      case 'Personal':
        return const Icon(Icons.person, color: Colors.green);
      case 'Other':
        return const Icon(Icons.category, color: Colors.grey);
      default:
        return const Icon(Icons.category, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final categories = todoProvider.categories;

    return AlertDialog(
      title: const Text('Manage Categories'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'New Category',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final newCategory = _categoryController.text.trim();
                    if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
                      todoProvider.addCategory(newCategory);
                      _categoryController.clear();
                    }
                  },
                ),
              ),
              onSubmitted: (value) {
                final newCategory = value.trim();
                if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
                  todoProvider.addCategory(newCategory);
                  _categoryController.clear();
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isDefault = ['Personal', 'Work', 'Shopping', 'Health', 'Other'].contains(category);

                  return ListTile(
                    leading: _getCategoryIcon(category),
                    title: Text(category),
                    trailing: !isDefault
                        ? IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () {
                        todoProvider.removeCategory(category);
                      },
                    )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}