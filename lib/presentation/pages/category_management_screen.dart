import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/todo_provider.dart'; // Fixed import path

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context, todoProvider),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: todoProvider.categories.length,
        itemBuilder: (context, index) {
          final category = todoProvider.categories[index];
          final icon = todoProvider.categoryIcons[category];
          final color = todoProvider.categoryColors[category];

          return ListTile(
            leading: Icon(icon, color: color),
            title: Text(category),
            trailing: todoProvider.canEditCategory(category)
                ? IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCategory(context, todoProvider, category),
            )
                : null,
            onTap: () => _editCategory(context, todoProvider, category),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, TodoProvider todoProvider) {
    String newCategoryName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => newCategoryName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newCategoryName.isNotEmpty) {
                  todoProvider.addCategory(newCategoryName);
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

  void _editCategory(BuildContext context, TodoProvider todoProvider, String category) {
    if (!todoProvider.canEditCategory(category)) return;

    String editedName = category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: category),
            onChanged: (value) => editedName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editedName.isNotEmpty && editedName != category) {
                  // Here you would need to implement category renaming logic
                  // This is more complex as it requires updating all todos with this category
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(BuildContext context, TodoProvider todoProvider, String category) {
    if (!todoProvider.canEditCategory(category)) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text('Are you sure you want to delete "$category"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                todoProvider.removeCategory(category);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}