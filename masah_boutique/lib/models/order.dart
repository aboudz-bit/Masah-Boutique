class Order {
  final int id;
  final String sessionId;
  final dynamic items;
  final int subtotal;
  final int shipping;
  final int discount;
  final int total;
  final String status;
  final String fulfillmentType;
  final String customerName;
  final String? customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final String shippingCity;
  final String shippingCountry;
  final String? trackingNumber;
  final String? discountCode;
  final String? notes;
  final String? createdAt;

  Order({
    required this.id,
    required this.sessionId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.status,
    required this.fulfillmentType,
    required this.customerName,
    this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingCountry,
    this.trackingNumber,
    this.discountCode,
    this.notes,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      sessionId: json['sessionId'] ?? json['session_id'] ?? '',
      items: json['items'],
      subtotal: json['subtotal'] ?? 0,
      shipping: json['shipping'] ?? 0,
      discount: json['discount'] ?? 0,
      total: json['total'] ?? 0,
      status: json['status'] ?? 'processing',
      fulfillmentType: json['fulfillmentType'] ?? json['fulfillment_type'] ?? 'delivery',
      customerName: json['customerName'] ?? json['customer_name'] ?? '',
      customerEmail: json['customerEmail'] ?? json['customer_email'],
      customerPhone: json['customerPhone'] ?? json['customer_phone'] ?? '',
      shippingAddress: json['shippingAddress'] ?? json['shipping_address'] ?? '',
      shippingCity: json['shippingCity'] ?? json['shipping_city'] ?? '',
      shippingCountry: json['shippingCountry'] ?? json['shipping_country'] ?? '',
      trackingNumber: json['trackingNumber'] ?? json['tracking_number'],
      discountCode: json['discountCode'] ?? json['discount_code'],
      notes: json['notes'],
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  String get formattedTotal {
    final riyals = total ~/ 100;
    final halalas = total % 100;
    return halalas > 0 ? '$riyals.$halalas SAR' : '$riyals SAR';
  }

  String getStatusText(String locale) {
    final statuses = {
      'processing': locale == 'ar' ? 'قيد المعالجة' : 'Processing',
      'confirmed': locale == 'ar' ? 'تم التأكيد' : 'Confirmed',
      'shipped': locale == 'ar' ? 'تم الشحن' : 'Shipped',
      'delivered': locale == 'ar' ? 'تم التوصيل' : 'Delivered',
      'cancelled': locale == 'ar' ? 'ملغي' : 'Cancelled',
    };
    return statuses[status] ?? status;
  }
}
