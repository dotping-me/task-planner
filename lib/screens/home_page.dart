import 'package:flutter/material.dart';
import 'package:taskplanner/db/db.dart';
import 'package:taskplanner/model/tree_node.dart';
import 'package:taskplanner/widgets/add_batch_dialog_widget.dart';
import 'package:taskplanner/widgets/add_category_dialog_widget.dart';
import 'package:taskplanner/widgets/add_task_dialog_widget.dart';
import 'package:taskplanner/widgets/tree_view_widget.dart';

class HomePage extends StatefulWidget {
    final String? initialUsername; // Parsed from TaskPlanner (Root)
    const HomePage({super.key, this.initialUsername});

    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    String? _username; // Metadata, sort of

    List<TreeNode> tree = [];
    int? selectedCategoryId;

    @override
    void initState() {
        super.initState();

        // Setup username
        _username = widget.initialUsername;
        if (_username == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
                _showNameDialog();
            });
        }

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

    // -------------------
    //   Dialog Handlers
    // -------------------

    // 'Username' Dialog
    void _showNameDialog() {
        final controller = TextEditingController();

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
                return AlertDialog(
                    title: const Text('Welcome!'),

                    content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                            labelText: 'Enter your name',
                        ),
                    ),

                    actions: [
                        ElevatedButton(
                            onPressed: () async {
                                final name = controller.text.trim();
                    
                                if (name.isNotEmpty) {
                                    await Db.saveUsername(name);

                                    setState(() {
                                        _username = name;
                                    });

                                    Navigator.of(context).pop();
                                }
                            },

                            child: const Text('Continue'),
                        ),
                    ],
                );
            },
        );
    }
    
    // Show 'Add Category' Dialog
    void _showAddCategoryDialog(BuildContext context) {
        showDialog(
            context: context,
            builder: (_) => AddCategoryDialog(
                parentId: null,
                onAdded: loadTree,
            ),
        );
    }

    // Show 'Add Task' Dialog
    void _showAddTaskDialog(BuildContext context) {
        showDialog(
            context: context,
            builder: (_) => AddTaskDialog(
                categoryId: null,
                onAdded: loadTree,
            ),
        );
    }

    // Show 'Batch Generator' Dialog
    void _showBatchGeneratorDialog(BuildContext context) {
        showDialog(
            context: context,
            builder: (_) => BatchGeneratorDialog(
            parentCategory: null,
            onUpdated: loadTree,
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.blue[800],

            body: SafeArea(
                child: Column(children: [

                    // Top part of the app, with the greetings and all that
                    Padding(padding: EdgeInsets.all(24.0), child: Column(children: [

                        // User greeting
                        Row(children: [
                            
                            // 'Change name' button
                            IconButton(
                                icon: const Icon(Icons.person, color: Colors.white, fontWeight: FontWeight.bold,),
                                onPressed: null),

                            const SizedBox(width: 10.0),

                            // Name displayed
                            Text(_username != null ? 'Hello, $_username!' : 'Hello!', 
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),),
                        ],),

                        // TODO: Stats cards, maybe?

                        SizedBox(height: 200.0,), // Spacing

                    ],),),
                
                    // Tree-view Display Container
                    // I want rounded corners here but just for the top

                    Expanded(child: GestureDetector(
                        
                        // Reset last clicked node when clicked outside
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                            setState(() {
                                selectedCategoryId = null;
                            });
                        },

                        child: Container(
                            
                        // I'm too lazy to redo all the indentation below
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.0),
                                topRight: Radius.circular(24.0),
                            )

                        ),

                        padding: EdgeInsets.all(24.0),
                        child: Column(children: [
                            
                            // Header
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Text('Tasks', style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 20),),

                                    // Button that shows dialog to add everything
                                    PopupMenuButton<String>(
                                        icon: const Icon(Icons.add),
                                        onSelected: (value) {
                                            switch (value) {
                                                case 'Add Top Category':
                                                    _showAddCategoryDialog(context);
                                                    break;
                                                
                                                case 'Add Top Task':
                                                    _showAddTaskDialog(context);
                                                    break;

                                                case 'Generate':
                                                    _showBatchGeneratorDialog(context);
                                                    break;
                                            }
                                        },

                                        itemBuilder: (context) => [
                                            const PopupMenuItem(
                                                value: 'Add Top Category',
                                                child: Text('Add Top Category'),
                                            ),


                                            const PopupMenuItem(
                                                value: 'Add Top Task',
                                                child: Text('Add Top Task'),
                                            ),
        
                                            const PopupMenuItem(
                                                value: 'Generate',
                                                child: Text('Generate'),
                                            ),
                                        ],
                                    ),
                                ],
                            ),

                            const SizedBox(height: 16.0,),

                            // Show categories and tasks here
                            Expanded(
                                child: tree.isEmpty
                                ? const Center(child: Text("No categories or tasks yet"))
                                : SingleChildScrollView(child: 
                
                                    TreeViewWidget(
                                        nodes: tree,
                                        reload: loadTree,

                                        // Track last clicked node
                                        selectedNodeId: selectedCategoryId,
                                        onSelect: (id) {
                                            setState(() {
                                            selectedCategoryId = id;
                                            });
                                        },
                                    ),

                                ),
                            ),

                        ],),))
                    ),]
                )
            )
        );
    }
}