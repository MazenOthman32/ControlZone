class Todo {
  final int? id;
  final String task;
  final bool isDone;

  Todo({this.id, required this.task, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {'id': id, 'task': task, 'isDone': isDone ? 1 : 0};
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(id: map['id'], task: map['task'], isDone: map['isDone'] == 1);
  }

  Todo copyWith({int? id, String? task, bool? isDone}) {
    return Todo(
      id: id ?? this.id,
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
    );
  }
}
