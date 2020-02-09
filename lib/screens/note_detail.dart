import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:stateful_app/helpers/dbase-helper.dart';
import 'package:stateful_app/models/notes.dart';

class NoteDetail extends StatefulWidget {
  final String appbarTitle;
  final Note note;

  NoteDetail(this.note, this.appbarTitle);

  @override
  _NoteDetailState createState() => _NoteDetailState(note, appbarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  String appbarTitle;
  Note note;
  _NoteDetailState(this.note, this.appbarTitle);
  DbaseHelper dbh = DbaseHelper();
  static List<String> _priorities = ['high', 'low'];
  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle _ts = Theme.of(context).textTheme.title;

    titleCtrl.text = note.title;
    descriptionCtrl.text = note.description;

    return WillPopScope(
        onWillPop: () async {
          return new Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(this.appbarTitle),
            leading: IconButton(
                onPressed: () {
                  moveToLastScreen();
                },
                icon: Icon(Icons.arrow_back)),
          ),
          body: Padding(
            padding: EdgeInsets.only(
              top: 15.0,
              left: 10.0,
              right: 10.0,
            ),
            child: ListView(children: <Widget>[
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  style: _ts,
                  value: getPriorityToString(note.priority),
                  onChanged: (val) {
                    setState(() {
                      updatePriorityToInt(val);
                    });
                  },
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleCtrl,
                    style: _ts,
                    onChanged: (val) {
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: _ts,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptionCtrl,
                    style: _ts,
                    onChanged: (val) {
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: _ts,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  )),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text(
                        'Save',
                        textScaleFactor: 1.5,
                      ),
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      onPressed: () {
                        setState(() {
                          _save();
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 5.0,
                  ),
                  Expanded(
                    child: RaisedButton(
                      child: Text(
                        'Delete',
                        textScaleFactor: 1.5,
                      ),
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      onPressed: () {
                        setState(() {
                          _delete();
                        });
                      },
                    ),
                  )
                ]),
              )
            ]),
          ),
        ));
  }

  bool moveToLastScreen() {
    return Navigator.of(context).pop(true);
  }

  void updatePriorityToInt(String val) {
    switch (val) {
      case "high":
        note.priority = 1;
        break;
      case "low":
        note.priority = 2;
        break;
    }
  }

  String getPriorityToString(int val) {
    String prio;
    switch (val) {
      case 1:
        prio = _priorities[0];
        break;
      case 2:
        prio = _priorities[1];
        break;
    }

    return prio;
  }

  void updateTitle() {
    note.title = titleCtrl.text;
  }

  void updateDescription() {
    note.description = descriptionCtrl.text;
  }

  void _save() async {
    moveToLastScreen();
    String date = DateFormat.yMMMd().format(DateTime.now());
    note.date = date;
    int res;
    if (note.id != null) {
      res = await dbh.update(note);
    } else {
      res = await dbh.insert(note);
    }

    if (res > 0) {
      _showAlertDialog('Status', 'Note has been succesfully saved');
    } else {
      _showAlertDialog('Status', 'there was a problem saving your note.');
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (note.id == null) {
      _showAlertDialog('Status', 'No note was deleted');
      return;
    }

    int result = await dbh.delete(note.id);

    if (result > 0) {
      _showAlertDialog('Status', 'Note was sucesfully deleted');
    } else {
      _showAlertDialog(
          'Status', 'Something went wrong while deleting your note.');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog ad = AlertDialog(title: Text(title), content: Text(message));
    showDialog(context: context, builder: (_) => ad);
  }
}
