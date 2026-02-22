import 'package:flutter/material.dart';
import 'package:taskplanner/model/task.dart';

class TaskWidget extends StatelessWidget {
    final Task task;
    final VoidCallback onToggle;
    final VoidCallback onDelete;

    const TaskWidget({
        super.key,
        required this.task,
        required this.onToggle,
        required this.onDelete,
    });

    @override
    Widget build(BuildContext context) {
        return Card(
            child: ListTile(
                leading: Checkbox(
                    value: task.status,
                    onChanged: (_) => onToggle(),
                ),

                title: Text(
                    task.title,
                    style: TextStyle(
                    decoration: task.status ? TextDecoration.lineThrough : null,
                    ),
                ),

                trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                ),
                
            ),
        );
    }
}