class Event {
  final int? id;
  final String title;
  final DateTime date;

  Event({this.id, required this.title, required this.date});

  Event copyWith({int? id, String? title, DateTime? date}) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'date': date.toIso8601String()};
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
    );
  }
}
