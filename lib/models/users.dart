class User {
  String key;
  String pic;
  String name;
  double rating;
  int nrating;

  User({
    this.key = "",
    this.pic = "",
    this.name = "",
    this.rating = 0.0,
    this.nrating = 0,
  });
}

User currentUser;
