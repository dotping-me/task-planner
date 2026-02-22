import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'sql.dart';
import 'package:taskplanner/model/category.dart';
import 'package:taskplanner/model/task.dart';

class Db {
    static Database? _db;
    static const String dbName = "taskplanner.db";

    // Returns an instance of the database
    static Future<Database> get database async {
        if (_db != null) return _db!;

        _db = await initDB();
        return _db!;
    }

    // Creates a new database if one doesn't already exist
    static Future<Database> initDB() async {
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, dbName);
        print("DB PATH: $path");

        // Creates the database
        return await openDatabase(path, version: 1, 
            onCreate: (db, version) async {
                await db.execute(createCategoryTable);
                await db.execute(createTaskTable);
            },

            onOpen: (db) async {
                await db.execute("PRAGMA foreign_keys = ON;");
            }
        );
    }

    // ----------------------------------------------
    //   Handlers for different database operations
    // ----------------------------------------------

    // Insert a category
    static Future<int> insertCategory(Category cat) async {
        final db = await database;
        final id = await db.insert('Category', cat.toMap());

        print("Inserted category: ${cat.name}, id=$id");

        return id;
    }

    // Delete a category
    static Future<int> deleteCategory(int id) async {
        final db = await database;
        return await db.delete(
            'Category',
            where: 'ID = ?',
            whereArgs: [id],
        );
    }

    // Insert a task
    static Future<int> insertTask(Task task) async {
        final db = await database;
        return await db.insert('Task', task.toMap(),);
    }

    // Toggle the status of a task (from 'Pending' to 'Completed', and vice-versa)
    static Future<int> toggleTaskStatus(Task task) async {
        final db = await database;
        return await db.update(
            'Task',
            task.toMap(),
            where: 'ID = ?',
            whereArgs: [task.id],
        );
    }

    // Delete a task
    static Future<int> deleteTask(int id) async {
        final db = await database;
        return await db.delete('Task', where: 'ID = ?', whereArgs: [id],);
    }

    // Get all tasks for a category
    static Future<List<Task>> getTasksByCategory(int? categoryId) async {
        final db = await database;
        final data = await db.query(
            'Task',
            where: categoryId == null ? 'Category IS NULL' : 'Category = ?',
            whereArgs: categoryId == null ? null : [categoryId],
        );

        return data.map((e) => Task.fromMap(e)).toList();
    }

    // Get subcategories
    static Future<List<Category>> getSubcategories(int? parentId) async {
        final db = await database;
        final data = await db.query(
            'Category',
            where: parentId == null ? 'Parent IS NULL' : 'Parent = ?',
            whereArgs: parentId == null ? null : [parentId],
        );
        
        return data.map((e) => Category.fromMap(e)).toList();
    }

    // Breadcrumbs for easier navigation
    static Future<List<Category>> getBreadcrumbs(int? categoryId) async {
        List<Category> trail = [];
        int? currentId = categoryId; // Can be Null

        while (currentId != null) {
            final db = await database;
            final data = await db.query(
                'Category',
                where: 'ID = ?',
                whereArgs: [currentId],
            );

            if (data.isEmpty) break; // Breadcrumbs end here...

            // Gets the parent of this category
            final cat = Category.fromMap(data.first);
            trail.insert(0, cat);
            currentId = cat.parent; // Iterates again but targets parent of this parent category
        }

        return trail;
    }
}