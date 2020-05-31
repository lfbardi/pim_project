import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'NotesDBWorker.dart';
import 'NotesModel.dart' show NotesModel, notesModel;

class NotesEntry extends StatelessWidget {
  NotesEntry() {
    _titleController.addListener(() {
      notesModel.entityBeingEdited.title = _titleController.text;
    });

    _contentController.addListener(() {
      notesModel.entityBeingEdited.content = _contentController.text;
    });
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _titleController.text = notesModel.entityBeingEdited.title;
    _contentController.text = notesModel.entityBeingEdited.content;

    return ScopedModel<NotesModel>(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
            builder: (BuildContext context, Widget child, NotesModel model) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: <Widget>[
                  FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        model.setStackIndex(0);
                      }),
                  Spacer(),
                  FlatButton(
                    child: Text('Save'),
                    onPressed: () => _saveNote(context, notesModel),
                  )
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.title),
                    title: TextFormField(
                        decoration: InputDecoration(hintText: 'Title'),
                        controller: _titleController,
                        validator: (value) {
                          if (value.length == 0) {
                            return 'Please enter a title';
                          }
                          return null;
                        }),
                  ),
                  ListTile(
                    leading: Icon(Icons.content_paste),
                    title: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 8,
                        decoration: InputDecoration(hintText: 'Content'),
                        controller: _contentController,
                        validator: (value) {
                          if (value.length == 0) {
                            return 'Please enter a content';
                          }
                          return null;
                        }),
                  ),
                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Row(
                      children: <Widget>[
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                                shape: Border.all(
                                        width: 18, color: Colors.red) +
                                    Border.all(
                                        width: 6,
                                        color: notesModel.color == 'red'
                                            ? Colors.red
                                            : Theme.of(context).canvasColor)),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'red';
                            notesModel.setColor('red');
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                                shape: Border.all(
                                        width: 18, color: Colors.green) +
                                    Border.all(
                                        width: 6,
                                        color: notesModel.color == 'green'
                                            ? Colors.green
                                            : Theme.of(context).canvasColor)),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'green';
                            notesModel.setColor('green');
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                                shape: Border.all(
                                        width: 18, color: Colors.blue) +
                                    Border.all(
                                        width: 6,
                                        color: notesModel.color == 'blue'
                                            ? Colors.blue
                                            : Theme.of(context).canvasColor)),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'blue';
                            notesModel.setColor('blue');
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                                shape: Border.all(
                                        width: 18, color: Colors.yellow) +
                                    Border.all(
                                        width: 6,
                                        color: notesModel.color == 'yellow'
                                            ? Colors.yellow
                                            : Theme.of(context).canvasColor)),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'yellow';
                            notesModel.setColor('yellow');
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                                shape: Border.all(
                                        width: 18, color: Colors.grey) +
                                    Border.all(
                                        width: 6,
                                        color: notesModel.color == 'grey'
                                            ? Colors.grey
                                            : Theme.of(context).canvasColor)),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'grey';
                            notesModel.setColor('grey');
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                                shape: Border.all(
                                        width: 18, color: Colors.purple) +
                                    Border.all(
                                        width: 6,
                                        color: notesModel.color == 'purple'
                                            ? Colors.purple
                                            : Theme.of(context).canvasColor)),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'purple';
                            notesModel.setColor('purple');
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }));
  }

  void _saveNote(BuildContext context, NotesModel model) async {
    if(!_formKey.currentState.validate()) return;

    if(model.entityBeingEdited.id == null) {
      await NotesDBWorker.db.createNote(notesModel.entityBeingEdited);
    } else {
      await NotesDBWorker.db.updateNote(notesModel.entityBeingEdited);
    }

    notesModel.loadData('notes', NotesDBWorker.db);

    model.setStackIndex(0);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text('Note saved'),
      )
    );
  }
}
