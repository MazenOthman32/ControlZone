class WaterLog {
  final int? id;
  final int amount; // in milliliters
  final DateTime date;

  WaterLog({this.id, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'amount': amount, 'date': date.toIso8601String()};
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }

  WaterLog copyWith({int? id, int? amount, DateTime? date}) {
    return WaterLog(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
