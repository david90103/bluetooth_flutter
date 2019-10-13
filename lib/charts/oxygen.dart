import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import '../common/RecordData.dart';
import '../common/database.dart';

class OxygenPage extends StatefulWidget {
  OxygenPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  OxygenPageState createState() => OxygenPageState();
}

class OxygenPageState extends State<OxygenPage> {
  MonitorDatabase database;
  bool _ready = false;

  Map oxygenChart = {
    'average': '--',
    'discription': '睡眠品質不佳 🐣(假資料)',
    'chart': null,
  };

  int oxygenMin = 100;
  int oxygenMax = 0;

  @override
  void initState() {
    super.initState();
    database = new MonitorDatabase();
    _drawOxygenChart();
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
      int value;
      for (int i = 0; i < oxygenList.length; i++) {
        value = oxygenList[i]['value'];
        if (value > 0) {
          if (oxygenMin > value) oxygenMin = value;
          if (oxygenMax < value) oxygenMax = value;
          sum += value;
        }
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
                          child: (_ready)
                              ? oxygenChart['chart']
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
                                Text('最低血氧值',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 18)),
                                Text(oxygenMin.toString() + '%',
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
                                Text('最高血氧值',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 18)),
                                Text(oxygenMax.toString() + '%',
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
        title: Text('睡眠呼吸檢測數據', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: body,
    );
  }
}
