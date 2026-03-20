class ShopkeeperProfile {
  final String id;
  final String name;
  final String username;
  final String email;
  final String location;

  ShopkeeperProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.location,
  });

  ShopkeeperProfile copyWith({
    String? name,
    String? username,
    String? email,
    String? location,
  }) {
    return ShopkeeperProfile(
      id: this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      location: location ?? this.location,
    );
  }

  factory ShopkeeperProfile.fromJson(Map<String, dynamic> json) {
    return ShopkeeperProfile(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      username: json['username'] ?? '',
      email: json['email'],
      location: json['location']?['address'] ?? '',
    );
  }
}

class ReceiverProfile {
  final String id;
  final String name;
  final String username;
  final String email;
  final String location;

  ReceiverProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.location,
  });

  ReceiverProfile copyWith({
    String? name,
    String? username,
    String? email,
    String? location,
  }) {
    return ReceiverProfile(
      id: this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      location: location ?? this.location,
    );
  }

  factory ReceiverProfile.fromJson(Map<String, dynamic> json) {
    return ReceiverProfile(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      username: json['username'] ?? '',
      email: json['email'],
      location: json['location']?['address'] ?? '',
    );
  }
}

class ShopDetails {
  final String shopName;
  final String shopLocation;
  final String aboutShop;
  final String ownerName;
  final String phone;
  final String shopImageUrl;

  ShopDetails({
    required this.shopName,
    required this.shopLocation,
    required this.aboutShop,
    required this.ownerName,
    required this.phone,
    required this.shopImageUrl,
  });

  ShopDetails copyWith({
    String? shopName,
    String? shopLocation,
    String? aboutShop,
    String? ownerName,
    String? phone,
    String? shopImageUrl,
  }) {
    return ShopDetails(
      shopName: shopName ?? this.shopName,
      shopLocation: shopLocation ?? this.shopLocation,
      aboutShop: aboutShop ?? this.aboutShop,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      shopImageUrl: shopImageUrl ?? this.shopImageUrl,
    );
  }

  factory ShopDetails.fromJson(Map<String, dynamic> json) {
    return ShopDetails(
      shopName: json['name'] ?? '',
      shopLocation: json['location']?['address'] ?? '',
      aboutShop: json['description'] ?? '',
      ownerName: '', // Handled by profile
      phone: '', 
      shopImageUrl: json['imageUrl'] ?? '',
    );
  }
}
