import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import '../common/database.dart';

class BarChartElement {
  final String key;
  final int value;
  BarChartElement(this.key, this.value);
}

class AHIPage extends StatefulWidget {
  AHIPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  AHIPageState createState() => AHIPageState();
}

class AHIPageState extends State<AHIPage> {
  MonitorDatabase database;
  bool _ready = false;

  int ahiMin = 999;
  int ahiMax = 0;

  Map ahiChart = {
    'chart': null,
  };

  @override
  void initState() {
    super.initState();
    database = new MonitorDatabase();
    _drawAHIChart();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _drawAHIChart() async {
    Map lastSleep = await database.getLatestSleepRecord();
    List risk = await database.getRiskRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    setState(() {
      List<BarChartElement> data = [];
      List<int> hoursList = new List.filled(24, -1);

      for (int i = 0; i < risk.length; i++) {
        if (i + 1 < risk.length &&
            risk[i]['value'] > 80 &&
            risk[i + 1]['value'] < 80) {
          //轉換時戳至小時
          int hour =
              DateTime.fromMillisecondsSinceEpoch(risk[i]['datetime'] * 1000)
                  .hour;
          if (hoursList[hour - 1] < 0) hoursList[hour - 1] = 0;
          hoursList[hour - 1]++;
        }
        if (ahiMin > risk[i]['value']) ahiMin = risk[i]['value'];
        if (ahiMax < risk[i]['value']) ahiMax = risk[i]['value'];
      }

      for (int i = 0; i < hoursList.length; i++) {
        if (hoursList[i] > -1) {
          data.add(
              new BarChartElement(((i + 1) % 24).toString(), hoursList[i]));
        }
      }
      var chartdata = [
        new charts.Series<BarChartElement, String>(
          id: 'Records',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (BarChartElement rec, _) => rec.key,
          measureFn: (BarChartElement rec, _) => rec.value,
          data: data,
        )
      ];
      ahiChart['chart'] = charts.BarChart(chartdata, animate: false);
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
                        'AHI指數紀錄',
                        style: TextStyle(fontSize: 24.0, color: Colors.blue),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 200.0),
                          child: (_ready)
                              ? ahiChart['chart']
                              : Center(child: Text('圖表載入中')),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(children: <Widget>[
                                Text('最低AHI',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 18)),
                                Text(ahiMin.round().toString() + ' %',
                                    style: TextStyle(
                                        color: Colors.blueGrey[600],
                                        fontSize: 18)),
                              ]),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(children: <Widget>[
                                Text('最高AHI',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 18)),
                                Text(ahiMax.round().toString() + ' %',
                                    style: TextStyle(
                                        color: Colors.blueGrey[600],
                                        fontSize: 18)),
                              ]),
                            ),
                          ),
                        ],
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
        title: Text('AHI指數紀錄', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: body,
    );
  }
}
