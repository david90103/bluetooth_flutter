import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonitorDatabase {
  Database database;
  String _user;

  Future _checkDatabaseInit() async {
    //取得用戶資訊
    var user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      _user = user.email;
    } else {
      _user = 'anonymous';
    }
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
          'INSERT INTO Beat(user, datetime, value) VALUES("$_user", $now, ${values[0]})');
      int id2 = await txn.rawInsert(
          'INSERT INTO Oxygen(user, datetime, value) VALUES("$_user", $now, ${values[1]})');
      int id3 = await txn.rawInsert(
          'INSERT INTO Breathe(user, datetime, value1, value2, value3, value4, value5, value6, '
          'value7, value8, value9, value10, value11, value12, value13, value14, value15, value16) VALUES("$_user", $now, '
          '${values[2]}, ${values[3]}, ${values[4]}, ${values[5]}, ${values[6]}, ${values[7]}, ${values[8]}, '
          '${values[9]}, ${values[10]}, ${values[11]}, ${values[12]}, ${values[13]}, ${values[14]}, ${values[15]}, '
          '${values[16]}, ${values[17]})');
      int id4 = await txn.rawInsert(
          'INSERT INTO Risk(user, datetime, value) VALUES("$_user", $now, ${values[18]})');

      print('record inserted: $id1 $id2 $id3 $id4 $_user');
    });
  }

  Future<Map> getLatestSleepRecord() async {
    await _checkDatabaseInit();
    var sleep = await database.rawQuery(
        'SELECT * FROM Sleep WHERE user = "$_user" ORDER BY endtime DESC LIMIT 1;');
    return sleep.toList()[0];
  }

  Future<Map> getHistorySleepRecord(time) async {
    await _checkDatabaseInit();
    var sleep = await database.rawQuery(
        'SELECT * FROM Sleep WHERE user = "$_user" AND starttime <= $time AND endtime >= $time ORDER BY endtime DESC LIMIT 1;');
    return sleep.toList()[0];
  }

  Future getLatestOxygenRecord(starttime, endtime) async {
    await _checkDatabaseInit();
    var oxygen = await database.rawQuery(
        'SELECT value FROM Oxygen WHERE user = "$_user" AND datetime BETWEEN $starttime AND $endtime ORDER BY datetime DESC LIMIT 400;');
    return oxygen.toList();
  }

  Future getOxygenRecord(starttime, endtime) async {
    await _checkDatabaseInit();
    var oxygen = await database.rawQuery(
        'SELECT value FROM Oxygen WHERE user = "$_user" AND datetime BETWEEN $starttime AND $endtime ORDER BY datetime;');
    return oxygen.toList();
  }

  Future getLatestBreatheRecord(starttime, endtime) async {
    await _checkDatabaseInit();
    var breathe = await database.rawQuery(
        'SELECT * FROM Breathe WHERE user = "$_user" AND datetime BETWEEN $starttime AND $endtime ORDER BY datetime DESC LIMIT 400;');
    return breathe.toList();
  }

  Future getBreatheRecord(starttime, endtime) async {
    await _checkDatabaseInit();
    var breathe = await database.rawQuery(
        'SELECT * FROM Breathe WHERE user = "$_user" AND datetime BETWEEN $starttime AND $endtime ORDER BY datetime;');
    return breathe.toList();
  }

  Future getBreatheRecordWithRisk(starttime, endtime) async {
    await _checkDatabaseInit();
    var breathe = await database.rawQuery(
        'SELECT * FROM (Breathe LEFT JOIN Risk ON Breathe.datetime=Risk.datetime) '
        'WHERE Breathe.user = "$_user" AND Breathe.datetime BETWEEN $starttime AND $endtime ORDER BY datetime;');
    return breathe.toList();
  }

  Future getLatestBeatsRecord() async {
    await _checkDatabaseInit();
    var breathe = await database.rawQuery(
        'SELECT value FROM Beat WHERE user = "$_user" ORDER BY endtime DESC LIMIT 1;');
    return breathe.toList()[0];
  }

  Future getBeatsRecord(starttime, endtime) async {
    await _checkDatabaseInit();
    var breathe = await database.rawQuery(
        'SELECT value FROM Beat WHERE user = "$_user" AND datetime BETWEEN $starttime AND $endtime ORDER BY datetime;');
    return breathe.toList();
  }

  Future getRiskRecord(starttime, endtime) async {
    await _checkDatabaseInit();
    var breathe = await database.rawQuery(
        'SELECT value, datetime FROM Risk WHERE user = "$_user" AND datetime BETWEEN $starttime AND $endtime ORDER BY datetime;');
    return breathe.toList();
  }

  Future saveTime(start, end) async {
    await _checkDatabaseInit();
    await database.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT INTO Sleep(user, starttime, endtime) VALUES("$_user", $start, $end)');
      print('sleep time inserted: $id');
    });
  }

  void close() {
    if (database != null) database.close();
  }
}
