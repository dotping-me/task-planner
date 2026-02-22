import 'package:flutter/material.dart';
import 'package:taskplanner/model/category.dart';

class CategoryWidget extends StatelessWidget {
    final Category category;
    final VoidCallback onTap;
    final VoidCallback onDelete;

    const CategoryWidget({
        super.key,
        required this.category,
        required this.onTap,
        required this.onDelete,
    });

    @override
    Widget build(BuildContext context) {
        return Card(
            child: ListTile(
                leading: const Icon(Icons.folder),
                title: Text(category.name),
                onTap: onTap,

                trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                )

            ),
        );
    }
}