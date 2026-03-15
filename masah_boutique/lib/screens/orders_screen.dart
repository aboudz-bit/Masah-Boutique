import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../models/order.dart';
import '../utils/money_formatter.dart';
import '../main.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await apiService.getOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myOrders),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kGoldPrimary))
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: kSecondaryText.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noOrders,
                        style: TextStyle(color: kSecondaryText, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        child: Text(
                          l10n.continueShopping,
                          style: const TextStyle(color: kGoldPrimary),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  color: kGoldPrimary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return _buildOrderCard(order, lang, l10n);
                    },
                  ),
                ),
    );
  }

  Widget _buildOrderCard(Order order, String lang, AppLocalizations l10n) {
    final statusColor = _getStatusColor(order.status);
    final statusText = _getStatusText(order.status, l10n);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.orderNumber(order.id.toString()),
                  style: playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kCharcoal,
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Date
          if (order.createdAt != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  _formatDate(order.createdAt!),
                  style: TextStyle(color: kSecondaryText, fontSize: 12),
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Fulfillment type
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  order.isPickup ? Icons.store_outlined : Icons.local_shipping_outlined,
                  color: kGoldPrimary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  order.isPickup ? l10n.storePickup : l10n.delivery,
                  style: TextStyle(
                    color: kCharcoal,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Pickup store info
          if (order.isPickup && order.pickupStoreName != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kGoldPrimary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, color: kGoldPrimary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.pickupStoreName!,
                            style: TextStyle(
                              color: kCharcoal,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (order.pickupAddress != null)
                            Text(
                              order.pickupAddress!,
                              style: TextStyle(color: kSecondaryText, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Tracking number
          if (order.trackingNumber != null && order.trackingNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2, color: kGoldPrimary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${lang == 'ar' ? 'رقم التتبع:' : 'Tracking:'} ',
                    style: TextStyle(color: kSecondaryText, fontSize: 13),
                  ),
                  Flexible(
                    child: Text(
                      order.trackingNumber!,
                      style: TextStyle(
                        color: kCharcoal,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Divider and total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: kDivider, height: 24),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: TextStyle(color: kSecondaryText, fontSize: 14),
                ),
                Text(
                  MoneyFormatter.format(order.total, lang),
                  style: playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kGoldPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.teal;
      case 'processing':
        return Colors.amber.shade700;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'ready_for_pickup':
        return Colors.indigo;
      case 'picked_up':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status) {
      case 'pending':
        return l10n.pending;
      case 'paid':
        return l10n.paid;
      case 'processing':
        return l10n.processing;
      case 'confirmed':
        return l10n.confirmed;
      case 'shipped':
        return l10n.shipped;
      case 'delivered':
        return l10n.delivered;
      case 'ready_for_pickup':
        return l10n.readyForPickup;
      case 'picked_up':
        return l10n.pickedUp;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
