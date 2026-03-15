import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/api_service.dart';
import 'services/cart_provider.dart';
import 'services/locale_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/stores_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/category_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'utils/arabic_digits.dart';

const kGoldPrimary = Color(0xFFC8A96E);
const kGoldDark = Color(0xFFB8944E);
const kBgDark = Color(0xFF1A1A2E);
const kBgDarker = Color(0xFF16162A);
const kBgCard = Color(0xFF222240);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MasahBoutiqueApp());
}

class MasahBoutiqueApp extends StatelessWidget {
  const MasahBoutiqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'بوتيك ماسـة',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.dark(
                primary: kGoldPrimary,
                secondary: const Color(0xFFE8D5A8),
                surface: kBgDark,
                onPrimary: kBgDark,
                onSecondary: kBgDark,
                onSurface: Colors.white,
              ),
              scaffoldBackgroundColor: kBgDark,
              appBarTheme: const AppBarTheme(
                backgroundColor: kBgDarker,
                foregroundColor: kGoldPrimary,
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGoldPrimary,
                  foregroundColor: kBgDark,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  elevation: 0,
                ),
              ),
              cardTheme: CardTheme(
                elevation: 0,
                color: kBgCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: kBgDarker,
                selectedItemColor: kGoldPrimary,
                unselectedItemColor: Colors.grey[600],
                type: BottomNavigationBarType.fixed,
                elevation: 0,
              ),
              useMaterial3: true,
            ),
            home: const MainScreen(),
            onGenerateRoute: (settings) {
              Widget? page;
              if (settings.name?.startsWith('/product/') ?? false) {
                final idStr = settings.name!.replaceFirst('/product/', '');
                final id = int.tryParse(idStr);
                if (id != null) page = ProductDetailScreen(productId: id);
              } else if (settings.name?.startsWith('/category/') ?? false) {
                final slug = settings.name!.replaceFirst('/category/', '');
                if (slug.isNotEmpty) page = CategoryScreen(slug: slug);
              } else if (settings.name == '/checkout') {
                page = const CheckoutScreen();
              } else if (settings.name == '/orders') {
                page = const OrdersScreen();
              } else if (settings.name == '/stores') {
                page = const StoresScreen();
              } else if (settings.name == '/order-confirmation') {
                page = OrderConfirmationScreen(order: settings.arguments);
              }
              if (page != null) {
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => page!,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOut),
                        ),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 280),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProductsScreen(),
    CartScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).loadCart();
      Provider.of<FavoritesProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final lang = Localizations.localeOf(context).languageCode;
    final cart = context.watch<CartProvider>();
    final cartBadge = ArabicDigits.convert(cart.itemCount, lang);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: kBgDarker,
            border: Border(
              top: BorderSide(
                color: kGoldPrimary.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: isAr ? 'الرئيسية' : 'Home',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_bag_outlined),
                activeIcon: const Icon(Icons.shopping_bag),
                label: isAr ? 'المتجر' : 'Shop',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: cart.itemCount > 0,
                  label: Text(cartBadge, style: const TextStyle(fontSize: 10)),
                  backgroundColor: kGoldPrimary,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                activeIcon: Badge(
                  isLabelVisible: cart.itemCount > 0,
                  label: Text(cartBadge, style: const TextStyle(fontSize: 10)),
                  backgroundColor: kGoldPrimary,
                  child: const Icon(Icons.shopping_cart),
                ),
                label: isAr ? 'السلة' : 'Cart',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: isAr ? 'الإعدادات' : 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
