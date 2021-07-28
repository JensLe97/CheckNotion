class Task {
  int? id;
  String title;
  int done; // 1 = Done, 0 = not done

  Task({required this.title, required this.done});
  Task.withId({required this.id, required this.title, required this.done});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) map['id'] = id;

    map['title'] = title;
    map['done'] = done;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(id: map['id'], title: map['title'], done: map['done']);
  }
}
