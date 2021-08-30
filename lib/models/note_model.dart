import 'package:little_tricks/models/item_model.dart';

class Note extends Item {
  String content;

  Note({required String title, required this.content}) : super(title: title);
  Note.withId({required int? id, required String title, required this.content})
      : super.withId(id: id, title: title);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['content'] = content;
    return map;
  }

  @override
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note.withId(
        id: map['id'], title: map['title'], content: map['content']);
  }
}
