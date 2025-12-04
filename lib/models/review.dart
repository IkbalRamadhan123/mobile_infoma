class Review {
  final int id;
  final int listingId;
  final int studentId;
  final double rating;
  final String title;
  final String comment;
  final DateTime createdAt;
  final bool isVerified; // verified purchase

  Review({
    required this.id,
    required this.listingId,
    required this.studentId,
    required this.rating,
    required this.title,
    required this.comment,
    required this.createdAt,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'studentId': studentId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified ? 1 : 0,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as int,
      listingId: map['listingId'] as int,
      studentId: map['studentId'] as int,
      rating: (map['rating'] as num).toDouble(),
      title: map['title'] as String,
      comment: map['comment'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isVerified: (map['isVerified'] as int?) == 1,
    );
  }
}
