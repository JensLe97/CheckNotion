import 'package:checknotion/models/item_model.dart';
import 'package:checknotion/models/note_model.dart';
import 'package:checknotion/models/task_model.dart';
import 'package:checknotion/models/time_model.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._instance();
  static Database? _db;

  DbHelper._instance();

  List<String> tableNames = <String>[
    'note_table',
    'task_table',
    'time_table',
  ];

  String colId = 'id';
  String colTitle = 'title';

  List<String> colNames = <String>[
    'content',
    'done',
    'time',
  ];

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db!;
  }

  Future<Database> _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'checknotion_list.db');
    final trickListDb =
        await openDatabase(path, version: 2, onCreate: _createDb);
    return trickListDb;
  }

  void _createDb(Database db, int version) async {
    // Create one DB with 3 tables
    for (var i = 0; i < tableNames.length; i++) {
      String tableName = tableNames.elementAt(i);
      String colName = colNames.elementAt(i);
      // Done needs to be an int
      String colType = colName.contains('done') ? 'INTEGER' : 'TEXT';
      await db.execute(
        'CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colName $colType)',
      );
    }
  }

  // Get the List<Map<String, dynamic>> directly from the DB
  Future<List<Map<String, dynamic>>> getItemMapList(String name) async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(name);
    return result;
  }

  // Get the List<Item> using getItemMapList and converts a
  // Map to a certain Item
  Future<List<Item>> getItemList(String name) async {
    final List<Map<String, dynamic>> itemMapList = await getItemMapList(name);
    final List<Item> itemList = [];
    itemMapList.forEach((itemMap) {
      if (name.contains('note')) {
        itemList.add(Note.fromMap(itemMap));
      } else if (name.contains('task')) {
        itemList.add(Task.fromMap(itemMap));
      } else if (name.contains('time')) {
        itemList.add(Time.fromMap(itemMap));
      }
    });
    return itemList;
  }

  Future<int> insertItem(Item item) async {
    Database db = await this.db;
    final int result = await db.insert(getTableName(item), item.toMap());
    return result;
  }

  Future<int> updateItem(Item item) async {
    Database db = await this.db;
    final int result = await db.update(
      getTableName(item),
      item.toMap(),
      where: '$colId = ?',
      whereArgs: [item.id],
    );
    return result;
  }

  Future<int> deleteItem(Item item, int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      getTableName(item),
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }

  String getTableName(Item item) {
    if (item is Note) {
      return tableNames.elementAt(0);
    } else if (item is Task) {
      return tableNames.elementAt(1);
    } else if (item is Time) {
      return tableNames.elementAt(2);
    } else {
      throw Exception("Invalid item type");
    }
  }
}
