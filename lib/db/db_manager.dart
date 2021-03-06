import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'table/app_settings_table.dart';

Database db;

class DbManager {
  DbManager._privateConstructor();

  static final DbManager _instance = DbManager._privateConstructor();

  static DbManager get instance => _instance;

  static const int _databaseVersion = 1;
  static const _databaseName = 'main_db';

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    if (!await Directory(dirname(path)).exists()) {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath(_databaseName);
    db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        var batch = db.batch();
        createAppSettingsTable(batch);
        await batch.commit();
      },
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   var batch = db.batch();
      //   if (oldVersion < 2 ) {
      //     // do some migrate works
      //   }
      //   await batch.commit();
      // },
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  createAppSettingsTable(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS ${AppSettings.tableName}');
    batch.execute('''CREATE TABLE ${AppSettings.tableName}
    (
      ${AppSettings.columnKey} INTEGER PRIMARY KEY,
      ${AppSettings.columnAmountStoriesPerLoad} INTEGER
    )''');
  }
}
