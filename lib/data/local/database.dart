import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper getInstance = DatabaseHelper._(); // Singleton pattern
  Database? dbObject;

  final String tableName = "notes";
  final String tableFirstColumnIsSeNum = "serial_no";
  final String tableSecondColumnIsTitle = "title";
  final String tableThirdColumnIsDescription = "description";

  Future<Database> gettingDatabase() async {
    dbObject ??= await openTheDatabase();
    return dbObject!;
  }

  Future<Database> openTheDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(appDirectory.path, "notesFolder.db");
    return await openDatabase(dbPath, onCreate: (db, version) {
      db.execute(
          "CREATE TABLE $tableName ($tableFirstColumnIsSeNum INTEGER PRIMARY KEY AUTOINCREMENT, $tableSecondColumnIsTitle TEXT, $tableThirdColumnIsDescription TEXT)");
    }, version: 1);
  }

  Future<bool> addNewNotes(
      {required String titleIs, required String descriptionIs}) async {
    final databaseRef = await gettingDatabase();
    int rowEffectedIs = await databaseRef.insert(tableName, {
      tableSecondColumnIsTitle: titleIs,
      tableThirdColumnIsDescription: descriptionIs
    });
    return rowEffectedIs > 0;
  }

  Future<List<Map<String, dynamic>>> fetchAllNotes() async {
    final databaseRef = await gettingDatabase();
    List<Map<String, dynamic>> fetchData = await databaseRef.query(tableName);
    return fetchData;
  }

  Future<bool> updateNotes(
      {required String titleIs,
        required String descriptionIs,
        required int indexIs}) async {
    final databaseRef = await gettingDatabase();
    int rowEffectedIs = await databaseRef.update(
        tableName,
        {
          tableSecondColumnIsTitle: titleIs,
          tableThirdColumnIsDescription: descriptionIs
        },
        where: "$tableFirstColumnIsSeNum = ?",
        whereArgs: [indexIs]);
    return rowEffectedIs > 0;
  }

  Future<bool> deleteNotes({required int indexIs}) async {
    final databaseRef = await gettingDatabase();
    int rowEffectedIs = await databaseRef.delete(tableName,
        where: "$tableFirstColumnIsSeNum = ?", whereArgs: [indexIs]);
    return rowEffectedIs > 0;
  }
}
