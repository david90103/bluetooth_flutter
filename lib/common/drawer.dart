import 'package:flutter/material.dart';
import 'package:bluetooth_app/home.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              Navigator.popUntil(context, ModalRoute.withName(HomePage.tag));
            },
          ),
          ListTile(
            title: Text('裝置連接'),
            onTap: () {
              Navigator.pushNamed(context, '/bluetooth');
            },
          ),
          ListTile(
            title: Text('歷史紀錄'),
            onTap: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          ListTile(
            title: Text('詳細資訊'),
            onTap: () {
              Navigator.pushNamed(context, '/details');
            },
          ),
        ],
      ),
    );
  }
}
