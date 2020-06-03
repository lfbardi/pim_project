import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:path/path.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../utils.dart' as utils;
import 'ContactsDBWorker.dart';
import 'ContactsModel.dart' show Contact, ContactsModel, contactsModel;

class ContactsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext context, Widget child, ContactsModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                File avatarFile = File(join(utils.directory.path, "avatar"));
                if(avatarFile.existsSync()) avatarFile.deleteSync();

                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              itemCount: contactsModel.entityList.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = contactsModel.entityList[index];
                File avatarFile = File(join(utils.directory.path, contact.id.toString()));
                bool avatarFilesExists = avatarFile.existsSync();

                return Column(
                  children: <Widget>[
                    Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          backgroundImage: avatarFilesExists ? FileImage(avatarFile) : null,
                          child: avatarFilesExists ? null : Text(contact.name.substring(0, 1).toUpperCase()),
                        ),
                        title: Text("${contact.name}"),
                        subtitle: contact.phone == null ? null : Text("${contact.phone}"),
                        onTap: () async {
                          File avatarFile = File(join(utils.directory.path, "avatar"));
                          if (avatarFile.existsSync()) avatarFile.deleteSync();
                          
                          contactsModel.entityBeingEdited = await ContactsDBWorker.db.getContact(contact.id);
                          if (contactsModel.entityBeingEdited.birthday == null) contactsModel.setChosenDate(null);
                            else {
                              List dateParts = contactsModel.entityBeingEdited.birthday.split(",");
                              DateTime birthday = DateTime(
                                int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])
                              );
                              contactsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(birthday.toLocal()));
                          }
                          contactsModel.setStackIndex(1);
                        },
                      ),
                      secondaryActions: <Widget>[
                         IconSlideAction(
                          caption : "Delete",
                          color : Colors.red,
                          icon : Icons.delete,
                          onTap : () => _deleteContact(context, contact)
                        )
                      ],
                    ),
                    Divider()
                  ],
                );
              }
            ),
          );
        }
      ),
    );
  }

  Future _deleteContact(BuildContext context, Contact contact) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: Text('Delete Contact'),
          content: Text('Are you sure you want to delete ${contact.name}?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(alertContext).pop(),
            ),
            FlatButton(
              child: Text('Delete'),
              onPressed: () async {
                File avatarFile = File(join(utils.directory.path, contact.id.toString()));
                if(avatarFile.existsSync()) avatarFile.deleteSync();

                await ContactsDBWorker.db.deleteContact(contact.id);
                Navigator.of(alertContext).pop();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Contact deleted"),
                  )
                );
                contactsModel.loadData('contacts', ContactsDBWorker.db);
              },
            )
          ],
        );
      }
    );
  }

}