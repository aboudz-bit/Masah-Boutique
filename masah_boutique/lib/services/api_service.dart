import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/store.dart';

class ApiService {
  static String get baseUrl {
    // For web, use relative URLs; for mobile, configure the server URL
    const serverUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:5000');
    return serverUrl;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Products
  static Future<List<Product>> getProducts({String? category, String? search, bool? featured}) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (search != null) params['search'] = search;
    if (featured == true) params['featured'] = 'true';

    final uri = Uri.parse('$baseUrl/api/products').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }

  static Future<Product> getProduct(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/products/$id'), headers: _headers);

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load product');
  }

  // Cart
  static Future<List<CartItem>> getCart() async {
    final response = await http.get(Uri.parse('$baseUrl/api/cart'), headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CartItem.fromJson(json)).toList();
    }
    throw Exception('Failed to load cart');
  }

  static Future<CartItem> addToCart({
    required int productId,
    required String size,
    required String color,
    int quantity = 1,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/cart'),
      headers: _headers,
      body: json.encode({
        'productId': productId,
        'size': size,
        'color': color,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      return CartItem.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to add to cart');
  }

  static Future<void> updateCartItem(int id, int quantity) async {
    await http.patch(
      Uri.parse('$baseUrl/api/cart/$id'),
      headers: _headers,
      body: json.encode({'quantity': quantity}),
    );
  }

  static Future<void> removeFromCart(int id) async {
    await http.delete(Uri.parse('$baseUrl/api/cart/$id'), headers: _headers);
  }

  static Future<void> clearCart() async {
    await http.delete(Uri.parse('$baseUrl/api/cart'), headers: _headers);
  }

  // Orders
  static Future<Order> createOrder(Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: _headers,
      body: json.encode(orderData),
    );

    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create order');
  }

  static Future<List<Order>> getOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/api/orders'), headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    }
    throw Exception('Failed to load orders');
  }

  static Future<Order> getOrder(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/orders/$id'), headers: _headers);

    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load order');
  }

  // Stores
  static Future<List<Store>> getStores() async {
    final response = await http.get(Uri.parse('$baseUrl/api/stores'), headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Store.fromJson(json)).toList();
    }
    throw Exception('Failed to load stores');
  }

  // Discount validation
  static Future<Map<String, dynamic>?> validateDiscount(String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/discounts/validate'),
      headers: _headers,
      body: json.encode({'code': code}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
}
