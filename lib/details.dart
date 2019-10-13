import 'package:flutter/material.dart';
import 'package:get_version/get_version.dart';

class DetailsPage extends StatefulWidget {
  @override
  DetailsPageState createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
  String _version;

  final List<TableRow> _table = [
    TableRow(children: [
      Center(child: Text('嚴重程度')),
      Center(child: Text('AHI(次/hr)'))
    ]),
    TableRow(
        children: [Center(child: Text('輕度')), Center(child: Text('5~15'))]),
    TableRow(
        children: [Center(child: Text('中度')), Center(child: Text('15~30'))]),
    TableRow(children: [Center(child: Text('重度')), Center(child: Text('>30'))]),
  ];

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  void _getVersion() async {
    String version = await GetVersion.projectVersion;
    setState(() {
      _version = version;
    });
  }

  Widget _buildTable() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.blueGrey[50],
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('呼吸中止判別標準', style: TextStyle(fontSize: 22)),
            SizedBox(
              height: 10,
            ),
            Text('1. 呼吸氣流明顯下降', style: TextStyle(fontSize: 18)),
            Text('2. 血氧濃度下降3%以上', style: TextStyle(fontSize: 18)),
            _divider(Colors.grey[400]),
            Table(
              border: TableBorder(
                top: BorderSide(),
                left: BorderSide(),
                right: BorderSide(),
                bottom: BorderSide(),
                horizontalInside: BorderSide(),
                verticalInside: BorderSide(),
              ),
              children: _table,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(color) {
    return SizedBox(
      height: 40,
      width: 200,
      child: Divider(
        height: 3.0,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('睡眠呼吸檢測數據', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Padding(
            //   padding: EdgeInsets.all(30),
            //   child: Image.asset('assets/ahi_info.png'),
            // ),
            _buildTable(),
            _divider(Colors.grey[300]),
            Text('聯絡資訊: 臺中榮民總醫院胸腔內科', style: TextStyle(fontSize: 18)),
            Text('聯絡電話: 04-2359-2525', style: TextStyle(fontSize: 18)),
            _divider(Colors.grey[300]),
            Text('🛠\n'),
            Text('Version ' + _version),
            Text('Author: David Tsai'),
          ],
        ),
      ),
    );
  }
}
