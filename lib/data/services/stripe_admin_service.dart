import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de sincronización con Stripe
/// Sincroniza pagos y actualizaciones de órdenes
class StripeAdminService {
  final SupabaseClient _client;

  StripeAdminService(this._client);

  /// Obtiene órdenes pagadas desde Stripe (sincronizadas en BD)
  Future<List<Map<String, dynamic>>> getPaidOrders() async {
    try {
      final orders = await _client
          .from('orders')
          .select()
          .or('status.eq.paid,status.eq.completed')
          .order('created_at', ascending: false);

      return (orders as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error fetching paid orders from Stripe sync: $e');
      return [];
    }
  }

  /// Obtiene órdenes fallidas o pendientes de pago
  Future<List<Map<String, dynamic>>> getFailedOrders() async {
    try {
      final orders = await _client
          .from('orders')
          .select()
          .or('status.eq.failed,status.eq.pending')
          .order('created_at', ascending: false);

      return (orders as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error fetching failed orders: $e');
      return [];
    }
  }

  /// Sincroniza estado de pago desde Stripe
  /// Esta función se llamaría desde un webhook de Stripe
  Future<bool> syncStripePaymentStatus(String stripeSessionId, String status) async {
    try {
      await _client
          .from('orders')
          .update({
            'status': status == 'complete' ? 'paid' : status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('stripe_session_id', stripeSessionId);

      return true;
    } catch (e) {
      print('❌ Error syncing Stripe payment status: $e');
      return false;
    }
  }

  /// Obtiene resumen de pagos por período
  Future<Map<String, dynamic>> getPaymentSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final start = startDate.toIso8601String();
      final end = endDate.toIso8601String();

      final paidOrders = await _client
          .from('orders')
          .select('id, total_price, status, created_at')
          .gte('created_at', start)
          .lte('created_at', end)
          .eq('status', 'paid');

      double totalPaid = 0;
      int orderCount = 0;

      for (var order in paidOrders as List) {
        totalPaid += (order['total_price'] as num? ?? 0).toDouble();
        orderCount++;
      }

      // Obtener órdenes rechazadas
      final failedOrders = await _client
          .from('orders')
          .select('id, total_price')
          .gte('created_at', start)
          .lte('created_at', end)
          .eq('status', 'failed');

      double totalFailed = 0;
      for (var order in failedOrders as List) {
        totalFailed += (order['total_price'] as num? ?? 0).toDouble();
      }

      return {
        'totalPaid': totalPaid / 100,
        'totalFailed': totalFailed / 100,
        'paidOrderCount': orderCount,
        'failedOrderCount': (failedOrders as List).length,
        'averageOrderValue': orderCount > 0 ? totalPaid / orderCount / 100 : 0,
      };
    } catch (e) {
      print('❌ Error getting payment summary: $e');
      return {
        'totalPaid': 0.0,
        'totalFailed': 0.0,
        'paidOrderCount': 0,
        'failedOrderCount': 0,
        'averageOrderValue': 0.0,
      };
    }
  }

  /// Obtiene órdenes con disputas de Stripe
  Future<List<Map<String, dynamic>>> getDisputedOrders() async {
    try {
      final orders = await _client
          .from('orders')
          .select()
          .eq('has_dispute', true)
          .order('updated_at', ascending: false);

      return (orders as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error fetching disputed orders: $e');
      return [];
    }
  }

  /// Registra un evento de webhook de Stripe
  Future<bool> logStripeWebhook({
    required String eventType,
    required String stripeSessionId,
    required Map<String, dynamic> eventData,
  }) async {
    try {
      await _client.from('stripe_webhooks_log').insert({
        'event_type': eventType,
        'stripe_session_id': stripeSessionId,
        'event_data': eventData,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('❌ Error logging Stripe webhook: $e');
      return false;
    }
  }

  /// Obtiene datos de refunds procesados
  Future<Map<String, dynamic>> getRefundStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final start = startDate.toIso8601String();
      final end = endDate.toIso8601String();

      final refunds = await _client
          .from('orders')
          .select('id, total_price')
          .gte('created_at', start)
          .lte('created_at', end)
          .eq('status', 'cancelled');

      double totalRefunded = 0;
      for (var order in refunds as List) {
        totalRefunded += (order['total_price'] as num? ?? 0).toDouble();
      }

      return {
        'totalRefunded': totalRefunded / 100,
        'refundCount': (refunds as List).length,
      };
    } catch (e) {
      print('❌ Error getting refund stats: $e');
      return {
        'totalRefunded': 0.0,
        'refundCount': 0,
      };
    }
  }
}
