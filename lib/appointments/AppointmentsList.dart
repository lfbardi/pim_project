import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'AppointmentsDBWorker.dart';
import 'AppointmentsModel.dart' show Appointment, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    EventList<Event> _markedDateMap = EventList();

    for(int i = 0; i < appointmentsModel.entityList.length; i++)  {
      Appointment appointment = appointmentsModel.entityList[i];
      List dateParts = appointment.appDate.split(',');
      DateTime appDate = DateTime(
       int.parse(dateParts[0]),
       int.parse(dateParts[1]),
       int.parse(dateParts[2])
      );

      _markedDateMap.add(appDate, Event(
        date: appDate,
        icon: Container(
          decoration: BoxDecoration(
            color: Colors.blue
          ),
        )
      ));
    }

    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (context, child, model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white,),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();
                DateTime now = DateTime.now();
                appointmentsModel.entityBeingEdited.appDate = '${now.year},${now.month},${now.day}';
                appointmentsModel.setChosenDate(DateFormat.yMMMMd('en_US').format(now.toLocal()));
                appointmentsModel.setAppTime(null);
                appointmentsModel.setStackIndex(1);
              }
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: CalendarCarousel<Event>(
                      thisMonthDayBorderColor: Colors.grey,
                      daysHaveCircularBorder: false,
                      markedDatesMap: _markedDateMap,
                      onDayPressed: (DateTime date, List<Event> events) {
                        _showAppointments(date, context);
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  void _showAppointments(DateTime date, BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ScopedModel<AppointmentsModel>(
          model: appointmentsModel,
          child: ScopedModelDescendant(
            builder: (BuildContext context, Widget child, AppointmentsModel model) {
              return Scaffold(
                body: Container(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      child: Column(
                        children: <Widget>[
                          Text(DateFormat.yMMMMd('en_US').format(date.toLocal()), 
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 24
                            ),
                          ),
                          Divider(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: appointmentsModel.entityList.length,
                              itemBuilder: (BuildContext context, int index) {
                                Appointment appointment = appointmentsModel.entityList[index];
                                
                                if(appointment.appDate != '${date.year},${date.month},${date.day}') return SizedBox( height: 0 );

                                String appTime = '';
                                if(appointment.appTime != null) {
                                  List timeParts = appointment.appTime.split(',');
                                  TimeOfDay at = TimeOfDay(
                                    hour: int.parse(timeParts[0]),
                                    minute: int.parse(timeParts[1])
                                  );

                                  appTime = ' (${at.format(context)})';
                                }

                                return Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.25,
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      color: Colors.grey.shade300,
                                      child: ListTile(
                                        title: Text('${appointment.title}$appTime'),
                                        subtitle: appointment.description == null ? null
                                          : Text('${appointment.description}'),
                                        onTap: () async {
                                          _editAppointment(context, appointment);
                                        },
                                      ),
                                    ),
                                    secondaryActions: <Widget>[
                                      IconSlideAction(
                                        caption: 'Delete',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: () => _deleteAppointment(context, appointment),
                                      )
                                    ],
                                  );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        );
      }
    );
  }

  void _editAppointment(BuildContext context, Appointment appointment) async {
    appointmentsModel.entityBeingEdited = await AppointmentsDBWorker.db.getAppointment(appointment.id);

    if(appointmentsModel.entityBeingEdited.appDate == null) appointmentsModel.setChosenDate(null);
      else {
        List dateParts = appointmentsModel.entityBeingEdited.appDate.split(',');
        DateTime appDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
        appointmentsModel.setChosenDate(DateFormat.yMMMMd('en_US').format(appDate.toLocal()));
      } 
    
    if(appointmentsModel.entityBeingEdited.appTime == null) appointmentsModel.setAppTime(null);
      else {
        List timeParts = appointmentsModel.entityBeingEdited.appTime.split(',');
        TimeOfDay appTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1])
        );
        appointmentsModel.setAppTime(appTime.format(context));
      }
      appointmentsModel.setStackIndex(1);
      Navigator.pop(context);
  }

  void _deleteAppointment(BuildContext context, Appointment appointment) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Appointment'),
          content: Text('Are you sure you want to delete ${appointment.title}?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text('Delete'),
              onPressed: () async {
                await AppointmentsDBWorker.db.deleteAppointment(appointment.id);
                Navigator.of(context).pop();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Appointment deleted')
                  )
                );
                appointmentsModel.loadData('appointments', AppointmentsDBWorker.db);
              },
            )
          ],
        );
      }
    );
  }

}