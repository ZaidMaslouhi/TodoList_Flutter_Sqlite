class Task {
  int id;
  String description;

  Task({this.id, this.description});

  Map<String, dynamic> toMap() =>
      <String, dynamic>{'id': id, 'description': description};

  Task.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    description = map['description'];
  }
}
