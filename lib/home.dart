import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}

class HomePage extends StatelessWidget {
  static String tag = 'home-page';

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
      padding: EdgeInsets.symmetric(vertical: 10.0),
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
                    '平均血氧值 87',
                    style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                  ),
                  Text(
                    '睡眠品質不佳 🐣',
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
                    '共150次',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey[800]),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.expand(height: 160.0),
                    child: charts.PieChart(_createSampleData(), animate: false),
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
                        '48次/hr',
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
                        '預警警報次數',
                        style: TextStyle(fontSize: 20.0, color: Colors.blue),
                      ),
                      Text(
                        '共85次',
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
      padding: EdgeInsets.symmetric(vertical: 15.0),
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
                    '睡眠時間6小時17分鐘',
                    style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                  ),
                  Text(
                    '比平均多30分鐘',
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

    Widget drawer = Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
            ),
          ),
          ListTile(
            title: Text('首頁'),
            onTap: () {
              // Update the state of the app.
            },
          ),
          ListTile(
            title: Text('裝置連接'),
            onTap: () {
              // Update the state of the app.
            },
          ),
          ListTile(
            title: Text('歷史紀錄'),
            onTap: () {
              // Update the state of the app.
            },
          ),
          ListTile(
            title: Text('設定'),
            onTap: () {
              // Update the state of the app.
            },
          ),
          ListTile(
            title: Text('詳細資訊'),
            onTap: () {
              // Update the state of the app.
            },
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('睡眠呼吸檢測數據', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      drawer: drawer,
      body: body,
    );
  }
}
