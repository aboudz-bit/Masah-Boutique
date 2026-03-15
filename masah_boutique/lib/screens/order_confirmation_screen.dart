import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/locale_provider.dart';
import '../utils/money_formatter.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final dynamic order;

  const OrderConfirmationScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isAr = locale.isArabic;
    final lang = locale.languageCode;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFC8A96E).withOpacity(0.1),
                    border: Border.all(color: const Color(0xFFC8A96E).withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.check, color: Color(0xFFC8A96E), size: 50),
                ),
                const SizedBox(height: 32),
                Text(
                  isAr ? 'تم تأكيد الطلب!' : 'Order Confirmed!',
                  style: const TextStyle(
                    color: Color(0xFFC8A96E),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (order != null) ...[
                  Text(
                    '${isAr ? "طلب رقم" : "Order"} #${order.id}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    MoneyFormatter.format(order.total, lang),
                    style: const TextStyle(color: Color(0xFFC8A96E), fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  isAr
                      ? 'شكراً لتسوقك من بوتيك ماسـة\nسنتواصل معك قريباً لتأكيد الطلب'
                      : 'Thank you for shopping at Masah Boutique\nWe will contact you shortly to confirm your order',
                  style: TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8A96E),
                      foregroundColor: const Color(0xFF1A1A2E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    child: Text(isAr ? 'متابعة التسوق' : 'Continue Shopping'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // Navigate to orders tab
                  },
                  child: Text(
                    isAr ? 'عرض طلباتي' : 'View My Orders',
                    style: const TextStyle(color: Color(0xFFC8A96E)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
