class Country {
  final String code;
  final String nameEn;
  final String nameAr;
  final List<City> cities;

  const Country({required this.code, required this.nameEn, required this.nameAr, required this.cities});
  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
}

class City {
  final String nameEn;
  final String nameAr;
  const City({required this.nameEn, required this.nameAr});
  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
}

const List<Country> kCountries = [
  Country(code: 'SA', nameEn: 'Saudi Arabia', nameAr: 'المملكة العربية السعودية', cities: [
    City(nameEn: 'Saihat', nameAr: 'سيهات'),
    City(nameEn: 'Qatif', nameAr: 'القطيف'),
    City(nameEn: 'Dammam', nameAr: 'الدمام'),
    City(nameEn: 'Khobar', nameAr: 'الخبر'),
    City(nameEn: 'Dhahran', nameAr: 'الظهران'),
    City(nameEn: 'Riyadh', nameAr: 'الرياض'),
    City(nameEn: 'Jeddah', nameAr: 'جدة'),
    City(nameEn: 'Makkah', nameAr: 'مكة المكرمة'),
    City(nameEn: 'Madinah', nameAr: 'المدينة المنورة'),
    City(nameEn: 'Tabuk', nameAr: 'تبوك'),
    City(nameEn: 'Abha', nameAr: 'أبها'),
    City(nameEn: 'Taif', nameAr: 'الطائف'),
    City(nameEn: 'Buraydah', nameAr: 'بريدة'),
    City(nameEn: 'Hail', nameAr: 'حائل'),
    City(nameEn: 'Najran', nameAr: 'نجران'),
    City(nameEn: 'Jubail', nameAr: 'الجبيل'),
    City(nameEn: 'Al Ahsa', nameAr: 'الأحساء'),
    City(nameEn: 'Yanbu', nameAr: 'ينبع'),
  ]),
  Country(code: 'AE', nameEn: 'United Arab Emirates', nameAr: 'الإمارات العربية المتحدة', cities: [
    City(nameEn: 'Dubai', nameAr: 'دبي'),
    City(nameEn: 'Abu Dhabi', nameAr: 'أبو ظبي'),
    City(nameEn: 'Sharjah', nameAr: 'الشارقة'),
    City(nameEn: 'Ajman', nameAr: 'عجمان'),
  ]),
  Country(code: 'KW', nameEn: 'Kuwait', nameAr: 'الكويت', cities: [
    City(nameEn: 'Kuwait City', nameAr: 'مدينة الكويت'),
    City(nameEn: 'Hawalli', nameAr: 'حولي'),
    City(nameEn: 'Salmiya', nameAr: 'السالمية'),
  ]),
  Country(code: 'BH', nameEn: 'Bahrain', nameAr: 'البحرين', cities: [
    City(nameEn: 'Manama', nameAr: 'المنامة'),
    City(nameEn: 'Muharraq', nameAr: 'المحرق'),
    City(nameEn: 'Riffa', nameAr: 'الرفاع'),
  ]),
  Country(code: 'QA', nameEn: 'Qatar', nameAr: 'قطر', cities: [
    City(nameEn: 'Doha', nameAr: 'الدوحة'),
    City(nameEn: 'Al Wakrah', nameAr: 'الوكرة'),
  ]),
  Country(code: 'OM', nameEn: 'Oman', nameAr: 'عُمان', cities: [
    City(nameEn: 'Muscat', nameAr: 'مسقط'),
    City(nameEn: 'Salalah', nameAr: 'صلالة'),
  ]),
];
