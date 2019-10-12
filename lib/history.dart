import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'common/database.dart';
import 'common/RecordData.dart';

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}

class HistoryPage extends StatefulWidget {
  HistoryPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  MonitorDatabase database;
  String ahi = '--';
  String beatsCount = '--';
  String eventCount = '--';

  Map oxygenChart = {
    'average': '--',
    'discription': '睡眠品質不佳 🐣(假資料)',
    'chart': null,
  };

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
    _drawOxygenChart();
    _drawBreatheChart();
    _drawBeats();
    // _drawEventsChart();
    // _drawAHI();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _drawOxygenChart() async {
    Map lastSleep = await database.getLatestSleepRecord();

    List oxygenList = await database.getOxygenRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    setState(() {
      List<RecordData> data = [];
      int sum = 0;
      for (int i = 0; i < oxygenList.length; i++) {
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
      oxygenChart['chart'] = charts.LineChart(chartdata, animate: false);
      oxygenChart['average'] = (sum ~/ data.length).toString();
    });
  }

  Future _drawBeats() async {
    Map lastSleep = await database.getLatestSleepRecord();
    List beatsList = await database.getBeatsRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    setState(() {
      double sum = 0;
      for (int i = 0; i < beatsList.length; i++) {
        if (beatsList[i]['value'] > 0) sum += beatsList[i]['value'];
      }
      beatsCount = (sum ~/ beatsList.length).toString();
    });
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
    });
  }

  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final data = [
      new LinearSales(0, 5),
      new LinearSales(1, 65),
      new LinearSales(2, 46),
      new LinearSales(3, 100),
    ];

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                  print('tap');
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
                      Text(
                        oxygenChart['discription'],
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[600]),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 200.0),
                          child: oxygenChart['chart'],
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

    Widget row2 = Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: new Material(
                borderRadius: new BorderRadius.all(Radius.circular(15.0)),
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    print('tap');
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
                          '共' + eventCount + '次',
                          style: TextStyle(
                              fontSize: 18.0, color: Colors.grey[800]),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 160.0),
                          child: charts.PieChart(_createSampleData(),
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
                        print('tap');
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
                        print('tap');
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10.0, left: 10.0),
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
                              beatsCount + ' 次',
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
                  print('tap');
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
        children: <Widget>[row1, row2, row3],
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
