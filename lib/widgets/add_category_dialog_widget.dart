import 'package:flutter/material.dart';
import 'package:taskplanner/db/db.dart';
import 'package:taskplanner/model/category.dart';

class AddCategoryDialog extends StatefulWidget {
    final int? parentId;
    final VoidCallback onAdded;

    const AddCategoryDialog({super.key, this.parentId, required this.onAdded});

    @override
    State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
    final TextEditingController controller = TextEditingController();

    // Handler to effect inserting a category
    Future<void> addCategory() async {
        final text = controller.text.trim();
        if (text.isEmpty) return;

        await Db.insertCategory(Category(name: text, parent: widget.parentId));
        
        controller.clear();
        Navigator.pop(context);
        widget.onAdded(); // Fires an event to reload data
    }

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: const Text("New Category"),

            content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: "Category name"),
            ),

            actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                ),

                ElevatedButton(
                    onPressed: addCategory,
                    child: const Text("Add"),
                ),
            ],
        );
    }
}