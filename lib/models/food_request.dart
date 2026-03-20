enum RequestStatus { pending, accepted, rejected }

class FoodRequest {
  final String id;
  final String foodId;
  final String foodName;
  final String foodImage;
  final String foodCategory;
  final int requestedQty;
  final String receiverName;
  final String receiverId;
  final String shopName;
  final String shopId;
  final RequestStatus status;
  final DateTime createdAt;

  FoodRequest({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.foodImage,
    required this.foodCategory,
    required this.requestedQty,
    required this.receiverName,
    required this.receiverId,
    required this.shopName,
    required this.shopId,
    this.status = RequestStatus.pending,
    required this.createdAt,
  });

  FoodRequest copyWith({
    RequestStatus? status,
  }) {
    return FoodRequest(
      id: this.id,
      foodId: this.foodId,
      foodName: this.foodName,
      foodImage: this.foodImage,
      foodCategory: this.foodCategory,
      requestedQty: this.requestedQty,
      receiverName: this.receiverName,
      receiverId: this.receiverId,
      shopName: this.shopName,
      shopId: this.shopId,
      status: status ?? this.status,
      createdAt: this.createdAt,
    );
  }

  factory FoodRequest.fromJson(Map<String, dynamic> json) {
    return FoodRequest(
      id: json['_id'] ?? json['id'],
      foodId: json['foodId'],
      foodName: json['foodName'],
      foodImage: json['foodImage'] ?? '',
      foodCategory: json['foodCategory'] ?? '',
      requestedQty: json['requestedQty'],
      receiverName: json['receiverName'],
      receiverId: json['receiverId'],
      shopName: json['shopName'],
      shopId: json['shopkeeperId'] ?? json['shopId'],
      status: _parseStatus(json['status']),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static RequestStatus _parseStatus(String? status) {
    switch (status) {
      case 'accepted': return RequestStatus.accepted;
      case 'rejected': return RequestStatus.rejected;
      default: return RequestStatus.pending;
    }
  }
}
