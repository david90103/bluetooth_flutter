import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import '../common/RecordData.dart';
import '../common/database.dart';

class BreathePage extends StatefulWidget {
  BreathePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  BreathePageState createState() => BreathePageState();
}

class BreathePageState extends State<BreathePage> {
  MonitorDatabase database;
  bool _ready = false;

  Map breatheChart = {
    'hours': '--',
    'minutes': '--',
    'seconds': '--',
    'compare': '比平均 -- -- 分鐘(假資料)',
    'chart': null,
  };

  @override
  void initState() {
    super.initState();
    database = new MonitorDatabase();
    _drawBreatheChart();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _drawBreatheChart() async {
    Map lastSleep = await database.getLatestSleepRecord();

    int hour = (lastSleep['endtime'] - lastSleep['starttime']) ~/ 3600;
    int minute = (lastSleep['endtime'] - lastSleep['starttime']) % 3600 ~/ 60;
    int second = (lastSleep['endtime'] - lastSleep['starttime']) % 60;

    List breatheList = await database.getBreatheRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    setState(() {
      List<RecordData> data = [];
      for (int i = 0; i < breatheList.length; i++) {
        if (breatheList[i]['value1'] > 0 && breatheList[i]['value9'] > 0) {
          data.add(new RecordData(i, breatheList[i]['value1']));
          data.add(new RecordData(i, breatheList[i]['value2']));
          data.add(new RecordData(i, breatheList[i]['value3']));
          data.add(new RecordData(i, breatheList[i]['value4']));
          data.add(new RecordData(i, breatheList[i]['value5']));
          data.add(new RecordData(i, breatheList[i]['value6']));
          data.add(new RecordData(i, breatheList[i]['value7']));
          data.add(new RecordData(i, breatheList[i]['value8']));
          data.add(new RecordData(i, breatheList[i]['value9']));
          data.add(new RecordData(i, breatheList[i]['value10']));
          data.add(new RecordData(i, breatheList[i]['value11']));
          data.add(new RecordData(i, breatheList[i]['value12']));
          data.add(new RecordData(i, breatheList[i]['value13']));
          data.add(new RecordData(i, breatheList[i]['value14']));
          data.add(new RecordData(i, breatheList[i]['value15']));
          data.add(new RecordData(i, breatheList[i]['value16']));
        }
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
      breatheChart['hours'] = hour.toString();
      breatheChart['minutes'] = minute.toString();
      breatheChart['seconds'] = second.toString();
      breatheChart['chart'] = charts.LineChart(chartdata, animate: false);
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget row = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Material(
              borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              color: Colors.white,
              child: InkWell(
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
                          child: (_ready)
                              ? breatheChart['chart']
                              : Center(child: Text('圖表載入中')),
                        ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[row],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('睡眠呼吸檢測數據', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: body,
    );
  }
}
