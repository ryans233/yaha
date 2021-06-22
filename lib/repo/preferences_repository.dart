import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yaha/db/db_manager.dart';
import 'package:yaha/db/table/app_settings_table.dart';

class PreferencesRepository {
  PreferencesRepository._privateConstructor();

  static final PreferencesRepository _instance =
      PreferencesRepository._privateConstructor();

  static PreferencesRepository get instance => _instance;

  Future<AppSettings> getSettings() async {
    final data = await db.query(
      AppSettings.tableName,
      where: '${AppSettings.columnKey} = ?',
      whereArgs: [0],
    );
    return data.isNotEmpty ? AppSettings.fromJson(data[0]) : AppSettings();
  }

  Future<void> set(String key, dynamic value) async {
    debugPrint("setSettings: key=${key.toString()} value=${value.toString()}");
    var appSettings = await getSettings();
    await db.insert(AppSettings.tableName, appSettings.toJson()..[key] = value,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
