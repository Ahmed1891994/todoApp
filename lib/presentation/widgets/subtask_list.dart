import 'package:flutter/material.dart';
import '../../domain/entities/todo.dart';

class SubTaskList extends StatefulWidget {
  final List<SubTask> subTasks;
  final Function(List<SubTask>) onSubTasksChanged;

  const SubTaskList({
    super.key,
    required this.subTasks,
    required this.onSubTasksChanged,
  });

  @override
  State<SubTaskList> createState() => __SubTaskListState();
}

class __SubTaskListState extends State<SubTaskList> {
  final TextEditingController _subTaskController = TextEditingController();
  late List<SubTask> _subTasks;

  @override
  void initState() {
    super.initState();
    _subTasks = List.from(widget.subTasks);
  }

  @override
  void didUpdateWidget(SubTaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subTasks != widget.subTasks) {
      _subTasks = List.from(widget.subTasks);
    }
  }

  void _addSubTask() {
    if (_subTaskController.text.isNotEmpty) {
      setState(() {
        _subTasks.add(SubTask(
          id: DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          title: _subTaskController.text,
        ));
        _subTaskController.clear();
      });
      widget.onSubTasksChanged(_subTasks);
    }
  }

  void _toggleSubTask(int index) {
    setState(() {
      _subTasks[index] = _subTasks[index].copyWith(
        completed: !_subTasks[index].completed,
      );
    });
    widget.onSubTasksChanged(_subTasks);
  }

  void _deleteSubTask(int index) {
    setState(() {
      _subTasks.removeAt(index);
    });
    widget.onSubTasksChanged(_subTasks);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subtasks:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subTaskController,
                decoration: const InputDecoration(
                  labelText: 'Add subtask',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
                onSubmitted: (_) => _addSubTask(),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: _addSubTask,
              tooltip: 'Add subtask',
            ),
          ],
        ),
        if (_subTasks.isNotEmpty) ...[
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 120),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _subTasks.length,
              itemBuilder: (context, index) {
                final subTask = _subTasks[index];

                return ListTile(
                  leading: Checkbox(
                    value: subTask.completed,
                    onChanged: (_) => _toggleSubTask(index),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  title: Text(
                    subTask.title,
                    style: TextStyle(
                      fontSize: 12,
                      decoration: subTask.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, size: 16),
                    onPressed: () => _deleteSubTask(index),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  minLeadingWidth: 20,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}