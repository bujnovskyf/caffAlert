class CoffeeLog {
  const CoffeeLog({
    required this.id,
    required this.userId,
    required this.createdAt,
  });

  factory CoffeeLog.fromJson(Map<String, dynamic> json) {
    return CoffeeLog(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  final int id;
  final String userId;
  final DateTime createdAt;
}
