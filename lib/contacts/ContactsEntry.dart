import "dart:async";
import "dart:io";
import "package:flutter/material.dart";
import "package:path/path.dart";
import "package:scoped_model/scoped_model.dart";
import "package:image_picker/image_picker.dart";
import "../utils.dart" as utils;
import "ContactsDBWorker.dart";
import "ContactsModel.dart" show ContactsModel, contactsModel;

class ContactsEntry extends StatelessWidget {

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry() {
    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
    _emailEditingController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });

  }

  Widget build(BuildContext context) {
    if (contactsModel.entityBeingEdited != null) {
      _nameEditingController.text = contactsModel.entityBeingEdited.name;
      _phoneEditingController.text = contactsModel.entityBeingEdited.phone;
      _emailEditingController.text = contactsModel.entityBeingEdited.email;
    }

    return ScopedModel(
      model : contactsModel,
      child : ScopedModelDescendant<ContactsModel>(
        builder : (BuildContext context, Widget child, ContactsModel model) {
          File avatarFile = File(join(utils.directory.path, "avatar"));
          if (!avatarFile.existsSync()) {
            if (model.entityBeingEdited != null && model.entityBeingEdited.id != null) {
              avatarFile = File(join(utils.directory.path, model.entityBeingEdited.id.toString()));
            }
          }
          return Scaffold(
            bottomNavigationBar : Padding(
            padding : EdgeInsets.symmetric(vertical : 0, horizontal : 10),
            child : Row(
              children : [
                FlatButton(
                  child : Text("Cancel"),
                  onPressed : () {
                    File avatarFile = File(join(utils.directory.path, "avatar"));
                    if (avatarFile.existsSync()) {
                      avatarFile.deleteSync();
                    }
                    FocusScope.of(context).requestFocus(FocusNode());
                    model.setStackIndex(0);
                  }
                ),
                Spacer(),
                FlatButton(
                  child : Text("Save"),
                  onPressed : () => _saveContact(context, model) 
                )
              ]
            )),
            body : Form(
              key : _formKey,
              child : ListView(
                children : [
                  ListTile(
                    title : avatarFile.existsSync() ? Image.file(avatarFile) : Text("No avatar image for this contact"),
                    trailing : IconButton(
                      icon : Icon(Icons.edit),
                      color : Colors.blue,
                      onPressed : () => _selectAvatar(context)
                    )
                  ),
                  ListTile(
                    leading : Icon(Icons.person),
                    title : TextFormField(
                      decoration : InputDecoration(hintText : "Name"),
                      controller : _nameEditingController,
                      validator : (String inValue) {
                        if (inValue.length == 0) { return "Please enter a name"; }
                        return null;
                      }
                    )
                  ),
                  ListTile(
                    leading : Icon(Icons.phone),
                    title : TextFormField(
                      keyboardType : TextInputType.phone,
                      decoration : InputDecoration(hintText : "Phone"),
                      controller : _phoneEditingController
                    )
                  ),
                  ListTile(
                    leading : Icon(Icons.email),
                    title : TextFormField(
                      keyboardType : TextInputType.emailAddress,
                      decoration : InputDecoration(hintText : "Email"),
                      controller : _emailEditingController
                    )
                  ),
                  ListTile(
                    leading : Icon(Icons.today),
                    title : Text("Birthday"),
                    subtitle : Text(contactsModel.chosenDate == null ? "" : contactsModel.chosenDate),
                    trailing : IconButton(
                      icon : Icon(Icons.edit),
                      color : Colors.blue,
                      onPressed : () async {
                        String chosenDate = await utils.selectDate(
                          context: context,
                          model: contactsModel,
                          dateString: contactsModel.entityBeingEdited.birthday
                        );
                        if (chosenDate != null) {
                          contactsModel.entityBeingEdited.birthday = chosenDate;
                        }
                      }
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

  Future _selectAvatar(BuildContext context) {
    return showDialog(
      context : context,
      builder : (BuildContext context) {
        return AlertDialog(
          content : SingleChildScrollView(
            child : ListBody(
              children : [
                GestureDetector(
                  child : Text("Take a picture"),
                  onTap : () async {
                    var cameraImage = await ImagePicker.pickImage(source : ImageSource.camera);
                    if (cameraImage != null) {
                      cameraImage.copySync(join(utils.directory.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(context).pop();
                  }
                ),
                Padding(padding : EdgeInsets.all(10)),
                GestureDetector(
                  child : Text("Select From Gallery"),
                  onTap : () async {
                    var galleryImage = await ImagePicker.pickImage(source : ImageSource.gallery);
                    if (galleryImage != null) {
                      galleryImage.copySync(join(utils.directory.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(context).pop();
                  }
                )
              ]
            )
          )
        );
      }
    );
  }

  void _saveContact(BuildContext context, ContactsModel model) async {

    if (!_formKey.currentState.validate()) return;

    var id;

    if (model.entityBeingEdited.id == null) {
      id = await ContactsDBWorker.db.createContact(contactsModel.entityBeingEdited);
    } else {
      id = contactsModel.entityBeingEdited.id;
      await ContactsDBWorker.db.updateContact(contactsModel.entityBeingEdited);
    }

    File avatarFile = File(join(utils.directory.path, "avatar"));
    if (avatarFile.existsSync()) {
      avatarFile.renameSync(join(utils.directory.path, id.toString()));
    }

    contactsModel.loadData("contacts", ContactsDBWorker.db);
    model.setStackIndex(0);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor : Colors.green,
        duration : Duration(seconds : 2),
        content : Text("Contact saved")
      )
    );
  }
}
