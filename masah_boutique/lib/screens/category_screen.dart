import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../main.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String slug;

  const CategoryScreen({super.key, required this.slug});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'newest';
  final _searchController = TextEditingController();
  bool _showSearch = false;

  static const _categoryIcons = {
    'abayas': Icons.checkroom,
    'jalabiyas': Icons.checkroom_outlined,
    'dresses': Icons.dry_cleaning,
    'bridal': Icons.favorite,
    'kids': Icons.child_care,
    'gifts': Icons.card_giftcard,
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  String _categoryName(AppLocalizations l10n) {
    switch (widget.slug) {
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
        return widget.slug;
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await apiService.getProducts(category: widget.slug);
      if (mounted) {
        setState(() {
          _products = products;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Product> result = List.from(_products);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.nameEn.toLowerCase().contains(q) ||
            p.nameAr.contains(_searchQuery) ||
            p.descriptionEn.toLowerCase().contains(q) ||
            p.descriptionAr.contains(_searchQuery);
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'price_low':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'best':
        result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case 'newest':
      default:
        // Keep original order (newest first from API)
        break;
    }

    _filteredProducts = result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.languageCode;
    final catIcon = _categoryIcons[widget.slug] ?? Icons.category;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(catIcon, size: 22, color: kGoldPrimary),
            const SizedBox(width: 8),
            Text(_categoryName(l10n)),
          ],
        ),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: kCharcoal,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchQuery = '';
                  _applyFilters();
                }
              });
            },
          ),
          // Sort popup
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: kCharcoal),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _applyFilters();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'newest',
                child: _sortMenuItem(l10n.newest, _sortBy == 'newest'),
              ),
              PopupMenuItem(
                value: 'price_low',
                child: _sortMenuItem(l10n.priceLowHigh, _sortBy == 'price_low'),
              ),
              PopupMenuItem(
                value: 'price_high',
                child: _sortMenuItem(l10n.priceHighLow, _sortBy == 'price_high'),
              ),
              PopupMenuItem(
                value: 'best',
                child: _sortMenuItem(l10n.bestSellers, _sortBy == 'best'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchProducts,
                  hintStyle: TextStyle(color: kSecondaryText),
                  prefixIcon: const Icon(Icons.search, color: kGoldPrimary, size: 20),
                  filled: true,
                  fillColor: kCardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kDivider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kDivider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kGoldPrimary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                    _applyFilters();
                  });
                },
              ),
            ),

          // Item count
          if (!_isLoading && _filteredProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.itemCount(_filteredProducts.length),
                  style: TextStyle(color: kSecondaryText, fontSize: 13),
                ),
              ),
            ),

          // Product grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kGoldPrimary))
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: kSecondaryText.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noProducts,
                              style: TextStyle(color: kSecondaryText, fontSize: 16),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    _applyFilters();
                                  });
                                },
                                child: Text(
                                  l10n.clearFilters,
                                  style: const TextStyle(color: kGoldPrimary),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        color: kGoldPrimary,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
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

  Widget _sortMenuItem(String label, bool isSelected) {
    return Row(
      children: [
        if (isSelected)
          const Padding(
            padding: EdgeInsetsDirectional.only(end: 8),
            child: Icon(Icons.check, color: kGoldPrimary, size: 18),
          ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? kGoldPrimary : kCharcoal,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
