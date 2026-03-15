import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  String get formattedSubtotal {
    final riyals = subtotal ~/ 100;
    final halalas = subtotal % 100;
    return halalas > 0 ? '$riyals.$halalas SAR' : '$riyals SAR';
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await ApiService.getCart();
    } catch (e) {
      print('Error loading cart: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart({
    required Product product,
    required String size,
    required String color,
    int quantity = 1,
  }) async {
    try {
      await ApiService.addToCart(
        productId: product.id,
        size: size,
        color: color,
        quantity: quantity,
      );
      await loadCart();
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    try {
      await ApiService.updateCartItem(itemId, quantity);
      await loadCart();
    } catch (e) {
      print('Error updating cart: $e');
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      await ApiService.removeFromCart(itemId);
      await loadCart();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await ApiService.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
}
