import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'ContactsModel.dart';

class ContactsDBWorker {
  ContactsDBWorker._();
  static final ContactsDBWorker db = ContactsDBWorker._();

  Database _db;

  Future get database async {
    if (_db == null) _db = await initDB();
    
    return _db;
  }

  Future<Database> initDB() async {
    String path = join(utils.directory.path, "contacts.db");

    Database db = await openDatabase(
      path,
      version : 1,
      onOpen : (db) { },
      onCreate : (Database inDB, int inVersion) async {
        await inDB.execute(
          "CREATE TABLE IF NOT EXISTS contacts ("
            "id INTEGER PRIMARY KEY,"
            "name TEXT,"
            "email TEXT,"
            "phone TEXT,"
            "birthday TEXT"
          ")"
        );
      }
    );
    return db;
  }

  Contact contactfromMap(Map contactMap) {
    Contact contact = Contact();
    contact.id = contactMap['id'];
    contact.name = contactMap['name'];
    contact.email = contactMap['email'];
    contact.phone = contactMap['phone'];
    contact.birthday = contactMap['birthday'];
    return contact;
  }

  Map<String, dynamic> contactToMap(Contact contact) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = contact.id;
    map['name'] = contact.name;
    map['email'] = contact.email;
    map['phone'] = contact.phone;
    map['birthday'] = contact.birthday;
    return map;
  }

  Future<int> createContact(Contact newContact) async {
    Database db = await database;
    List<Map<String, dynamic>> contacts =  await db.rawQuery(
      'SELECT MAX(id) + 1 AS id FROM contacts'
    );
    int id = contacts.first['id'];
    if(id == null) id = 1;

    return await db.insert('contacts', contactToMap(newContact));
  }

  Future<Contact> getContact(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> contact = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id]
    );
    return contactfromMap(contact.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var contacts = await db.query('contacts');
    var list = contacts.isNotEmpty 
      ? contacts.map((contact) => contactfromMap(contact)).toList() 
      : [];
    return list;
  }

  Future<int> updateContact(Contact contact) async {
    Database db = await database;
    return await db.update(
      'contacts', 
      contactToMap(contact),
      where: 'id = ?',
      whereArgs: [ contact.id ] 
    );
  }

  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [ id ] 
    );
  }


}