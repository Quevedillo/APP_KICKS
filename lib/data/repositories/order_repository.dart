import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderRepository {
  final SupabaseClient _client;

  OrderRepository(this._client);

  /// Crear un nuevo pedido después del pago exitoso
  Future<Order?> createOrder({
    required String stripePaymentIntentId,
    required List<CartItem> cartItems,
    required int totalPrice,
    int? discountAmount,
    String? discountCodeId,
    String? shippingName,
    String? shippingEmail,
    String? shippingPhone,
    Map<String, dynamic>? shippingAddress,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    try {
      // Convertir items del carrito a formato JSON
      final itemsJson = cartItems.map((item) => {
        'product_id': item.productId,
        'name': item.product.name,
        'brand': item.product.brand,
        'image': item.product.images.isNotEmpty ? item.product.images.first : '',
        'price': item.product.price,
        'size': item.size,
        'quantity': item.quantity,
      }).toList();

      final orderData = {
        'user_id': userId,
        'stripe_payment_intent_id': stripePaymentIntentId,
        'total_amount': totalPrice,
        'subtotal_amount': totalPrice + (discountAmount ?? 0),
        'discount_amount': discountAmount ?? 0,
        'discount_code_id': discountCodeId,
        'status': 'paid',
        'items': itemsJson,
        'shipping_name': shippingName ?? _client.auth.currentUser?.email?.split('@').first,
        'shipping_email': shippingEmail ?? _client.auth.currentUser?.email,
        'shipping_phone': shippingPhone,
        'shipping_address': shippingAddress,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      print('✅ Pedido creado exitosamente: ${response['id']}');

      // Reducir stock de las tallas compradas
      for (final item in cartItems) {
        try {
          await _client.rpc('reduce_size_stock', params: {
            'p_product_id': item.productId,
            'p_size': item.size,
            'p_quantity': item.quantity,
          });
        } catch (stockErr) {
          print('⚠️ Error reduciendo stock para ${item.productId} talla ${item.size}: $stockErr');
        }
      }

      return Order.fromJson(response);
    } catch (e) {
      print('❌ Error creando pedido: $e');
      rethrow;
    }
  }

  Future<List<Order>> getUserOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final data = await _client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) {
            try {
              return Order.fromJson(e as Map<String, dynamic>);
            } catch (itemError) {
              print('Error parsing order item $e: $itemError');
              return null;
            }
          })
          .whereType<Order>()
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    final data = await _client
        .from('orders')
        .select()
        .eq('id', orderId)
        .maybeSingle();

    if (data == null) return null;
    return Order.fromJson(data);
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final cancelReason = reason?.isNotEmpty == true ? reason! : 'Cancelado por el cliente';

      // Usar la función atómica de Supabase que restaura el stock
      final result = await _client.rpc('cancel_order_atomic', params: {
        'p_order_id': orderId,
        'p_user_id': userId,
        'p_reason': cancelReason,
      });

      if (result != null && result['success'] == true) {
        return true;
      } else {
        print('Error cancelling order: ${result?['error']}');
        return false;
      }
    } catch (e) {
      print('Error cancelling order: $e');
      // Fallback al método simple si la función no existe
      try {
        final cancelReason = reason?.isNotEmpty == true ? reason! : 'Cancelado por el cliente';
        await _client
            .from('orders')
            .update({
              'status': 'cancelled',
              'cancelled_at': DateTime.now().toIso8601String(),
              'cancelled_reason': cancelReason,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', orderId);
        return true;
      } catch (e2) {
        print('Fallback cancel also failed: $e2');
        return false;
      }
    }
  }

  Future<bool> requestReturn(String orderId, String reason) async {
    try {
      await _client
          .from('orders')
          .update({
            'return_status': 'requested',
            'return_requested_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
      return true;
    } catch (e) {
      print('Error requesting return: $e');
      return false;
    }
  }
}
