class Bookmark {
  final int id;
  final int listingId;
  final int studentId;
  final DateTime bookmarkedAt;

  Bookmark({
    required this.id,
    required this.listingId,
    required this.studentId,
    required this.bookmarkedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'studentId': studentId,
      'bookmarkedAt': bookmarkedAt.toIso8601String(),
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int,
      listingId: map['listingId'] as int,
      studentId: map['studentId'] as int,
      bookmarkedAt: DateTime.parse(map['bookmarkedAt'] as String),
    );
  }
}
