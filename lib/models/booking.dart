class Booking {
  final int id;
  final int listingId;
  final int studentId;
  final int providerId;
  final String bookingType; // 'booking', 'registrasi', 'pembelian'
  final String status; // 'pending', 'approved', 'rejected', 'completed'
  final String? rejectionReason;
  final int quantity;
  final double totalPrice;
  final DateTime bookingDate;
  final DateTime? completionDate;
  final String? notes;

  Booking({
    required this.id,
    required this.listingId,
    required this.studentId,
    required this.providerId,
    required this.bookingType,
    required this.status,
    this.rejectionReason,
    this.quantity = 1,
    required this.totalPrice,
    required this.bookingDate,
    this.completionDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'studentId': studentId,
      'providerId': providerId,
      'bookingType': bookingType,
      'status': status,
      'rejectionReason': rejectionReason,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'bookingDate': bookingDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as int,
      listingId: map['listingId'] as int,
      studentId: map['studentId'] as int,
      providerId: map['providerId'] as int,
      bookingType: map['bookingType'] as String,
      status: map['status'] as String,
      rejectionReason: map['rejectionReason'] as String?,
      quantity: map['quantity'] as int? ?? 1,
      totalPrice: (map['totalPrice'] as num).toDouble(),
      bookingDate: DateTime.parse(map['bookingDate'] as String),
      completionDate: map['completionDate'] != null
          ? DateTime.parse(map['completionDate'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }

  Booking copyWith({
    int? id,
    int? listingId,
    int? studentId,
    int? providerId,
    String? bookingType,
    String? status,
    String? rejectionReason,
    int? quantity,
    double? totalPrice,
    DateTime? bookingDate,
    DateTime? completionDate,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      studentId: studentId ?? this.studentId,
      providerId: providerId ?? this.providerId,
      bookingType: bookingType ?? this.bookingType,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      bookingDate: bookingDate ?? this.bookingDate,
      completionDate: completionDate ?? this.completionDate,
      notes: notes ?? this.notes,
    );
  }
}
