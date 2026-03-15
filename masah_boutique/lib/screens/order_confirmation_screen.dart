import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../utils/money_formatter.dart';
import '../main.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final dynamic order;

  const OrderConfirmationScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.languageCode;

    return Scaffold(
      backgroundColor: kCreamBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success checkmark circle
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGoldPrimary.withOpacity(0.08),
                    border: Border.all(color: kGoldPrimary.withOpacity(0.3), width: 2.5),
                  ),
                  child: const Icon(Icons.check, color: kGoldPrimary, size: 56),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  l10n.orderConfirmed,
                  style: playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: kGoldPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                // Order number and total
                if (order != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: kCardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kDivider),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.orderNumber(order.id.toString()),
                          style: TextStyle(
                            color: kCharcoal,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          MoneyFormatter.format(order.total, lang),
                          style: playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: kGoldPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Thank you message
                Text(
                  l10n.orderConfirmedMessage,
                  style: TextStyle(
                    color: kSecondaryText,
                    fontSize: 15,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Continue shopping button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGoldPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(l10n.continueShopping),
                  ),
                ),

                const SizedBox(height: 14),

                // View orders link
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.pushNamed(context, '/orders');
                  },
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: Text(l10n.myOrders),
                  style: TextButton.styleFrom(
                    foregroundColor: kGoldPrimary,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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
