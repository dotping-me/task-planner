import 'package:flutter/material.dart';
import 'package:taskplanner/db/db.dart';
import 'package:taskplanner/model/tree_node.dart';
import 'package:taskplanner/widgets/add_category_dialog_widget.dart';
import 'package:taskplanner/widgets/add_task_dialog_widget.dart';
import 'package:taskplanner/widgets/task_widget.dart';

class TreeViewWidget extends StatefulWidget {
    final List<TreeNode> nodes;
    final VoidCallback reload;
    final double indent;
    
    // Logic to track last clicked node
    final int? selectedNodeId;
    final Function(int) onSelect;

    const TreeViewWidget({
        super.key,
        required this.nodes,
        required this.reload,
        required this.selectedNodeId,
        required this.onSelect,

        this.indent = 0.0, // Default value for root
    });

    @override
    State<TreeViewWidget> createState() => _TreeViewWidgetState();
}

// For the progress bars
class _TaskCount {
    final int total;
    final int completed;
    _TaskCount(this.total, this.completed);
}

class _TreeViewWidgetState extends State<TreeViewWidget> {
    final Map<int, bool> _expandedNodes = {};

    // Logic to determine if a node was expanded or not
    void toggleExpanded(int id) {
        setState(() {
            _expandedNodes[id] = !(_expandedNodes[id] ?? false);
        });
    }

    bool isExpanded(int id) => _expandedNodes[id] ?? false;

    // TODO: Remove this if it adds too much strain
    // Finds the percentage of tasks completed in this category recursively
    double _calculateProgress(TreeNode node) {
        final result = _countTasksRecursive(node);
        if (result.total == 0) return 0.0;
        
        return result.completed / result.total;
    }

    _TaskCount _countTasksRecursive(TreeNode node) {
        int total = 0;
        int completed = 0;

        for (final child in node.children) {
            if (child.task != null) {
                total++;
            
                if (child.task!.status) completed++;
            }

            if (child.category != null) {
                final sub = _countTasksRecursive(child);
                total += sub.total;
                completed += sub.completed;
            }
        }

        return _TaskCount(total, completed);
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.nodes.map((node) {
                
                // Its children are tasks, thus display category node
                if (node.category != null) {
                    final cat = node.category!;
                    final expanded = isExpanded(cat.id!);
                    final isSelected = widget.selectedNodeId == cat.id;

                    return Padding(
                        padding: EdgeInsets.only(left: widget.indent),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                
                                // Just for the sake of the animation
                                GestureDetector(
                                    onTap: () {
                                        toggleExpanded(cat.id!);
                                        widget.onSelect(cat.id!); // Highlight this node
                                    },

                                    child: Container(

                                        // Styling for selected node
                                        decoration: isSelected
                                            ? BoxDecoration(
                                                border: Border.all(color: Colors.blue, width: 2),
                                                borderRadius: BorderRadius.circular(8),
                                            )
                                            : null,

                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Row(
                                            children: [

                                                // The 'arrow' icon
                                                Icon(
                                                    expanded ? Icons.expand_more : Icons.chevron_right,
                                                    color: Colors.grey[400],
                                                ),
                                            
                                            const SizedBox(width: 4),
                                            
                                            Expanded(
                                                child: Text(
                                                    cat.name,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18.0,
                                                        color: Colors.black,
                                                    ),
                                                ),
                                            ),

                                            // Progress bar
                                            SizedBox(
                                                width: 100,
                                                child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(6),
                                                    child: LinearProgressIndicator(
                                                    value: _calculateProgress(node), // Returns a %
                                                    minHeight: 6,
                                                    backgroundColor: Colors.grey[300],
                                                    
                                                    // TODO: Add random colours maybe?
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                                                    ),

                                                ),
                                            ),

                                            const SizedBox(width: 8),

                                            // Options dropdown
                                            // TODO: Maybe customize the UI for the options
                                            PopupMenuButton<String>(
                                                icon: Icon(Icons.more_horiz, color: Colors.grey[400]),
                                                tooltip: 'Actions',
                                                
                                                onSelected: (value) async {
                                                    switch (value) {
                                                        case 'Add Subcategory':
                                                            showDialog(
                                                                context: context,
                                                                builder: (_) => AddCategoryDialog(
                                                                    parentId: cat.id,
                                                                    onAdded: widget.reload,
                                                                ),
                                                            );
                                                            break;

                                                        case 'Add Task':
                                                            showDialog(
                                                                context: context,
                                                                builder: (_) => AddTaskDialog(
                                                                    categoryId: cat.id,
                                                                    onAdded: widget.reload,
                                                                ),
                                                            );
                                                            break;

                                                        case 'Delete':
                                                            await Db.deleteCategory(cat.id!);
                                                            widget.reload();
                                                            break;
                                                        }
                                                    },
                                                itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                        value: 'Add Subcategory',
                                                        child: Text('Add Subcategory'),
                                                    ),

                                                    const PopupMenuItem(
                                                        value: 'Add Task',
                                                        child: Text('Add Task'),
                                                    ),

                                                    const PopupMenuItem(
                                                        value: 'Delete',
                                                        child: Text('Delete'),
                                                    ),
                                                ],
                                            ),
                                        ],),
                                    ),
                                ),

                                // Animated expansion for children (Recursive call)
                                AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: expanded
                                        ? TreeViewWidget(
                                            nodes: node.children,
                                            reload: widget.reload,
                                            indent: widget.indent + 16.0,
                                            selectedNodeId: widget.selectedNodeId,
                                            onSelect: widget.onSelect,
                                        )
                                        : const SizedBox.shrink(),
                                ),
                            ],
                        ),
                    );

                // Show task instead
                } else if (node.task != null) {
                    final t = node.task!;
                    return Padding(
                        padding: EdgeInsets.only(left: widget.indent),
                        child: TaskWidget(
                            task: t,
                            onToggle: () async {
                                t.status = !t.status;
                                await Db.toggleTaskStatus(t);
                                widget.reload();
                            },

                            onDelete: () async {
                                if (t.id != null) await Db.deleteTask(t.id!);
                                widget.reload();
                            },
                        ),
                    );
                }

                return const SizedBox.shrink();
            }).toList(),
        );
    }
}