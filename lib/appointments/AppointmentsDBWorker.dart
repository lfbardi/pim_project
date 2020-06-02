import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'AppointmentsModel.dart';

class AppointmentsDBWorker {

  AppointmentsDBWorker._();

  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  Database _db;

  Future get database async {
    if(_db == null) {
      _db = await _initDB();
    }
    return _db;
  }

  Future<Database> _initDB() async {
    String path = join(utils.directory.path, 'appointments.db');
    Database db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
          'CREATE TABLE IF NOT EXISTS appointments ('
          'id INTEGER PRIMARY KEY,'
          'title TEXT,'
          'description TEXT,'
          'appDate TEXT,'
          'appTime TEXT'
          ')'
        );
      }
    );
    return db;
  }

  Appointment appointmentFromMap(Map appointmentMap) {
    Appointment appointment = Appointment();
    appointment.id = appointmentMap['id'];
    appointment.title = appointmentMap['title'];
    appointment.description = appointmentMap['description'];
    appointment.appDate = appointmentMap['appDate'];
    appointment.appTime = appointmentMap['appTime'];
    return appointment;
  }

  Map<String, dynamic> appointmentToMap(Appointment appointment) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = appointment.id;
    map['title'] = appointment.title;
    map['description'] = appointment.description;
    map['appDate'] = appointment.appDate;
    map['appTime'] = appointment.appTime;
    return map;
  }

  Future<int> createAppointment(Appointment newAppointment) async {
    Database db = await database;
    List<Map<String, dynamic>> appointments =  await db.rawQuery(
      'SELECT MAX(id) + 1 AS id FROM appointments'
    );
    int id = appointments.first['id'];
    if(id == null) id = 1;

    return await db.insert('appointments', appointmentToMap(newAppointment));
  }

  Future<Appointment> getAppointment(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> appointments = await db.query(
      'appointments',
      where: 'id = ?',
      whereArgs: [id]
    );
    return appointmentFromMap(appointments.first);
  }

  Future<List> getAllAppointments() async {
    Database db = await database;
    var appointments = await db.query('appointments');
    var list = appointments.isNotEmpty 
      ? appointments.map((appointment) => appointmentFromMap(appointment)).toList() 
      : [];
    return list;
  }

  Future<int> updateAppointment(Appointment appointment) async {
    Database db = await database;
    return await db.update(
      'appointments', 
      appointmentToMap(appointment),
      where: 'id = ?',
      whereArgs: [ appointment.id ] 
    );
  }

  Future<int> deleteAppointment(int id) async {
    Database db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [ id ] 
    );
  }

}