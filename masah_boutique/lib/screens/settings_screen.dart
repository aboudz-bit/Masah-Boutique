import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isAr = locale.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الإعدادات' : 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Brand header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF222240),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC8A96E).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC8A96E).withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.diamond_outlined, color: Color(0xFFC8A96E), size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  'بوتيك ماسـة',
                  style: TextStyle(color: Color(0xFFC8A96E), fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  isAr ? 'أناقتك تبدأ من هنا' : 'Your Elegance Starts Here',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Language toggle
          _buildSettingCard(
            icon: Icons.language,
            title: isAr ? 'اللغة' : 'Language',
            subtitle: isAr ? 'العربية' : 'English',
            trailing: Switch(
              value: isAr,
              onChanged: (_) => locale.toggleLocale(),
              activeColor: const Color(0xFFC8A96E),
            ),
          ),

          const SizedBox(height: 12),

          // Orders
          _buildSettingCard(
            icon: Icons.receipt_long,
            title: isAr ? 'طلباتي' : 'My Orders',
            subtitle: isAr ? 'عرض سجل الطلبات' : 'View order history',
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),

          const SizedBox(height: 12),

          // Instagram
          _buildSettingCard(
            icon: Icons.camera_alt,
            title: isAr ? 'انستقرام' : 'Instagram',
            subtitle: '@masahboutique',
            onTap: () async {
              final uri = Uri.parse('https://www.instagram.com/masahboutique');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),

          const SizedBox(height: 12),

          // Store locator
          _buildSettingCard(
            icon: Icons.store,
            title: isAr ? 'فروعنا' : 'Our Stores',
            subtitle: isAr ? 'سيهات، القطيف، الدمام' : 'Saihat, Qatif, Dammam',
            onTap: () => Navigator.pushNamed(context, '/stores'),
          ),

          const SizedBox(height: 24),

          // Info section
          Text(
            isAr ? 'معلومات' : 'Information',
            style: const TextStyle(color: Color(0xFFC8A96E), fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _buildInfoTile(Icons.local_shipping_outlined, isAr ? 'شحن مجاني للطلبات فوق ١٥٠ ر.س' : 'Free shipping on orders over SAR 150'),
          _buildInfoTile(Icons.replay, isAr ? 'سياسة إرجاع ٣٠ يوم' : '30-day return policy'),
          _buildInfoTile(Icons.lock_outline, isAr ? 'دفع آمن' : 'Secure payment'),
          _buildInfoTile(Icons.handshake_outlined, isAr ? 'منتجات أصلية ١٠٠٪' : '100% authentic products'),

          const SizedBox(height: 24),

          // Discount banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFC8A96E).withOpacity(0.15), const Color(0xFFC8A96E).withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC8A96E).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer, color: Color(0xFFC8A96E)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAr ? 'استخدمي كود MASAH10 لخصم ١٠٪ على أول طلب' : 'Use code MASAH10 for 10% off your first order',
                    style: TextStyle(color: Colors.grey[300], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Version
          Center(
            child: Text(
              'v1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
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
          color: const Color(0xFF222240),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC8A96E).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFC8A96E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFC8A96E), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC8A96E), size: 20),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}
