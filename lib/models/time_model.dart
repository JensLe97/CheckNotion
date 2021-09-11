import 'package:checknotion/models/item_model.dart';

class Time extends Item {
  String time;

  Time({required String title, required this.time}) : super(title: title);
  Time.withId({required int id, required String title, required this.time})
      : super.withId(id: id, title: title);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['time'] = time;
    return map;
  }

  @override
  factory Time.fromMap(Map<String, dynamic> map) {
    return Time.withId(id: map['id'], title: map['title'], time: map['time']);
  }
}
