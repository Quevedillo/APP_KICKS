import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/discount_code.dart';

class DiscountRepository {
  final SupabaseClient _client;

  DiscountRepository(this._client);

  /// Validar un código de descuento
  Future<DiscountValidationResult> validateCode(
    String code,
    int cartTotal,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      
      // Buscar el código
      final data = await _client
          .from('discount_codes')
          .select()
          .eq('code', code.toUpperCase())
          .eq('is_active', true)
          .maybeSingle();
      
      if (data == null) {
        return DiscountValidationResult(
          valid: false,
          error: 'Código no válido o expirado',
        );
      }
      
      final discount = DiscountCode.fromJson(data);
      
      // Verificar fecha de expiración
      if (discount.expiresAt != null && discount.expiresAt!.isBefore(DateTime.now())) {
        return DiscountValidationResult(
          valid: false,
          error: 'Este código ha expirado',
        );
      }
      
      // Verificar usos máximos globales
      if (discount.maxUses != null && discount.currentUses >= discount.maxUses!) {
        return DiscountValidationResult(
          valid: false,
          error: 'Este código ha alcanzado su límite de usos',
        );
      }
      
      // Verificar usos por usuario
      if (userId != null) {
        final userUses = await _client
            .from('discount_code_uses')
            .select('id')
            .eq('code_id', discount.id)
            .eq('user_id', userId);
        
        if ((userUses as List).length >= discount.maxUsesPerUser) {
          return DiscountValidationResult(
            valid: false,
            error: 'Ya has usado este código',
          );
        }
      }
      
      // Verificar compra mínima
      if (cartTotal < discount.minPurchase) {
        final minPurchase = (discount.minPurchase / 100).toStringAsFixed(2);
        return DiscountValidationResult(
          valid: false,
          error: 'Compra mínima requerida: €$minPurchase',
        );
      }
      
      // Calcular descuento
      int discountAmount;
      if (discount.discountType == 'percentage') {
        discountAmount = (cartTotal * discount.discountValue / 100).round();
      } else {
        discountAmount = discount.discountValue;
      }
      
      // El descuento no puede ser mayor que el total
      if (discountAmount > cartTotal) {
        discountAmount = cartTotal;
      }
      
      return DiscountValidationResult(
        valid: true,
        discountCode: discount,
        discountAmount: discountAmount,
      );
    } catch (e) {
      return DiscountValidationResult(
        valid: false,
        error: 'Error validando código: $e',
      );
    }
  }

  /// Registrar el uso de un código de descuento
  Future<bool> recordCodeUse({
    required String codeId,
    required String? orderId,
    required int discountAmount,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      
      // Registrar uso
      await _client.from('discount_code_uses').insert({
        'code_id': codeId,
        'user_id': userId,
        'order_id': orderId,
        'discount_amount': discountAmount,
      });
      
      // Incrementar contador de usos
      await _client.rpc('increment_discount_code_uses', params: {
        'p_code_id': codeId,
      });
      
      return true;
    } catch (e) {
      print('Error recording discount code use: $e');
      return false;
    }
  }

  /// Obtener todos los códigos de descuento activos (admin)
  Future<List<DiscountCode>> getActiveDiscountCodes() async {
    final data = await _client
        .from('discount_codes')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    
    return (data as List).map((e) => DiscountCode.fromJson(e)).toList();
  }

  /// Crear un nuevo código de descuento (admin)
  Future<DiscountCode?> createDiscountCode({
    required String code,
    String? description,
    required String discountType,
    required int discountValue,
    int minPurchase = 0,
    int? maxUses,
    int maxUsesPerUser = 1,
    DateTime? expiresAt,
  }) async {
    try {
      final data = await _client.from('discount_codes').insert({
        'code': code.toUpperCase(),
        'description': description,
        'discount_type': discountType,
        'discount_value': discountValue,
        'min_purchase': minPurchase,
        'max_uses': maxUses,
        'max_uses_per_user': maxUsesPerUser,
        'is_active': true,
        'expires_at': expiresAt?.toIso8601String(),
        'created_by': _client.auth.currentUser?.id,
      }).select().single();
      
      return DiscountCode.fromJson(data);
    } catch (e) {
      print('Error creating discount code: $e');
      return null;
    }
  }

  /// Desactivar un código de descuento (admin)
  Future<bool> deactivateCode(String codeId) async {
    try {
      await _client
          .from('discount_codes')
          .update({'is_active': false})
          .eq('id', codeId);
      return true;
    } catch (e) {
      print('Error deactivating discount code: $e');
      return false;
    }
  }
}

class DiscountValidationResult {
  final bool valid;
  final String? error;
  final DiscountCode? discountCode;
  final int? discountAmount;

  DiscountValidationResult({
    required this.valid,
    this.error,
    this.discountCode,
    this.discountAmount,
  });
}
