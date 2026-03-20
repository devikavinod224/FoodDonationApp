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
  final String id;
  final String shopName;
  final String shopLocation;
  final String aboutShop;
  final String ownerName;
  final String phone;
  final String shopImageUrl;
  final String? distance;
  final double lat;
  final double lng;

  ShopDetails({
    required this.id,
    required this.shopName,
    required this.shopLocation,
    required this.aboutShop,
    required this.ownerName,
    required this.phone,
    required this.shopImageUrl,
    this.distance,
    required this.lat,
    required this.lng,
  });

  factory ShopDetails.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    return ShopDetails(
      id: json['_id'] ?? json['id'] ?? '',
      shopName: json['name'] ?? '',
      shopLocation: location['address'] ?? '',
      aboutShop: json['description'] ?? '',
      ownerName: '', // Handled by profile if needed
      phone: '', 
      shopImageUrl: json['imageUrl'] ?? '',
      distance: json['distance'] != null ? '${(json['distance'] / 1000).toStringAsFixed(1)} km' : null,
      lat: (location['lat'] ?? 0).toDouble(),
      lng: (location['lng'] ?? 0).toDouble(),
    );
  }
}
