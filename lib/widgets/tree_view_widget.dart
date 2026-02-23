import 'package:flutter/material.dart';
import 'package:taskplanner/db/db.dart';
import 'package:taskplanner/model/tree_node.dart';
import 'package:taskplanner/widgets/add_category_dialog_widget.dart';
import 'package:taskplanner/widgets/add_task_dialog_widget.dart';
import 'package:taskplanner/widgets/task_widget.dart';

class TreeViewWidget extends StatelessWidget {
    final List<TreeNode> nodes;
    final Future<void> Function() reload; // Callback to force UI update
    final double indent; // For children

    const TreeViewWidget({
        super.key,
        required this.nodes,
        required this.reload,
        this.indent = 0.0, // Default value for root
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            
            // Loop through each node
            children: nodes.map((node) {
                
                // Display category
                if (node.category != null) {
                    final cat = node.category!;
                    
                    return Padding( // Adds indentation
                        padding: EdgeInsets.only(left: indent),
                        
                        child: ExpansionTile(
                            key: PageStorageKey(cat.id),
                            title: Row(
                                children: [
                                    Expanded(child: Text(cat.name)),

                                    // 'Add Category' button
                                    IconButton(
                                        tooltip: "Add Subcategory",
                                        icon: const Icon(Icons.create_new_folder),

                                        onPressed: () => showDialog(
                                            context: context,
                                            builder: (_) => AddCategoryDialog(
                                                parentId: cat.id,
                                                onAdded: reload,
                                            ),
                                        ),
                                    ),

                                    // 'Add Task' button
                                    IconButton(
                                        tooltip: "Add Task",
                                        icon: const Icon(Icons.add),
                                        onPressed: () => showDialog(
                                            context: context,
                                            builder: (_) => AddTaskDialog(
                                                categoryId: cat.id,
                                                onAdded: reload,
                                            ),
                                        ),
                                    ),

                                    // 'Delete this category' button
                                    IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                            if (cat.id != null) {
                                                await Db.deleteCategory(cat.id!);
                                                await reload();
                                            }
                                        },
                                    ),
                                ],
                            ),

                            // Recursively render children nodes
                            children: [
                                if (node.children.isNotEmpty)
                                    TreeViewWidget(
                                        nodes: node.children,
                                        reload: reload,
                                        indent: indent + 20.0,
                                    ),
                            ],
                        ),
                    );
                }

                // Display task
                else if (node.task != null) {
                    final t = node.task!;

                    return Padding( // Adds indentation
                        padding: EdgeInsets.only(left: indent),
                        child: TaskWidget(
                            task: t,
                            
                            // NOTE: No handler functions implemented because this
                            //       is a stateless widget (widget being TreeView)

                            onToggle: () async {
                                t.status = !t.status;
                                await Db.toggleTaskStatus(t);
                                await reload();
                            },

                            onDelete: () async {
                                if (t.id != null) await Db.deleteTask(t.id!);
                                await reload();
                            },
                        ),
                    );
                }

                return const SizedBox.shrink();
            }).toList(),
        );
    }
}