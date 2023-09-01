import 'dart:async';
import 'dart:developer';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Todo implements Comparable {
  final int id;
  final String title;
  final String description;

  Todo(
    this.id,
    this.title,
    this.description,
  );

  @override
  int compareTo(other) => other.compareTo(id);

  @override
  bool operator ==(covariant Todo other) => other.id == id;
  Todo.fromRow(Map<String, dynamic> data)
      : id = data['ID'],
        title = data['TITLE'],
        description = data['DESC'];
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Todo, id: $id, title: $title, title: $title';
}

class TodoDB {
  final String dbName;
  Database? _db;

  List<Todo> _todos = [];
  StreamController<List<Todo>> _streamController =
      StreamController<List<Todo>>.broadcast();
  TodoDB(this.dbName);
  // C in CRUD
  Future<bool> create(String title, String description) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final id = await db.insert('TODOS', {
        'TITLE': title,
        'DESC': description,
      });
      final todo = Todo(
        id,
        title,
        description,
      );
      _todos.add(todo);
      _streamController.add(_todos);
      return true;
    } catch (e) {
      log('Error creating todo $e');
      return false;
    }
  }

// R in CRUD

  Future<bool> delete(Todo todo) async {
    final db = _db;
    if (db == null) {
      return false;
    }

    try {
      final deleteCount = await db.delete(
        'TODOS',
        where: 'ID = ?',
        whereArgs: [todo.id],
      );

      if (deleteCount == 0) {
        _todos.remove(todo);
        _streamController.add(_todos);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('Error deleting todo $e');
      return false;
    }
  }

  // U in CRUD

  Future<bool> update(Todo todo) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final updateCount = await db.update(
          'TODOS',
          {
            'TITLE': todo.title,
            'DESC': todo.description,
          },
          where: 'ID = ?',
          whereArgs: [todo.id]);

      if (updateCount == 1) {
        _todos.removeWhere((element) => element.id == todo.id);
        _todos.add(todo);
        _streamController.add(_todos);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('Error updating todo $e');
      return false;
    }
  }

  Future<List<Todo>> _fetchTodos() async {
    final db = _db;
    if (db == null) {
      return Future.value([]);
    }
    try {
      final read = await db.query(
        'TODOS',
        distinct: true,
        columns: [
          'ID',
          'TITLE',
          'DESC',
        ],
        orderBy: 'ID',
      );

      final todos = read.map((e) => Todo.fromRow(e)).toList();
      return todos;
    } catch (e) {
      log('Error fetching todos $e');
      return Future.value([]);
    }
  }

  Future<bool> close() async {
    final db = _db;
    if (db == null) {
      return false;
    }
    await db.close();
    return true;
  }

  Future<bool> open() async {
    if (_db != null) {
      return true;
    }
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$dbName';

    try {
      final db = await openDatabase(path);
      _db = db;

      // * create table
      final create = '''
        CREATE TABLE IF NOT EXISTS TODOS (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          TITLE STRING NOT NULL,
          DESC STRING NOT NULL
        )''';

      await db.execute(create);
      //  read all existing todo objects
      final todos = await _fetchTodos();
      _todos = todos;
      _streamController.add(_todos);

      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Stream<List<Todo>> all() =>
      _streamController.stream.map((todos) => todos..sort());
}

typedef OnCompose = void Function(String firstName, String lastName);
