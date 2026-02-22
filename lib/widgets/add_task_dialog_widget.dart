import 'package:flutter/material.dart';
import 'package:taskplanner/db/db.dart';
import 'package:taskplanner/model/task.dart';

class AddTaskDialog extends StatefulWidget {
    final int? categoryId;
    final VoidCallback onAdded;

    const AddTaskDialog({super.key, this.categoryId, required this.onAdded});

    @override
    State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
    final TextEditingController controller = TextEditingController();
    
    // Handler to insert a task in database
    Future<void> addTask() async {
        final text = controller.text.trim();
        if (text.isEmpty) return;

        await Db.insertTask(Task(title: text, category: widget.categoryId));

        controller.clear();
        Navigator.pop(context);
        widget.onAdded();
    }

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: const Text("New Task"),

            content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: "Task title"),
            ),
            
            actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                ),

                ElevatedButton(
                    onPressed: addTask,
                    child: const Text("Add"),
                ),
            ],
        );
    }
}