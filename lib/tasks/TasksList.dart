import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'TasksDBWorker.dart';
import 'TasksModel.dart' show Task, TasksModel, tasksModel;


class TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext context, Widget child, TasksModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                tasksModel.entityBeingEdited = Task();
                tasksModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              itemCount: tasksModel.entityList.length,
              itemBuilder: (BuildContext context, int index) {
                Task task = tasksModel.entityList[index];
                String sDueDate;
                if (task.dueDate != null) {
                  List dateParts = task.dueDate.split(',');
                  DateTime dueDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
                  sDueDate = DateFormat.yMMMMd('en_US').format(dueDate.toLocal());
                }
                return Slidable(
                  actionExtentRatio: 0.25,
                  actionPane: SlidableDrawerActionPane(),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.completed == 'true' ? true : false,
                      onChanged: (value) async {
                        task.completed = value.toString();
                        await TasksDBWorker.db.updateTask(task);
                        tasksModel.loadData('tasks', TasksDBWorker.db);
                      }
                    ),
                    title: Text('${task.description}', style: task.completed == 'true' ? TextStyle(
                      color: Theme.of(context).disabledColor,
                      decoration: TextDecoration.lineThrough
                    ) : TextStyle(
                        color: Theme.of(context).textTheme.headline6.color
                      )
                    ),
                    subtitle: task.dueDate == null ? null :
                      Text(sDueDate, style: task.completed == 'true' ? TextStyle(
                        color: Theme.of(context).disabledColor,
                        decoration: TextDecoration.lineThrough
                      ) : TextStyle(
                        color: Theme.of(context).textTheme.headline6.color
                      )),
                      onTap: () async {
                        if (task.completed == 'true') return;

                        tasksModel.entityBeingEdited = await TasksDBWorker.db.getTask(task.id);

                        if (tasksModel.entityBeingEdited.dueDate == null) tasksModel.setChosenDate(null);
                          else tasksModel.setChosenDate(sDueDate);

                        tasksModel.setStackIndex(1);
                      },
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => _deleteTask(context, task),
                    )
                  ],
                );
              }
            ),
          );
        }
      ),
    );
  }

  Future _deleteTask(BuildContext context, Task task) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete ${task.description}?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text('Delete'),
              onPressed: () async {
                await TasksDBWorker.db.deleteTask(task.id);
                Navigator.of(context).pop();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Task deleted')
                  )
                );
                tasksModel.loadData('tasks', TasksDBWorker.db);
              },
            )
          ],
        );
      }
    );
  }

}