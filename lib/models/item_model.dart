abstract class Item {
  int? id;
  String title;

  Item({required this.title});
  Item.withId({required this.id, required this.title});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) map['id'] = id;
    map['title'] = title;

    return map;
  }
}
