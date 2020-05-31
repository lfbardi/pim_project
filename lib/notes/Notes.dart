import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'NotesDBWorker.dart';
import 'NotesList.dart';
import 'NotesEntry.dart';
import 'NotesModel.dart' show NotesModel, notesModel;

class Notes extends StatelessWidget {

  Notes() {
    notesModel.loadData('notes', NotesDBWorker.db);
  } 

  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget child, NotesModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[
              NotesList(),
              NotesEntry()
            ],
          );
        }
      ),
    );
  }
}