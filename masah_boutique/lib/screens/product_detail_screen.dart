import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';
import '../models/product.dart';
import '../providers/language_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/money_formatter.dart';
import '../utils/arabic_digits.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  int _currentMediaIndex = 0;
  final PageController _mediaController = PageController();
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;

  /// Combined list of media: images first, then video (if any).
  List<String> _mediaUrls = [];
  int _videoIndex = -1; // index in _mediaUrls, -1 if no video

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _mediaController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await apiService.getProduct(widget.productId);
      final media = <String>[...product.images];
      int vidIdx = -1;
      if (product.videoUrl != null && product.videoUrl!.isNotEmpty) {
        vidIdx = media.length;
        media.add(product.videoUrl!);
        _initVideo(product.videoUrl!);
      }
      if (mounted) {
        setState(() {
          _product = product;
          _mediaUrls = media;
          _videoIndex = vidIdx;
          _selectedSize = product.sizes.isNotEmpty ? product.sizes.first : null;
          _selectedColor = product.colors.isNotEmpty ? product.colors.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initVideo(String url) {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) setState(() => _videoInitialized = true);
      });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.languageCode;
    final favProvider = Provider.of<FavoritesProvider>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: kCreamBg,
        appBar: AppBar(backgroundColor: kCreamBg, elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: kGoldPrimary)),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: kCreamBg,
        appBar: AppBar(backgroundColor: kCreamBg, elevation: 0),
        body: Center(
          child: Text(l10n.error, style: TextStyle(color: kSecondaryText)),
        ),
      );
    }

    final product = _product!;
    final hasDiscount = product.originalPrice != null && product.originalPrice! > product.price;
    final isFav = favProvider.isFavorite(product.id);

    return Scaffold(
      backgroundColor: kCreamBg,
      body: CustomScrollView(
        slivers: [
          // -- Media slider --
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            backgroundColor: kCardBg,
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : kCharcoal,
                ),
                onPressed: () => favProvider.toggleFavorite(product.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  Expanded(
                    child: _mediaUrls.isNotEmpty
                        ? PageView.builder(
                            controller: _mediaController,
                            itemCount: _mediaUrls.length,
                            onPageChanged: (i) => setState(() => _currentMediaIndex = i),
                            itemBuilder: (context, index) {
                              if (index == _videoIndex) {
                                return _buildVideoSlide();
                              }
                              return GestureDetector(
                                onTap: () => _openFullscreenImage(context, _mediaUrls[index]),
                                child: Image.network(
                                  _mediaUrls[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: kCreamBg,
                                    child: Center(
                                      child: Icon(Icons.checkroom, size: 80, color: kGoldPrimary.withOpacity(0.3)),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: kCreamBg,
                            child: Center(
                              child: Icon(Icons.checkroom, size: 80, color: kGoldPrimary.withOpacity(0.3)),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          // -- Thumbnail strip --
          if (_mediaUrls.length > 1)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _mediaUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _currentMediaIndex == index;
                    final isVideo = index == _videoIndex;
                    return GestureDetector(
                      onTap: () {
                        _mediaController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? kGoldPrimary : kDivider,
                            width: isSelected ? 2 : 1,
                          ),
                          color: kCardBg,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: isVideo
                            ? Icon(Icons.play_circle_outline, color: kGoldPrimary, size: 24)
                            : Image.network(
                                _mediaUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.image, color: kSecondaryText, size: 20),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // -- Product details --
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // badge
                  if (product.badge != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: kGoldPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),

                  // name
                  Text(
                    product.name(lang),
                    style: playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: kCharcoal),
                  ),
                  const SizedBox(height: 12),

                  // price
                  Row(
                    children: [
                      Text(
                        MoneyFormatter.format(product.price, lang),
                        style: TextStyle(color: kGoldPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 12),
                        Text(
                          MoneyFormatter.format(product.originalPrice!, lang),
                          style: TextStyle(
                            color: kSecondaryText,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${((product.originalPrice! - product.price) * 100 / product.originalPrice!).round()}%',
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // rating
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        return Icon(
                          i < product.rating.round() ? Icons.star : Icons.star_border,
                          color: kGoldPrimary,
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${product.rating}',
                        style: TextStyle(color: kSecondaryText, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.reviews(product.reviewCount),
                        style: TextStyle(color: kSecondaryText.withOpacity(0.8), fontSize: 13),
                      ),
                    ],
                  ),

                  // description
                  const SizedBox(height: 24),
                  Text(
                    l10n.description,
                    style: playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: kCharcoal),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description(lang),
                    style: TextStyle(color: kSecondaryText, fontSize: 15, height: 1.6),
                  ),

                  // fabric
                  if (product.fabric(lang) != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.texture, color: kGoldPrimary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${l10n.fabricCare}: ${product.fabric(lang)}',
                          style: TextStyle(color: kSecondaryText, fontSize: 14),
                        ),
                      ],
                    ),
                  ],

                  const Divider(height: 32),

                  // -- Size selector --
                  if (product.sizes.isNotEmpty) ...[
                    Text(
                      l10n.size,
                      style: playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600, color: kCharcoal),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: product.sizes.map((size) {
                        final isSelected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = size),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? kGoldPrimary : kCardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? kGoldPrimary : kDivider,
                              ),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected ? Colors.white : kCharcoal,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // -- Color selector --
                  if (product.colors.isNotEmpty) ...[
                    Text(
                      l10n.color,
                      style: playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600, color: kCharcoal),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: product.colors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? kGoldPrimary : kCardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? kGoldPrimary : kDivider,
                              ),
                            ),
                            child: Text(
                              color,
                              style: TextStyle(
                                color: isSelected ? Colors.white : kCharcoal,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // -- Quantity selector --
                  Text(
                    l10n.quantity,
                    style: playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600, color: kCharcoal),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildQuantityButton(Icons.remove, () {
                        if (_quantity > 1) setState(() => _quantity--);
                      }),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          ArabicDigits.convert(_quantity, lang),
                          style: TextStyle(color: kCharcoal, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      _buildQuantityButton(Icons.add, () {
                        setState(() => _quantity++);
                      }),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // -- Add to cart bottom bar --
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardBg,
          border: Border(top: BorderSide(color: kDivider)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // total price
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.total, style: TextStyle(color: kSecondaryText, fontSize: 12)),
                    Text(
                      MoneyFormatter.format(product.price * _quantity, lang),
                      style: TextStyle(
                        color: kGoldPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              // button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: product.inStock ? _addToCart : null,
                    icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                    label: Text(
                      product.inStock ? l10n.addToBag : l10n.error,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: product.inStock ? kGoldPrimary : kSecondaryText,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Video slide ----------

  Widget _buildVideoSlide() {
    if (!_videoInitialized || _videoController == null) {
      return Container(
        color: kCreamBg,
        child: const Center(child: CircularProgressIndicator(color: kGoldPrimary)),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _videoController!.value.isPlaying
              ? _videoController!.pause()
              : _videoController!.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          if (!_videoController!.value.isPlaying)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
            ),
        ],
      ),
    );
  }

  // ---------- Quantity button ----------

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kDivider),
        ),
        child: Icon(icon, color: kGoldPrimary, size: 20),
      ),
    );
  }

  // ---------- Fullscreen image viewer ----------

  void _openFullscreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  // ---------- Add to cart ----------

  Future<void> _addToCart() async {
    if (_selectedSize == null || _selectedColor == null) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final success = await cartProvider.addToCart(
      _product!.id,
      _selectedSize!,
      _selectedColor!,
      quantity: _quantity,
    );

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? l10n.addedToBag : l10n.error),
          backgroundColor: success ? kGoldPrimary : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

// ---------- Fullscreen image viewer with pinch zoom ----------

class _FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullscreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image,
              color: Colors.white38,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}
