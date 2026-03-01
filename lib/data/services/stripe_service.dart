import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

/// Stripe service that delegates server-side operations to Supabase Edge Functions.
/// No secret keys are stored or used in the client.
class StripeService {
  static String get publicKey => const String.fromEnvironment('PUBLIC_STRIPE_PUBLIC_KEY');

  static Future<void> init() async {
    final key = publicKey;
    if (key.isEmpty) {
      debugPrint('ERROR: PUBLIC_STRIPE_PUBLIC_KEY no configurada. Asegúrate de pasarla vía --dart-define o dart-define-from-file');
      return;
    }

    try {
      Stripe.publishableKey = key;
      Stripe.instance.applySettings();
      debugPrint('✅ Stripe inicializado');
    } catch (e) {
      debugPrint('❌ Error inicializando Stripe: $e');
      rethrow;
    }
  }

  /// Crea un PaymentIntent vía Edge Function (server-side)
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    required String orderId,
    Map<String, String>? metadata,
  }) async {
    if (amount <= 0) throw Exception('Monto debe ser mayor a 0');
    if (orderId.isEmpty) throw Exception('orderId vacío');

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'stripe-proxy',
        body: {
          'action': 'create-payment-intent',
          'amount': amount,
          'currency': currency,
          'orderId': orderId,
          'metadata': metadata,
        },
      );

      if (response.status != 200) {
        final error = response.data is Map ? response.data['error'] : 'Error desconocido';
        throw Exception('Stripe error: $error');
      }

      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('clientSecret')) {
        return {
          'clientSecret': data['clientSecret'],
          'paymentIntentId': data['paymentIntentId'],
        };
      }
      throw Exception('clientSecret no recibido');
    } catch (e) {
      debugPrint('Error createPaymentIntent: $e');
      rethrow;
    }
  }

  static Future<void> initPaymentSheet({
    required String clientSecret,
    required String email,
    String merchantName = 'KicksPremium',
  }) async {
    if (clientSecret.isEmpty) throw Exception('clientSecret vacío');

    try {
      final params = SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantName,
        billingDetails: BillingDetails(email: email),
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            background: Color(0xFF0A0A0A),
            primary: Color(0xFFFF3131),
            componentBackground: Color(0xFF1C1C1C),
            componentText: Color(0xFFFFFFFF),
            placeholderText: Color(0xFF9E9E9E),
            primaryText: Color(0xFFFFFFFF),
            secondaryText: Color(0xFF9E9E9E),
            componentBorder: Color(0xFF2C2C2C),
            icon: Color(0xFFFFFFFF),
          ),
          shapes: PaymentSheetShape(
            borderRadius: 12,
            borderWidth: 0.5,
          ),
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            colors: PaymentSheetPrimaryButtonTheme(
              dark: PaymentSheetPrimaryButtonThemeColors(
                background: Color(0xFFFF3131),
                text: Color(0xFFFFFFFF),
                border: Color(0xFFFF3131),
              ),
            ),
            shapes: const PaymentSheetPrimaryButtonShape(),
          ),
        ),
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: params,
      );
    } catch (e) {
      debugPrint('Error initPaymentSheet: $e');
      throw Exception('Error inicializando pago: $e');
    }
  }

  static Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      final msg = e.toString().toLowerCase();

      if (msg.contains('cancel')) {
        throw Exception('Pago cancelado');
      }

      debugPrint('Error presentPaymentSheet: $e');
      throw Exception('Error procesando pago: $e');
    }
  }

  /// Reembolso vía Edge Function (server-side, solo admin)
  static Future<bool> refundPayment({required String paymentIntentId}) async {
    if (paymentIntentId.isEmpty) throw Exception('paymentIntentId vacío');

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'stripe-proxy',
        body: {
          'action': 'refund',
          'paymentIntentId': paymentIntentId,
        },
      );

      if (response.status != 200) {
        final error = response.data is Map ? response.data['error'] : 'Refund failed';
        throw Exception('Error reembolso: $error');
      }

      return true;
    } catch (e) {
      debugPrint('Error refundPayment: $e');
      rethrow;
    }
  }
}