import 'package:pim_project/BaseModel.dart';

class Appointment {
  int id;
  String title;
  String description;
  String appDate;
  String appTime;

  String toString() {
    return "{ id=$id, title=$title, description=$description, appDate=$appDate, appTime=$appTime }";
  }
}

class AppointmentsModel extends BaseModel {
  String appTime;
  
  void setAppTime(String _appTime) { 
    appTime = _appTime;
    notifyListeners();
  }

}

AppointmentsModel appointmentsModel = AppointmentsModel();