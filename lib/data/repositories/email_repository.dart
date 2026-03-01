import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/email_service.dart';

class EmailRepository {
  final EmailService emailService;

  EmailRepository(SupabaseClient client) : emailService = EmailService(client);

  /// Enviar email de bienvenida
  Future<bool> sendWelcome(String email, String name) {
    return emailService.sendWelcomeEmail(email, name);
  }

  /// Enviar confirmación de pedido
  Future<bool> sendOrderConfirmation(
    String email,
    String orderId,
    double total,
    List<Map<String, dynamic>> items,
  ) {
    return emailService.sendOrderConfirmationEmail(email, orderId, total, items);
  }

  /// Notificar admin sobre nuevo pedido
  Future<bool> notifyAdminNewOrder(
    String orderId,
    String customerEmail,
    double totalAmount,
    List<Map<String, dynamic>> items,
  ) {
    return emailService.sendAdminOrderNotification(
      orderId,
      customerEmail,
      totalAmount,
      items,
    );
  }

  /// Actualizar estado de pedido
  Future<bool> sendOrderStatusUpdate(
    String email,
    String orderId,
    String status,
    String? trackingUrl,
  ) {
    // The previous API had trackingUrl, but the new one doesn't take it currently, 
    // let's pass trackingUrl as part of the message or skip it if unsupported.
    // Right now sendOrderStatusUpdate only takes email, orderId, status.
    return emailService.sendOrderStatusUpdate(email, orderId, status);
  }

  /// Enviar newsletter
  Future<Map<String, int>> sendNewsletter(
    List<String> emails,
    String subject,
    String content,
  ) {
    return emailService.sendNewsletter(emails, subject, content);
  }

  /// Enviar email de recuperación de contraseña
  Future<bool> sendPasswordReset(
    String email,
    String name,
    String resetLink,
  ) {
    return emailService.sendPasswordReset(email, resetLink);
  }

  /// Enviar email de contacto
  Future<bool> sendContactForm(
    String senderName,
    String senderEmail,
    String subject,
    String message,
  ) {
    return emailService.sendContactForm(
      senderEmail,
      senderName,
      subject,
      message,
    );
  }

  /// Reportar problema
  Future<bool> sendProblemReport(
    String userEmail,
    String userName,
    String problem,
    String? attachmentUrl,
  ) {
    // Current Edge Function expected signatures
    final List<String> images = attachmentUrl != null ? [attachmentUrl] : [];
    return emailService.sendProblemReport(
      userEmail,
      'N/A', // orderId missing in previous
      problem,
      problem, // description
      images,
    );
  }

  /// Enviar factura de cancelación/reembolso
  Future<bool> sendCancellationInvoice(
    String email,
    String orderId,
    double refundAmount,
    String customerName,
    List<Map<String, dynamic>> items, {
    String? reason,
  }) {
    return emailService.sendCancellationInvoice(
      email,
      orderId,
      refundAmount,
      items,
    );
  }
}
