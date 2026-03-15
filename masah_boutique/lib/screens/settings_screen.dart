import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final isAr = langProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Brand Logo Placeholder ---
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kDivider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGoldPrimary.withOpacity(0.08),
                    border: Border.all(color: kGoldPrimary.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.diamond_outlined, color: kGoldPrimary, size: 40),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.appName,
                  style: playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: kGoldPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.heroTitle,
                  style: TextStyle(color: kSecondaryText, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '@masahboutique',
                  style: TextStyle(color: kSecondaryText.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Language Toggle (Pill-style) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kDivider),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kGoldPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.language, color: kGoldPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.language,
                    style: TextStyle(
                      color: kCharcoal,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Pill-style switcher
                Container(
                  decoration: BoxDecoration(
                    color: kCreamBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: kDivider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _languagePill(
                        label: 'العربية',
                        isSelected: isAr,
                        onTap: () {
                          if (!isAr) langProvider.toggleLanguage();
                        },
                      ),
                      _languagePill(
                        label: 'EN',
                        isSelected: !isAr,
                        onTap: () {
                          if (isAr) langProvider.toggleLanguage();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // --- Notifications ---
          _buildSettingCard(
            context: context,
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: isAr ? 'عرض إشعاراتك' : 'View your notifications',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),

          const SizedBox(height: 12),

          // --- Orders ---
          _buildSettingCard(
            context: context,
            icon: Icons.receipt_long_outlined,
            title: l10n.myOrders,
            subtitle: isAr ? 'عرض سجل الطلبات' : 'View order history',
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),

          const SizedBox(height: 24),

          // --- Info Section ---
          Text(
            isAr ? 'معلومات' : 'Information',
            style: playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kCharcoal,
            ),
          ),
          const SizedBox(height: 14),

          _buildInfoTile(
            Icons.local_shipping_outlined,
            l10n.shippingInfo,
            isAr ? 'شحن مجاني للطلبات فوق ١٥٠ ر.س' : 'Free shipping on orders over SAR 150',
          ),
          _buildInfoTile(
            Icons.replay,
            l10n.returnPolicy,
            isAr ? 'استبدال وإرجاع خلال ٣٠ يوم' : 'Exchange and return within 30 days',
          ),
          _buildInfoTile(
            Icons.lock_outline,
            l10n.securePayment,
            isAr ? 'جميع المدفوعات مشفرة وآمنة' : 'All payments are encrypted and secure',
          ),
          _buildInfoTile(
            Icons.handshake_outlined,
            isAr ? 'منتجات أصلية' : 'Authentic Products',
            isAr ? 'منتجات أصلية ١٠٠٪ مصنوعة يدوياً' : '100% authentic handcrafted products',
          ),

          const SizedBox(height: 24),

          // --- Welcome Discount Banner ---
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kGoldPrimary.withOpacity(0.12),
                  kGoldPrimary.withOpacity(0.04),
                ],
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGoldPrimary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kGoldPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_offer, color: kGoldPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MASAH10',
                        style: TextStyle(
                          color: kGoldPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.welcomeDiscount,
                        style: TextStyle(color: kSecondaryText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- About ---
          Center(
            child: Text(
              l10n.aboutBrand,
              style: TextStyle(color: kSecondaryText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

          // --- Version ---
          Center(
            child: Text(
              'v1.0.0',
              style: TextStyle(color: kSecondaryText.withOpacity(0.5), fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _languagePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kGoldPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kSecondaryText,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kDivider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kGoldPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kGoldPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: kCharcoal,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: kSecondaryText, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right, color: kSecondaryText),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kGoldPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kGoldPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: kCharcoal,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: kSecondaryText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
