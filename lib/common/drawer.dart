import 'package:flutter/material.dart';
import 'package:bluetooth_app/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../login.dart';

class MainDrawer extends StatefulWidget {
  MainDrawer({Key key}) : super(key: key);
  @override
  MainDrawerState createState() => MainDrawerState();
}

class MainDrawerState extends State<MainDrawer> {
  FirebaseUser _user;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Stack(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  height: 50,
                  child: ClipOval(
                    child: (_user != null)
                        ? Image.network(_user.photoUrl, fit: BoxFit.cover)
                        : null,
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(FontAwesomeIcons.signOutAlt),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      await LoginPageState.googleSignIn.signOut();
                      LoginPageState.googleAccount = null;
                      _user = null;
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        (_user != null) ? _user.displayName : '尚未登入',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        (_user != null) ? _user.email : '',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ],
            ),
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
              Navigator.pushNamed(context, '/historylist');
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('更多資訊'),
            onTap: () {
              Navigator.pushNamed(context, '/details');
            },
          ),
        ],
      ),
    );
  }
}
