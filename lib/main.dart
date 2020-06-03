import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pim_project/contacts/Contacts.dart';
import 'appointments/Appointments.dart';
import 'tasks/Tasks.dart';
import 'notes/Notes.dart';
import 'utils.dart' as utils;

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  startMeUp() async {
    Directory directory = await getApplicationDocumentsDirectory();
    utils.directory = directory;
    runApp(PIMProject());
  }
  startMeUp();
}

class PIMProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Flutter Book'),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.date_range),
                  text: 'Appointments',
                ),
                Tab(
                  icon: Icon(Icons.contacts),
                  text: 'Contacts',
                ),
                Tab(
                  icon: Icon(Icons.note),
                  text: 'Notes',
                ),
                Tab(
                  icon: Icon(Icons.assignment_turned_in),
                  text: 'Tasks',
                ),
              ]
            ),
          ),
          body: TabBarView(
            children: [
              Appointments(),
              Contacts(),
              Notes(),
              Tasks()
            ]
          ),
        )
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}