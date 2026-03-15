import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/product.dart';
import '../providers/language_provider.dart';
import '../utils/money_formatter.dart';
import 'product_detail_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _heroController = PageController();
  Timer? _heroTimer;
  int _currentHeroPage = 0;

  List<Product> _featuredProducts = [];
  Map<String, Product?> _categoryPreviewProducts = {};
  bool _isLoading = true;

  static const _categories = [
    'abayas',
    'jalabiyas',
    'dresses',
    'bridal',
    'kids',
    'gifts',
  ];

  static const _categoryIcons = {
    'abayas': Icons.checkroom,
    'jalabiyas': Icons.auto_awesome,
    'dresses': Icons.celebration,
    'bridal': Icons.favorite,
    'kids': Icons.child_care,
    'gifts': Icons.card_giftcard,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _startHeroAutoScroll();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  void _startHeroAutoScroll() {
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_heroController.hasClients) return;
      _currentHeroPage = (_currentHeroPage + 1) % 3;
      _heroController.animateToPage(
        _currentHeroPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadData() async {
    try {
      final products = await apiService.getProducts(featured: true);
      final previews = <String, Product?>{};
      for (final cat in _categories) {
        try {
          final catProducts = await apiService.getProducts(category: cat);
          previews[cat] = catProducts.isNotEmpty ? catProducts.first : null;
        } catch (_) {
          previews[cat] = null;
        }
      }
      if (mounted) {
        setState(() {
          _featuredProducts = products;
          _categoryPreviewProducts = previews;
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
    final isAr = langProvider.isArabic;

    return Scaffold(
      backgroundColor: kCreamBg,
      body: CustomScrollView(
        slivers: [
          // -- SliverAppBar with hero PageView --
          SliverAppBar(
            expandedHeight: 360,
            floating: false,
            pinned: true,
            backgroundColor: kCardBg,
            title: Text(
              l10n.appName,
              style: playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kGoldPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: Text(
                  isAr ? 'EN' : '\u0639',
                  style: TextStyle(
                    color: kGoldPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () => langProvider.toggleLanguage(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroPageView(l10n, isAr),
            ),
          ),

          // -- Category circles --
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                l10n.categories,
                style: playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kCharcoal,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return _buildCategoryCircle(cat, l10n, lang);
                },
              ),
            ),
          ),

          // -- Featured products header --
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.featuredPieces,
                    style: playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kCharcoal,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShopScreen()),
                      );
                    },
                    child: Text(
                      l10n.viewAll,
                      style: TextStyle(color: kGoldPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -- Featured products grid --
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: kGoldPrimary),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _featuredProducts[index];
                    return _buildProductCard(product, lang);
                  },
                  childCount: _featuredProducts.length,
                ),
              ),
            ),

          // -- Brand info section --
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kDivider),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kGoldPrimary.withOpacity(0.4), width: 2),
                    ),
                    child: Icon(Icons.diamond_outlined, color: kGoldPrimary, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appName,
                    style: playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: kCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.aboutBrand,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kSecondaryText, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '@masahboutique',
                    style: TextStyle(color: kGoldPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr ? 'سيهات، المنطقة الشرقية' : 'Saihat, Eastern Province',
                    style: TextStyle(color: kSecondaryText, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoChip(Icons.local_shipping_outlined, l10n.shippingInfo),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.replay, l10n.returnPolicy),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.lock_outline, l10n.securePayment),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ---------- Hero PageView ----------

  Widget _buildHeroPageView(AppLocalizations l10n, bool isAr) {
    final slides = [
      _HeroSlide(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF2D1B4E)],
        ),
        title: l10n.appName,
        subtitle: l10n.heroTitle,
      ),
      _HeroSlide(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF2D1B4E), Color(0xFF0F3460)],
        ),
        title: l10n.eidCollection,
        subtitle: l10n.exploreCollection,
      ),
      _HeroSlide(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F3460), Color(0xFF1A1A2E)],
        ),
        title: l10n.newDrop,
        subtitle: l10n.heroSubtitle,
      ),
    ];

    return Stack(
      children: [
        PageView.builder(
          controller: _heroController,
          itemCount: slides.length,
          onPageChanged: (i) => setState(() => _currentHeroPage = i),
          itemBuilder: (context, index) {
            final slide = slides[index];
            return Container(
              decoration: BoxDecoration(gradient: slide.gradient),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // radial glow
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.8,
                          colors: [
                            kGoldPrimary.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          slide.title,
                          style: playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: kGoldPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            slide.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ShopScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGoldPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            l10n.shopNow,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // dots
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentHeroPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentHeroPage == i ? kGoldPrimary : Colors.white38,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ---------- Category circle ----------

  Widget _buildCategoryCircle(String cat, AppLocalizations l10n, String lang) {
    final label = _categoryLabel(cat, l10n);
    final previewProduct = _categoryPreviewProducts[cat];
    final icon = _categoryIcons[cat] ?? Icons.category;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/category/$cat');
      },
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kCardBg,
                border: Border.all(color: kGoldPrimary.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: previewProduct != null && previewProduct.images.isNotEmpty
                  ? Image.network(
                      previewProduct.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(icon, color: kGoldPrimary, size: 28),
                    )
                  : Icon(icon, color: kGoldPrimary, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: kCharcoal,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Product card ----------

  Widget _buildProductCard(Product product, String lang) {
    final hasDiscount = product.originalPrice != null && product.originalPrice! > product.price;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image area
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      color: kCreamBg,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(Icons.checkroom, size: 48, color: kGoldPrimary.withOpacity(0.3)),
                            ),
                          )
                        : Center(
                            child: Icon(Icons.checkroom, size: 48, color: kGoldPrimary.withOpacity(0.3)),
                          ),
                  ),
                  if (product.badge != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kGoldPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.badge!,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${((product.originalPrice! - product.price) * 100 / product.originalPrice!).round()}%',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // info area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name(lang),
                      style: TextStyle(
                        color: kCharcoal,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: kGoldPrimary, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              '${product.rating}',
                              style: TextStyle(color: kSecondaryText, fontSize: 11),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${product.reviewCount})',
                              style: TextStyle(color: kSecondaryText.withOpacity(0.7), fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              MoneyFormatter.format(product.price, lang),
                              style: TextStyle(
                                color: kGoldPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 6),
                              Text(
                                MoneyFormatter.format(product.originalPrice!, lang),
                                style: TextStyle(
                                  color: kSecondaryText,
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Info chip ----------

  Widget _buildInfoChip(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: kGoldPrimary, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: kSecondaryText, fontSize: 10),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ---------- Helpers ----------

  String _categoryLabel(String cat, AppLocalizations l10n) {
    switch (cat) {
      case 'abayas':
        return l10n.abayas;
      case 'jalabiyas':
        return l10n.jalabiyas;
      case 'dresses':
        return l10n.dresses;
      case 'bridal':
        return l10n.bridal;
      case 'kids':
        return l10n.kids;
      case 'gifts':
        return l10n.gifts;
      default:
        return cat;
    }
  }
}

class _HeroSlide {
  final LinearGradient gradient;
  final String title;
  final String subtitle;

  const _HeroSlide({
    required this.gradient,
    required this.title,
    required this.subtitle,
  });
}
