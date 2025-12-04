class Category {
  final int id;
  final String name;
  final String type; // 'hunian', 'kegiatan', 'marketplace'
  final String parentCategory; // for sub categories
  final bool isSubCategory;
  final String? icon;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.parentCategory = '',
    this.isSubCategory = false,
    this.icon,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'parentCategory': parentCategory,
      'isSubCategory': isSubCategory ? 1 : 0,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      parentCategory: map['parentCategory'] as String? ?? '',
      isSubCategory: (map['isSubCategory'] as int?) == 1,
      icon: map['icon'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
