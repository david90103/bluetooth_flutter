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
  int historyTime = 0;
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _drawbeatChart({time = 0}) async {
    Map lastSleep;
    if (time == 0 || time == null) {
      lastSleep = await database.getLatestSleepRecord();
    } else {
      lastSleep = await database.getHistorySleepRecord(time);
    }

    List beatList = await database.getBeatsRecord(
        lastSleep['starttime'], lastSleep['endtime']);
    setState(() {
      List<RecordData> data = [];
      double value;
      for (int i = 0; i < beatList.length; i++) {
        value = beatList[i]['value'];
        if (value - 1 > 0) {
          if (value > 140) value = 140;
          if (value < 60) value = 60;
          if (beatMin > value) beatMin = value;
          if (beatMax < value) beatMax = value;
        }
        data.add(new RecordData(i, value));
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
      beatChart['chart'] = charts.LineChart(
        chartdata,
        animate: false,
        primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec: new charts.StaticNumericTickProviderSpec(
            <charts.TickSpec<num>>[
              charts.TickSpec<num>(60),
              charts.TickSpec<num>(100),
              charts.TickSpec<num>(140),
            ],
          ),
        ),
      );
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (historyTime == 0) {
      historyTime = ModalRoute.of(context).settings.arguments;
      _drawbeatChart(time: historyTime);
    }
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
