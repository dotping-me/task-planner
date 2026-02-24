import 'package:flutter/material.dart';
import 'package:taskplanner/model/task.dart';

class TaskWidget extends StatelessWidget {
    final Task task;
    final VoidCallback onToggle;
    final VoidCallback onDelete;

    const TaskWidget({
        super.key,
        required this.task,
        required this.onToggle,
        required this.onDelete,
    });

    @override
    Widget build(BuildContext context) {
        Theme.of(context);

        return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

            decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                ),
            ),


            child: Row(children: [
                
                // Checkbox
                SizedBox(
                    height: 24,
                    width: 24,
                    
                    child: Checkbox(
                        value: task.status,
                        onChanged: (_) => onToggle(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                        ),
                    ),
                ),

                const SizedBox(width: 12),

                // Display task details
                Expanded(
                    child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: task.status
                                ? Colors.grey[500] // Grey when completed
                                : Colors.grey[900],
                            decoration:
                                task.status ? TextDecoration.lineThrough : null,
                        ),

                        child: Text(task.title),
                    ),
                ),

                // Delete button
                IconButton(
                    icon: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey[400],
                    ),

                    splashRadius: 18,
                    onPressed: onDelete,
                ),
            ],),
        );
    }
}