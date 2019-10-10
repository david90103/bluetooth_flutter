import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sqflite/sqflite.dart';

import '../home.dart';
import '../common/breathe.dart';

class DataSample {
  double temperature1;
  double temperature2;
  double waterpHlevel;
  DateTime timestamp;

  DataSample(
      {this.temperature1,
      this.temperature2,
      this.waterpHlevel,
      this.timestamp});
}

class BackgroundCollectingTask extends Model {
  static BackgroundCollectingTask of(BuildContext context,
          {bool rebuildOnChange = false}) =>
      ScopedModel.of<BackgroundCollectingTask>(context,
          rebuildOnChange: rebuildOnChange);

  final BluetoothConnection _connection;
  List<int> _buffer = List<int>();
  Database database;

  // @TODO , Such sample collection in real code should be delegated
  // (via `Stream<DataSample>` preferably) and then saved for later
  // displaying on chart (or even stright prepare for displaying).
  List<DataSample> samples = List<
      DataSample>(); // @TODO ? should be shrinked at some point, endless colleting data would cause memory shortage.

  bool inProgress;

  BackgroundCollectingTask._fromConnection(this._connection) {
    _connection.input.listen((data) {
      _buffer += data;

      while (true) {
        int index = _buffer.indexOf('\n'.codeUnitAt(0));
        if (index >= 0) {
          List result = utf8.decode(_buffer).split(',');
          HomePageState.beat = double.parse(result[0]);
          HomePageState.oxygen = int.parse(result[1]);

          for (int i = 0; i < 16; i++) {
            HomePageState.breathe.removeAt(0);
            HomePageState.breathe.add(double.parse(result[2 + i]));
          }

          HomePageState.risk = int.parse(result[18]);

          if (HomePageState.recording) _saveRecord(result);
          _buffer.clear();
          notifyListeners();
        } else {
          break;
        }
      }
    }).onDone(() {
      inProgress = false;
      notifyListeners();
    });
  }

  static Future<BackgroundCollectingTask> connect(
      BluetoothDevice server) async {
    final BluetoothConnection connection =
        await BluetoothConnection.toAddress(server.address);
    return BackgroundCollectingTask._fromConnection(connection);
  }

  void dispose() {
    _connection.dispose();
  }

  Future<void> start() async {
    _initDatabase();
    inProgress = true;
    _buffer.clear();
    samples.clear();
    notifyListeners();
    _connection.output.add(ascii.encode('start'));
    await _connection.output.allSent;
  }

  Future<void> cancel() async {
    if (database != null) database.close();
    inProgress = false;
    notifyListeners();
    _connection.output.add(ascii.encode('stop'));
    await _connection.finish();
  }

  Future<void> pause() async {
    inProgress = false;
    notifyListeners();
    _connection.output.add(ascii.encode('stop'));
    await _connection.output.allSent;
  }

  Future<void> reasume() async {
    inProgress = true;
    notifyListeners();
    _connection.output.add(ascii.encode('start'));
    await _connection.output.allSent;
  }

  Iterable<DataSample> getLastOf(Duration duration) {
    DateTime startingTime = DateTime.now().subtract(duration);
    int i = samples.length;
    do {
      i -= 1;
      if (i <= 0) {
        break;
      }
    } while (samples[i].timestamp.isAfter(startingTime));
    return samples.getRange(i, samples.length);
  }

  void _initDatabase() async {
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
  }

  void _saveRecord(List values) async {
    List result = await database.rawQuery('select *  from Oxygen');
    print(result[result.length - 1]);

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

      print('inserted: $id1 $id2 $id4');
    });
  }
}
