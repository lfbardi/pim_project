import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import "../utils.dart" as utils;
import 'TasksDBWorker.dart';
import 'TasksModel.dart' show TasksModel, tasksModel;

class TasksEntry extends StatelessWidget {
  TasksEntry() {
   _descriptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
  }
  
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    if (tasksModel.entityBeingEdited != null) {
      _descriptionEditingController.text = tasksModel.entityBeingEdited.description;
    }

    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
            builder: (BuildContext context, Widget child, TasksModel model) {
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
                    onPressed: () => _saveTask(context, tasksModel),
                  )
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                        decoration: InputDecoration(hintText: 'Description'),
                        controller: _descriptionEditingController,
                        validator: (value) {
                          if (value.length == 0) return 'Please enter a description';

                          return null;
                        }),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text('Due Date'),
                    subtitle: Text(tasksModel.chosenDate == null ? '' : tasksModel.chosenDate),
                    trailing: IconButton(
                      icon: Icon(Icons.edit), color: Colors.blue,
                      onPressed: () async {
                        String chosenDate = await utils.selectDate(
                          context: context,
                          model: tasksModel,
                          dateString: tasksModel.entityBeingEdited.dueDate
                        );
                        if (chosenDate != null) tasksModel.entityBeingEdited.dueDate = chosenDate;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Row(
                      children: <Widget>[
                        
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }));
  }

  void _saveTask(BuildContext context, TasksModel model) async {
    if(!_formKey.currentState.validate()) return;

    if(model.entityBeingEdited.id == null) {
      await TasksDBWorker.db.createTask(tasksModel.entityBeingEdited);
    } else {
      await TasksDBWorker.db.updateTask(tasksModel.entityBeingEdited);
    }

    tasksModel.loadData('tasks', TasksDBWorker.db);

    model.setStackIndex(0);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text('Task saved'),
      )
    );
  }
}
