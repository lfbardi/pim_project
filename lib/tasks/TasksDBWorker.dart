import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'TasksModel.dart';

class TasksDBWorker {

  TasksDBWorker._();

  static final TasksDBWorker db = TasksDBWorker._();

  Database _db;

  Future get database async {
    if(_db == null) {
      _db = await _initDB();
    }
    return _db;
  }

  Future<Database> _initDB() async {
    String path = join(utils.directory.path, 'tasks.db');
    Database db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
          'CREATE TABLE IF NOT EXISTS tasks ('
          'id INTEGER PRIMARY KEY,'
          'description TEXT,'
          'dueDate TEXT,'
          'completed TEXT'
          ')'
        );
      }
    );
    return db;
  }

  Task taskfromMap(Map taskMap) {
    Task task = Task();
    task.id = taskMap['id'];
    task.description = taskMap['description'];
    task.dueDate = taskMap['dueDate'];
    task.completed = taskMap['completed'];
    return task;
  }

  Map<String, dynamic> taskToMap(Task task) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = task.id;
    map['description'] = task.description;
    map['dueDate'] = task.dueDate;
    map['completed'] = task.completed;
    return map;
  }

  Future<int> createTask(Task newTask) async {
    Database db = await database;
    List<Map<String, dynamic>> tasks =  await db.rawQuery(
      'SELECT MAX(id) + 1 AS id FROM tasks'
    );
    int id = tasks.first['id'];
    if(id == null) id = 1;

    return await db.insert('tasks', taskToMap(newTask));

    // return await db.rawInsert(
    //   'INSERT INTO tasks (id, description, dueDate, completed) '
    //   'values (?, ?, ?, ?)',
    //   [ id, newTask.description, newTask.dueDate, newTask.completed ]
    // );
  }

  Future<Task> getTask(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> task = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id]
    );
    return taskfromMap(task.first);
  }

  Future<List> getAllTasks() async {
    Database db = await database;
    var tasks = await db.query('tasks');
    var list = tasks.isNotEmpty 
      ? tasks.map((task) => taskfromMap(task)).toList() 
      : [];
    return list;
  }

  Future<int> updateTask(Task task) async {
    Database db = await database;
    return await db.update(
      'tasks', 
      taskToMap(task),
      where: 'id = ?',
      whereArgs: [ task.id ] 
    );
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [ id ] 
    );
  }

}