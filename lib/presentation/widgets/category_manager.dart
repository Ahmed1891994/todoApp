import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/todo_provider.dart';

class CategoryManager extends StatefulWidget {
  const CategoryManager({super.key});

  @override
  _CategoryManagerState createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  final TextEditingController _newCategoryController = TextEditingController();
  final Map<String, IconData> _categoryIcons = {};
  final Map<String, Color> _categoryColors = {};

  final List<IconData> _availableIcons = [
    Icons.person,
    Icons.work,
    Icons.shopping_cart,
    Icons.local_hospital,
    Icons.home,
    Icons.school,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.directions_car,
    Icons.attach_money,
    Icons.movie,
    Icons.music_note,
    Icons.book,
    Icons.computer,
    Icons.phone,
    Icons.email,
    Icons.calendar_today,
    Icons.alarm,
    Icons.star,
    Icons.favorite,
  ];

  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    // Initialize default icons and colors for existing categories
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    for (final category in todoProvider.categories) {
      _categoryIcons[category] = todoProvider.categoryIcons[category] ?? _getDefaultIcon(category);
      _categoryColors[category] = todoProvider.categoryColors[category] ?? _getDefaultColor(category);
    }
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

  void _showIconColorPicker(String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Customize $category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select Icon:'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: _availableIcons.map((icon) {
                        return IconButton(
                          icon: Icon(icon),
                          color: _categoryIcons[category] == icon
                              ? _categoryColors[category]
                              : Colors.grey,
                          onPressed: () {
                            setState(() {
                              _categoryIcons[category] = icon;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text('Select Color:'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: _availableColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _categoryColors[category] = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _categoryColors[category] == color
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<TodoProvider>(context, listen: false)
                        .updateCategoryStyle(category, _categoryIcons[category]!, _categoryColors[category]!);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return AlertDialog(
      title: const Text('Manage Categories'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newCategoryController,
              decoration: InputDecoration(
                labelText: 'New Category',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_newCategoryController.text.isNotEmpty) {
                      todoProvider.addCategory(_newCategoryController.text);
                      _categoryIcons[_newCategoryController.text] = Icons.category;
                      _categoryColors[_newCategoryController.text] = Colors.blue;
                      _newCategoryController.clear();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: todoProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = todoProvider.categories[index];
                  return ListTile(
                    leading: Icon(
                      _categoryIcons[category] ?? Icons.category,
                      color: _categoryColors[category] ?? Colors.blue,
                    ),
                    title: Text(category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showIconColorPicker(category),
                        ),
                        if (category != 'Personal' &&
                            category != 'Work' &&
                            category != 'Shopping' &&
                            category != 'Health' &&
                            category != 'Other')
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => todoProvider.removeCategory(category),
                          ),
                      ],
                    ),
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