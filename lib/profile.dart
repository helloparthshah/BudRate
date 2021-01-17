import 'package:BudRate/loginPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/users.dart';

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User cuser = User();

  @override
  void initState() {
    final ref = FirebaseDatabase.instance.reference();

    ref.child(index).once().then((DataSnapshot data) async {
      var values = data.value;
      setState(() {
        cuser = User(
          key: values['key'],
          pic: values['pic'].toString(),
          name: values['name'].toString(),
          rating: values['rating'].toDouble(),
          nrating: values['nratings'].toInt(),
        );
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF0A0C1B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: 70.0,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) {
                        return Icon(
                          index < cuser.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.white,
                          size: 30.0,
                        );
                      },
                    ),
                  ),
                  Text(
                    cuser.rating.toStringAsFixed(2) +
                        " Stars by " +
                        cuser.nrating.toString() +
                        " users",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        splashColor: Colors.white,
                        onPressed: () async {
                          signOutGoogle();
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setInt('login', 0);
                          runApp(LoginPage());
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        highlightElevation: 0,
                        borderSide: BorderSide(color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 100.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: Center(
              child: Column(
                children: <Widget>[
                  Opacity(
                    opacity: 0.5,
                    child: Icon(
                      FontAwesomeIcons.chevronUp,
                      size: 50.0,
                    ),
                  ),
                  Text(
                    "Swipe up",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
