import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de Email (Refactorizado para usar Supabase Edge Functions)
/// Las credenciales SMTP y el envío real se manejan de forma segura en el servidor.
class EmailService {
  final SupabaseClient _client;

  EmailService(this._client);

  Future<bool> _sendEmail({
    required String type,
    required String to,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'send-email',
        body: {
          'type': type,
          'to': to,
          'data': data,
        },
      );
      
      if (response.status == 200 && response.data is Map) {
        return response.data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error invocando send-email Edge Function: $e');
      return false;
    }
  }

  /// Enviar email de bienvenida a nuevo usuario
  Future<bool> sendWelcomeEmail(String userEmail, String userName) async {
    return _sendEmail(
      type: 'welcome',
      to: userEmail,
      data: {'userName': userName},
    );
  }

  /// Enviar confirmación de pedido al cliente
  Future<bool> sendOrderConfirmationEmail(
    String userEmail,
    String orderId,
    double totalAmount,
    List<Map<String, dynamic>> items,
  ) async {
    return _sendEmail(
      type: 'order-confirmation',
      to: userEmail,
      data: {
        'orderId': orderId,
        'totalAmount': totalAmount,
        'items': items,
      },
    );
  }

  /// Notificar al admin sobre nuevo pedido
  Future<bool> sendAdminOrderNotification(
    String orderId,
    String customerEmail,
    double totalAmount,
    List<Map<String, dynamic>> items,
  ) async {
    return _sendEmail(
      type: 'admin-order-notification',
      to: '', // El Edge Function usará la variable de entorno ADMIN_EMAIL
      data: {
        'orderId': orderId,
        'customerEmail': customerEmail,
        'totalAmount': totalAmount,
        'items': items,
      },
    );
  }

  /// Actualización de estado del pedido
  Future<bool> sendOrderStatusUpdate(
    String userEmail,
    String orderId,
    String newStatus,
  ) async {
    return _sendEmail(
      type: 'order-status',
      to: userEmail,
      data: {
        'orderId': orderId,
        'status': newStatus,
      },
    );
  }

  /// Enviar enlace de reseteo de contraseña (gestionado por Supabase Auth, pero si hay correos personalizados)
  Future<bool> sendPasswordReset(String userEmail, String resetLink) async {
    return _sendEmail(
      type: 'password-reset',
      to: userEmail,
      data: {'resetLink': resetLink},
    );
  }

  /// Formulario de contacto
  Future<bool> sendContactForm(
    String userEmail,
    String name,
    String issueType,
    String message,
  ) async {
    return _sendEmail(
      type: 'contact-form',
      to: '', // Va al admin
      data: {
        'userEmail': userEmail,
        'name': name,
        'issueType': issueType,
        'message': message,
      },
    );
  }

  /// Reportar un problema con un pedido
  Future<bool> sendProblemReport(
    String userEmail,
    String orderId,
    String issueType,
    String description,
    List<String> images,
  ) async {
    return _sendEmail(
      type: 'problem-report',
      to: '', // Va al admin
      data: {
        'userEmail': userEmail,
        'orderId': orderId,
        'issueType': issueType,
        'description': description,
        'images': images,
      },
    );
  }

  /// Enviar factura de abono (reembolso)
  Future<bool> sendCancellationInvoice(
    String userEmail,
    String orderId,
    double amount,
    List<Map<String, dynamic>> items,
  ) async {
    return _sendEmail(
      type: 'cancellation-invoice',
      to: userEmail,
      data: {
        'orderId': orderId,
        'amount': amount,
        'items': items,
      },
    );
  }

  /// Enviar newsletter a múltiples correos
  Future<Map<String, int>> sendNewsletter(
    List<String> emails,
    String subject,
    String htmlContent,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'send-email',
        body: {
          'type': 'newsletter',
          'to': '', // Múltiples destinatarios
          'data': {
            'emails': emails,
            'subject': subject,
            'htmlContent': htmlContent,
          },
        },
      );
      
      if (response.status == 200 && response.data is Map) {
        return {
          'successful': response.data['successful'] ?? 0,
          'failed': response.data['failed'] ?? 0,
        };
      }
      return {'successful': 0, 'failed': emails.length};
    } catch (e) {
      debugPrint('❌ Error sending newsletter: $e');
      return {'successful': 0, 'failed': emails.length};
    }
  }
}
