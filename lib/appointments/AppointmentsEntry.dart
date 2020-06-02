import "dart:async";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "../utils.dart" as utils;
import "AppointmentsDBWorker.dart";
import "AppointmentsModel.dart" show AppointmentsModel, appointmentsModel;

class AppointmentsEntry extends StatelessWidget {

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry() {
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.description = _descriptionEditingController.text;
    });

  }

  Widget build(BuildContext context) {

    if (appointmentsModel.entityBeingEdited != null) {
      _titleEditingController.text = appointmentsModel.entityBeingEdited.title;
      _descriptionEditingController.text = appointmentsModel.entityBeingEdited.description;
    }

    return ScopedModel(
      model : appointmentsModel,
      child : ScopedModelDescendant<AppointmentsModel>(
        builder : (BuildContext context, Widget child, AppointmentsModel model) {
          return Scaffold(
            bottomNavigationBar : Padding(
              padding : EdgeInsets.symmetric(vertical : 0, horizontal : 10),
              child : Row(
                children : [
                  FlatButton(
                    child : Text("Cancel"),
                    onPressed : () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      model.setStackIndex(0);
                    }
                  ),
                  Spacer(),
                  FlatButton(
                    child : Text("Save"),
                    onPressed : () => _saveAppointment(context, appointmentsModel) 
                  )
                ]
              )
            ),
            body : Form(
              key : _formKey,
              child : ListView(
                children : [
                  ListTile(
                    leading : Icon(Icons.subject),
                    title : TextFormField(
                      decoration : InputDecoration(hintText : "Title"),
                      controller : _titleEditingController,
                      validator : (String inValue) {
                        if (inValue.length == 0) return "Please enter a title"; 
                        return null;
                      }
                    )
                  ),
                  ListTile(
                    leading : Icon(Icons.description),
                    title : TextFormField(
                      keyboardType : TextInputType.multiline,
                      maxLines : 4,
                      decoration : InputDecoration(hintText : "Description"),
                      controller : _descriptionEditingController
                    )
                  ),
                  ListTile(
                    leading : Icon(Icons.today),
                    title : Text("Date"),
                    subtitle : Text(appointmentsModel.chosenDate == null ? "" : appointmentsModel.chosenDate),
                    trailing : IconButton(
                      icon : Icon(Icons.edit),
                      color : Colors.blue,
                      onPressed : () async {
                        String chosenDate = await utils.selectDate(
                          context: context,
                          model: appointmentsModel,
                          dateString: appointmentsModel.entityBeingEdited.appDate,
                        );
                        if (chosenDate != null) {
                          appointmentsModel.entityBeingEdited.appDate = chosenDate;
                        }
                      }
                    )
                  ),
                  ListTile(
                    leading : Icon(Icons.alarm),
                    title : Text("Time"),
                    subtitle : Text(appointmentsModel.appTime == null ? "" : appointmentsModel.appTime),
                    trailing : IconButton(
                      icon : Icon(Icons.edit),
                      color : Colors.blue,
                      onPressed : () => _selectTime(context)
                    )
                  )
                ]
              )
            )
          );
        }
      )
    );
  } 

  Future _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();

    if (appointmentsModel.entityBeingEdited.appTime != null) {
      List timeParts = appointmentsModel.entityBeingEdited.appTime.split(",");
      initialTime = TimeOfDay(hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1]));
    }

    TimeOfDay picked = await showTimePicker(context : context, initialTime : initialTime);

    if (picked != null) {
      appointmentsModel.entityBeingEdited.appTime = "${picked.hour},${picked.minute}";
      appointmentsModel.setAppTime(picked.format(context));
    }
  }

  void _saveAppointment(BuildContext inContext, AppointmentsModel inModel) async {
    if (!_formKey.currentState.validate()) return;


    if (inModel.entityBeingEdited.id == null) await AppointmentsDBWorker.db.createAppointment(appointmentsModel.entityBeingEdited);
      else await AppointmentsDBWorker.db.updateAppointment(appointmentsModel.entityBeingEdited);

    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
    inModel.setStackIndex(0);

    Scaffold.of(inContext).showSnackBar(
      SnackBar(
        backgroundColor : Colors.green,
        duration : Duration(seconds : 2),
        content : Text("Appointment saved")
      )
    );
  }
}
