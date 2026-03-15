import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../models/product.dart';
import '../providers/language_provider.dart';
import '../utils/money_formatter.dart';
import 'product_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  final String? initialCategory;

  const ShopScreen({super.key, this.initialCategory});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

enum _SortOption { newest, priceLow, priceHigh, bestSellers }

class _ShopScreenState extends State<ShopScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  _SortOption _sortOption = _SortOption.newest;
  final TextEditingController _searchController = TextEditingController();

  static const _categories = [
    'all',
    'abayas',
    'jalabiyas',
    'dresses',
    'bridal',
    'kids',
    'gifts',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final category = _selectedCategory == 'all' ? null : _selectedCategory;
      final search = _searchQuery.isNotEmpty ? _searchQuery : null;
      final products = await apiService.getProducts(category: category, search: search);
      if (mounted) {
        setState(() {
          _products = _sortProducts(products);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _products = [];
          _isLoading = false;
        });
      }
    }
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.from(products);
    switch (_sortOption) {
      case _SortOption.newest:
        // keep server order (newest first by default)
        break;
      case _SortOption.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _SortOption.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _SortOption.bestSellers:
        sorted.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.languageCode;

    return Scaffold(
      backgroundColor: kCreamBg,
      appBar: AppBar(
        backgroundColor: kCreamBg,
        title: Text(
          l10n.shop,
          style: playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: kCharcoal),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<_SortOption>(
            icon: Icon(Icons.sort, color: kCharcoal),
            tooltip: l10n.sortBy,
            onSelected: (option) {
              setState(() {
                _sortOption = option;
                _products = _sortProducts(_products);
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: _SortOption.newest, child: Text(l10n.newest)),
              PopupMenuItem(value: _SortOption.priceLow, child: Text(l10n.priceLowHigh)),
              PopupMenuItem(value: _SortOption.priceHigh, child: Text(l10n.priceHighLow)),
              PopupMenuItem(value: _SortOption.bestSellers, child: Text(l10n.bestSellers)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // -- Search bar --
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                _searchQuery = value.trim();
                _loadProducts();
              },
              decoration: InputDecoration(
                hintText: l10n.searchProducts,
                hintStyle: TextStyle(color: kSecondaryText, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: kSecondaryText),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: kSecondaryText, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _loadProducts();
                        },
                      )
                    : null,
                filled: true,
                fillColor: kCardBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                  borderSide: BorderSide(color: kGoldPrimary),
                ),
              ),
            ),
          ),

          // -- Category filter chips --
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(_categoryLabel(cat, l10n)),
                  selected: isSelected,
                  selectedColor: kGoldPrimary,
                  backgroundColor: kCardBg,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : kCharcoal,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  side: BorderSide(color: isSelected ? kGoldPrimary : kDivider),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) {
                    setState(() => _selectedCategory = cat);
                    _loadProducts();
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // -- Product count --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.itemCount(_products.length),
                style: TextStyle(color: kSecondaryText, fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // -- Product grid with pull-to-refresh --
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kGoldPrimary))
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: kSecondaryText.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(l10n.noProducts, style: TextStyle(color: kSecondaryText, fontSize: 16)),
                            if (_searchQuery.isNotEmpty || _selectedCategory != 'all') ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _selectedCategory = 'all';
                                  _loadProducts();
                                },
                                child: Text(
                                  l10n.clearFilters,
                                  style: TextStyle(color: kGoldPrimary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: kGoldPrimary,
                        onRefresh: _loadProducts,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(_products[index], lang);
                          },
                        ),
                      ),
          ),
        ],
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
                            errorBuilder: (_, __, ___) =>
                                Center(child: Icon(Icons.checkroom, size: 48, color: kGoldPrimary.withOpacity(0.3))),
                          )
                        : Center(child: Icon(Icons.checkroom, size: 48, color: kGoldPrimary.withOpacity(0.3))),
                  ),
                  if (product.badge != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: kGoldPrimary, borderRadius: BorderRadius.circular(8)),
                        child: Text(product.badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '-${((product.originalPrice! - product.price) * 100 / product.originalPrice!).round()}%',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
                      style: TextStyle(color: kCharcoal, fontSize: 13, fontWeight: FontWeight.w600),
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
                            Text('${product.rating}', style: TextStyle(color: kSecondaryText, fontSize: 11)),
                            const SizedBox(width: 4),
                            Text('(${product.reviewCount})', style: TextStyle(color: kSecondaryText.withOpacity(0.7), fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                MoneyFormatter.format(product.price, lang),
                                style: TextStyle(color: kGoldPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  MoneyFormatter.format(product.originalPrice!, lang),
                                  style: TextStyle(color: kSecondaryText, fontSize: 11, decoration: TextDecoration.lineThrough),
                                  overflow: TextOverflow.ellipsis,
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

  // ---------- Helpers ----------

  String _categoryLabel(String cat, AppLocalizations l10n) {
    switch (cat) {
      case 'all':
        return l10n.all;
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
