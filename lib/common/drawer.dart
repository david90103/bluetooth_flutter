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
            leading: Icon(Icons.home),
            title: Text('首頁'),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName(HomePage.tag));
            },
          ),
          ListTile(
            leading: Icon(Icons.link),
            title: Text('裝置連接'),
            onTap: () {
              Navigator.pushNamed(context, '/bluetooth');
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('歷史紀錄'),
            onTap: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
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
