import '../services/email_service.dart';

class EmailRepository {
  final EmailService emailService = EmailService();

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
    return emailService.sendOrderStatusUpdate(email, orderId, status, trackingUrl);
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
    return emailService.sendPasswordResetEmail(email, name, resetLink);
  }

  /// Enviar email de contacto
  Future<bool> sendContactForm(
    String senderName,
    String senderEmail,
    String subject,
    String message,
  ) {
    return emailService.sendContactFormEmail(
      senderName,
      senderEmail,
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
    return emailService.sendProblemReportEmail(
      userEmail,
      userName,
      problem,
      attachmentUrl,
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
    return emailService.sendCancellationInvoiceEmail(
      email,
      orderId,
      refundAmount,
      customerName,
      items,
      reason: reason,
    );
  }
}
