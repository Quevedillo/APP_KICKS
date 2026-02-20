import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/category/category_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'screens/sales/sales_screen.dart';
import 'screens/products/all_products_screen.dart';
import 'widgets/main_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Main shell with bottom navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    
    // Full screen routes (no bottom nav)
    GoRoute(
      path: '/product/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return ProductDetailScreen(slug: slug);
      },
    ),
    GoRoute(
      path: '/category/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return CategoryScreen(slug: slug);
      },
    ),
    // All products catalog
    GoRoute(
      path: '/products',
      builder: (context, state) => const AllProductsScreen(),
    ),
    // Ofertas / Sales screens
    GoRoute(
      path: '/sales',
      builder: (context, state) => const SalesScreen(),
    ),
    GoRoute(
      path: '/sales/:collection',
      builder: (context, state) {
        final collection = state.pathParameters['collection']!;
        return SalesScreen(collection: collection);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final redirect = state.uri.queryParameters['redirect'];
        return LoginScreen(redirectTo: redirect);
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminPanelScreen(),
    ),
  ],
);

