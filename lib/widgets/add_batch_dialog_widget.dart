import 'package:flutter/material.dart';
import 'package:taskplanner/db/db.dart';
import 'package:taskplanner/model/category.dart';
import 'package:taskplanner/model/task.dart';

class BatchGeneratorDialog extends StatefulWidget {
    final Category? parentCategory; // Null for Root
    final VoidCallback onUpdated;

    const BatchGeneratorDialog({
        super.key,
        this.parentCategory,
        required this.onUpdated}
    );

    @override
    State<BatchGeneratorDialog> createState() => _BatchGeneratorDialogState();
}

class _BatchGeneratorDialogState extends State<BatchGeneratorDialog> {
    List<TextEditingController> levelControllers = [];
    List<TextEditingController> valueControllers = [];
    bool isGenerating = false; // Just to show loading state

    @override
    void initState() {
        super.initState();
        addLevel(); // Adds first level
    }

    // Release memory
    @override
    void dispose() {
        for (var c in levelControllers) { c.dispose(); }
        for (var c in valueControllers) { c.dispose(); }
        super.dispose();
    }

    // Create new controllers (Text inputs) for new level
    void addLevel() {
        levelControllers.add(TextEditingController());
        valueControllers.add(TextEditingController());
        setState(() {});
    }

    // Deletes a level
    void removeLevel(int index) {
        levelControllers[index].dispose();
        valueControllers[index].dispose();

        levelControllers.removeAt(index);
        valueControllers.removeAt(index);
        setState(() {}); // Forces UI reload
    }

    Future<void> generateBatch() async {
        final levels = <String>[];
        final values = <String, List<String>>{};

        // Catches text inputs
        for (int i = 0; i < levelControllers.length; i++) {
            final lvlName = levelControllers[i].text.trim();
            final valText = valueControllers[i].text.trim();

            if (lvlName.isEmpty || valText.isEmpty) continue;

            levels.add(lvlName);
            values[lvlName] = valText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }

        if (levels.isEmpty) return;

        setState(() => isGenerating = true);

        // Function defined inside a function for encapsulation
        // Recursively performs database entries
        Future<void> insertLevel(int depth, int? parentId) async {
            final level = levels[depth];
            final entries = values[level]!;

            for (final entry in entries) {

                // Last level are tasks
                if (depth == levels.length - 1) {
                    await Db.insertTask(Task(title: entry, category: parentId));
                
                // Create categories
                } else {
                    final newCatId = await Db.insertCategory(
                        Category(name: entry, parent: parentId)
                    );

                    await insertLevel(depth + 1, newCatId); // Recursive call
                }
            }
        }

        await insertLevel(0, widget.parentCategory?.id); // Recursion starts here!

        setState(() => isGenerating = false);
        widget.onUpdated();
        Navigator.pop(context);
    }   

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: const Text("Batch Generator"),
            
            content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView( child: Column(
                    children: [
                        for (int i = 0; i < levelControllers.length; i++)
                        Row(
                            children: [
                                Expanded(
                                    flex: 2,
                                    child: TextField(
                                        controller: levelControllers[i],
                                        decoration: InputDecoration(hintText: "Level Name (e.g. Year)"),
                                    ),
                                ),

                                const SizedBox(width: 8),
                    
                                Expanded(
                                    flex: 3,
                                    child: TextField(
                                        controller: valueControllers[i],
                                        decoration: const InputDecoration(hintText: "Values (comma-separated)"),
                                    ),
                                ),
                    
                                IconButton(
                                    icon: const Icon(Icons.highlight_remove_sharp, color: Colors.red),
                                    onPressed: () => removeLevel(i),
                                ),
                            ],
                        ),

                        const SizedBox(height: 10),
                        Row(
                            children: [
                                ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text("Add Level"),
                                    onPressed: addLevel,
                                ),

                                const SizedBox(width: 10),

                                // Shows loading state
                                ElevatedButton.icon(
                                    icon: isGenerating ? const CircularProgressIndicator(strokeWidth: 2) : const Icon(Icons.done),
                                    label: const Text("Generate"),
                                    onPressed: isGenerating ? null : generateBatch,
                                ),
                            ],
                        ),
                    ],),
                ),
            ),
        );
    }
}