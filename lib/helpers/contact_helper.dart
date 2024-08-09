import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String contactTable = 'contactTable';
const String idColumn = 'idColumn';
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String phoneColumn = "phoneColumn";
const String imgColumn = "imgColumn";

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
    //Retorna o banco de dados
    final dataBasesPath = await getDatabasesPath();
    final path = join(dataBasesPath, 'contactsNew.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = (await db)!; //obtem o Banco de dados
    contact.id = await dbContact.insert(
        contactTable, contact.toMap()); //Insere o ctt no banco de dados
    return contact; // Retorna o contato
  }

  Future<Contact?> getContact(int id) async {
    Database dbContact = (await db)!; //obtem o Banco de dados
    List<Map> maps = await dbContact.query(contactTable,
        columns: [
          idColumn,
          nameColumn,
          phoneColumn,
          emailColumn,
          phoneColumn,
          imgColumn
        ], //retorna todas as colunas
        where: "$idColumn = ?", //somente do id selecionado!
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = (await db)!; //obtem o Banco de dados
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = (await db)!; //obtem o Banco de dados
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List<Contact>> getAllContacts() async {
    Database dbContact = (await db)!; // obtem o Banco de dados
    List<Map> listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = listMap.map((map) => Contact.fromMap(map)).toList();
    return listContact;
  }


  Future<int?> getNumber() async {
    Database dbContact = (await db)!; //obtem o Banco de dados
    return Sqflite.firstIntValue(await dbContact.rawQuery(
        "SELECT COUNT (*) FROM $contactTable")); // Retorna a quantidade de elementos da tabela
  }

  Future close() async {
    Database dbContact = (await db)!; //obtem o Banco de dados
    dbContact.close(); 
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
