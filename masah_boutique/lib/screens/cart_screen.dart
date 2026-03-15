import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_provider.dart';
import '../services/locale_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final locale = context.watch<LocaleProvider>();
    final isAr = locale.isArabic;
    final lang = locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'سلة التسوق' : 'Shopping Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmClearCart(isAr),
            ),
        ],
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC8A96E)))
          : cart.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text(
                        isAr ? 'السلة فارغة' : 'Your cart is empty',
                        style: TextStyle(color: Colors.grey[500], fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAr ? 'ابدئي بالتسوق الآن!' : 'Start shopping now!',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF222240),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFC8A96E).withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                // Product image placeholder
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D1B4E),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.checkroom, color: Color(0xFFC8A96E), size: 30),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product?.getName(lang) ?? '',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.size} • ${item.color}',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.formattedTotal,
                                            style: const TextStyle(
                                              color: Color(0xFFC8A96E),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              _buildSmallButton(Icons.remove, () {
                                                if (item.quantity > 1) {
                                                  cart.updateQuantity(item.id, item.quantity - 1);
                                                } else {
                                                  cart.removeItem(item.id);
                                                }
                                              }),
                                              Container(
                                                width: 32,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              _buildSmallButton(Icons.add, () {
                                                cart.updateQuantity(item.id, item.quantity + 1);
                                              }),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                                  onPressed: () => cart.removeItem(item.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16162A),
                        border: Border(top: BorderSide(color: const Color(0xFFC8A96E).withOpacity(0.2))),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isAr ? 'المجموع' : 'Subtotal',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                                ),
                                Text(
                                  cart.formattedSubtotal,
                                  style: const TextStyle(
                                    color: Color(0xFFC8A96E),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC8A96E),
                                  foregroundColor: const Color(0xFF1A1A2E),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                                child: Text(isAr ? 'إتمام الطلب' : 'Checkout'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSmallButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFC8A96E).withOpacity(0.3)),
        ),
        child: Icon(icon, color: const Color(0xFFC8A96E), size: 16),
      ),
    );
  }

  void _confirmClearCart(bool isAr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222240),
        title: Text(isAr ? 'تفريغ السلة' : 'Clear Cart', style: const TextStyle(color: Colors.white)),
        content: Text(
          isAr ? 'هل تريدين تفريغ السلة بالكامل؟' : 'Are you sure you want to clear your cart?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? 'إلغاء' : 'Cancel', style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(context);
            },
            child: Text(isAr ? 'تفريغ' : 'Clear', style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
