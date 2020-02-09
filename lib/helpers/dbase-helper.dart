import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/notes.dart';

class DbaseHelper {
  static DbaseHelper _dbaseHelper;
  static Database _dbase;

  DbaseHelper._createInstance();

  String noteTable = 'NoteTable';
  String colId = 'Id';
  String colTitle = 'Title';
  String colDescription = 'Description';
  String colPriority = 'Priority';
  String colDate = 'Date';

  factory DbaseHelper() {
    if (_dbaseHelper == null) {
      _dbaseHelper = DbaseHelper._createInstance();
    }
    return _dbaseHelper;
  }

  Future<Database> get dbase async {
    if (_dbase == null) {
      _dbase = await initializeDbase();
    }
    return _dbase;
  }

  Future<Database> initializeDbase() async {
    //Get application directory
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'notes.db';

    // Open / create dbase
    Database notesDbase =
        await openDatabase(path, version: 1, onCreate: _createDb);

    return notesDbase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,' +
            '$colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate' +
            ' TEXT)');
  }

  Future<List<Map<String, dynamic>>> getallNotes() async {
    Database db = await dbase;

    List<Map<String, dynamic>> result =
        await db.query(noteTable, orderBy: '$colPriority ASC');

    return result;
  }

  Future<int> insert(Note note) async {
    Database db = await dbase;
    int result = await db.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> update(Note note) async {
    Database db = await dbase;
    int result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);

    return result;
  }

  Future<int> delete(int id) async {
    Database db = await dbase;
    int result =
        await db.delete(noteTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  Future<int> countAllNotes() async {
    Database db = await dbase;
    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int resultCount = Sqflite.firstIntValue(result);
    return resultCount;
  }

  Future<List<Note>> getNoteList() async {
    List<Map<String, dynamic>> noteMap = await getallNotes();
    int count = noteMap.length;

    List<Note> noteList = List<Note>();

    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMap[i]));
    }

    return noteList;
  }
}
