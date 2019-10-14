import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import '../common/RecordData.dart';
import '../common/database.dart';

class BeatPage extends StatefulWidget {
  BeatPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  BeatPageState createState() => BeatPageState();
}

class BeatPageState extends State<BeatPage> {
  MonitorDatabase database;
  bool _ready = false;

  double beatMin = 999;
  double beatMax = 0;

  Map beatChart = {
    'chart': null,
  };

  @override
  void initState() {
    super.initState();
    database = new MonitorDatabase();
    _drawbeatChart();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _drawbeatChart() async {
    Map lastSleep = await database.getLatestSleepRecord();

    List beatList = await database.getBeatsRecord(
        lastSleep['starttime'], lastSleep['endtime']);
    setState(() {
      List<RecordData> data = [];
      double value;
      for (int i = 0; i < beatList.length; i++) {
        value = beatList[i]['value'];
        if (value - 1 > 0) {
          if (beatMin > value) beatMin = value;
          if (beatMax < value) beatMax = value;
        }
        data.add(new RecordData(i, beatList[i]['value']));
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
      beatChart['chart'] = charts.LineChart(chartdata, animate: false);
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
                        '心跳數據',
                        style: TextStyle(fontSize: 24.0, color: Colors.blue),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 200.0),
                          child: (_ready)
                              ? beatChart['chart']
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
                                Text('最低心跳',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 18)),
                                Text(beatMin.round().toString() + ' BPM',
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
                                Text('最高心跳',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 18)),
                                Text(beatMax.round().toString() + ' BPM',
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
        title: Text('心跳數據', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: body,
    );
  }
}
