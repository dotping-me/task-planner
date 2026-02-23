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
        runApp(const TaskPlanner());

    } catch (e, st) {
        print('DB Init error: $e\n$st');
    }
}

class TaskPlanner extends StatelessWidget {
    const TaskPlanner({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Task Planner',
            theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
            home: const HomePage(),
        );
    }
}