import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user_profile.dart';
import '../models/category.dart';
import '../models/discount_code.dart';

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  Future<Map<String, dynamic>> getDashboardStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    try {
      // 1. Pedidos Hoy
      final ordersTodayResponse = await _client
          .from('orders')
          .select('id')
          .gte('created_at', today);
      
      // 2. Ingresos Totales de hoy
      final revenueTodayData = await _client
          .from('orders')
          .select('total_price')
          .gte('created_at', today)
          .neq('status', 'cancelled');
      
      double revenueToday = 0;
      for (var order in revenueTodayData) {
        revenueToday += (order['total_price'] as num).toDouble();
      }

      // 3. Usuarios nuevos hoy
      final newUsersTodayResponse = await _client
          .from('user_profiles')
          .select('id')
          .gte('created_at', today);

      // 4. Total productos
      final totalProductsResponse = await _client
          .from('products')
          .select('id');

      return {
        'ordersToday': ordersTodayResponse.length,
        'revenueToday': revenueToday,
        'newUsersToday': newUsersTodayResponse.length,
        'totalProducts': totalProductsResponse.length,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'ordersToday': 0,
        'revenueToday': 0.0,
        'newUsersToday': 0,
        'totalProducts': 0,
      };
    }
  }

  Future<List<Order>> getAllOrders() async {
    try {
      final data = await _client
          .from('orders')
          .select()
          .order('created_at', ascending: false);
      
      return (data as List).map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching all orders: $e');
      return [];
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final data = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      return (data as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching all products: $e');
      return [];
    }
  }

  Future<List<UserProfile>> getAllUsers() async {
    try {
      final data = await _client
          .from('user_profiles')
          .select()
          .order('created_at', ascending: false);
      
      return (data as List).map((e) => UserProfile.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _client
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Categories
  Future<List<Category>> getAllCategories() async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .order('display_order', ascending: true);
      return (data as List).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<bool> upsertCategory(Category category) async {
    try {
      final data = {
        'name': category.name,
        'slug': category.slug,
        'description': category.description,
        'icon': category.icon,
        'display_order': category.displayOrder,
      };
      if (category.id.isNotEmpty && !category.id.startsWith('temp_')) {
        await _client.from('categories').update(data).eq('id', category.id);
      } else {
        await _client.from('categories').insert(data);
      }
      return true;
    } catch (e) {
      print('Error upserting category: $e');
      return false;
    }
  }

  // Discount Codes
  Future<List<DiscountCode>> getAllDiscountCodes() async {
    try {
      final data = await _client
          .from('discount_codes')
          .select()
          .order('created_at', ascending: false);
      return (data as List).map((e) => DiscountCode.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching discount codes: $e');
      return [];
    }
  }

  Future<bool> upsertDiscountCode(DiscountCode code) async {
    try {
      final data = code.toJson();
      if (code.id.isNotEmpty && !code.id.startsWith('temp_')) {
        await _client.from('discount_codes').update(data).eq('id', code.id);
      } else {
        await _client.from('discount_codes').insert(data);
      }
      return true;
    } catch (e) {
      print('Error upserting discount code: $e');
      return false;
    }
  }

  // Product Management
  Future<bool> upsertProduct(Product product) async {
    try {
      final data = product.toJson();
      // Remove id from data if it's a new product
      if (product.id.isEmpty || product.id.startsWith('temp_')) {
        data.remove('id');
        await _client.from('products').insert(data);
      } else {
        await _client.from('products').update(data).eq('id', product.id);
      }
      return true;
    } catch (e) {
      print('Error upserting product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _client.from('products').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }
}
