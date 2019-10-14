import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../common/database.dart';

class EventsPage extends StatefulWidget {
  EventsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  EventsPageState createState() => EventsPageState();
}

class EventsPageState extends State<EventsPage> {
  MonitorDatabase database;
  bool _ready = false;

  Map<String, double> dataMap = new Map();
  List<Color> colorList = [
    Colors.red[400],
    Colors.yellow[400],
    Colors.blue[400],
  ];

  @override
  void initState() {
    super.initState();
    database = new MonitorDatabase();
    _draweventsChart();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _draweventsChart() async {
    int low = 0;
    int mid = 0;
    int high = 0;

    Map lastSleep = await database.getLatestSleepRecord();
    List risk = await database.getRiskRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    setState(() {
      for (int i = 0; i < risk.length; i++) {
        if (risk[i]['value'] > 80) {
          high++;
        } else if (risk[i]['value'] > 40) {
          mid++;
        } else if (risk[i]['value'] > 0) {
          low++;
        }
      }
      dataMap.putIfAbsent("80% ~ 100%", () => high.toDouble());
      dataMap.putIfAbsent("40% ~ 80%", () => mid.toDouble());
      dataMap.putIfAbsent("0% ~ 40%", () => low.toDouble());
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
                        '睡眠事件所占比',
                        style: TextStyle(fontSize: 24.0, color: Colors.blue),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 250.0),
                          child: (_ready)
                              ? PieChart(dataMap: dataMap, colorList: colorList)
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
        title: Text('睡眠事件所占比', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: body,
    );
  }
}
