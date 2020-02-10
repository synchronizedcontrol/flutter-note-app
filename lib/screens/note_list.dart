import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:stateful_app/screens/note_detail.dart';
import 'package:stateful_app/helpers/dbase-helper.dart';
import 'package:stateful_app/models/notes.dart';

class NoteList extends StatefulWidget {
  NoteList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DbaseHelper dbh = DbaseHelper();
  List<Note> noteList;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToDetail(Note('', 2, ''), 'Add note');
          },
          tooltip: 'Add note',
          child: Icon(Icons.add)),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          Map<String, dynamic> setItems =
              getPriorityLayout(this.noteList[position].priority);
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: setItems['color'],
                child: setItems['icon'],
              ),
              title: Text(this.noteList[position].title, style: titleStyle),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                child: Icon(Icons.delete, color: Colors.grey),
                onTap: () {
                  _deleteNote(context, noteList[position].id);
                },
              ),
              onTap: () {
                navigateToDetail(this.noteList[position], 'Edit note');
              },
            ),
          );
        });
  }

  void navigateToDetail(Note note, String title) async {
    bool reloadList =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));
    if (reloadList) {
      updateListView();
    }
  }

  Map<String, dynamic> getPriorityLayout(int prio) {
    Map<String, dynamic> map = Map<String, dynamic>();
    switch (prio) {
      case 1:
        map['color'] = Colors.red;
        map['icon'] = Icon(Icons.play_arrow);
        break;
      case 2:
        map['color'] = Colors.yellow;
        map['icon'] = Icon(Icons.keyboard_arrow_right);
        break;
      default:
        map['color'] = Colors.yellow;
        map['icon'] = Icon(Icons.keyboard_arrow_right);
    }

    return map;
  }

  void _deleteNote(BuildContext context, int id) async {
    int res = await dbh.delete(id);
    if (res > 0) {
      _showSnackbar(context, 'Note deleted succesfully');
      updateListView();
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() async {
    final Future<Database> dbFuture = dbh.initializeDbase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = dbh.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
