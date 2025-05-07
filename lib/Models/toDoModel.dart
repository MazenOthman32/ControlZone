class Todo {
  final int? id;
  final String task;
  final bool isDone;
  final String category;

  Todo({
    this.id,
    required this.task,
    this.isDone = false,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'isDone': isDone ? 1 : 0,
      'category': category,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      task: map['task'],
      isDone: map['isDone'] == 1,
      category: map['category'],
    );
  }

  Todo copyWith({int? id, String? task, bool? isDone, String? category}) {
    return Todo(
      id: id ?? this.id,
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
      category: category ?? this.category,
    );
  }
}
