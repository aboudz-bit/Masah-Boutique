import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/locale_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String slug;

  const CategoryScreen({super.key, required this.slug});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  final _categoryNames = {
    'abayas': {'en': 'Abayas', 'ar': 'عبايات'},
    'jalabiyas': {'en': 'Jalabiyas', 'ar': 'جلابيات'},
    'dresses': {'en': 'Dresses', 'ar': 'فساتين'},
    'bridal': {'en': 'Bridal', 'ar': 'عرائس'},
    'kids': {'en': 'Kids', 'ar': 'أطفال'},
    'gifts': {'en': 'Gifts', 'ar': 'هدايا'},
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ApiService.getProducts(category: widget.slug);
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
    final catName = _categoryNames[widget.slug];
    final title = catName != null ? (isAr ? catName['ar']! : catName['en']!) : widget.slug;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC8A96E)))
          : _products.isEmpty
              ? Center(
                  child: Text(
                    isAr ? 'لا توجد منتجات في هذا القسم' : 'No products in this category',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                )
              : GridView.builder(
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
    );
  }
}
