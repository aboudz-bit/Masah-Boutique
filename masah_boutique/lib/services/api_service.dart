import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/store.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      final uri = Uri.base;
      return '${uri.scheme}://${uri.host}:${uri.port}';
    }
    return const String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:5000');
  }

  static final http.Client _client = http.Client();
  static String? _cookie;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_cookie != null) 'Cookie': _cookie!,
  };

  static void _updateCookie(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      _cookie = setCookie.split(';').first;
    }
  }

  // Products
  static Future<List<Product>> getProducts({String? category, String? search, bool? featured}) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (search != null) params['search'] = search;
    if (featured == true) params['featured'] = 'true';

    final uri = Uri.parse('$baseUrl/api/products').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await _client.get(uri, headers: _headers);
    _updateCookie(response);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Product.fromJson(j)).toList();
    }
    throw Exception('Failed to load products');
  }

  static Future<Product> getProduct(int id) async {
    final response = await _client.get(Uri.parse('$baseUrl/api/products/$id'), headers: _headers);
    _updateCookie(response);

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load product');
  }

  // Cart
  static Future<List<CartItem>> getCart() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/cart'), headers: _headers);
    _updateCookie(response);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => CartItem.fromJson(j)).toList();
    }
    throw Exception('Failed to load cart');
  }

  static Future<CartItem> addToCart({
    required int productId,
    required String size,
    required String color,
    int quantity = 1,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/cart'),
      headers: _headers,
      body: json.encode({
        'productId': productId,
        'size': size,
        'color': color,
        'quantity': quantity,
      }),
    );
    _updateCookie(response);

    if (response.statusCode == 200) {
      return CartItem.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to add to cart');
  }

  static Future<void> updateCartItem(int id, int quantity) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl/api/cart/$id'),
      headers: _headers,
      body: json.encode({'quantity': quantity}),
    );
    _updateCookie(response);
  }

  static Future<void> removeFromCart(int id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/api/cart/$id'), headers: _headers);
    _updateCookie(response);
  }

  static Future<void> clearCart() async {
    final response = await _client.delete(Uri.parse('$baseUrl/api/cart'), headers: _headers);
    _updateCookie(response);
  }

  // Orders
  static Future<Order> createOrder(Map<String, dynamic> orderData) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: _headers,
      body: json.encode(orderData),
    );
    _updateCookie(response);

    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create order');
  }

  static Future<List<Order>> getOrders() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/orders'), headers: _headers);
    _updateCookie(response);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Order.fromJson(j)).toList();
    }
    throw Exception('Failed to load orders');
  }

  static Future<Order> getOrder(int id) async {
    final response = await _client.get(Uri.parse('$baseUrl/api/orders/$id'), headers: _headers);
    _updateCookie(response);

    if (response.statusCode == 200) {
      return Order.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load order');
  }

  // Stores
  static Future<List<Store>> getStores() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/stores'), headers: _headers);
    _updateCookie(response);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Store.fromJson(j)).toList();
    }
    throw Exception('Failed to load stores');
  }

  // Discount validation
  static Future<Map<String, dynamic>?> validateDiscount(String code) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/discounts/validate'),
      headers: _headers,
      body: json.encode({'code': code}),
    );
    _updateCookie(response);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  // Shipping quotes
  static Future<List<dynamic>> getShippingQuotes({
    required String destinationCity,
    required String destinationCountry,
    int itemCount = 1,
    int subtotal = 0,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/shipping/quote'),
      headers: _headers,
      body: json.encode({
        'destinationCity': destinationCity,
        'destinationCountry': destinationCountry,
        'itemCount': itemCount,
        'subtotal': subtotal,
      }),
    );
    _updateCookie(response);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get shipping quotes');
  }
}
