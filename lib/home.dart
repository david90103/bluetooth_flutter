import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'common/drawer.dart';
import 'common/breathe.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'bluetooth/BackgroundCollectingTask.dart';
import 'bluetooth/SelectBondedDevicePage.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String _timeString;
  BackgroundCollectingTask _collectingTask;
  static double beat = 0.0;
  static int oxygen = 0;
  static int risk = 0;
  static bool recording = false;

  static List<double> breathe;

  static List<charts.Series<Breathe, int>> _chartData() {
    List<Breathe> data = [];
    for (int i = 0; i < 480; i++) {
      data.add(new Breathe(i - 480, breathe[i]));
    }

    return [
      new charts.Series<Breathe, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Breathe sales, _) => sales.sec,
        measureFn: (Breathe sales, _) => sales.value,
        data: data,
      )
    ];
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MM/dd  hh:mm:ss a').format(dateTime);
  }

  @override
  void initState() {
    //vertical mode only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // init breathe data
    breathe = new List();
    for (int i = 0; i < 480; i++) {
      breathe.add(0);
    }

    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  void dispose() {
    _collectingTask?.dispose();
    super.dispose();
  }

  Future<void> _startBackgroundTask(
      BuildContext context, BluetoothDevice server) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      await _collectingTask.start();
    } catch (ex) {
      if (_collectingTask != null) {
        _collectingTask.cancel();
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _monitorPressed() async {
    print('pressed');
    if (_collectingTask != null && _collectingTask.inProgress) {
      await _collectingTask.cancel();
      setState(() {
        /* Update for `_collectingTask.inProgress` */
      });
    } else {
      final BluetoothDevice selectedDevice = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) {
        return SelectBondedDevicePage(checkAvailability: false);
      }));

      if (selectedDevice != null) {
        await _startBackgroundTask(context, selectedDevice);
        setState(() {
          /* Update for `_collectingTask.inProgress` */
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget row1 = Padding(
      padding: EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: new Container(
              margin: EdgeInsets.only(right: 5.0),
              padding: EdgeInsets.symmetric(vertical: 10.0),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.tint, color: Colors.red),
                  SizedBox(height: 10),
                  Text(
                    '血氧值',
                    style: TextStyle(fontSize: 20.0, color: Colors.blue),
                  ),
                  SizedBox(height: 5),
                  Text(
                    oxygen.toString() + '%',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: new Container(
              margin: EdgeInsets.only(left: 5.0),
              padding: EdgeInsets.symmetric(vertical: 10.0),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(FontAwesomeIcons.heartbeat, color: Colors.redAccent),
                  SizedBox(height: 10),
                  Text(
                    '心跳',
                    style: TextStyle(fontSize: 20.0, color: Colors.blue),
                  ),
                  SizedBox(height: 5),
                  Text(
                    beat.toString() + ' BPM',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget row2 = Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '呼吸中止風險值  ' + risk.toString() + '%',
              style: TextStyle(fontSize: 22.0, color: Colors.blue),
            ),
          ],
        ),
      ),
    );

    Widget row3 = Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints.expand(height: 200.0),
                child: charts.LineChart(_chartData(), animate: false),
              ),
            ),
          ],
        ),
      ),
    );

    Widget row4 = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: new Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _timeString,
              style: TextStyle(fontSize: 26.0, color: Colors.blue),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: () {
                  setState(() {
                    recording = !recording;
                  });
                },
                padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 50.0),
                color: recording ? Colors.green : Colors.redAccent,
                child: Text(recording ? '記錄中' : '開始記錄',
                    style: TextStyle(color: Colors.white, fontSize: 22)),
              ),
            ),
          ],
        ),
      ),
    );

    Widget body = Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Column(
        children: <Widget>[
          Expanded(flex: 4, child: row1),
          Expanded(flex: 2, child: row2),
          Expanded(flex: 7, child: row3),
          Expanded(flex: 4, child: row4)
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: (_collectingTask != null && _collectingTask.inProgress)
                ? SpinKitPulse(color: Colors.white)
                : Icon(Icons.bluetooth),
            onPressed: () {
              _monitorPressed();
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('睡眠呼吸檢測數據', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      drawer: MainDrawer(),
      body: body,
    );
  }
}
