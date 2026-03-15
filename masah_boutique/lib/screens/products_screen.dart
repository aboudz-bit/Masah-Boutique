import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/locale_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialCategory;

  const ProductsScreen({super.key, this.initialCategory});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'key': 'all', 'en': 'All', 'ar': 'الكل'},
    {'key': 'abayas', 'en': 'Abayas', 'ar': 'عبايات'},
    {'key': 'jalabiyas', 'en': 'Jalabiyas', 'ar': 'جلابيات'},
    {'key': 'dresses', 'en': 'Dresses', 'ar': 'فساتين'},
    {'key': 'bridal', 'en': 'Bridal', 'ar': 'عرائس'},
    {'key': 'kids', 'en': 'Kids', 'ar': 'أطفال'},
    {'key': 'gifts', 'en': 'Gifts', 'ar': 'هدايا'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      List<Product> products;
      if (_searchQuery.isNotEmpty) {
        products = await ApiService.getProducts(search: _searchQuery);
      } else if (_selectedCategory != null && _selectedCategory != 'all') {
        products = await ApiService.getProducts(category: _selectedCategory);
      } else {
        products = await ApiService.getProducts();
      }
      setState(() {
        _products = products;
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
      appBar: AppBar(
        title: Text(isAr ? 'المنتجات' : 'Products'),
        actions: [
          IconButton(
            icon: Text(isAr ? 'EN' : 'ع', style: TextStyle(color: const Color(0xFFC8A96E), fontWeight: FontWeight.bold)),
            onPressed: () => locale.toggleLocale(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: isAr ? 'ابحثي عن منتج...' : 'Search products...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFC8A96E)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadProducts();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF222240),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFC8A96E).withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFC8A96E).withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFC8A96E)),
                ),
              ),
              onSubmitted: (value) {
                setState(() => _searchQuery = value);
                _loadProducts();
              },
            ),
          ),

          // Category filters
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = (_selectedCategory ?? 'all') == cat['key'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(isAr ? cat['ar']! : cat['en']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? cat['key'] : 'all';
                        _searchQuery = '';
                        _searchController.clear();
                      });
                      _loadProducts();
                    },
                    selectedColor: const Color(0xFFC8A96E),
                    backgroundColor: const Color(0xFF222240),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey[400],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(color: const Color(0xFFC8A96E).withOpacity(0.3)),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Products grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC8A96E)))
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
                            const SizedBox(height: 16),
                            Text(
                              isAr ? 'لا توجد منتجات' : 'No products found',
                              style: TextStyle(color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        color: const Color(0xFFC8A96E),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
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
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
