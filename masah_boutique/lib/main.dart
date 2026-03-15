import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/api_service.dart';
import 'services/cart_provider.dart';
import 'services/locale_provider.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/stores_screen.dart';

void main() {
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
                primary: const Color(0xFFC8A96E),
                secondary: const Color(0xFFE8D5A8),
                surface: const Color(0xFF1A1A2E),
                onPrimary: const Color(0xFF1A1A2E),
                onSecondary: const Color(0xFF1A1A2E),
                onSurface: Colors.white,
              ),
              scaffoldBackgroundColor: const Color(0xFF1A1A2E),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF16162A),
                foregroundColor: Color(0xFFC8A96E),
                elevation: 0,
              ),
              fontFamily: 'Tajawal',
              useMaterial3: true,
            ),
            home: const MainScreen(),
            routes: {
              '/products': (context) => const ProductsScreen(),
              '/cart': (context) => const CartScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/stores': (context) => const StoresScreen(),
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

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductsScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const StoresScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16162A),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFC8A96E).withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF16162A),
            selectedItemColor: const Color(0xFFC8A96E),
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: isAr ? 'الرئيسية' : 'Home',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.grid_view_outlined),
                activeIcon: const Icon(Icons.grid_view),
                label: isAr ? 'المنتجات' : 'Products',
              ),
              BottomNavigationBarItem(
                icon: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Badge(
                      isLabelVisible: cart.itemCount > 0,
                      label: Text('${cart.itemCount}'),
                      backgroundColor: const Color(0xFFC8A96E),
                      textColor: const Color(0xFF1A1A2E),
                      child: child!,
                    );
                  },
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                activeIcon: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Badge(
                      isLabelVisible: cart.itemCount > 0,
                      label: Text('${cart.itemCount}'),
                      backgroundColor: const Color(0xFFC8A96E),
                      textColor: const Color(0xFF1A1A2E),
                      child: child!,
                    );
                  },
                  child: const Icon(Icons.shopping_bag),
                ),
                label: isAr ? 'السلة' : 'Cart',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long_outlined),
                activeIcon: const Icon(Icons.receipt_long),
                label: isAr ? 'الطلبات' : 'Orders',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.store_outlined),
                activeIcon: const Icon(Icons.store),
                label: isAr ? 'الفروع' : 'Stores',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
