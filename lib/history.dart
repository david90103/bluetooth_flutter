import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'common/database.dart';

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
    'discription': '--',
    'chart': _createSampleData(),
  };

  Map breatheChart = {
    'hours': '--',
    'minutes': '--',
    'seconds': '--',
    'compare': '比平均多30分鐘',
    'chart': _createSampleData(),
  };

  @override
  void initState() {
    super.initState();
    database = new MonitorDatabase();
    _drawOxygenChart();
    _drawBreatheChart();
    // _drawEventsChart();
    // _drawAHI();
    // _drawWarning();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _drawOxygenChart() async {
    setState(() {
      //
    });
  }

  Future _drawBreatheChart() async {
    Map lastSleep = await database.getLatestSleepRecord();

    int hour = (lastSleep['endtime'] - lastSleep['starttime']) ~/ 3600;
    int minute = (lastSleep['endtime'] - lastSleep['starttime']) % 3600 ~/ 60;
    int second = (lastSleep['endtime'] - lastSleep['starttime']) % 60;

    setState(() {
      breatheChart['hours'] = hour.toString();
      breatheChart['minutes'] = minute.toString();
      breatheChart['seconds'] = second.toString();
    });
  }

  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final data = [
      new LinearSales(0, 5),
      new LinearSales(1, 25),
      new LinearSales(2, 100),
      new LinearSales(3, 75),
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
            child: new Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    '整夜血氧數據',
                    style: TextStyle(fontSize: 24.0, color: Colors.blue),
                  ),
                  Text(
                    oxygenChart['average'],
                    style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                  ),
                  Text(
                    oxygenChart['discription'],
                    style: TextStyle(fontSize: 20.0, color: Colors.grey[600]),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(height: 200.0),
                      child:
                          charts.LineChart(_createSampleData(), animate: false),
                    ),
                  ),
                ],
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
            child: new Container(
              margin: EdgeInsets.only(right: 5.0),
              padding: EdgeInsets.only(top: 20.0),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    '睡眠事件所占比',
                    style: TextStyle(fontSize: 20.0, color: Colors.blue),
                  ),
                  Text(
                    '共' + eventCount + '次',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey[800]),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.expand(height: 160.0),
                    child:
                        charts.PieChart(oxygenChart['chart'], animate: false),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10.0, left: 10.0),
                  padding: EdgeInsets.symmetric(vertical: 25.0),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'AHI指數',
                        style: TextStyle(fontSize: 20.0, color: Colors.blue),
                      ),
                      Text(
                        ahi + ' 次/hr',
                        style:
                            TextStyle(fontSize: 18.0, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, left: 10.0),
                  padding: EdgeInsets.symmetric(vertical: 25.0),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        '心跳次數❤️',
                        style: TextStyle(fontSize: 20.0, color: Colors.blue),
                      ),
                      Text(
                        beatsCount + ' 次',
                        style:
                            TextStyle(fontSize: 18.0, color: Colors.grey[800]),
                      ),
                    ],
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
            child: new Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              ),
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
                    style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                  ),
                  Text(
                    breatheChart['compare'],
                    style: TextStyle(fontSize: 20.0, color: Colors.grey[600]),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(height: 200.0),
                      child: charts.LineChart(breatheChart['chart'],
                          animate: false),
                    ),
                  ),
                ],
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
