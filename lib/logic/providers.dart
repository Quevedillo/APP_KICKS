import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/email_repository.dart';
import '../data/repositories/admin_repository.dart';
import '../data/repositories/discount_repository.dart';
import '../data/services/stripe_admin_service.dart';
import '../data/models/product.dart';
import '../data/models/category.dart';
import '../data/models/order.dart';
import '../data/models/cart_item.dart';
import '../data/models/user_profile.dart';
import '../data/models/discount_code.dart';

// ========== Clients ==========
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ========== Repositories ==========
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(supabaseClientProvider));
});

final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  return EmailRepository();
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(supabaseClientProvider));
});

final discountRepositoryProvider = Provider<DiscountRepository>((ref) {
  return DiscountRepository(ref.watch(supabaseClientProvider));
});

final stripeAdminServiceProvider = Provider<StripeAdminService>((ref) {
  return StripeAdminService(ref.watch(supabaseClientProvider));
});

// ========== Auth Providers ==========
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final userProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider) != null;
});

final userEmailProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  return user?.email ?? '';
});

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;
  return ref.watch(authRepositoryProvider).getUserProfile();
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return false;
  return ref.watch(authRepositoryProvider).isAdmin();
});

// ========== Product Providers ==========
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(productRepositoryProvider).getCategories();
});

final productsProvider = FutureProvider.family<List<Product>, String?>((ref, categorySlug) async {
  return ref.watch(productRepositoryProvider).getProducts(categorySlug: categorySlug);
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productRepositoryProvider).getProducts();
  return products.where((p) => p.isFeatured).toList();
});

final productBySlugProvider = FutureProvider.family<Product?, String>((ref, slug) async {
  return ref.watch(productRepositoryProvider).getProductBySlug(slug);
});

// ========== Order Providers ==========
final userOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return [];
  ref.watch(authStateProvider);
  return ref.watch(orderRepositoryProvider).getUserOrders();
});

// ========== Cart State ==========
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(Product product, String size, int quantity) {
    if (quantity <= 0) return;
    if (!product.sizesAvailable.containsKey(size)) return;
    
    final existingIndex = state.indexWhere(
      (item) => item.productId == product.id && item.size == size,
    );

    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      final maxStock = _getStockForSize(product, size);
      final finalQuantity = newQuantity > maxStock ? maxStock : newQuantity;
      
      state = [
        ...state.sublist(0, existingIndex),
        existingItem.copyWith(quantity: finalQuantity),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      final maxStock = _getStockForSize(product, size);
      final finalQuantity = quantity > maxStock ? maxStock : quantity;
      state = [
        ...state,
        CartItem(
          productId: product.id,
          product: product,
          quantity: finalQuantity,
          size: size,
        ),
      ];
    }
  }

  void removeItem(String productId, String size) {
    state = state.where(
      (item) => !(item.productId == productId && item.size == size),
    ).toList();
  }

  void updateQuantity(String productId, String size, int quantity) {
    if (quantity <= 0) {
      removeItem(productId, size);
      return;
    }

    final index = state.indexWhere(
      (item) => item.productId == productId && item.size == size,
    );

    if (index >= 0) {
      final item = state[index];
      final maxStock = item.availableStock;
      final finalQuantity = quantity > maxStock ? maxStock : quantity;
      
      state = [
        ...state.sublist(0, index),
        item.copyWith(quantity: finalQuantity),
        ...state.sublist(index + 1),
      ];
    }
  }

  void clearCart() {
    state = [];
  }

  int _getStockForSize(Product product, String size) {
    if (!product.sizesAvailable.containsKey(size)) return 0;
    final stock = product.sizesAvailable[size];
    if (stock is int) return stock;
    if (stock is String) return int.tryParse(stock) ?? 0;
    return 0;
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartTotalProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  int total = 0;
  for (final item in cart) {
    total += (item.product.price * item.quantity).toInt();
  }
  return total;
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  int count = 0;
  for (final item in cart) {
    count += item.quantity;
  }
  return count;
});

final cartOpenProvider = NotifierProvider<CartOpenNotifier, bool>(
  CartOpenNotifier.new,
);

class CartOpenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setOpen(bool value) => state = value;
}

// ========== Search State ==========
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final searchResultsProvider = FutureProvider<List<Product>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  return ref.watch(productRepositoryProvider).searchProducts(query);
});

// ========== Admin Providers ==========

/// Dashboard con estadísticas en tiempo real sincronizadas con BD y Stripe
final adminDashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getDashboardStats();
});

/// Todas las órdenes sincronizadas con Stripe
final adminAllOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getAllOrders();
});

/// Órdenes por estado específico
final adminOrdersByStatusProvider = FutureProvider.family.autoDispose<List<Order>, String>((ref, status) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getOrdersByStatus(status);
});

/// Solicitudes de devolución
final adminReturnRequestsProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getReturnRequests();
});

/// Todos los productos con stock sincronizado
final adminAllProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getAllProducts();
});

/// Productos con bajo stock
final adminLowStockProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getLowStockProducts();
});

/// Todos los usuarios
final adminAllUsersProvider = FutureProvider.autoDispose<List<UserProfile>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getAllUsers();
});

/// Estadísticas de usuarios
final adminUserStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getUserStats();
});

/// Todas las categorías
final adminAllCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getAllCategories();
});

/// Todos los códigos de descuento
final adminAllDiscountCodesProvider = FutureProvider.autoDispose<List<DiscountCode>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getAllDiscountCodes();
});

/// Códigos de descuento activos
final adminActiveDiscountCodesProvider = FutureProvider.autoDispose<List<DiscountCode>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getActiveDiscountCodes();
});

/// Estadísticas de órdenes por estado
final adminOrderStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(adminRepositoryProvider).getOrderStats();
});

/// Análisis de ingresos
final adminRevenueAnalyticsProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, (DateTime, DateTime)>(
  (ref, dates) async {
    final isAdmin = await ref.watch(isAdminProvider.future);
    if (!isAdmin) throw Exception('Not authorized');
    return ref.watch(adminRepositoryProvider).getRevenueAnalytics(
      startDate: dates.$1,
      endDate: dates.$2,
    );
  },
);

/// Sección actualmente seleccionada en admin
class AdminSelectedSectionNotifier extends Notifier<int> {
  @override
  int build() => 0;
  
  void setSection(int index) => state = index;
}

final adminSelectedSectionProvider = NotifierProvider<AdminSelectedSectionNotifier, int>(
  AdminSelectedSectionNotifier.new,
);

// ========== STRIPE ADMIN PROVIDERS ==========

/// Órdenes pagadas sincronizadas desde Stripe
final stripePaidOrdersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(stripeAdminServiceProvider).getPaidOrders();
});

/// Órdenes fallidas en Stripe
final stripeFailedOrdersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(stripeAdminServiceProvider).getFailedOrders();
});

/// Resumen de pagos por período
final stripePaymentSummaryProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, (DateTime, DateTime)>(
  (ref, dates) async {
    final isAdmin = await ref.watch(isAdminProvider.future);
    if (!isAdmin) throw Exception('Not authorized');
    return ref.watch(stripeAdminServiceProvider).getPaymentSummary(
      startDate: dates.$1,
      endDate: dates.$2,
    );
  },
);

/// Órdenes con disputas en Stripe
final stripeDisputedOrdersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final isAdmin = await ref.watch(isAdminProvider.future);
  if (!isAdmin) throw Exception('Not authorized');
  return ref.watch(stripeAdminServiceProvider).getDisputedOrders();
});

/// Estadísticas de reembolsos
final stripeRefundStatsProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, (DateTime, DateTime)>(
  (ref, dates) async {
    final isAdmin = await ref.watch(isAdminProvider.future);
    if (!isAdmin) throw Exception('Not authorized');
    return ref.watch(stripeAdminServiceProvider).getRefundStats(
      startDate: dates.$1,
      endDate: dates.$2,
    );
  },
);
