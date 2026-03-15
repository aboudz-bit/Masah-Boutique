import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/cart_provider.dart';
import '../services/locale_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();

  String _fulfillmentType = 'delivery';
  String _country = 'SA';
  bool _isSubmitting = false;
  int _discountAmount = 0;
  String? _appliedDiscount;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final locale = context.watch<LocaleProvider>();
    final isAr = locale.isArabic;

    final shipping = cart.subtotal >= 15000 ? 0 : 1500;
    final total = cart.subtotal + shipping - _discountAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إتمام الطلب' : 'Checkout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Customer info
            _sectionTitle(isAr ? 'معلومات التواصل' : 'Contact Information'),
            const SizedBox(height: 12),
            _buildField(_nameController, isAr ? 'الاسم الكامل' : 'Full Name', Icons.person, required: true),
            _buildField(_phoneController, isAr ? 'رقم الجوال' : 'Phone Number', Icons.phone, required: true, keyboardType: TextInputType.phone),
            _buildField(_emailController, isAr ? 'البريد الإلكتروني (اختياري)' : 'Email (optional)', Icons.email, keyboardType: TextInputType.emailAddress),

            const SizedBox(height: 24),

            // Fulfillment type
            _sectionTitle(isAr ? 'طريقة الاستلام' : 'Fulfillment'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFulfillmentOption(
                    'delivery',
                    Icons.local_shipping,
                    isAr ? 'توصيل' : 'Delivery',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFulfillmentOption(
                    'pickup',
                    Icons.store,
                    isAr ? 'استلام من الفرع' : 'Pickup',
                  ),
                ),
              ],
            ),

            if (_fulfillmentType == 'delivery') ...[
              const SizedBox(height: 16),
              _buildField(_addressController, isAr ? 'العنوان' : 'Address', Icons.location_on, required: true),
              _buildField(_cityController, isAr ? 'المدينة' : 'City', Icons.location_city, required: true),
            ],

            const SizedBox(height: 24),

            // Discount code
            _sectionTitle(isAr ? 'كود الخصم' : 'Discount Code'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(isAr ? 'أدخلي الكود' : 'Enter code', Icons.local_offer),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _applyDiscount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222240),
                    foregroundColor: const Color(0xFFC8A96E),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: const Color(0xFFC8A96E).withOpacity(0.3)),
                    ),
                  ),
                  child: Text(isAr ? 'تطبيق' : 'Apply'),
                ),
              ],
            ),
            if (_appliedDiscount != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${isAr ? "تم تطبيق الكود:" : "Applied:"} $_appliedDiscount',
                  style: const TextStyle(color: Colors.green, fontSize: 13),
                ),
              ),

            // Notes
            const SizedBox(height: 24),
            _buildField(_notesController, isAr ? 'ملاحظات (اختياري)' : 'Notes (optional)', Icons.note, maxLines: 3),

            const SizedBox(height: 24),

            // Order summary
            _sectionTitle(isAr ? 'ملخص الطلب' : 'Order Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF222240),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC8A96E).withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _summaryRow(isAr ? 'المنتجات' : 'Subtotal', _formatPrice(cart.subtotal)),
                  _summaryRow(isAr ? 'الشحن' : 'Shipping', shipping == 0 ? (isAr ? 'مجاني' : 'Free') : _formatPrice(shipping)),
                  if (_discountAmount > 0)
                    _summaryRow(isAr ? 'الخصم' : 'Discount', '-${_formatPrice(_discountAmount)}', isDiscount: true),
                  const Divider(color: Color(0xFFC8A96E), height: 24),
                  _summaryRow(
                    isAr ? 'الإجمالي' : 'Total',
                    _formatPrice(total),
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitOrder(total, shipping),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8A96E),
                  foregroundColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF1A1A2E), strokeWidth: 2))
                    : Text(isAr ? 'تأكيد الطلب' : 'Place Order'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFFC8A96E), fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon,
      {bool required = false, TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(label, icon),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) return 'Required';
                return null;
              }
            : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[500]),
      prefixIcon: Icon(icon, color: const Color(0xFFC8A96E), size: 20),
      filled: true,
      fillColor: const Color(0xFF222240),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFC8A96E).withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFC8A96E).withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC8A96E)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildFulfillmentOption(String type, IconData icon, String label) {
    final isSelected = _fulfillmentType == type;
    return GestureDetector(
      onTap: () => setState(() => _fulfillmentType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC8A96E).withOpacity(0.1) : const Color(0xFF222240),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFC8A96E) : const Color(0xFFC8A96E).withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFC8A96E), size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? const Color(0xFFC8A96E) : Colors.grey[400], fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.normal)),
          Text(value, style: TextStyle(
            color: isDiscount ? Colors.green : (isBold ? const Color(0xFFC8A96E) : Colors.white),
            fontSize: isBold ? 20 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          )),
        ],
      ),
    );
  }

  String _formatPrice(int halalas) {
    final riyals = halalas ~/ 100;
    final h = halalas % 100;
    return h > 0 ? '$riyals.$h SAR' : '$riyals SAR';
  }

  Future<void> _applyDiscount() async {
    final code = _discountController.text.trim();
    if (code.isEmpty) return;

    final result = await ApiService.validateDiscount(code);
    if (result != null) {
      final cart = context.read<CartProvider>();
      int discount = 0;
      if (result['type'] == 'percentage') {
        discount = (cart.subtotal * result['value'] / 100).round();
      } else {
        discount = result['value'];
      }
      setState(() {
        _discountAmount = discount;
        _appliedDiscount = code.toUpperCase();
      });
    } else {
      if (mounted) {
        final isAr = context.read<LocaleProvider>().isArabic;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'كود الخصم غير صالح' : 'Invalid discount code'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _submitOrder(int total, int shipping) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final cart = context.read<CartProvider>();
      final items = cart.items.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'size': item.size,
        'color': item.color,
        'price': item.product?.price ?? 0,
        'name': item.product?.nameAr ?? '',
      }).toList();

      await ApiService.createOrder({
        'items': items,
        'subtotal': cart.subtotal,
        'shipping': shipping,
        'discount': _discountAmount,
        'total': total,
        'fulfillmentType': _fulfillmentType,
        'customerName': _nameController.text.trim(),
        'customerEmail': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        'customerPhone': _phoneController.text.trim(),
        'shippingAddress': _addressController.text.trim(),
        'shippingCity': _cityController.text.trim(),
        'shippingCountry': _country,
        'discountCode': _appliedDiscount,
        'notes': _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      });

      await cart.clearCart();

      if (mounted) {
        final isAr = context.read<LocaleProvider>().isArabic;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF222240),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFFC8A96E), size: 64),
                const SizedBox(height: 16),
                Text(
                  isAr ? 'تم تأكيد طلبك!' : 'Order Confirmed!',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr ? 'شكراً لتسوقك من بوتيك ماسـة' : 'Thank you for shopping at Masah Boutique',
                  style: TextStyle(color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(isAr ? 'حسناً' : 'OK', style: const TextStyle(color: Color(0xFFC8A96E))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final isAr = context.read<LocaleProvider>().isArabic;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'حدث خطأ، حاولي مرة أخرى' : 'Error, please try again'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
