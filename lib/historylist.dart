import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'common/database.dart';

class HistoryListPage extends StatefulWidget {
  HistoryListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  HistoryListPageState createState() => HistoryListPageState();
}

class HistoryListPageState extends State<HistoryListPage> {
  MonitorDatabase database;
  Widget _body = Container(alignment: Alignment.center, child: Text('資料載入中'));

  @override
  void initState() {
    super.initState();
    database = new MonitorDatabase();
    _drawList();
  }

  void _drawList() async {
    List sleeps = await database.getAllSleepRecord();
    setState(() {
      _body = ListView.builder(
          itemCount: sleeps.length,
          itemBuilder: (context, idx) {
            DateTime s = DateTime.fromMillisecondsSinceEpoch(
                sleeps[idx]['starttime'] * 1000);
            DateTime e = DateTime.fromMillisecondsSinceEpoch(
                sleeps[idx]['endtime'] * 1000);
            String start = DateFormat('MM-dd kk:mm').format(s);
            String end = DateFormat('MM-dd kk:mm').format(e);
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/history',
                      arguments: sleeps[idx]['starttime'] + 1);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        start + ' 至 ' + end,
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        sleeps[idx]['user'].toString(),
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('歷史紀錄', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _body,
    );
  }
}
