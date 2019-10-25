import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'common/database.dart';
import 'common/RecordData.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  MonitorDatabase database;
  int historyTime = 0;
  String sleepStart = '--';
  String sleepEnd = '--';
  String sleepTimeHour = '--';
  String sleepTimeMinute = '--';
  String ahi = '--';
  String beatsCount = '--';
  String eventCount = '--';

  Map oxygenChart = {
    'average': '--',
    'chart': null,
  };

  Map breatheChart = {
    'hours': '--',
    'minutes': '--',
    'seconds': '--',
    'compare': '比平均 -- -- 分鐘(假資料)',
    'chart': null,
  };

  Map eventsChart = {
    'low': 1,
    'mid': 1,
    'high': 1,
  };

  @override
  void initState() {
    super.initState();
    historyTime = 0;
    database = new MonitorDatabase();
    _drawSleepTime();
    _drawOxygenChart();
    _drawBreatheChart();
    _drawBeats();
    //睡眠事件圖表及AHI指數
    _drawEventsChartAndAHI();
  }

  void _checkUpload(int time, String title, param) async {
    DateTime s = DateTime.fromMillisecondsSinceEpoch(time * 1000);
    String t = DateFormat('yyyyMMddkkmm').format(s);

    var user = await FirebaseAuth.instance.currentUser();
    final databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference
        .child('records')
        .child(user.displayName)
        .child(t)
        .child(title)
        .once()
        .then((DataSnapshot snapshot) async {
      if (snapshot.value == null) {
        await databaseReference
            .child('records')
            .child(user.displayName)
            .child(t)
            .child(title)
            .set(jsonEncode(param));
        print('Upload finish $title');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _drawSleepTime({int time = 0}) async {
    Map lastSleep;
    if (time == 0) {
      lastSleep = await database.getLatestSleepRecord();
    } else {
      lastSleep = await database.getHistorySleepRecord(time);
    }

    setState(() {
      DateTime s =
          DateTime.fromMillisecondsSinceEpoch(lastSleep['starttime'] * 1000);
      DateTime e =
          DateTime.fromMillisecondsSinceEpoch(lastSleep['endtime'] * 1000);

      sleepTimeHour =
          ((lastSleep['endtime'] - lastSleep['starttime']) ~/ 3600).toString();
      sleepTimeMinute =
          ((lastSleep['endtime'] - lastSleep['starttime']) % 3600 ~/ 60)
              .toString();
      sleepStart = DateFormat('MM-dd kk:mm').format(s);
      sleepEnd = DateFormat('MM-dd kk:mm').format(e);
    });
  }

  Future _drawOxygenChart({int time = 0}) async {
    Map lastSleep;
    if (time == 0) {
      lastSleep = await database.getLatestSleepRecord();
    } else {
      lastSleep = await database.getHistorySleepRecord(time);
    }
    List oxygenList = await database.getLatestOxygenRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    //上傳睡眠時間紀錄
    _checkUpload(lastSleep['starttime'], 'sleep', lastSleep);
    //上傳血氧紀錄
    _checkUpload(lastSleep['starttime'], 'oxygen', oxygenList);

    setState(() {
      List<RecordData> data = [];
      int sum = 0;
      for (int i = 0; i < oxygenList.length; i++) {
        if (i > 400) break;
        if (oxygenList[i]['value'] > 0) sum += oxygenList[i]['value'];
        data.add(new RecordData(i, oxygenList[i]['value'].toDouble()));
      }
      var chartdata = [
        new charts.Series<RecordData, int>(
          id: 'Records',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (RecordData rec, _) => rec.sec,
          measureFn: (RecordData rec, _) => rec.value,
          data: data,
        )
      ];
      oxygenChart['chart'] = charts.LineChart(
        chartdata,
        animate: false,
        primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec: new charts.StaticNumericTickProviderSpec(
            <charts.TickSpec<num>>[
              charts.TickSpec<num>(80),
              charts.TickSpec<num>(100),
            ],
          ),
        ),
      );
      oxygenChart['average'] =
          (data.length > 0) ? (sum ~/ data.length).toString() : '--';
    });
  }

  Future _drawEventsChartAndAHI({int time = 0}) async {
    int count = 0;
    Map lastSleep;
    eventsChart['low'] = eventsChart['mid'] = eventsChart['high'] = 0;

    if (time == 0) {
      lastSleep = await database.getLatestSleepRecord();
    } else {
      lastSleep = await database.getHistorySleepRecord(time);
    }
    int hour = (lastSleep['endtime'] - lastSleep['starttime']) ~/ 3600;
    List risk = await database.getRiskRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    //上傳風險值紀錄
    _checkUpload(lastSleep['starttime'], 'risk', risk);

    setState(() {
      int totalRisks = risk.length;
      for (int i = 0; i < risk.length; i++) {
        if (risk[i]['value'] >= 80) {
          eventsChart['high']++;
        } else if (risk[i]['value'] > 40) {
          eventsChart['mid']++;
        } else if (risk[i]['value'] > 0) {
          eventsChart['low']++;
        } else {
          //invalid value
          totalRisks--;
        }
        if (i + 1 < risk.length &&
            risk[i]['value'] >= 80 &&
            risk[i + 1]['value'] < 80) {
          count++;
        }
      }
      if (totalRisks == 0) {
        eventCount = '0';
      } else {
        eventCount = (eventsChart['high'] / totalRisks * 100 ~/ 1).toString();
      }
      ahi = (hour > 0) ? (count ~/ hour).toString() : count.toString();
    });
  }

  Future _drawBeats({int time = 0}) async {
    Map lastSleep;
    if (time == 0) {
      lastSleep = await database.getLatestSleepRecord();
    } else {
      lastSleep = await database.getHistorySleepRecord(time);
    }
    List beatsList = await database.getBeatsRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    //上傳心跳紀錄
    _checkUpload(lastSleep['starttime'], 'beat', beatsList);

    setState(() {
      double sum = 0;
      int count = 0;
      for (int i = 0; i < beatsList.length; i++) {
        if (beatsList[i]['value'] - 1 > 0) {
          sum += beatsList[i]['value'];
          count++;
        }
      }
      beatsCount = (count > 0) ? (sum ~/ count).toString() : '--';
    });
  }

  Future _drawBreatheChart({int time = 0}) async {
    Map lastSleep;
    if (time == 0) {
      lastSleep = await database.getLatestSleepRecord();
    } else {
      lastSleep = await database.getHistorySleepRecord(time);
    }

    int hour = (lastSleep['endtime'] - lastSleep['starttime']) ~/ 3600;
    int minute = (lastSleep['endtime'] - lastSleep['starttime']) % 3600 ~/ 60;
    int second = (lastSleep['endtime'] - lastSleep['starttime']) % 60;

    List breatheList = await database.getBreatheRecordWithRisk(
        lastSleep['starttime'], lastSleep['endtime']);

    //上傳呼吸紀錄
    _checkUpload(lastSleep['starttime'], 'breathe', breatheList);

    setState(() {
      Map<String, List<RecordData>> data = {'normal': [], 'danger': []};

      for (int i = 0; i < breatheList.length; i++) {
        if (i > 400) break;
        if (breatheList[i]['value1'] > 0 && breatheList[i]['value9'] > 0) {
          for (int j = 1; j <= 16; j++) {
            double value = breatheList[i]['value' + j.toString()];
            if (value > 400) value = 400;
            if (value < 0) value = 0;
            // 檢查risk > 80
            if (breatheList[i]['value'] >= 80) {
              data['danger'].add(new RecordData(i, value));
              data['normal'].add(new RecordData(i, null));
            } else {
              data['normal'].add(new RecordData(i, value));
              data['danger'].add(new RecordData(i, null));
            }
          }
        }
      }
      var chartdata = [
        new charts.Series<RecordData, int>(
          id: 'Normal',
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          domainFn: (RecordData rec, _) => rec.sec,
          measureFn: (RecordData rec, _) => rec.value,
          data: data['normal'],
        ),
        new charts.Series<RecordData, int>(
          id: 'Danger',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (RecordData rec, _) => rec.sec,
          measureFn: (RecordData rec, _) => rec.value,
          data: data['danger'],
        )
      ];
      breatheChart['hours'] = hour.toString();
      breatheChart['minutes'] = minute.toString();
      breatheChart['seconds'] = second.toString();
      breatheChart['chart'] = charts.LineChart(
        chartdata,
        animate: false,
        primaryMeasureAxis:
            new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),
        domainAxis: new charts.NumericAxisSpec(
            showAxisLine: true, renderSpec: new charts.NoneRenderSpec()),
      );
    });
  }

  List<charts.Series<RecordData, int>> _createEventsData() {
    final data = [
      new RecordData(1, eventsChart['low'].toDouble()),
      new RecordData(2, eventsChart['mid'].toDouble()),
      new RecordData(3, eventsChart['high'].toDouble()),
    ];
    return [
      new charts.Series<RecordData, int>(
        id: 'Events',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (RecordData sales, _) =>
            sales.sec, //map key instead of second
        measureFn: (RecordData sales, _) => sales.value,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget title = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Material(
              borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Text(
                      '🌙',
                      style: TextStyle(fontSize: 24.0, color: Colors.blue),
                    ),
                    Text(
                      '本次睡眠時間',
                      style: TextStyle(fontSize: 24.0, color: Colors.blue),
                    ),
                    Text(
                      sleepStart + ' 到 ' + sleepEnd,
                      style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                    ),
                    Text(
                      sleepTimeHour + ' 小時 ' + sleepTimeMinute + ' 分鐘',
                      style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget row1 = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Material(
              borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/history/oxygen',
                      arguments: historyTime);
                },
                child: new Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Text(
                        '整夜血氧數據',
                        style: TextStyle(fontSize: 24.0, color: Colors.blue),
                      ),
                      Text(
                        '平均血氧值 ' + oxygenChart['average'],
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 200.0),
                          child: oxygenChart['chart'],
                        ),
                      ),
                      Text(
                        '點擊查看完整資料',
                        style:
                            TextStyle(fontSize: 18.0, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget row2 = Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 5),
              child: new Material(
                borderRadius: new BorderRadius.all(Radius.circular(15.0)),
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/history/events',
                        arguments: historyTime);
                  },
                  child: new Container(
                    padding: EdgeInsets.only(top: 20.0),
                    alignment: Alignment.center,
                    child: Column(
                      children: <Widget>[
                        Text(
                          '睡眠事件所占比',
                          style: TextStyle(fontSize: 20.0, color: Colors.blue),
                        ),
                        Text(
                          '高風險值 ' + eventCount + '%',
                          style: TextStyle(
                              fontSize: 18.0, color: Colors.grey[800]),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 160.0),
                          child: charts.PieChart(_createEventsData(),
                              animate: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 10),
                  child: Material(
                    borderRadius: new BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/history/ahi',
                            arguments: historyTime);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 25.0),
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'AHI指數',
                              style:
                                  TextStyle(fontSize: 20.0, color: Colors.blue),
                            ),
                            Text(
                              ahi + ' 次/hr',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 10),
                  child: Material(
                    borderRadius: new BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/history/beat',
                            arguments: historyTime);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 25.0),
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            Text(
                              '心跳次數❤️',
                              style:
                                  TextStyle(fontSize: 20.0, color: Colors.blue),
                            ),
                            Text(
                              beatsCount + ' BPM',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget row3 = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Material(
              borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/history/breathe',
                      arguments: historyTime);
                },
                child: new Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Text(
                        '整夜呼吸數據',
                        style: TextStyle(fontSize: 24.0, color: Colors.blue),
                      ),
                      Text(
                        '睡眠時間 ' +
                            breatheChart['hours'] +
                            ' 小時 ' +
                            breatheChart['minutes'] +
                            ' 分鐘 ' +
                            breatheChart['seconds'] +
                            ' 秒',
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                      ),
                      Text(
                        breatheChart['compare'],
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[600]),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 200.0),
                          child: breatheChart['chart'],
                        ),
                      ),
                      Text(
                        '點擊查看完整資料',
                        style:
                            TextStyle(fontSize: 18.0, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget body = Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: ListView(
        children: <Widget>[title, row1, row2, row3],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.calendarAlt),
            onPressed: () {
              DatePicker.showDatePicker(
                context,
                pickerMode: DateTimePickerMode.datetime,
                initialDateTime: DateTime.now(),
                dateFormat: 'yyyy-MM-dd HH mm',
                onConfirm: (datetime, list) {
                  int t = datetime.millisecondsSinceEpoch ~/ 1000;
                  historyTime = t;
                  _drawSleepTime(time: t);
                  _drawOxygenChart(time: t);
                  _drawBreatheChart(time: t);
                  _drawBeats(time: t);
                  _drawEventsChartAndAHI(time: t);
                },
              );
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('歷史紀錄', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: body,
    );
  }
}
