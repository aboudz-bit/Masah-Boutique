import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../models/order.dart';
import '../main.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await apiService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = data.map((json) => AppNotification.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getNotificationIcon(AppNotification notification) {
    final title = notification.title.toLowerCase();
    if (title.contains('order') || title.contains('طلب')) {
      return Icons.receipt_long_outlined;
    } else if (title.contains('ship') || title.contains('شحن')) {
      return Icons.local_shipping_outlined;
    } else if (title.contains('deliver') || title.contains('توصيل')) {
      return Icons.check_circle_outline;
    } else if (title.contains('pickup') || title.contains('استلام')) {
      return Icons.store_outlined;
    } else if (title.contains('discount') || title.contains('خصم') || title.contains('offer') || title.contains('عرض')) {
      return Icons.local_offer_outlined;
    } else if (title.contains('welcome') || title.contains('مرحب')) {
      return Icons.waving_hand_outlined;
    }
    return Icons.notifications_outlined;
  }

  String _timeAgo(String? dateStr, String lang) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 30) {
        final months = diff.inDays ~/ 30;
        return lang == 'ar' ? 'منذ $months شهر' : '${months}mo ago';
      } else if (diff.inDays > 0) {
        return lang == 'ar' ? 'منذ ${diff.inDays} يوم' : '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        return lang == 'ar' ? 'منذ ${diff.inHours} ساعة' : '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        return lang == 'ar' ? 'منذ ${diff.inMinutes} دقيقة' : '${diff.inMinutes}m ago';
      } else {
        return lang == 'ar' ? 'الآن' : 'Just now';
      }
    } catch (_) {
      return '';
    }
  }

  Future<void> _onNotificationTap(AppNotification notification) async {
    // Mark as read
    try {
      await apiService.markNotificationRead(notification.id);
      // Update local state
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = AppNotification(
            id: notification.id,
            userId: notification.userId,
            orderId: notification.orderId,
            title: notification.title,
            message: notification.message,
            read: true,
            createdAt: notification.createdAt,
          );
        }
      });
    } catch (_) {}

    // Navigate to orders if orderId exists
    if (notification.orderId != null && mounted) {
      Navigator.pushNamed(context, '/orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kGoldPrimary))
          : _notifications.isEmpty
              ? _buildEmptyState(l10n)
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: kGoldPrimary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification, lang);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kGoldPrimary.withOpacity(0.08),
            ),
            child: Icon(
              Icons.notifications_none,
              size: 48,
              color: kSecondaryText.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noNotifications,
            style: TextStyle(
              color: kSecondaryText,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Provider.of<LanguageProvider>(context, listen: false).isArabic
                ? 'ستظهر إشعاراتك هنا'
                : 'Your notifications will appear here',
            style: TextStyle(color: kSecondaryText.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification, String lang) {
    final isUnread = !notification.read;
    final icon = _getNotificationIcon(notification);

    return GestureDetector(
      onTap: () => _onNotificationTap(notification),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? kGoldPrimary.withOpacity(0.04) : kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread ? kGoldPrimary.withOpacity(0.2) : kDivider,
          ),
          boxShadow: [
            if (isUnread)
              BoxShadow(
                color: kGoldPrimary.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kGoldPrimary.withOpacity(isUnread ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isUnread ? kGoldPrimary : kSecondaryText,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: kCharcoal,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: kGoldPrimary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: kSecondaryText,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(notification.createdAt, lang),
                    style: TextStyle(
                      color: kSecondaryText.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow if has orderId
            if (notification.orderId != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: Icon(
                  Icons.chevron_right,
                  color: kSecondaryText.withOpacity(0.5),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
