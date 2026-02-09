import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class StripeService {
  static String get publicKey => dotenv.env['PUBLIC_STRIPE_PUBLIC_KEY'] ?? '';
  static String get _stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  static Future<void> init() async {
    final key = publicKey;
    if (key.isEmpty) {
      debugPrint('ERROR: PUBLIC_STRIPE_PUBLIC_KEY no está en .env');
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

  /// Crea un PaymentIntent directamente usando la API de Stripe
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    required String orderId,
    Map<String, String>? metadata,
  }) async {
    if (amount <= 0) throw Exception('Monto debe ser mayor a 0');
    if (orderId.isEmpty) throw Exception('orderId vacío');
    if (_stripeSecretKey.isEmpty) throw Exception('STRIPE_SECRET_KEY no configurada');

    final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
    
    try {
      // Preparar body en formato form-urlencoded
      final bodyParams = {
        'amount': amount.toString(),
        'currency': currency,
        'automatic_payment_methods[enabled]': 'true',
        'metadata[orderId]': orderId,
      };
      
      // Añadir metadatos adicionales
      if (metadata != null) {
        metadata.forEach((key, value) {
          bodyParams['metadata[$key]'] = value;
        });
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: bodyParams,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (data.containsKey('client_secret')) {
          return {
            'clientSecret': data['client_secret'],
            'paymentIntentId': data['id'],
          };
        }
        throw Exception('client_secret no recibido');
      }
      
      // Parsear error de Stripe
      try {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']?['message'] ?? 'Error desconocido';
        throw Exception('Stripe error: $errorMsg');
      } catch (_) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Timeout: Stripe no responde');
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: $e');
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

  static Future<bool> refundPayment({required String paymentIntentId}) async {
    if (paymentIntentId.isEmpty) throw Exception('paymentIntentId vacío');
    if (_stripeSecretKey.isEmpty) throw Exception('STRIPE_SECRET_KEY no configurada');

    final url = Uri.parse('https://api.stripe.com/v1/refunds');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_intent': paymentIntentId,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      }

      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } on TimeoutException {
      throw Exception('Timeout en reembolso');
    } on http.ClientException catch (e) {
      throw Exception('Error conexión: $e');
    }
  }
}