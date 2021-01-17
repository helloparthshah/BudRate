import 'package:BudRate/loginPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'models/users.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class Explore extends StatefulWidget {
  Explore({Key key}) : super(key: key);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  TextEditingController editingController = TextEditingController();
  List<User> u = List<User>();
  List<User> l = List<User>();

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  void getUsers() {
    databaseReference.once().then((DataSnapshot snapshot) {
      setState(() {
        u.clear();
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          if (currentUser.key != values['key'])
            u.add(
              User(
                key: values['key'],
                pic: values['pic'],
                name: values['name'],
                rating: values['rating'].toDouble(),
                nrating: values['nratings'],
              ),
            );
        });
        l = u;
      });
    });
  }

  void filterSearchResults(String query) {
    List<User> dummySearchList = List<User>();
    dummySearchList.addAll(u);
    if (query.isNotEmpty) {
      List<User> dummyListData = List<User>();
      dummySearchList.forEach((item) {
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        l.clear();
        l.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        l.clear();
        l.addAll(u);
      });
    }
  }

  Future updRecord(int index, double rating) async {
    double newrating = (rating + (u[index].rating * u[index].nrating)) /
        (u[index].nrating + 1);

    databaseReference.child(u[index].key).update({
      'nratings': u[index].nrating + 1,
      'rating': newrating,
    });
    setState(() {
      u[index].nrating = u[index].nrating + 1;
      u[index].rating = rating;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        u[index].rating = newrating;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          onChanged: (value) {
            filterSearchResults(value);
          },
          controller: editingController,
          decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)))),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: l.length,
            itemBuilder: (context, index) {
              User user = l[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(user.pic),
                            radius: 30.0,
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Text(
                                user.name,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(fontSize: 20.0),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (i) {
                            return GestureDetector(
                              onTap: () {
                                updRecord(index, (i + 1).toDouble());
                              },
                              child: Icon(
                                i < num.parse(user.rating.toStringAsFixed(0))
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.black,
                                size: 30.0,
                              ),
                            );
                          }),
                        ),
                        Text(user.rating.toStringAsFixed(2) +
                            " Stars by " +
                            user.nrating.toString() +
                            " users"),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
