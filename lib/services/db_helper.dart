import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sql_lite_app/model/task.dart';

class DbHelper {
  static Database _db;
  static const String DbName = 'todo.db';
  static const String Table = 'todo';
  static const String ID = 'id';
  static const String description = 'description';

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $Table ($ID INTEGER PRIMARY KEY, $description TEXT)");
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DbName);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  Future<Task> save(Task t) async {
    var dbClient = await db;
    t.id = await dbClient.insert(Table, t.toMap());
    return t;

//    await dbClient.transtion((txn) async {
//      var query = "INSERT INTO $TABLE ($NAME) values('"+$t.description+"')";
//      return await tnx.rawInsert(query);
//    });
  }

  Future<List<Task>> getTasks() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(Table, columns: [ID, description]);
//    List<Map> maps = await dbClient.rawQuery("SELECT * FROM $Table");
    List<Task> tasks = [];
    if (maps.length > 0)
      for (int i = 0; i < maps.length; i++) tasks.add(Task.fromMap(maps[i]));
    return tasks;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(Table, where: 'ID = ?', whereArgs: [id]);
  }

  Future<int> update(Task t) async {
    var dbClient = await db;
    return await dbClient
        .update(Table, t.toMap(), where: 'ID = ?', whereArgs: [t.id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
