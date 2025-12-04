class History {
  final int id;
  final int studentId;
  final int listingId;
  final String type; // 'viewed', 'bookmarked'
  final DateTime viewedAt;

  History({
    required this.id,
    required this.studentId,
    required this.listingId,
    required this.type,
    required this.viewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'listingId': listingId,
      'type': type,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'] as int,
      studentId: map['studentId'] as int,
      listingId: map['listingId'] as int,
      type: map['type'] as String,
      viewedAt: DateTime.parse(map['viewedAt'] as String),
    );
  }
}
