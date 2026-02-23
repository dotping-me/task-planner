import 'package:taskplanner/model/category.dart';
import 'package:taskplanner/model/task.dart';

// Basically just a 'recursive' dropdown list
class TreeNode {
    final Category? category;
    final Task? task;
    List<TreeNode> children;
    bool isExpanded;

    TreeNode({
        this.category,
        this.task,
        this.children = const [],
        this.isExpanded = false,  // Default
    });
}