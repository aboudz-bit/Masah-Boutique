class Store {
  final int id;
  final String nameEn;
  final String nameAr;
  final String addressEn;
  final String addressAr;
  final String city;
  final String phone;
  final String hoursEn;
  final String hoursAr;
  final String? mapUrl;
  final bool isActive;

  Store({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.addressEn,
    required this.addressAr,
    required this.city,
    required this.phone,
    required this.hoursEn,
    required this.hoursAr,
    this.mapUrl,
    required this.isActive,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      nameEn: json['nameEn'] ?? json['name_en'] ?? '',
      nameAr: json['nameAr'] ?? json['name_ar'] ?? '',
      addressEn: json['addressEn'] ?? json['address_en'] ?? '',
      addressAr: json['addressAr'] ?? json['address_ar'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      hoursEn: json['hoursEn'] ?? json['hours_en'] ?? '',
      hoursAr: json['hoursAr'] ?? json['hours_ar'] ?? '',
      mapUrl: json['mapUrl'] ?? json['map_url'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;
  String address(String locale) => locale == 'ar' ? addressAr : addressEn;
  String hours(String locale) => locale == 'ar' ? hoursAr : hoursEn;
}
