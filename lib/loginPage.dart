import 'package:BudRate/Home.dart';
import 'package:BudRate/models/users.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
double rating = 0.0;
int nratings = 0;
String name;
String email;
String index;
String imageUrl = "http://pluspng.com/img-png/google-logo-png-open-2000.png";

Future<String> signInWithGoogle() async {
  WidgetsFlutterBinding.ensureInitialized();

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);

  name = user.displayName;
  email = user.email;
  imageUrl = user.photoUrl;

  /* if (name.contains(" ")) {
    name = name.substring(0, name.indexOf(" "));
  } */

  if (email.contains("@")) {
    index = email.substring(0, email.indexOf("@"));
  }

  return 'signInWithGoogle succeeded: $user';
}

Future signOutGoogle() async {
  googleSignIn.signOut();
  print("User Signed Out");
  name = "";
  email = "";
  imageUrl = "http://pluspng.com/img-png/google-logo-png-open-2000.png";
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> checkSignIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int login = prefs.getInt('login') ?? 0;
    if (login == 1) {
      await signInWithGoogle().whenComplete(() async {
        await createRecord();
        runApp(Home());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    checkSignIn();
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF0A0C1B), Color(0xFF202124)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /* Image(image: AssetImage("images/icon.png"), height: 200.0), */
              SizedBox(height: 20),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  "BudRate",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: 50),
              Directionality(
                textDirection: TextDirection.ltr,
                child: _signInButton(),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.white,
      onPressed: () async {
        await signInWithGoogle().whenComplete(() async {
          await createRecord();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('login', 1);
          runApp(Home());
          print("Signing in...");
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /* Image(image: AssetImage("images/google_logo.png"), height: 35.0), */
            Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future createRecord() async {
    final ref = FirebaseDatabase.instance.reference();

    ref.child(index).once().then((DataSnapshot data) {
      if (data.value == null || data.value.length == 0)
        ref.child(index).set({
          'key': index,
          'pic': imageUrl,
          'name': name,
          'rating': rating,
          'email': email,
          'nratings': nratings,
        });
      else {
        if (data.key == index) {
          rating = data.value['rating'].toDouble();
          nratings = data.value['nratings'];
          print(nratings);
          currentUser = User(
            key: index,
            pic: imageUrl,
            name: name,
            rating: rating,
            nrating: nratings,
          );
          return;
        } else
          ref.child(index).set({
            'key': index,
            'pic': imageUrl,
            'name': name,
            'rating': rating,
            'email': email,
            'nratings': nratings,
          });
      }
    });

    currentUser = User(
      key: index,
      pic: imageUrl,
      name: name,
      rating: rating,
      nrating: nratings,
    );
  }
}
