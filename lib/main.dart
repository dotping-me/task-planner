import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/home_page.dart';
import 'package:taskplanner/db/db.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
        // For Linux / Windows / macOS
        if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
        }
        
        await Db.database; // Creates DB

        final username = await Db.getUsername();
        runApp(TaskPlanner(initialUsername: username));

    } catch (e, st) {

        // Error State
        runApp(MaterialApp(
            home: Scaffold(
                body: Center(child: Text('DB Init error: $e\n$st')),
            ),
        ));
    }
}

class TaskPlanner extends StatelessWidget {
    final String? initialUsername;
    const TaskPlanner({super.key, this.initialUsername});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Task Planner',

            // Add switchable themes later? I don't know
            // theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),

            home: HomePage(initialUsername: initialUsername),
        );
    }
}