class OrderModel {
  final String id;
  final String customerId;
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final String paymentMethod;
  final String? paymentProofUrl;
  final double latitude;
  final double longitude;
  final String addressText;
  final String status;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.totalPrice,
    required this.paymentMethod,
    this.paymentProofUrl,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    this.status = 'pending',
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      items: json['items'] is List ? List<Map<String, dynamic>>.from(json['items']) : [],
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method']?.toString() ?? 'cod',
      paymentProofUrl: json['payment_proof_url']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? -6.208845,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 106.845612,
      addressText: json['address_text']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'items': items,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'payment_proof_url': paymentProofUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address_text': addressText,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}