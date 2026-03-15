import 'product.dart';

class CartItem {
  final int id;
  final String sessionId;
  final int productId;
  final int quantity;
  final String size;
  final String color;
  final Product? product;

  CartItem({
    required this.id,
    required this.sessionId,
    required this.productId,
    required this.quantity,
    required this.size,
    required this.color,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      sessionId: json['sessionId'] ?? json['session_id'] ?? '',
      productId: json['productId'] ?? json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  int get totalPrice => (product?.price ?? 0) * quantity;

  String get formattedTotal {
    final riyals = totalPrice ~/ 100;
    final halalas = totalPrice % 100;
    return halalas > 0 ? '$riyals.$halalas SAR' : '$riyals SAR';
  }
}
