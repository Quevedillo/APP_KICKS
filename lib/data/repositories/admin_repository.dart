import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user_profile.dart';
import '../models/category.dart';
import '../models/discount_code.dart';

/// Repositorio centralizado para todas las operaciones de administración
/// Sincroniza datos con Supabase y Stripe
class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  // ========== DASHBOARD ==========

  /// Obtiene estadísticas del dashboard sincronizadas con BD y Stripe
  /// Incluye: pedidos, ingresos, usuarios, productos, stocks bajos
  Future<Map<String, dynamic>> getDashboardStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    try {
      // 1. Pedidos de hoy (validados: pagados/procesando)
      final ordersTodayResponse = await _client
          .from('orders')
          .select('id, status, total_price, stripe_session_id')
          .gte('created_at', today)
          .or('status.eq.paid,status.eq.completed,status.eq.processing,status.eq.shipped');

      double revenueToday = 0;
      int paidOrdersToday = 0;

      for (var order in ordersTodayResponse as List) {
        final totalPrice = order['total_price'] as num?;
        final status = order['status'] as String?;

        if (totalPrice != null && (status == 'paid' || status == 'completed')) {
          revenueToday += totalPrice.toDouble();
          paidOrdersToday++;
        }
      }

      // 2. Usuarios nuevos hoy
      final newUsersTodayResponse = await _client
          .from('user_profiles')
          .select('id')
          .gte('created_at', today);

      // 3. Productos activos y sus stocks
      final totalProductsResponse = await _client
          .from('products')
          .select('id, stock')
          .eq('is_active', true);

      // 4. Contar productos con stock bajo (< 5)
      int lowStockCount = 0;
      for (var product in totalProductsResponse as List) {
        final stock = product['stock'] as int?;
        if (stock != null && stock < 5) {
          lowStockCount++;
        }
      }

      // 5. Órdenes pendientes de envío
      final pendingShipmentsResponse = await _client
          .from('orders')
          .select('id')
          .eq('status', 'processing');

      // 6. Ingresos totales (todos los tiempos, pagos confirmados)
      final totalRevenueData = await _client
          .from('orders')
          .select('total_price')
          .or('status.eq.paid,status.eq.completed');

      double totalRevenue = 0;
      for (var order in totalRevenueData as List) {
        final totalPrice = order['total_price'] as num?;
        if (totalPrice != null) {
          totalRevenue += totalPrice.toDouble();
        }
      }

      // 7. Ingresos del mes actual
      final firstDayOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
      final monthlyRevenueData = await _client
          .from('orders')
          .select('total_price')
          .gte('created_at', firstDayOfMonth)
          .or('status.eq.paid,status.eq.completed');

      double monthlyRevenue = 0;
      for (var order in monthlyRevenueData as List) {
        final totalPrice = order['total_price'] as num?;
        if (totalPrice != null) {
          monthlyRevenue += totalPrice.toDouble();
        }
      }

      // 8. Pedidos pendientes (pagados pero no enviados)
      final pendingOrdersResponse = await _client
          .from('orders')
          .select('id')
          .inFilter('status', ['paid', 'processing']);

      // 9. Producto más vendido (calculado desde items JSONB en orders)
      String topProduct = 'Sin datos';
      try {
        final allPaidOrders = await _client
            .from('orders')
            .select('items')
            .or('status.eq.paid,status.eq.completed');

        // Contar cantidad vendida por producto
        final Map<String, int> productCount = {};
        final Map<String, String> productNames = {};
        
        for (var order in allPaidOrders as List) {
          final itemsData = order['items'];
          List<dynamic> items = [];
          
          if (itemsData is String && itemsData.isNotEmpty) {
            try {
              final decoded = jsonDecode(itemsData);
              if (decoded is List) items = decoded;
            } catch (_) {}
          } else if (itemsData is List) {
            items = itemsData;
          }
          
          for (var item in items) {
            if (item is Map<String, dynamic>) {
              final name = item['name'] as String? ?? '';
              final qty = (item['quantity'] as num?)?.toInt() ?? 1;
              final productId = item['product_id'] as String? ?? name;
              if (name.isNotEmpty) {
                productCount[productId] = (productCount[productId] ?? 0) + qty;
                productNames[productId] = name;
              }
            }
          }
        }
        
        if (productCount.isNotEmpty) {
          final topId = productCount.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
          topProduct = productNames[topId] ?? 'Sin datos';
        }
      } catch (e) {
        // Fallback si hay error
        topProduct = 'Sin datos';
      }

      // 10. Ventas de los últimos 7 días
      final List<Map<String, dynamic>> salesLast7Days = [];
      for (int i = 6; i >= 0; i--) {
        final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final nextDay = day.add(const Duration(days: 1));
        
        try {
          final dayOrders = await _client
              .from('orders')
              .select('total_price')
              .gte('created_at', day.toIso8601String())
              .lt('created_at', nextDay.toIso8601String())
              .or('status.eq.paid,status.eq.completed');

          double dayTotal = 0;
          for (var order in dayOrders as List) {
            final totalPrice = order['total_price'] as num?;
            if (totalPrice != null) {
              dayTotal += totalPrice.toDouble();
            }
          }
          
          salesLast7Days.add({
            'date': day.toIso8601String(),
            'total': dayTotal / 100, // Centavos a euros
          });
        } catch (e) {
          salesLast7Days.add({'date': day.toIso8601String(), 'total': 0.0});
        }
      }

      return {
        'ordersToday': (ordersTodayResponse as List).length,
        'paidOrdersToday': paidOrdersToday,
        'revenueToday': revenueToday / 100, // Centavos a moneda
        'totalRevenue': totalRevenue / 100, // Total histórico
        'monthlyRevenue': monthlyRevenue / 100, // Ingresos del mes
        'pendingOrders': (pendingOrdersResponse as List).length,
        'topProduct': topProduct,
        'salesLast7Days': salesLast7Days,
        'newUsersToday': (newUsersTodayResponse as List).length,
        'totalProducts': (totalProductsResponse as List).length,
        'lowStockProducts': lowStockCount,
        'pendingShipments': (pendingShipmentsResponse as List).length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error fetching dashboard stats: $e');
      rethrow;
    }
  }

  // ========== ORDERS MANAGEMENT ==========

  /// Obtiene todas las órdenes sincronizadas con Stripe
  Future<List<Order>> getAllOrders() async {
    try {
      final data = await _client
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching all orders: $e');
      rethrow;
    }
  }

  /// Obtiene órdenes filtradas por estado
  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final data = await _client
          .from('orders')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching orders by status: $e');
      rethrow;
    }
  }

  /// Obtiene órdenes de un usuario específico
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final data = await _client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching user orders: $e');
      rethrow;
    }
  }

  /// Actualiza estado de orden y sincroniza con Stripe si es necesario
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final now = DateTime.now().toIso8601String();

      await _client.from('orders').update({
        'status': status,
        'updated_at': now,
      }).eq('id', orderId);

      return true;
    } catch (e) {
      print('❌ Error updating order status: $e');
      return false;
    }
  }

  /// Actualiza estado de devolución
  Future<bool> updateReturnStatus(String orderId, String returnStatus) async {
    try {
      final now = DateTime.now().toIso8601String();

      await _client.from('orders').update({
        'return_status': returnStatus,
        'updated_at': now,
      }).eq('id', orderId);

      return true;
    } catch (e) {
      print('❌ Error updating return status: $e');
      return false;
    }
  }

  /// Obtiene órdenes con devoluciones solicitadas
  Future<List<Order>> getReturnRequests() async {
    try {
      final data = await _client
          .from('orders')
          .select()
          .neq('return_status', 'none')
          .order('updated_at', ascending: false);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching return requests: $e');
      rethrow;
    }
  }

  // ========== PRODUCTS MANAGEMENT ==========

  /// Obtiene todos los productos con stock sincronizado
  Future<List<Product>> getAllProducts() async {
    try {
      final data = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching all products: $e');
      rethrow;
    }
  }

  /// Obtiene productos con bajo stock
  Future<List<Product>> getLowStockProducts({int threshold = 5}) async {
    try {
      final data = await _client
          .from('products')
          .select()
          .lt('stock', threshold)
          .order('stock', ascending: true);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching low stock products: $e');
      rethrow;
    }
  }

  /// Crea o actualiza un producto
  Future<bool> upsertProduct(Product product) async {
    try {
      final data = product.toJson();
      final now = DateTime.now().toIso8601String();

      if (product.id.isEmpty || product.id.startsWith('temp_')) {
        data.remove('id');
        data['created_at'] = now;
        data['updated_at'] = now;
        await _client.from('products').insert(data);
      } else {
        data['updated_at'] = now;
        await _client.from('products').update(data).eq('id', product.id);
      }

      return true;
    } catch (e) {
      print('❌ Error upserting product: $e');
      return false;
    }
  }

  /// Elimina un producto
  Future<bool> deleteProduct(String id) async {
    try {
      await _client.from('products').delete().eq('id', id);
      return true;
    } catch (e) {
      print('❌ Error deleting product: $e');
      return false;
    }
  }

  // ========== CATEGORIES MANAGEMENT ==========

  /// Obtiene todas las categorías ordenadas por display_order
  Future<List<Category>> getAllCategories() async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .order('display_order', ascending: true);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching categories: $e');
      rethrow;
    }
  }

  /// Crea o actualiza una categoría
  Future<bool> upsertCategory(Category category) async {
    try {
      final data = {
        'name': category.name,
        'slug': category.slug,
        'description': category.description,
        'icon': category.icon,
        'display_order': category.displayOrder,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (category.id.isNotEmpty && !category.id.startsWith('temp_')) {
        await _client.from('categories').update(data).eq('id', category.id);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        await _client.from('categories').insert(data);
      }

      return true;
    } catch (e) {
      print('❌ Error upserting category: $e');
      return false;
    }
  }

  /// Elimina una categoría
  Future<bool> deleteCategory(String id) async {
    try {
      await _client.from('categories').delete().eq('id', id);
      return true;
    } catch (e) {
      print('❌ Error deleting category: $e');
      return false;
    }
  }

  // ========== USERS MANAGEMENT ==========

  /// Obtiene todos los usuarios
  Future<List<UserProfile>> getAllUsers() async {
    try {
      final data = await _client
          .from('user_profiles')
          .select()
          .order('created_at', ascending: false);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching all users: $e');
      rethrow;
    }
  }

  /// Obtiene usuarios administradores
  Future<List<UserProfile>> getAdminUsers() async {
    try {
      final data = await _client
          .from('user_profiles')
          .select()
          .eq('is_admin', true)
          .order('created_at', ascending: false);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching admin users: $e');
      rethrow;
    }
  }

  /// Obtiene estadísticas de usuarios
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final allUsers = await _client.from('user_profiles').select('id');
      final adminUsers = await _client
          .from('user_profiles')
          .select('id')
          .eq('is_admin', true);

      return {
        'totalUsers': (allUsers as List).length,
        'adminUsers': (adminUsers as List).length,
        'regularUsers': (allUsers as List).length - (adminUsers as List).length,
      };
    } catch (e) {
      print('❌ Error fetching user stats: $e');
      return {
        'totalUsers': 0,
        'adminUsers': 0,
        'regularUsers': 0,
      };
    }
  }

  // ========== DISCOUNT CODES MANAGEMENT ==========

  /// Obtiene todos los códigos de descuento
  Future<List<DiscountCode>> getAllDiscountCodes() async {
    try {
      final data = await _client
          .from('discount_codes')
          .select()
          .order('created_at', ascending: false);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => DiscountCode.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching discount codes: $e');
      rethrow;
    }
  }

  /// Obtiene códigos activos
  Future<List<DiscountCode>> getActiveDiscountCodes() async {
    try {
      final data = await _client
          .from('discount_codes')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (data.isEmpty) return [];

      return (data as List)
          .map((e) => DiscountCode.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching active discount codes: $e');
      rethrow;
    }
  }

  /// Crea o actualiza un código de descuento
  Future<bool> upsertDiscountCode(DiscountCode code) async {
    try {
      final data = code.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      if (code.id.isNotEmpty && !code.id.startsWith('temp_')) {
        await _client.from('discount_codes').update(data).eq('id', code.id);
      } else {
        data.remove('id');
        data['created_at'] = DateTime.now().toIso8601String();
        await _client.from('discount_codes').insert(data);
      }

      return true;
    } catch (e) {
      print('❌ Error upserting discount code: $e');
      return false;
    }
  }

  /// Elimina un código de descuento
  Future<bool> deleteDiscountCode(String id) async {
    try {
      await _client.from('discount_codes').delete().eq('id', id);
      return true;
    } catch (e) {
      print('❌ Error deleting discount code: $e');
      return false;
    }
  }

  // ========== ANALYTICS ==========

  /// Obtiene ingresos por rango de fechas
  Future<Map<String, dynamic>> getRevenueAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final start = startDate.toIso8601String();
      final end = endDate.toIso8601String();

      final orders = await _client
          .from('orders')
          .select('total_price, status, created_at')
          .gte('created_at', start)
          .lte('created_at', end)
          .or('status.eq.paid,status.eq.completed');

      double totalRevenue = 0;
      int totalOrders = 0;
      Map<String, double> dailyRevenue = {};

      for (var order in orders as List) {
        final totalPrice = order['total_price'] as num?;
        final createdAt = order['created_at'] as String?;

        if (totalPrice != null) {
          totalRevenue += totalPrice.toDouble();
          totalOrders++;

          if (createdAt != null) {
            final date = DateTime.parse(createdAt).toIso8601String().split('T')[0];
            dailyRevenue[date] = (dailyRevenue[date] ?? 0) + totalPrice.toDouble();
          }
        }
      }

      return {
        'totalRevenue': totalRevenue / 100,
        'totalOrders': totalOrders,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders / 100 : 0,
        'dailyRevenue': dailyRevenue,
      };
    } catch (e) {
      print('❌ Error fetching revenue analytics: $e');
      rethrow;
    }
  }

  /// Obtiene órdenes por estado
  Future<Map<String, int>> getOrderStats() async {
    try {
      final statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
      Map<String, int> stats = {};

      for (var status in statuses) {
        final count = await _client
            .from('orders')
            .select('id')
            .eq('status', status);
        stats[status] = (count as List).length;
      }

      return stats;
    } catch (e) {
      print('❌ Error fetching order stats: $e');
      return {};
    }
  }
}
