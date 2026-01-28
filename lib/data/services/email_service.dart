import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  final String smtpHost = dotenv.env['SMTP_HOST'] ?? '';
  final String smtpPort = dotenv.env['SMTP_PORT'] ?? '';
  final String smtpUser = dotenv.env['SMTP_USER'] ?? '';
  final String smtpPass = dotenv.env['SMTP_PASS'] ?? '';
  final String fromEmail = dotenv.env['FROM_EMAIL'] ?? '';
  final String adminEmail = dotenv.env['ADMIN_EMAIL'] ?? '';

  /// Enviar email de bienvenida a nuevo usuario
  Future<bool> sendWelcomeEmail(String userEmail, String userName) async {
    return _sendEmail(
      to: userEmail,
      subject: '¡Bienvenido a KicksPremium! 👟',
      htmlBody: _getWelcomeEmailTemplate(userName),
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
      to: userEmail,
      subject: 'Confirmación de tu pedido #$orderId - KicksPremium 📦',
      htmlBody: _getOrderConfirmationTemplate(orderId, totalAmount, items),
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
      to: adminEmail,
      subject: '[NUEVO PEDIDO] #$orderId - KicksPremium 🔔',
      htmlBody: _getAdminOrderNotificationTemplate(orderId, customerEmail, totalAmount, items),
    );
  }

  /// Enviar actualización de estado de pedido
  Future<bool> sendOrderStatusUpdate(
    String userEmail,
    String orderId,
    String status,
    String? trackingUrl,
  ) async {
    return _sendEmail(
      to: userEmail,
      subject: 'Tu pedido #$orderId ha sido $status - KicksPremium 📮',
      htmlBody: _getOrderStatusTemplate(orderId, status, trackingUrl),
    );
  }

  /// Enviar newsletter a múltiples usuarios
  Future<Map<String, int>> sendNewsletter(
    List<String> emails,
    String subject,
    String htmlContent,
  ) async {
    int successful = 0;
    int failed = 0;

    for (String email in emails) {
      final result = await _sendEmail(
        to: email,
        subject: subject,
        htmlBody: htmlContent,
      );
      if (result) {
        successful++;
      } else {
        failed++;
      }
    }

    return {'successful': successful, 'failed': failed};
  }

  /// Enviar email de recuperación de contraseña
  Future<bool> sendPasswordResetEmail(
    String userEmail,
    String userName,
    String resetLink,
  ) async {
    return _sendEmail(
      to: userEmail,
      subject: 'Recupera tu contraseña de KicksPremium 🔐',
      htmlBody: _getPasswordResetTemplate(userName, resetLink),
    );
  }

  /// Enviar email de contacto/consulta desde formulario
  Future<bool> sendContactFormEmail(
    String senderName,
    String senderEmail,
    String subject,
    String message,
  ) async {
    return _sendEmail(
      to: adminEmail,
      cc: senderEmail,
      subject: '[CONTACTO] $subject',
      htmlBody: _getContactFormTemplate(senderName, senderEmail, subject, message),
    );
  }

  /// Enviar reporte de problemas
  Future<bool> sendProblemReportEmail(
    String userEmail,
    String userName,
    String problemDescription,
    String? attachmentUrl,
  ) async {
    return _sendEmail(
      to: adminEmail,
      subject: '[REPORTE] Problema reportado por $userName',
      htmlBody: _getProblemReportTemplate(userName, userEmail, problemDescription, attachmentUrl),
    );
  }

  /// Función genérica para enviar emails
  Future<bool> _sendEmail({
    required String to,
    String? cc,
    required String subject,
    required String htmlBody,
  }) async {
    try {
      // TODO: Implementar con servicio SMTP real (nodemailer, Resend, SendGrid, etc)
      // Por ahora, retorna true para demostración
      print('📧 Email enviado a: $to');
      print('Asunto: $subject');
      return true;
    } catch (e) {
      print('❌ Error al enviar email: $e');
      return false;
    }
  }

  // ========== Plantillas de Email ==========

  String _getWelcomeEmailTemplate(String userName) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #1a1a1a; color: #fff; padding: 20px; text-align: center; border-radius: 5px; }
          .content { padding: 20px; background: #f9f9f9; border-radius: 5px; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
          .button { display: inline-block; padding: 10px 20px; background: #FFD700; color: #000; text-decoration: none; border-radius: 5px; margin: 10px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>👟 ¡Bienvenido a KicksPremium!</h1>
          </div>
          <div class="content">
            <p>Hola <strong>$userName</strong>,</p>
            <p>¡Gracias por registrarte en KicksPremium! Estamos emocionados de tenerte como parte de nuestra comunidad de amantes de las zapatillas.</p>
            <p>En KicksPremium encontrarás:</p>
            <ul>
              <li>✅ Zapatillas auténticas de las mejores marcas</li>
              <li>✅ Precios competitivos</li>
              <li>✅ Envíos rápidos y seguros</li>
              <li>✅ Atención al cliente 24/7</li>
            </ul>
            <p>Haz clic en el botón de abajo para empezar a explorar nuestro catálogo:</p>
            <a href="https://kickspremium.com" class="button">Explorar Zapatillas</a>
            <p>¿Preguntas? No dudes en contactarnos.</p>
          </div>
          <div class="footer">
            <p>© 2026 KicksPremium. Todos los derechos reservados.</p>
            <p>Unsubscribe | <a href="#">Preferencias</a></p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _getOrderConfirmationTemplate(
    String orderId,
    double totalAmount,
    List<Map<String, dynamic>> items,
  ) {
    String itemsHtml = items.map((item) {
      return '''
        <tr>
          <td>${item['name']}</td>
          <td>${item['size']}</td>
          <td>${item['quantity']}</td>
          <td>\$${item['price']}</td>
        </tr>
      ''';
    }).join();

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #1a1a1a; color: #fff; padding: 20px; text-align: center; }
          table { width: 100%; border-collapse: collapse; margin: 20px 0; }
          th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
          th { background: #f0f0f0; }
          .total { font-size: 18px; font-weight: bold; color: #FFD700; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📦 Pedido Confirmado</h1>
            <p>Pedido #$orderId</p>
          </div>
          <div style="padding: 20px; background: #f9f9f9;">
            <p>¡Tu pedido ha sido confirmado con éxito!</p>
            <table>
              <thead>
                <tr>
                  <th>Producto</th>
                  <th>Talla</th>
                  <th>Cantidad</th>
                  <th>Precio</th>
                </tr>
              </thead>
              <tbody>
                $itemsHtml
              </tbody>
            </table>
            <p style="text-align: right;" class="total">Total: \$$totalAmount</p>
            <p>Recibirás actualizaciones sobre tu envío en los próximos días.</p>
          </div>
          <div class="footer">
            <p>© 2026 KicksPremium</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _getAdminOrderNotificationTemplate(
    String orderId,
    String customerEmail,
    double totalAmount,
    List<Map<String, dynamic>> items,
  ) {
    String itemsHtml = items.map((item) {
      return '''
        <tr>
          <td>${item['name']}</td>
          <td>${item['size']}</td>
          <td>${item['quantity']}</td>
          <td>\$${item['price']}</td>
        </tr>
      ''';
    }).join();

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #ff6b6b; color: #fff; padding: 20px; text-align: center; }
          table { width: 100%; border-collapse: collapse; margin: 20px 0; }
          th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
          th { background: #f0f0f0; }
          .alert { background: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 10px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🔔 NUEVO PEDIDO RECIBIDO</h1>
          </div>
          <div style="padding: 20px; background: #f9f9f9;">
            <div class="alert">
              <strong>¡Tienes un nuevo pedido!</strong>
            </div>
            <p><strong>Número de Pedido:</strong> $orderId</p>
            <p><strong>Email del Cliente:</strong> $customerEmail</p>
            <p><strong>Monto Total:</strong> \$$totalAmount</p>
            <h3>Artículos:</h3>
            <table>
              <thead>
                <tr>
                  <th>Producto</th>
                  <th>Talla</th>
                  <th>Cantidad</th>
                  <th>Precio</th>
                </tr>
              </thead>
              <tbody>
                $itemsHtml
              </tbody>
            </table>
            <p>Por favor, procesa este pedido lo antes posible.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _getOrderStatusTemplate(String orderId, String status, String? trackingUrl) {
    String trackingSection = trackingUrl != null
        ? '<p>Seguimiento: <a href="$trackingUrl">$trackingUrl</a></p>'
        : '';

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #1a1a1a; color: #fff; padding: 20px; text-align: center; }
          .status { font-size: 18px; font-weight: bold; color: #28a745; padding: 15px; background: #e8f5e9; border-radius: 5px; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📮 Actualización de tu Pedido</h1>
          </div>
          <div style="padding: 20px; background: #f9f9f9;">
            <p>Hola,</p>
            <p>Tu pedido <strong>#$orderId</strong> ha sido <strong>$status</strong>.</p>
            <div class="status">$status</div>
            $trackingSection
            <p>Gracias por tu compra en KicksPremium.</p>
          </div>
          <div class="footer">
            <p>© 2026 KicksPremium</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _getPasswordResetTemplate(String userName, String resetLink) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #1a1a1a; color: #fff; padding: 20px; text-align: center; }
          .button { display: inline-block; padding: 10px 20px; background: #FFD700; color: #000; text-decoration: none; border-radius: 5px; margin: 20px 0; }
          .warning { background: #f8d7da; padding: 15px; border-left: 4px solid #f5c6cb; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🔐 Recupera tu Contraseña</h1>
          </div>
          <div style="padding: 20px; background: #f9f9f9;">
            <p>Hola <strong>$userName</strong>,</p>
            <p>Recibimos una solicitud para recuperar tu contraseña.</p>
            <a href="$resetLink" class="button">Recuperar Contraseña</a>
            <div class="warning">
              <strong>Nota:</strong> Este enlace expira en 1 hora. Si no solicitaste esta recuperación, ignora este email.
            </div>
          </div>
          <div class="footer">
            <p>© 2026 KicksPremium</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _getContactFormTemplate(
    String senderName,
    String senderEmail,
    String subject,
    String message,
  ) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #1a1a1a; color: #fff; padding: 20px; text-align: center; }
          .message-box { background: #f9f9f9; padding: 15px; border-left: 4px solid #FFD700; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📬 Nuevo Mensaje de Contacto</h1>
          </div>
          <div style="padding: 20px;">
            <p><strong>Nombre:</strong> $senderName</p>
            <p><strong>Email:</strong> $senderEmail</p>
            <p><strong>Asunto:</strong> $subject</p>
            <div class="message-box">
              <p><strong>Mensaje:</strong></p>
              <p>$message</p>
            </div>
            <p>Responde directamente a este email o contacta al usuario en: $senderEmail</p>
          </div>
          <div class="footer">
            <p>© 2026 KicksPremium</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _getProblemReportTemplate(
    String userName,
    String userEmail,
    String problemDescription,
    String? attachmentUrl,
  ) {
    String attachmentSection = attachmentUrl != null
        ? '<p><strong>Archivo adjunto:</strong> <a href="$attachmentUrl">Ver archivo</a></p>'
        : '';

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #dc3545; color: #fff; padding: 20px; text-align: center; }
          .problem-box { background: #f8d7da; padding: 15px; border-left: 4px solid #dc3545; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>⚠️ Reporte de Problema</h1>
          </div>
          <div style="padding: 20px;">
            <p><strong>Usuario:</strong> $userName</p>
            <p><strong>Email:</strong> $userEmail</p>
            <div class="problem-box">
              <p><strong>Descripción del Problema:</strong></p>
              <p>$problemDescription</p>
            </div>
            $attachmentSection
            <p>Por favor, revisa este reporte lo antes posible.</p>
          </div>
          <div class="footer">
            <p>© 2026 KicksPremium</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }
}
