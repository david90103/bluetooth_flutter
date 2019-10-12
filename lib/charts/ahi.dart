import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import '../common/RecordData.dart';
import '../common/database.dart';

class AHIPage extends StatefulWidget {
  AHIPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  AHIPageState createState() => AHIPageState();
}

class AHIPageState extends State<AHIPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('AHI Page'));
  }
}
