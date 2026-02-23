import 'package:flutter/material.dart';
import 'package:taskplanner/db/db.dart';
import 'package:taskplanner/model/tree_node.dart';
import 'package:taskplanner/widgets/fab_widget.dart';
import 'package:taskplanner/widgets/tree_view_widget.dart';

class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    List<TreeNode> tree = [];

    @override
    void initState() {
        super.initState();
        loadTree();
    }

    // Just forces a UI update
    Future<void> loadTree() async {
        tree = await buildTree(parentId: null);
        setState(() {});
    }

    // Builds the tree recursively by using implemented database queries
    Future<List<TreeNode>> buildTree({int? parentId}) async {
        final subcategories = await Db.getSubcategories(parentId);
        final tasks = await Db.getTasksByCategory(parentId);

        List<TreeNode> nodes = [];

        for (var cat in subcategories) {
            nodes.add(
                TreeNode(
                    category: cat,
                    children: await buildTree(parentId: cat.id),
                ),
            );
        }

        for (var task in tasks) {
            nodes.add(TreeNode(task: task));
        }

        return nodes;
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text("Categories")), // No breadcrumbs :(
            
            floatingActionButton: AddItemFAB(
                parentId: null,
                onUpdated: loadTree,
            ),

            body: tree.isEmpty
                ? const Center(child: Text("No categories or tasks yet"))
                : TreeViewWidget(
                    nodes: tree,
                    reload: loadTree,
                ),
        );
    }
}