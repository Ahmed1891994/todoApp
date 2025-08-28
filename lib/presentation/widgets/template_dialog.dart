import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/todo_provider.dart';
import '../../domain/entities/todo.dart';

class TemplateDialog extends StatelessWidget {
  const TemplateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final templates = todoProvider.templates;

    return AlertDialog(
      title: const Text('Task Templates'),
      content: SizedBox(
        width: double.maxFinite,
        child: templates.isEmpty
            ? const Center(
          child: Text('No templates saved yet.'),
        )
            : ListView.builder(
          shrinkWrap: true,
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return ListTile(
              title: Text(template.title),
              subtitle: template.description != null
                  ? Text(template.description!)
                  : null,
              leading: _getCategoryIcon(template.category),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () {
                      todoProvider.addTodoFromTemplate(template);
                      Navigator.of(context).pop();
                    },
                    tooltip: 'Add from template',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(context, template, todoProvider);
                    },
                    tooltip: 'Delete template',
                  ),
                ],
              ),
            );
          },
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

  void _showDeleteConfirmation(BuildContext context, Todo template, TodoProvider todoProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Delete template "${template.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                todoProvider.deleteTemplate(template.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

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
      default:
        return const Icon(Icons.category, color: Colors.grey);
    }
  }
}