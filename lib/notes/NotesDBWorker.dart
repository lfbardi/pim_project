import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'NotesModel.dart';

class NotesDBWorker {

  NotesDBWorker._();

  static final NotesDBWorker db = NotesDBWorker._();

  Database _db;

  Future get database async {
    if(_db == null) {
      _db = await _initDB();
    }
    return _db;
  }

  Future<Database> _initDB() async {
    String path = join(utils.directory.path, 'notes.db');
    Database db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
          'CREATE TABLE IF NOT EXISTS notes ('
          'id INTEGER PRIMARY KEY,'
          'title TEXT,'
          'content TEXT,'
          'color TEXT'
          ')'
        );
      }
    );
    return db;
  }

  Note notefromMap(Map noteMap) {
    Note note = Note();
    note.id = noteMap['id'];
    note.title = noteMap['title'];
    note.content = noteMap['content'];
    note.color = noteMap['color'];
    return note;
  }

  Map<String, dynamic> noteToMap(Note note) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = note.id;
    map['title'] = note.title;
    map['content'] = note.content;
    map['color'] = note.color;
    return map;
  }

  Future<int> createNote(Note newNote) async {
    Database db = await database;
    List<Map<String, dynamic>> notes =  await db.rawQuery(
      'SELECT MAX(id) + 1 AS id FROM notes'
    );
    int id = notes.first['id'];
    if(id == null) id = 1;

    return await db.insert('notes', noteToMap(newNote));

    // return await db.rawInsert(
    //   'INSERT INTO notes (id, title, content, color) '
    //   'values (?, ?, ?, ?)',
    //   [ id, newNote.title, newNote.content, newNote.color ]
    // );
  }

  Future<Note> getNote(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> note = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id]
    );
    return notefromMap(note.first);
  }

  Future<List> getAllNotes() async {
    Database db = await database;
    var notes = await db.query('notes');
    var list = notes.isNotEmpty 
      ? notes.map((note) => notefromMap(note)).toList() 
      : [];
    return list;
  }

  Future<int> updateNote(Note note) async {
    Database db = await database;
    return await db.update(
      'notes', 
      noteToMap(note),
      where: 'id = ?',
      whereArgs: [ note.id ] 
    );
  }

  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [ id ] 
    );
  }

}