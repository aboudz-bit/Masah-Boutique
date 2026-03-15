class Product {
  final int id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final int price;
  final int? originalPrice;
  final String category;
  final String? subcategory;
  final List<String> images;
  final String? videoUrl;
  final List<String> sizes;
  final List<String> colors;
  final String? fabricEn;
  final String? fabricAr;
  final bool inStock;
  final bool featured;
  final String? badge;
  final double rating;
  final int reviewCount;
  final bool arEnabled;

  Product({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
    this.originalPrice,
    required this.category,
    this.subcategory,
    required this.images,
    this.videoUrl,
    required this.sizes,
    required this.colors,
    this.fabricEn,
    this.fabricAr,
    required this.inStock,
    required this.featured,
    this.badge,
    required this.rating,
    required this.reviewCount,
    this.arEnabled = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nameEn: json['nameEn'] ?? json['name_en'] ?? '',
      nameAr: json['nameAr'] ?? json['name_ar'] ?? '',
      descriptionEn: json['descriptionEn'] ?? json['description_en'] ?? '',
      descriptionAr: json['descriptionAr'] ?? json['description_ar'] ?? '',
      price: json['price'] ?? 0,
      originalPrice: json['originalPrice'] ?? json['original_price'],
      category: json['category'] ?? '',
      subcategory: json['subcategory'],
      images: List<String>.from(json['images'] ?? []),
      videoUrl: json['videoUrl'] ?? json['video_url'],
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      fabricEn: json['fabricEn'] ?? json['fabric_en'],
      fabricAr: json['fabricAr'] ?? json['fabric_ar'],
      inStock: json['inStock'] ?? json['in_stock'] ?? true,
      featured: json['featured'] ?? false,
      badge: json['badge'],
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviewCount: json['reviewCount'] ?? json['review_count'] ?? 0,
      arEnabled: json['arEnabled'] ?? json['ar_enabled'] ?? false,
    );
  }

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;
  String getDescription(String locale) => locale == 'ar' ? descriptionAr : descriptionEn;
  String? getFabric(String locale) => locale == 'ar' ? fabricAr : fabricEn;

  String get formattedPrice {
    final riyals = price ~/ 100;
    final halalas = price % 100;
    return halalas > 0 ? '$riyals.$halalas SAR' : '$riyals SAR';
  }

  String get formattedOriginalPrice {
    if (originalPrice == null) return '';
    final riyals = originalPrice! ~/ 100;
    final halalas = originalPrice! % 100;
    return halalas > 0 ? '$riyals.$halalas SAR' : '$riyals SAR';
  }

  int? get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return null;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }
}
