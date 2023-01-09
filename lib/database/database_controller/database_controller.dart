import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uic_map/database/models/additional_info_model.dart';
import 'package:uic_map/database/models/building_info_model.dart';

class DatabaseController {
  final TABLES = ["Building_Info", "Additional_Info"];
  var database;

  DatabaseController(String dbfilename) {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      _open(dbfilename);
    } catch (SQLiteDatabaseCorruptException) {
      _open(dbfilename);
    }
  }

  void _open(String dbfilename) async {
    // Construct the path to the app's writable database file:
    var dbDir = await getDatabasesPath();
    var dbPath = join(dbDir, "app.db");

    // Delete any existing database:
    await deleteDatabase(dbPath);

    // Create the writable database file from the bundled demo database file:
    ByteData data =
        await rootBundle.load("assets/database/UIC__building_info.db");
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes);

    database = await openDatabase(dbPath);
  }

  Future<List<BuildingModel>> searchBuildingInfo(String query) async {
    final db = await database;

    final List<Map<String, dynamic>> searchResults = await db.query(TABLES[0],
        columns: ['*'],
        where: 'CODE = ? OR NAME LIKE ?',
        whereArgs: [query, '%$query%']);

    return List.generate(searchResults.length, (i) {
      return BuildingModel(
          ADDRESS: searchResults[i]['ADDRESS'],
          LATITUDE: searchResults[i]['LATITUDE'],
          LONGITUDE: searchResults[i]['LONGITUDE'],
          CODE: searchResults[i]['CODE'],
          NAME: searchResults[i]['NAME'],
          TYPE: searchResults[i]['TYPE'],
          CAMPUS: searchResults[i]['CAMPUS']);
    });
  }

  Future<List<InfoModel>> searchAdditionalInfo(String query) async {
    final db = await database;

    final List<Map<String, dynamic>> searchResults = await db.query(TABLES[1], // wrap this with a try catch
        columns: ['*'], where: 'CODE = ?', whereArgs: [query]);

    return List.generate(searchResults.length, (i) {
      return InfoModel(
          NAME: searchResults[i]['NAME'],
          CODE: searchResults[i]['CODE'],
          NUMBER: searchResults[i]['NUMBER'],
          ADDRESS: searchResults[i]['ADDRESS'],
          INFO: searchResults[i]['INFO']);
    });
  }
}
