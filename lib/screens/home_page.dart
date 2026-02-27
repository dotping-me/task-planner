import 'package:flutter/material.dart';
import 'package:taskplanner/db/db.dart';
import 'package:taskplanner/model/tree_node.dart';
import 'package:taskplanner/widgets/add_batch_dialog_widget.dart';
import 'package:taskplanner/widgets/add_category_dialog_widget.dart';
import 'package:taskplanner/widgets/add_task_dialog_widget.dart';
import 'package:taskplanner/widgets/footer_widget.dart';
import 'package:taskplanner/widgets/tree_view_widget.dart';

class HomePage extends StatefulWidget {
  final String? initialUsername; // Parsed from TaskPlanner (Root)
  const HomePage({super.key, this.initialUsername});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _username; // Metadata, sort of

  // Detects if the Tree View Container is at the top of the screen or not
  final ScrollController _scrollController = ScrollController();
  bool _isAtTop = true;

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

    // Logic to detect if tasks are at the top of the screen
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final atTop = _scrollController.position.pixels <= 0;

      if (atTop != _isAtTop) {
        if (mounted) {
          setState(() {
            _isAtTop = atTop;
          });
        }
      } else {
        if (mounted) {
          _isAtTop = false;
        }
      }
    });

    loadTree();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            decoration: const InputDecoration(labelText: 'Enter your name'),
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
      builder: (_) => AddCategoryDialog(parentId: null, onAdded: loadTree),
    );
  }

  // Show 'Add Task' Dialog
  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddTaskDialog(categoryId: null, onAdded: loadTree),
    );
  }

  // Show 'Batch Generator' Dialog
  void _showBatchGeneratorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) =>
          BatchGeneratorDialog(parentCategory: null, onUpdated: loadTree),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],

      body: Stack(children: [
        SafeArea(
          child: CustomScrollView(
            controller: _scrollController, // Feeds in data

            slivers: [
              // Hero (ish) section
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.blue[800],
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Greeting Row
                      Row(
                        children: [
                          Text(
                            _username != null ? 'Hello, $_username!' : 'Hello!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// TODO: Stats Cards here maybe?
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              /// Tree View Container
              SliverFillRemaining(
                hasScrollBody: true,

                // Unrounds corners at the top (and vice-versa)
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_isAtTop ? 24.0 : 0.0),
                      topRight: Radius.circular(_isAtTop ? 24.0 : 0.0),
                    ),
                  ),

                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      /// Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tasks',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),

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
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Add Top Category',
                                child: Text('Add Top Category'),
                              ),
                              PopupMenuItem(
                                value: 'Add Top Task',
                                child: Text('Add Top Task'),
                              ),
                              PopupMenuItem(
                                value: 'Generate',
                                child: Text('Generate'),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16.0),

                      /// TreeView Section
                      Expanded(
                        child: tree.isEmpty
                            ? const Center(
                                child: Text(
                                  "* Cricket Noises *",
                                  style: TextStyle(
                                    fontVariations: [FontVariation.italic(1.0)],
                                  ),
                                ),
                              )
                            : Stack(
                                children: [
                                  // Scrollable Tree
                                  TreeViewWidget(
                                    nodes: tree,
                                    reload: loadTree,
                                    selectedNodeId: selectedCategoryId,
                                    onSelect: (id) {
                                      setState(() {
                                        selectedCategoryId = id;
                                      });
                                    },
                                  ),

                                  // Adding a gradient at the bottom of the screen
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: IgnorePointer(
                                      child: Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withAlpha(0),
                                              Colors.white,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FooterScene(),
        )
      ]),
    );
  }
}