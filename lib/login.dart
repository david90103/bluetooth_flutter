import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool wife = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBackground(
        behaviour: BubblesBehaviour(options: BubbleOptions()),
        vsync: this,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: Container(),
            ),
            Expanded(
              flex: 1,
              child: Card(
                child: SignInButton(
                  Buttons.Google,
                  onPressed: () {
                    Navigator.of(context).pushNamed(HomePage.tag);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Card(
                child: SignInButton(
                  Buttons.GitHub,
                  text: 'View source on Github',
                  onPressed: () async {
                    const url =
                        'https://github.com/david90103/bluetooth_flutter';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
