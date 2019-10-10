import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'common/drawer.dart';

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _timeString;

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
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget row1 = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: new Container(
              margin: EdgeInsets.only(right: 5.0),
              padding: EdgeInsets.symmetric(vertical: 20.0),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Column(
                children: <Widget>[
                  Icon(FontAwesomeIcons.tint, color: Colors.red),
                  SizedBox(height: 10),
                  Text(
                    '血氧值',
                    style: TextStyle(fontSize: 24.0, color: Colors.blue),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '90%',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: new Container(
              margin: EdgeInsets.only(left: 5.0),
              padding: EdgeInsets.symmetric(vertical: 20.0),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Column(
                children: <Widget>[
                  Icon(FontAwesomeIcons.heartbeat, color: Colors.redAccent),
                  SizedBox(height: 10),
                  Text(
                    '心跳',
                    style: TextStyle(fontSize: 24.0, color: Colors.blue),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '85 BPM',
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
                    '呼吸中止風險值  87%',
                    style: TextStyle(fontSize: 24.0, color: Colors.blue),
                  ),
                ],
              ),
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

    Widget row4 = Padding(
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
                    _timeString,
                    style: TextStyle(fontSize: 28.0, color: Colors.blue),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(HomePage.tag);
                      },
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 60.0),
                      color: Colors.redAccent,
                      child: Text('開始記錄',
                          style: TextStyle(color: Colors.white, fontSize: 24)),
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
        children: <Widget>[row1, row2, row3, row4],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('睡眠呼吸檢測數據', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      drawer: MainDrawer(),
      body: body,
    );
  }
}
