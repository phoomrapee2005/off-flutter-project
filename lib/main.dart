import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Required for sqflite on web to persist data in IndexedDB
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Initialize providers
  final productProvider = ProductProvider();
  final orderProvider = OrderProvider();
  final authProvider = AuthProvider();

  await productProvider.loadProducts();
  await orderProvider.loadOrders();

  runApp(
    ClickClackApp(
      productProvider: productProvider,
      orderProvider: orderProvider,
      authProvider: authProvider,
    ),
  );
}

class ClickClackApp extends StatelessWidget {
  final ProductProvider? productProvider;
  final OrderProvider? orderProvider;
  final AuthProvider? authProvider;

  const ClickClackApp({
    super.key,
    this.productProvider,
    this.orderProvider,
    this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        productProvider != null
            ? ChangeNotifierProvider.value(value: productProvider!)
            : ChangeNotifierProvider(
                create: (_) => ProductProvider()..loadProducts(),
              ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        orderProvider != null
            ? ChangeNotifierProvider.value(value: orderProvider!)
            : ChangeNotifierProvider(
                create: (_) => OrderProvider()..loadOrders(),
              ),
        authProvider != null
            ? ChangeNotifierProvider.value(value: authProvider!)
            : ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Click & Clack',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A1C23),
            primary: const Color(0xFF1A1C23),
            secondary: const Color(0xFF4361EE),
            surface: Colors.white,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.promptTextTheme(),
          appBarTheme: AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: const Color(0xFFF8F9FA),
            foregroundColor: const Color(0xFF1A1C23),
            titleTextStyle: GoogleFonts.prompt(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C23),
              letterSpacing: -0.5,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.withAlpha(20), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFF1A1C23),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withAlpha(30)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withAlpha(30)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF1A1C23),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
