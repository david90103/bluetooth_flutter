import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home.dart';

class StateModel {
  bool isLoading;
  FirebaseUser user;
  StateModel({
    this.isLoading = false,
    this.user,
  });
}

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  StateModel state;
  GoogleSignInAccount googleAccount;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<Null> initUser() async {
    googleAccount = await getSignedInAccount(googleSignIn);
    if (googleAccount == null) {
      setState(() {
        state.isLoading = false;
      });
    }
  }

  Future<Null> signInWithGoogle() async {
    if (googleAccount != null) {
      await googleSignIn.signOut();
    }
    // Start the sign-in process:
    googleAccount = await googleSignIn.signIn();
    FirebaseUser firebaseUser = await signIntoFirebase(googleAccount);
    state.user = firebaseUser; // new user
    setState(() {
      state.isLoading = false;
      state.user = firebaseUser;
      print(state.user);
      Navigator.of(context).pushNamed(HomePage.tag, arguments: state.user);
    });
  }

  Future<GoogleSignInAccount> getSignedInAccount(
      GoogleSignIn googleSignIn) async {
    GoogleSignInAccount account = googleSignIn.currentUser;
    if (account == null) {
      account = await googleSignIn.signInSilently();
    }
    return account;
  }

  Future<FirebaseUser> signIntoFirebase(
      GoogleSignInAccount googleSignInAccount) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return (await _auth.signInWithCredential(credential)).user;
  }

  @override
  void initState() {
    super.initState();
    state = new StateModel(isLoading: true);
    initUser();
  }

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
                    signInWithGoogle();
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Card(
                child: SignInButton(
                  Buttons.GitHub,
                  text: 'View source code on Github',
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
