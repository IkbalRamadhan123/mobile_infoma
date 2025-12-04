class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String userType; // 'mahasiswa', 'penyedia', 'admin'
  final String? profileImage;
  final String? bio;
  final String address;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.userType,
    this.profileImage,
    this.bio,
    required this.address,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'userType': userType,
      'profileImage': profileImage,
      'bio': bio,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
    if (includeId) {
      map['id'] = id;
    }
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String,
      userType: map['userType'] as String,
      profileImage: map['profileImage'] as String?,
      bio: map['bio'] as String?,
      address: map['address'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: (map['isActive'] as int) == 1,
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? userType,
    String? profileImage,
    String? bio,
    String? address,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
