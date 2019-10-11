import 'package:sqflite/sqflite.dart';

class MonitorDatabase {
  Database database;

  Future _checkDatabaseInit() async {
    if (database == null) await initDatabase();
  }

  Future initDatabase() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + '/sqflite.db';

    // open the database
    database = await openDatabase(path, version: 1);

    var beat = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="Beat"');
    var oxygen = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="Oxygen"');
    var breathe = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="Breathe"');
    var risk = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="Risk"');
    var sleep = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="Sleep"');

    if (beat.isEmpty) {
      await database.execute(
          'CREATE TABLE Beat (id INTEGER PRIMARY KEY, user CHAR(40), datetime INTEGER, value FLOAT)');
    }
    if (oxygen.isEmpty) {
      await database.execute(
          'CREATE TABLE Oxygen (id INTEGER PRIMARY KEY, user CHAR(40), datetime INTEGER, value INTEGER)');
    }
    if (breathe.isEmpty) {
      String valueSubquery = '';
      for (int i = 1; i <= 16; i++) {
        valueSubquery += ', value' + i.toString() + ' FLOAT';
      }
      await database.execute(
          'CREATE TABLE Breathe (id INTEGER PRIMARY KEY, user CHAR(40), datetime INTEGER' +
              valueSubquery +
              ')');
    }
    if (risk.isEmpty) {
      await database.execute(
          'CREATE TABLE Risk (id INTEGER PRIMARY KEY, user CHAR(40), datetime INTEGER, value INTEGER)');
    }
    if (sleep.isEmpty) {
      await database.execute(
          'CREATE TABLE Sleep (id INTEGER PRIMARY KEY, user CHAR(40), starttime INTEGER, endtime INTEGER)');
    }
  }

  void saveRecord(List values) async {
    await _checkDatabaseInit();
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Beat(user, datetime, value) VALUES("david", $now, ${values[0]})');
      int id2 = await txn.rawInsert(
          'INSERT INTO Oxygen(user, datetime, value) VALUES("david", $now, ${values[1]})');
      // int id3 = await txn.rawInsert(
      //     'INSERT INTO Breathe(user, datetime, value) VALUES("david", $now, 80)');
      int id4 = await txn.rawInsert(
          'INSERT INTO Risk(user, datetime, value) VALUES("david", $now, ${values[2]})');

      print('record inserted: $id1 $id2 $id4');
    });
  }

  Future<Map> getLatestSleepRecord() async {
    await _checkDatabaseInit();
    var sleep = await database
        .rawQuery('SELECT * FROM Sleep ORDER BY endtime DESC LIMIT 1;');
    return sleep.toList()[0];
  }

  Future saveTime(start, end) async {
    await _checkDatabaseInit();
    await database.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT INTO Sleep(user, starttime, endtime) VALUES("david", $start, $end)');
      print('sleep time inserted: $id');
    });
  }

  void close() {
    if (database != null) database.close();
  }
}
