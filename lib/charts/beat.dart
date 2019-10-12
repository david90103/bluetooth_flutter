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
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Beat Page'));
  }
}
