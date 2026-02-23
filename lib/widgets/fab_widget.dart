import 'package:flutter/material.dart';
import 'package:taskplanner/model/category.dart';
import 'package:taskplanner/widgets/add_batch_dialog_widget.dart';
import 'package:taskplanner/widgets/add_category_dialog_widget.dart';
import 'package:taskplanner/widgets/add_task_dialog_widget.dart';

class AddItemFAB extends StatelessWidget {
    final int? parentId; // If Null, then it means that it is on the root/first level
    final VoidCallback onUpdated;

    const AddItemFAB({
        super.key,
        this.parentId,
        required this.onUpdated,
    });

    // Show 'Add Category' Dialog
    void _showAddCategoryDialog(BuildContext context) {
        showDialog(
            context: context,
            builder: (_) => AddCategoryDialog(
                parentId: parentId,
                onAdded: onUpdated,
            ),
        );
    }

    // Show 'Add Task' Dialog
    void _showAddTaskDialog(BuildContext context) {
        showDialog(
            context: context,
            builder: (_) => AddTaskDialog(
                categoryId: parentId,
                onAdded: onUpdated,
            ),
        );
    }

    // Show 'Batch Generator' Dialog
    void _showBatchGeneratorDialog(BuildContext context) {
        showDialog(
            context: context,
            builder: (_) => BatchGeneratorDialog(
            parentCategory: parentId != null ? Category(id: parentId!, name: 'Parent') : null,
            onUpdated: onUpdated,
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            
            children: [
                FloatingActionButton(
                    heroTag: "category_${parentId ?? 'root'}",
                    onPressed: () => _showAddCategoryDialog(context),
                    child: const Icon(Icons.folder),
                ),

                const SizedBox(height: 10),

                FloatingActionButton(
                    heroTag: "task_${parentId ?? 'root'}",
                    onPressed: () => _showAddTaskDialog(context),
                    child: const Icon(Icons.add),
                ),

                const SizedBox(height: 10),

                FloatingActionButton(
                    heroTag: "batch_${parentId ?? 'root'}",
                    onPressed: () => _showBatchGeneratorDialog(context),
                    tooltip: "Batch Generate",
                    child: const Icon(Icons.grid_view),
                ),
            ],
        );
    }
}