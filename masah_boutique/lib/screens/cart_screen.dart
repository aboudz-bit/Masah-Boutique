import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../providers/language_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/money_formatter.dart';
import '../utils/arabic_digits.dart';
import 'product_detail_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).loadCart();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.languageCode;
    final cartProvider = Provider.of<CartProvider>(context);
    final favProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      backgroundColor: kCreamBg,
      appBar: AppBar(
        backgroundColor: kCreamBg,
        elevation: 0,
        title: Text(
          l10n.yourBag,
          style: playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: kCharcoal),
        ),
        centerTitle: true,
        actions: [
          if (_tabController.index == 0 && cartProvider.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmClearCart(l10n),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          labelColor: kGoldPrimary,
          unselectedLabelColor: kSecondaryText,
          indicatorColor: kGoldPrimary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(l10n.cart),
                  if (cartProvider.itemCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: kGoldPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        ArabicDigits.convert(cartProvider.itemCount, lang),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 18),
                  const SizedBox(width: 6),
                  Text(l10n.wishlist),
                  if (favProvider.favoriteIds.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: kGoldPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        ArabicDigits.convert(favProvider.favoriteIds.length, lang),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCartTab(cartProvider, l10n, lang),
          _buildWishlistTab(favProvider, cartProvider, l10n, lang),
        ],
      ),
    );
  }

  // ===== Cart Tab =====

  Widget _buildCartTab(CartProvider cartProvider, AppLocalizations l10n, String lang) {
    if (cartProvider.loading) {
      return const Center(child: CircularProgressIndicator(color: kGoldPrimary));
    }

    if (cartProvider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 72, color: kSecondaryText.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(l10n.emptyBag, style: TextStyle(color: kSecondaryText, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              l10n.continueShopping,
              style: TextStyle(color: kSecondaryText.withOpacity(0.7), fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Shipping calculation: free over 15000 halalas (150 SAR)
    final subtotal = cartProvider.subtotal;
    const freeShippingThreshold = 15000;
    const shippingCost = 2500; // 25 SAR
    final shipping = subtotal >= freeShippingThreshold ? 0 : shippingCost;
    final total = subtotal + shipping;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              final product = item.product;

              return Dismissible(
                key: Key('cart-${item.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => cartProvider.removeItem(item.id),
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete, color: Colors.redAccent),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kDivider),
                  ),
                  child: Row(
                    children: [
                      // product image
                      GestureDetector(
                        onTap: product != null
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(productId: product.id),
                                  ),
                                )
                            : null,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: kCreamBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: product != null && product.images.isNotEmpty
                              ? Image.network(
                                  product.images.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.checkroom, color: kGoldPrimary.withOpacity(0.3), size: 30),
                                )
                              : Icon(Icons.checkroom, color: kGoldPrimary.withOpacity(0.3), size: 30),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product?.name(lang) ?? '',
                              style: TextStyle(color: kCharcoal, fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.size} \u2022 ${item.color}',
                              style: TextStyle(color: kSecondaryText, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  MoneyFormatter.format(item.totalPrice, lang),
                                  style: TextStyle(
                                    color: kGoldPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                // quantity controls
                                Row(
                                  children: [
                                    _buildSmallButton(Icons.remove, () {
                                      if (item.quantity > 1) {
                                        cartProvider.updateQuantity(item.id, item.quantity - 1);
                                      } else {
                                        cartProvider.removeItem(item.id);
                                      }
                                    }),
                                    Container(
                                      width: 32,
                                      alignment: Alignment.center,
                                      child: Text(
                                        ArabicDigits.convert(item.quantity, lang),
                                        style: TextStyle(color: kCharcoal, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    _buildSmallButton(Icons.add, () {
                                      cartProvider.updateQuantity(item.id, item.quantity + 1);
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // -- Order summary --
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          decoration: BoxDecoration(
            color: kCardBg,
            border: Border(top: BorderSide(color: kDivider)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // subtotal
                _buildSummaryRow(l10n.subtotal, MoneyFormatter.format(subtotal, lang)),
                const SizedBox(height: 8),
                // shipping
                _buildSummaryRow(
                  l10n.shipping,
                  shipping == 0 ? l10n.freeShipping : MoneyFormatter.format(shipping, lang),
                  valueColor: shipping == 0 ? Colors.green : null,
                ),
                if (subtotal < freeShippingThreshold) ...[
                  const SizedBox(height: 6),
                  Text(
                    lang == 'ar'
                        ? 'شحن مجاني للطلبات فوق ${MoneyFormatter.format(freeShippingThreshold, lang)}'
                        : 'Free shipping on orders over ${MoneyFormatter.format(freeShippingThreshold, lang)}',
                    style: TextStyle(color: kSecondaryText, fontSize: 11),
                  ),
                ],
                const Divider(height: 20),
                // total
                _buildSummaryRow(
                  l10n.total,
                  MoneyFormatter.format(total, lang),
                  isBold: true,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGoldPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      l10n.proceedToCheckout,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== Wishlist Tab =====

  Widget _buildWishlistTab(
    FavoritesProvider favProvider,
    CartProvider cartProvider,
    AppLocalizations l10n,
    String lang,
  ) {
    final favorites = favProvider.favoriteProducts;

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 72, color: kSecondaryText.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(l10n.noFavorites, style: TextStyle(color: kSecondaryText, fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        final hasDiscount = product.originalPrice != null && product.originalPrice! > product.price;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kDivider),
          ),
          child: Row(
            children: [
              // image
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)),
                  );
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kCreamBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.checkroom, color: kGoldPrimary.withOpacity(0.3), size: 30),
                        )
                      : Icon(Icons.checkroom, color: kGoldPrimary.withOpacity(0.3), size: 30),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name(lang),
                      style: TextStyle(color: kCharcoal, fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          MoneyFormatter.format(product.price, lang),
                          style: TextStyle(color: kGoldPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            MoneyFormatter.format(product.originalPrice!, lang),
                            style: TextStyle(
                              color: kSecondaryText,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // quick add to cart
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: ElevatedButton.icon(
                              onPressed: product.inStock && product.sizes.isNotEmpty && product.colors.isNotEmpty
                                  ? () async {
                                      final success = await cartProvider.addToCart(
                                        product.id,
                                        product.sizes.first,
                                        product.colors.first,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(success ? l10n.addedToBag : l10n.error),
                                            backgroundColor: success ? kGoldPrimary : Colors.redAccent,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                              label: Text(l10n.addToBag, style: const TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kGoldPrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // remove from favorites
                        SizedBox(
                          height: 34,
                          width: 34,
                          child: IconButton(
                            onPressed: () => favProvider.toggleFavorite(product.id),
                            icon: const Icon(Icons.close, size: 18),
                            color: Colors.redAccent,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== Helpers =====

  Widget _buildSmallButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kCreamBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kDivider),
        ),
        child: Icon(icon, color: kGoldPrimary, size: 16),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? kCharcoal : kSecondaryText,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isBold ? kGoldPrimary : kCharcoal),
            fontSize: isBold ? 20 : 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _confirmClearCart(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.clearAll, style: TextStyle(color: kCharcoal)),
        content: Text(
          l10n.remove,
          style: TextStyle(color: kSecondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: TextStyle(color: kSecondaryText)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clearCart();
              Navigator.pop(ctx);
            },
            child: Text(l10n.clearAll, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
