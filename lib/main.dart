import 'package:flutter/material.dart';

void main() {
    runApp(const TaskPlanner());
}

class TaskPlanner extends StatelessWidget {
    const TaskPlanner({super.key});

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Task Planner',
            theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.blue,
                ),
            home: const HomePage(),
        );
    }
}

// Just an object defining a task, just simple stuff really
class Task {
    String title;
    bool done;

    Task(this.title, { this.done = false }); // This is the constructor
}

class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomeState();
}

// So basically this is the handler for the home page, what it does and so on
class _HomeState extends State<HomePage> {
    final List<Task> tasks = [];
    final TextEditingController controller = TextEditingController(); // A textfield

    void addTask(String text) {
        if (text.trim().isEmpty) return;

        // Updates the state which in turns updates the UI
        // Sort of like a cascading update
        setState(() {
          tasks.add(Task(text));
        });

        controller.clear();
        Navigator.pop(context); // ???
    }

    // Shows a dialog, allowing user to create a task
    void showAddDialog() {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                title: const Text("New Task"),
                content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: "Do something, I guess?"),
                    // onSubmitted: addTask,                    
                ),

                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                    ),

                    ElevatedButton(
                        onPressed: () => addTask(controller.text),
                        child: const Text("Add"),
                    ),
                ],
            ),
        );
    }

    // Togles between 'done' and 'not done'
    void toggleTask(int index) {
        setState(() {
          tasks[index].done = !tasks[index].done;
        });
    }

    // Delete a task
    void deleteTask(int index) {
        setState(() {
          tasks.removeAt(index);
        });
    }

    // This is the function that returns what the UI displays
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text("My Tasks"), centerTitle: true,),
            
            floatingActionButton: FloatingActionButton(
                onPressed: showAddDialog, child: const Icon(Icons.add),),

            body: tasks.isEmpty 

                // No tasks yet
                ? const Center(
                    child: Text("No tasts yet!", 
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 10),),
                ) 
                
                // Display tasks
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: tasks.length,

                    itemBuilder: (context, index) {
                        final t = tasks[index];

                        return Card(
                            child: ListTile(
                                leading: Checkbox(
                                    value: t.done,
                                    onChanged: (_) => toggleTask(index)
                                ),

                                title: Text(t.title, style: TextStyle(decoration: t.done ? TextDecoration.lineThrough : null),),
                                
                                trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => deleteTask(index),
                                ),

                            ),
                        );
                    },
                ),

        );
    }
}
