import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';
import '../common/database.dart';

import '../home.dart';

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
  MonitorDatabase database;

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
          try {
            List result = utf8.decode(_buffer).split(',');
            HomePageState.beat = _adjustBeat(double.parse(result[0]));
            HomePageState.oxygen = _adjustOxygen(int.parse(result[1]));

            for (int i = 0; i < 16; i++) {
              HomePageState.breathe.removeAt(0);
              HomePageState.breathe.add(double.parse(result[2 + i]));
            }

            HomePageState.risk = int.parse(result[18]);
            if (HomePageState.recording) database.saveRecord(result);
          } catch (e) {
            print(e);
          }
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

  double _adjustBeat(beat) {
    if (beat < 60) beat = 60.0;
    if (beat > 140) beat = 140.0;
    //檢查浮動是否過大
    double prev = HomePageState.beat;
    if (prev == 0) {
      return beat;
    } else if (prev - beat > 10) {
      return prev - 10;
    } else if (beat - prev > 10) {
      return prev + 10;
    }
    return beat;
  }

  int _adjustOxygen(oxygen) {
    //檢查感測器是否脫落
    if (oxygen == 0) {
      if (HomePageState.dropAlert <= 10) {
        HomePageState.dropAlert++;
      }
    } else {
      HomePageState.dropAlert = 0;
    }
    if (oxygen < 80) oxygen = 80;
    if (oxygen > 100) oxygen = 100;
    //檢查浮動是否過大
    int prev = HomePageState.oxygen;
    if (prev == 0) {
      return oxygen;
    } else if (prev - oxygen > 2) {
      return prev - 2;
    } else if (oxygen - prev > 2) {
      return prev + 2;
    }
    return oxygen;
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
    database = new MonitorDatabase();
    inProgress = true;
    _buffer.clear();
    samples.clear();
    notifyListeners();
    _connection.output.add(ascii.encode('start'));
    await _connection.output.allSent;
  }

  Future<void> cancel() async {
    database.close();
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
}
