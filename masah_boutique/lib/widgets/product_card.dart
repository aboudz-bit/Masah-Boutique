import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../main.dart';
import '../models/product.dart';
import '../providers/language_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/api_service.dart';
import '../utils/money_formatter.dart';
import '../utils/arabic_digits.dart';
import 'shimmer_placeholder.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  Product get product => widget.product;

  // ---------- Tap scale animation ----------

  void _onTapDown(TapDownDetails _) {
    setState(() => _scale = 0.96);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  void _onTap() {
    Navigator.of(context).pushNamed('/product/${product.id}');
  }

  // ---------- Quick-add bottom sheet ----------

  void _quickAdd() {
    final lang = Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final hasSizes = product.sizes.isNotEmpty;
    final hasColors = product.colors.isNotEmpty;

    if (!hasSizes && !hasColors) {
      // No options needed -- add directly with empty defaults
      _addToCart(
        product.sizes.isNotEmpty ? product.sizes.first : '',
        product.colors.isNotEmpty ? product.colors.first : '',
      );
      return;
    }

    String selectedSize = product.sizes.isNotEmpty ? product.sizes.first : '';
    String selectedColor = product.colors.isNotEmpty ? product.colors.first : '';

    showModalBottomSheet(
      context: context,
      backgroundColor: kCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: kDivider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.name(lang),
                      style: playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kCharcoal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // Size selection
                    if (hasSizes) ...[
                      Text(
                        l10n.size,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.sizes.map((size) {
                          final selected = size == selectedSize;
                          return GestureDetector(
                            onTap: () => setSheetState(() => selectedSize = size),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? kGoldPrimary : kCardBg,
                                border: Border.all(
                                  color: selected ? kGoldPrimary : kDivider,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : kCharcoal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Color selection
                    if (hasColors) ...[
                      Text(
                        l10n.color,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.colors.map((color) {
                          final selected = color == selectedColor;
                          return GestureDetector(
                            onTap: () => setSheetState(() => selectedColor = color),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? kGoldPrimary : kCardBg,
                                border: Border.all(
                                  color: selected ? kGoldPrimary : kDivider,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                color,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : kCharcoal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _addToCart(selectedSize, selectedColor);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGoldPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.addToBag,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addToCart(String size, String color) async {
    HapticFeedback.lightImpact();
    final cart = Provider.of<CartProvider>(context, listen: false);
    final success = await cart.addToCart(product.id, size, color);
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? l10n.addedToBag : l10n.error,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: success ? kGoldDark : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).languageCode;
    final favProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favProvider.isFavorite(product.id);

    final hasDiscount = product.originalPrice != null && product.originalPrice! > product.price;
    final discountPct = hasDiscount
        ? (((product.originalPrice! - product.price) / product.originalPrice!) * 100).round()
        : 0;

    return GestureDetector(
      onTap: _onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Image area ----
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    // Product image with shimmer loading
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: product.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.images.first.startsWith('http')
                                    ? product.images.first
                                    : '${ApiService.baseUrl}${product.images.first}',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const ShimmerPlaceholder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: kCreamBg,
                                  child: Icon(
                                    Icons.checkroom,
                                    size: 48,
                                    color: kGoldPrimary.withOpacity(0.3),
                                  ),
                                ),
                              )
                            : Container(
                                color: kCreamBg,
                                child: Icon(
                                  Icons.checkroom,
                                  size: 48,
                                  color: kGoldPrimary.withOpacity(0.3),
                                ),
                              ),
                      ),
                    ),

                    // Badge (top-left)
                    if (product.badge != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kGoldPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                    // Discount percentage badge (top-left, below product badge)
                    if (hasDiscount)
                      Positioned(
                        top: product.badge != null ? 34 : 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${ArabicDigits.convert(discountPct, lang)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                    // Video indicator badge (top-right area)
                    if (product.videoUrl != null && product.videoUrl!.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: kCharcoal.withOpacity(0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.videocam_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),

                    // Favorite heart button (top-right, below video badge if present)
                    Positioned(
                      top: product.videoUrl != null && product.videoUrl!.isNotEmpty ? 40 : 8,
                      right: 8,
                      child: _FavoriteButton(
                        isFavorite: isFav,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          favProvider.toggleFavorite(product.id);
                        },
                      ),
                    ),

                    // Quick-add to cart button (bottom-left)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: _quickAdd,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kGoldPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kGoldPrimary.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Info area ----
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name(lang),
                      style: const TextStyle(
                        color: kCharcoal,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rating row
                    if (product.reviewCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: kGoldPrimary, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              ArabicDigits.convert(product.rating, lang),
                              style: const TextStyle(
                                color: kCharcoal,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '(${ArabicDigits.convert(product.reviewCount, lang)})',
                              style: const TextStyle(
                                color: kSecondaryText,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Price row
                    Row(
                      children: [
                        Text(
                          MoneyFormatter.format(product.price, lang),
                          style: const TextStyle(
                            color: kGoldDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              MoneyFormatter.format(product.originalPrice!, lang),
                              style: const TextStyle(
                                color: kSecondaryText,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: kSecondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Animated Favorite Heart Button ----------

class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant _FavoriteButton old) {
    super.didUpdateWidget(old);
    if (widget.isFavorite != old.isFavorite && widget.isFavorite) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kCardBg.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: widget.isFavorite ? Colors.redAccent : kSecondaryText,
            size: 18,
          ),
        ),
      ),
    );
  }
}
