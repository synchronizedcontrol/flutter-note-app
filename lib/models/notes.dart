//Class model for Note

class Note {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  Note(this._date, this._priority, this._title, [this._description]);

  Note.withId(this._id, this._date, this._priority, this._title,
      [this._description]);

  int get id => _id;
  String get title => _title;
  String get description => _description;
  String get date => _date;
  int get priority => _priority;

  set title(String newTitle) {
    if (newTitle.isNotEmpty && newTitle.length < 100) {
      _title = newTitle;
    } else {
      throw new Error();
    }
  }

  set description(String newDesc) {
    if (newDesc.isNotEmpty) _description = newDesc;
  }

  set date(String newDate) {
    _date = newDate;
  }

  set priority(int prio) {
    if (prio >= 1 && prio <= 2) _priority = prio;
  }

  //For mapping purposes

  Map<String, dynamic> toMap() {
    Map map = <String, dynamic>{};
    if (id != null) {
      map['id'] = _id;
    }

    map['title'] = _title;
    map['description'] = _description;
    map['date'] = _date;
    map['priority'] = _priority;

    return map;
  }

  // Constructor function to extract Note object from map

  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._date = map['date'];
    this._priority = map['priority'];
  }
}
