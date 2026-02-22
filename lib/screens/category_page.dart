import 'package:flutter/material.dart';

import 'package:taskplanner/db/db.dart';
import 'package:taskplanner/model/category.dart';
import 'package:taskplanner/model/task.dart';
import 'package:taskplanner/widgets/add_category_dialog_widget.dart';
import 'package:taskplanner/widgets/add_task_dialog_widget.dart';
import 'package:taskplanner/widgets/breadcrumbs.dart';
import 'package:taskplanner/widgets/category_widget.dart';
import 'package:taskplanner/widgets/fab_widget.dart';
import 'package:taskplanner/widgets/task_widget.dart';

class CategoryPage extends StatefulWidget {
    final Category? category; // If Null -> Root
    const CategoryPage({super.key, required this.category});

    @override
    State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
    List<Category> subcategories = [];
    List<Task> tasks = [];
    List<Category> breadcrumbs = [];

    final TextEditingController categoryController = TextEditingController();
    final TextEditingController taskController = TextEditingController();

    @override
    void initState() {
        super.initState();
        loadData();
    }

    // Loads the relevant subcategories and tasks for this catergory being shown
    Future<void> loadData() async {
        final cats = await Db.getSubcategories(widget.category?.id);
        final t = await Db.getTasksByCategory(widget.category?.id);

        final breadcrumbsTrail = widget.category != null
            ? await Db.getBreadcrumbs(widget.category!.id)
            : <Category>[];

        setState(() {
            subcategories = cats;
            tasks = t;
            breadcrumbs = breadcrumbsTrail;
        });
    }

    // Dialog to add a category (subcategory) to this category
    void showAddCategoryDialog() {
        showDialog(
            context: context,
            builder: (_) => AddCategoryDialog(
                parentId: widget.category?.id,
                onAdded: loadData,
            ),
        );
    }

    // Dialog to add a task to this category
    void showAddTaskDialog() {
        showDialog(
            context: context,
            builder: (_) => AddTaskDialog(
                categoryId: widget.category?.id,
                onAdded: loadData,
            ),
        );
    }

    // Changes the status of a task and also reflect change in database
    Future<void> toggleTask(Task task) async {
        setState(() {
            task.status = !task.status;
        });

        await Db.toggleTaskStatus(task);
        // loadData();
    }

    // Removes the task and also reloads page data
    Future<void> deleteTask(Task task) async {
        if (task.id != null) await Db.deleteTask(task.id!);
        loadData();
    }

    // Navigate to other subcategories
    void openCategory(Category cat) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CategoryPage(category: cat)), // Uses this page itself to render subcategory
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Breadcrumbs(
                    trail: breadcrumbs,
                    parentContext: context,
                ),
                
                centerTitle: false,
            ),
            
            floatingActionButton: AddItemFAB(
                parentId: widget.category?.id, // current folder
                onUpdated: loadData,
            ),


            body: ListView(
                padding: const EdgeInsets.all(12),
                
                children: [
                    if (subcategories.isNotEmpty) 
                        ...subcategories.map((cat) => CategoryWidget(
                            category: cat,
                            onTap: () => openCategory(cat),
                            onDelete: () async {
                                await Db.deleteCategory(cat.id!);
                                loadData();
                            },
                        )
                    ),
                    
                    if (tasks.isNotEmpty)
                        ...tasks.map((t) => TaskWidget(
                            task: t,
                            onToggle: () => toggleTask(t),
                            onDelete: () => deleteTask(t),
                        )
                    ),
                    
                    // No data yet
                    if (subcategories.isEmpty && tasks.isEmpty)
                        const Center(
                            child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("No subcategories or tasks yet!", textAlign: TextAlign.center),
                        )
                    ),
                ],
            ),
        );
    }
}