import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_provider.dart';
import '../services/locale_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await ApiService.getProduct(widget.productId);
      setState(() {
        _product = product;
        _selectedSize = product.sizes.isNotEmpty ? product.sizes.first : null;
        _selectedColor = product.colors.isNotEmpty ? product.colors.first : null;
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFC8A96E))),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(isAr ? 'المنتج غير موجود' : 'Product not found',
              style: TextStyle(color: Colors.grey[500])),
        ),
      );
    }

    final product = _product!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Product Image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checkroom, size: 80, color: const Color(0xFFC8A96E).withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text(
                        product.getName(lang),
                        style: TextStyle(color: const Color(0xFFC8A96E).withOpacity(0.5), fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (product.badge != null)
                Container(
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8A96E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.badge!,
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Price
                  Text(
                    product.getName(lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          color: Color(0xFFC8A96E),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          product.formattedOriginalPrice,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 18,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${product.discountPercentage}%',
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Rating
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < product.rating.round() ? Icons.star : Icons.star_border,
                          color: const Color(0xFFC8A96E),
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${product.rating}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount} ${isAr ? "تقييم" : "reviews"})',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),

                  // Description
                  const SizedBox(height: 24),
                  Text(
                    isAr ? 'الوصف' : 'Description',
                    style: const TextStyle(color: Color(0xFFC8A96E), fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.getDescription(lang),
                    style: TextStyle(color: Colors.grey[300], fontSize: 15, height: 1.6),
                  ),

                  // Fabric
                  if (product.getFabric(lang) != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.texture, color: Color(0xFFC8A96E), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${isAr ? "القماش: " : "Fabric: "}${product.getFabric(lang)}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ],
                    ),
                  ],

                  // Size selection
                  const SizedBox(height: 24),
                  Text(
                    isAr ? 'المقاس' : 'Size',
                    style: const TextStyle(color: Color(0xFFC8A96E), fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
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
                            color: isSelected ? const Color(0xFFC8A96E) : const Color(0xFF222240),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFC8A96E) : const Color(0xFFC8A96E).withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey[300],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Color selection
                  const SizedBox(height: 24),
                  Text(
                    isAr ? 'اللون' : 'Color',
                    style: const TextStyle(color: Color(0xFFC8A96E), fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
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
                            color: isSelected ? const Color(0xFFC8A96E) : const Color(0xFF222240),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFC8A96E) : const Color(0xFFC8A96E).withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            color,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey[300],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Quantity
                  const SizedBox(height: 24),
                  Text(
                    isAr ? 'الكمية' : 'Quantity',
                    style: const TextStyle(color: Color(0xFFC8A96E), fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuantityButton(Icons.remove, () {
                        if (_quantity > 1) setState(() => _quantity--);
                      }),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
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

      // Add to Cart button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16162A),
          border: Border(top: BorderSide(color: const Color(0xFFC8A96E).withOpacity(0.2))),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: product.inStock ? _addToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: product.inStock ? const Color(0xFFC8A96E) : Colors.grey[700],
                foregroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              child: Text(
                product.inStock
                    ? (isAr ? 'أضيفي إلى السلة' : 'Add to Cart')
                    : (isAr ? 'نفذت الكمية' : 'Out of Stock'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF222240),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC8A96E).withOpacity(0.3)),
        ),
        child: Icon(icon, color: const Color(0xFFC8A96E), size: 20),
      ),
    );
  }

  Future<void> _addToCart() async {
    if (_selectedSize == null || _selectedColor == null) return;

    final cart = context.read<CartProvider>();
    await cart.addToCart(
      product: _product!,
      size: _selectedSize!,
      color: _selectedColor!,
      quantity: _quantity,
    );

    if (mounted) {
      final isAr = context.read<LocaleProvider>().isArabic;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'تمت الإضافة إلى السلة' : 'Added to cart'),
          backgroundColor: const Color(0xFFC8A96E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
