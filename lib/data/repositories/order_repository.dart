import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/stripe_service.dart';

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

    // Convertir items del carrito a formato JSON
    // Incluimos discount_amount y shipping_address dentro del JSON de items
    // como metadata, para evitar problemas si las columnas no existen en la tabla
    final itemsJson = cartItems.map((item) => {
      'product_id': item.productId,
      'name': item.product.name,
      'brand': item.product.brand,
      'image': item.product.images.isNotEmpty ? item.product.images.first : '',
      'price': item.product.price,
      'size': item.size,
      'quantity': item.quantity,
    }).toList();

    // Intentamos insertar con todas las columnas. Si falla por PGRST204,
    // retentamos con solo las columnas base garantizadas.
    final fullOrderData = {
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

    // Datos mínimos garantizados (sin columnas opcionales que puedan faltar)
    final minimalOrderData = {
      'user_id': userId,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'total_amount': totalPrice,
      'status': 'paid',
      'items': itemsJson,
      'shipping_email': shippingEmail ?? _client.auth.currentUser?.email,
      'created_at': DateTime.now().toIso8601String(),
    };

    Map<String, dynamic> response;
    try {
      response = await _client
          .from('orders')
          .insert(fullOrderData)
          .select()
          .single();
    } catch (fullInsertErr) {
      final errStr = fullInsertErr.toString();
      // PGRST204 = columna no encontrada en schema cache
      if (errStr.contains('PGRST204') || errStr.contains('schema cache')) {
        print('⚠️ INSERT completo falló (columnas faltantes), usando INSERT mínimo: $fullInsertErr');
        // Intentar con subconjunto sin las columnas que causan error
        try {
          response = await _client
              .from('orders')
              .insert(minimalOrderData)
              .select()
              .single();
        } catch (minimalErr) {
          // Si también falla, intentar SIN shipping_address (puede ser la culpable)
          final withoutAddressData = Map<String, dynamic>.from(fullOrderData)
            ..remove('shipping_address')
            ..remove('shipping_phone')
            ..remove('subtotal_amount')
            ..remove('discount_amount')
            ..remove('discount_code_id');
          response = await _client
              .from('orders')
              .insert(withoutAddressData)
              .select()
              .single();
        }
      } else {
        rethrow;
      }
    }

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

  Future<List<Order>> getAllOrders() async {
    try {
      final data = await _client
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) {
            try {
              return Order.fromJson(e as Map<String, dynamic>);
            } catch (itemError) {
              print('Error parsing order $e: $itemError');
              return null;
            }
          })
          .whereType<Order>()
          .toList();
    } catch (e) {
      print('Error fetching all orders: $e');
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

  /// Actualiza el estado del pedido. Solo admin.
  Future<bool> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? reason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (reason != null) {
        updateData['cancelled_reason'] = reason;
      }
      await _client.from('orders').update(updateData).eq('id', orderId);
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Procesar reembolso Stripe + marcar como refunded
  Future<bool> refundOrder(String orderId, {String? reason}) async {
    try {
      final orderData = await _client
          .from('orders')
          .select('stripe_payment_intent_id, status, total_amount')
          .eq('id', orderId)
          .maybeSingle();

      if (orderData == null) return false;

      final paymentIntentId = orderData['stripe_payment_intent_id'] as String?;
      if (paymentIntentId != null && paymentIntentId.isNotEmpty) {
        await StripeService.refundPayment(paymentIntentId: paymentIntentId);
      }

      await _client.from('orders').update({
        'status': 'refunded',
        'cancelled_reason': reason ?? 'Reembolso procesado por administrador',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      return true;
    } catch (e) {
      print('Error refunding order: $e');
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final cancelReason = reason?.isNotEmpty == true ? reason! : 'Cancelado por el cliente';

      final orderData = await _client
          .from('orders')
          .select('stripe_payment_intent_id, status')
          .eq('id', orderId)
          .maybeSingle();

      // Intentar función atómica primero
      try {
        final result = await _client.rpc('cancel_order_atomic', params: {
          'p_order_id': orderId,
          'p_user_id': userId,
          'p_reason': cancelReason,
        });

        if (result != null && result['success'] == true) {
          if (orderData != null && orderData['stripe_payment_intent_id'] != null) {
            try {
              await StripeService.refundPayment(
                paymentIntentId: orderData['stripe_payment_intent_id'],
              );
              await _client.from('orders').update({
                'status': 'refunded',
                'updated_at': DateTime.now().toIso8601String(),
              }).eq('id', orderId);
            } catch (refundErr) {
              print('⚠️ Error procesando reembolso Stripe: $refundErr');
            }
          }
          return true;
        }
      } catch (_) {
        // Fallback
      }

      // Fallback simple
      await _client.from('orders').update({
        'status': 'cancelled',
        'cancelled_reason': cancelReason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      if (orderData != null && orderData['stripe_payment_intent_id'] != null) {
        try {
          await StripeService.refundPayment(
            paymentIntentId: orderData['stripe_payment_intent_id'],
          );
          await _client.from('orders').update({
            'status': 'refunded',
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', orderId);
        } catch (refundErr) {
          print('⚠️ Error procesando reembolso Stripe: $refundErr');
        }
      }
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  Future<bool> requestReturn(String orderId, String reason) async {
    try {
      await _client.from('orders').update({
        'return_status': 'requested',
        'cancelled_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
      return true;
    } catch (e) {
      // Si return_status no existe, usar campo status
      try {
        await _client.from('orders').update({
          'status': 'return_requested',
          'cancelled_reason': reason,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', orderId);
        return true;
      } catch (e2) {
        print('Error requesting return: $e2');
        return false;
      }
    }
  }
}
