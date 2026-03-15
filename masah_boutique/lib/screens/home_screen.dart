import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/locale_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _featuredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      final products = await ApiService.getProducts(featured: true);
      setState(() {
        _featuredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isAr = locale.isArabic;
    final lang = locale.languageCode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            title: Text(
              'بوتيك ماسـة',
              style: TextStyle(
                color: const Color(0xFFC8A96E),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                icon: Text(
                  isAr ? 'EN' : 'ع',
                  style: TextStyle(
                    color: const Color(0xFFC8A96E),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () => locale.toggleLocale(),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFFC8A96E)),
                onPressed: () => _openInstagram(),
              ),
            ],
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2D1B4E),
                    const Color(0xFF1A1A2E),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shimmer effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.8,
                          colors: [
                            const Color(0xFFC8A96E).withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Diamond icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFC8A96E).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.diamond_outlined,
                          color: Color(0xFFC8A96E),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'بوتيك ماسـة',
                        style: TextStyle(
                          color: const Color(0xFFC8A96E),
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFC8A96E).withOpacity(0.3),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAr ? 'أناقتك تبدأ من هنا' : 'Your Elegance Starts Here',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _openInstagram(),
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: Text(isAr ? 'تابعينا على انستقرام' : 'Follow on Instagram'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC8A96E),
                          foregroundColor: const Color(0xFF1A1A2E),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'تسوقي حسب الفئة' : 'Shop by Category',
                    style: const TextStyle(
                      color: Color(0xFFC8A96E),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip(Icons.checkroom, isAr ? 'عبايات' : 'Abayas', 'abayas'),
                        _buildCategoryChip(Icons.auto_awesome, isAr ? 'جلابيات' : 'Jalabiyas', 'jalabiyas'),
                        _buildCategoryChip(Icons.celebration, isAr ? 'فساتين' : 'Dresses', 'dresses'),
                        _buildCategoryChip(Icons.favorite, isAr ? 'عرائس' : 'Bridal', 'bridal'),
                        _buildCategoryChip(Icons.child_care, isAr ? 'أطفال' : 'Kids', 'kids'),
                        _buildCategoryChip(Icons.card_giftcard, isAr ? 'هدايا' : 'Gifts', 'gifts'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Featured Products
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'منتجات مميزة' : 'Featured Products',
                    style: const TextStyle(
                      color: Color(0xFFC8A96E),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
                    },
                    child: Text(
                      isAr ? 'عرض الكل' : 'View All',
                      style: const TextStyle(color: Color(0xFFC8A96E)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFFC8A96E)),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _featuredProducts[index];
                    return ProductCard(
                      product: product,
                      locale: lang,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(productId: product.id),
                          ),
                        );
                      },
                    );
                  },
                  childCount: _featuredProducts.length,
                ),
              ),
            ),

          // Instagram CTA
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF222240),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFC8A96E).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.camera_alt, color: Color(0xFFC8A96E), size: 40),
                  const SizedBox(height: 12),
                  Text(
                    isAr ? 'تابعينا على انستقرام' : 'Follow us on Instagram',
                    style: const TextStyle(
                      color: Color(0xFFC8A96E),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@masahboutique',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _openInstagram(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFC8A96E)),
                      foregroundColor: const Color(0xFFC8A96E),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(isAr ? 'زوري حسابنا' : 'Visit Our Profile'),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(IconData icon, String label, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductsScreen(initialCategory: category)),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(left: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF222240),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFC8A96E).withOpacity(0.2),
                ),
              ),
              child: Icon(icon, color: const Color(0xFFC8A96E), size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInstagram() async {
    final uri = Uri.parse('https://www.instagram.com/masahboutique');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
