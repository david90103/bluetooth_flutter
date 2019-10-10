import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
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
            Text('☎️\n'),
            Text('聯絡資訊: 臺中榮民總醫院胸腔內科', style: TextStyle(fontSize: 18)),
            Text('聯絡電話: 04-2359-2525', style: TextStyle(fontSize: 18)),
            SizedBox(
              height: 40,
              width: 200,
              child: Divider(
                height: 3.0,
                color: Colors.grey[300],
              ),
            ),
            Text('🛠\n'),
            Text('Version 0.0.1'),
            Text('Author: David Tsai'),
          ],
        ),
      ),
    );
  }
}
