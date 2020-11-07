import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/models/todo.dart';

import 'models/task.dart';

class DatabaseHelper{
    Future<Database> database()async{
      return openDatabase(
          join(await getDatabasesPath(), 'todo.db'),
        onCreate: (db, version) async {
          // Run the CREATE TABLE statement on the database.
          await db.execute("CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, description  TEXT)",);
          await db.execute("CREATE TABLE todo(id INTEGER PRIMARY KEY,taskId INTEGER, title TEXT, isDone  INTEGER)",);

          return db;
        },
        version: 1,
      );
    }
    //for insert task
    Future<int> insertTask(Task task) async{
      int taskId = 0;
        Database _db = await database();
        await _db.insert('tasks', task.toMap(),conflictAlgorithm: ConflictAlgorithm.replace).then((value) {
          taskId = value;
        });

        return taskId;
    }

    Future<void> UpdateTaskTitle(int id, String title) async {
      Database _db = await database();
      await _db.rawUpdate("UPDATE tasks SET title = '$title' WHERE id =  '$id'");
    }
    Future<void> UpdateTaskDescription(int id, String description) async {
      Database _db = await database();
      await _db.rawUpdate("UPDATE tasks SET description = '$description' WHERE id =  '$id'");
    }
    // for insert TODOo
    Future<void> insertTodo(Todo todo) async{
      Database _db = await database();
      await _db.insert('todo', todo.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
    }

    Future<List<Task>> getTasks() async {
      Database _db = await database();
      List<Map<String, dynamic>> taskMap = await _db.query('tasks');
      return List.generate(taskMap.length,(index) {
        return Task(id: taskMap[index]['id'], title: taskMap[index]['title'],description: taskMap[index]['description']);
      });
    }
    Future<List<Todo>> getTodo(int taskId) async {
      Database _db = await database();
      List<Map<String, dynamic>> TodoMap = await _db.rawQuery("SELECT * FROM todo WHERE  taskId = $taskId");
      return List.generate(TodoMap.length,(index) {
        return Todo(id: TodoMap[index]['id'], title: TodoMap[index]['title'], taskId: TodoMap[index]['taskId'], isDone: TodoMap[index]['isDone']);
      });
    }

    Future<void> UpdateTodoDone(int id, int isDone) async {
      Database _db = await database();
      await _db.rawUpdate("UPDATE todo  SET isDone = '$isDone' WHERE id =  '$id'");
    }

    Future<void> deleteTask(int id,) async {
      Database _db = await database();
      await _db.rawDelete("DELETE FROM tasks  WHERE id =  '$id'");
      await _db.rawDelete("DELETE FROM todo WHERE taskId = '$id'");
    }
}