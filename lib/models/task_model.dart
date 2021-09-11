import 'package:checknotion/models/item_model.dart';

class Task extends Item {
  int done; // 1 = Done, 0 = not done

  Task({required String title, required this.done}) : super(title: title);
  Task.withId({required int? id, required String title, required this.done})
      : super.withId(id: id, title: title);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['done'] = done;
    return map;
  }

  @override
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(id: map['id'], title: map['title'], done: map['done']);
  }
}
