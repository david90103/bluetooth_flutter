import 'package:flutter/material.dart';
import 'bluetooth/MainPage.dart' as bluetooth;
import 'details.dart';
import 'home.dart';
import 'login.dart';
import 'history.dart';
import 'charts/ahi.dart';
import 'charts/beat.dart';
import 'charts/breathe.dart';
import 'charts/events.dart';
import 'charts/oxygen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    '/bluetooth': (context) => bluetooth.MainPage(),
    '/details': (context) => DetailsPage(),
    '/history': (context) => HistoryPage(),
    '/history/beat': (context) => BeatPage(),
    '/history/oxygen': (context) => OxygenPage(),
    '/history/events': (context) => EventsPage(),
    '/history/ahi': (context) => AHIPage(),
    '/history/breathe': (context) => BreathePage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '睡眠呼吸檢測數據',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Nunito',
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}
