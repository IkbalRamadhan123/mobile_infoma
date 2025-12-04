class Listing {
  final int id;
  final int providerId;
  final String title;
  final String description;
  final String type; // 'hunian', 'kegiatan', 'marketplace'
  final String category; // main category
  final String subCategory; // sub category
  final double price;
  final String? image;
  final String? additionalImages; // JSON array of images
  final double? latitude;
  final double? longitude;
  final String? location;
  final int views;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime? eventDate; // for kegiatan
  final String? quota; // for kegiatan
  final String condition; // 'baru' or 'bekas' for marketplace
  final bool isActive;

  Listing({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.subCategory,
    required this.price,
    this.image,
    this.additionalImages,
    this.latitude,
    this.longitude,
    this.location,
    this.views = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    this.eventDate,
    this.quota,
    this.condition = 'baru',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerId': providerId,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'subCategory': subCategory,
      'price': price,
      'image': image,
      'additionalImages': additionalImages,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'views': views,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'eventDate': eventDate?.toIso8601String(),
      'quota': quota,
      'condition': condition,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id'] as int,
      providerId: map['providerId'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      category: map['category'] as String,
      subCategory: map['subCategory'] as String,
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String?,
      additionalImages: map['additionalImages'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      location: map['location'] as String?,
      views: map['views'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      eventDate: map['eventDate'] != null
          ? DateTime.parse(map['eventDate'] as String)
          : null,
      quota: map['quota'] as String?,
      condition: map['condition'] as String? ?? 'baru',
      isActive: (map['isActive'] as int?) == 1,
    );
  }

  Listing copyWith({
    int? id,
    int? providerId,
    String? title,
    String? description,
    String? type,
    String? category,
    String? subCategory,
    double? price,
    String? image,
    String? additionalImages,
    double? latitude,
    double? longitude,
    String? location,
    int? views,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? eventDate,
    String? quota,
    String? condition,
    bool? isActive,
  }) {
    return Listing(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      price: price ?? this.price,
      image: image ?? this.image,
      additionalImages: additionalImages ?? this.additionalImages,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      views: views ?? this.views,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      eventDate: eventDate ?? this.eventDate,
      quota: quota ?? this.quota,
      condition: condition ?? this.condition,
      isActive: isActive ?? this.isActive,
    );
  }
}
