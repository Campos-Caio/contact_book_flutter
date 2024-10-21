import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String contactTable = 'contactTable';
const String idColumn = 'idColumn';
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String phoneColumn = "phoneColumn";
const String imgColumn = "imgColumn";
const String loginTable = 'loginTable';
const String usernameColumn = 'usernameColumn';
const String passwordColumn = 'passwordColumn';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  Future<Database> initDb() async {
    final dataBasesPath = await getDatabasesPath();
    final path = join(dataBasesPath, 'contactsNew.db');

    // Incrementa a versão do banco de dados para recriar as tabelas, se necessário
    return await openDatabase(path, version: 2, // Incremento da versão
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");

      await db.execute(
          "CREATE TABLE $loginTable($usernameColumn TEXT PRIMARY KEY, $passwordColumn TEXT)");
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      // Recria a tabela se a versão do banco for aumentada
      if (oldVersion < 2) {
        await db.execute(
          "CREATE TABLE IF NOT EXISTS $loginTable($usernameColumn TEXT PRIMARY KEY, $passwordColumn TEXT)");
      }
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = (await db)!; 
    contact.id = await dbContact.insert(contactTable, contact.toMap()); 
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database dbContact = (await db)!;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [
          idColumn,
          nameColumn,
          phoneColumn,
          emailColumn,
          phoneColumn,
          imgColumn
        ], 
        where: "$idColumn = ?", 
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = (await db)!;
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = (await db)!;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List<Contact>> getAllContacts() async {
    Database dbContact = (await db)!; 
    List<Map> listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact =
        listMap.map((map) => Contact.fromMap(map)).toList();
    return listContact;
  }

  Future<int?> getNumber() async {
    Database dbContact = (await db)!;
    return Sqflite.firstIntValue(await dbContact.rawQuery(
        "SELECT COUNT (*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = (await db)!;
    dbContact.close();
  }

  // Métodos relacionados ao login
  Future<int> saveLogin(String username, String password) async {
    Database dbLogin = (await db)!;
    Map<String, dynamic> loginData = {
      usernameColumn: username,
      passwordColumn: password,
    };
    return await dbLogin.insert(loginTable, loginData);
  }

  Future<Map?> getLogin(String username, String password) async {
    Database dbLogin = (await db)!;
    List<Map> maps = await dbLogin.query(loginTable,
        columns: [usernameColumn, passwordColumn],
        where: "$usernameColumn = ? AND $passwordColumn = ?",
        whereArgs: [username, password]);
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }
}

class Contact {
  int id = 0;
  String name = "";
  String email = "";
  String phone = "";
  String img = "";

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, Object?> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };

    if (id != 0) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
