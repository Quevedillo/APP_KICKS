import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String smtpHost = dotenv.env['SMTP_HOST'] ?? '';
  final String smtpPort = dotenv.env['SMTP_PORT'] ?? '';
  final String smtpUser = dotenv.env['SMTP_USER'] ?? '';
  final String smtpPass = dotenv.env['SMTP_PASS'] ?? '';
  final String fromEmail = dotenv.env['FROM_EMAIL'] ?? '';
  final String adminEmail = dotenv.env['ADMIN_EMAIL'] ?? '';

  /// Obtener servidor SMTP configurado
  SmtpServer _getSmtpServer() {
    if (smtpHost == 'smtp.gmail.com') {
      return gmail(smtpUser, smtpPass);
    }
    return SmtpServer(
      smtpHost,
      port: int.tryParse(smtpPort) ?? 587,
      username: smtpUser,
      password: smtpPass,
      ssl: false,
      allowInsecure: false,
    );
  }

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

  /// Enviar factura de cancelación/reembolso al cliente
  Future<bool> sendCancellationInvoiceEmail(
    String userEmail,
    String orderId,
    double refundAmount,
    String customerName,
    List<Map<String, dynamic>> items, {
    String? reason,
  }) async {
    return _sendEmail(
      to: userEmail,
      subject: 'Factura de Cancelación - Pedido #$orderId - KicksPremium',
      htmlBody: _getCancellationInvoiceTemplate(orderId, refundAmount, customerName, items, reason),
    );
  }

  /// Función genérica para enviar emails via SMTP
  Future<bool> _sendEmail({
    required String to,
    String? cc,
    required String subject,
    required String htmlBody,
  }) async {
    try {
      if (smtpUser.isEmpty || smtpPass.isEmpty) {
        print('❌ SMTP no configurado: faltan credenciales en env');
        return false;
      }

      final smtpServer = _getSmtpServer();

      final message = Message()
        ..from = Address(fromEmail.isNotEmpty ? fromEmail : smtpUser, 'KicksPremium')
        ..recipients.add(to)
        ..subject = subject
        ..html = htmlBody;

      if (cc != null && cc.isNotEmpty) {
        message.ccRecipients.add(cc);
      }

      final sendReport = await send(message, smtpServer);
      print('📧 Email enviado correctamente a: $to');
      print('   Asunto: $subject');
      print('   Report: $sendReport');
      return true;
    } on MailerException catch (e) {
      print('❌ Error SMTP al enviar email: ${e.message}');
      for (var p in e.problems) {
        print('   Problema: ${p.code}: ${p.msg}');
      }
      return false;
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
    // totalAmount ya viene CON IVA.
    // Calculamos base e IVA a partir del total
    final baseAmount = totalAmount / 1.21;
    final ivaAmount = totalAmount - baseAmount;

    String itemsHtml = items.map((item) {
      final price = item['price'] is num
          ? (item['price'] as num).toDouble()
          : double.tryParse(item['price'].toString()) ?? 0.0;
      final qty = item['quantity'] ?? 1;
      final lineTotal = price * (qty is num ? qty.toInt() : 1);
      final imageUrl = item['image'] ?? '';
      final imageTag = imageUrl.toString().isNotEmpty
          ? '<img src="$imageUrl" width="60" height="60" alt="${item['name']}" style="border-radius:8px;object-fit:cover;">'
          : '<div style="width:60px;height:60px;background:#333;border-radius:8px;"></div>';

      return '''
        <tr>
          <td style="padding:12px 8px;border-bottom:1px solid #2a2a2a;">$imageTag</td>
          <td style="padding:12px 8px;border-bottom:1px solid #2a2a2a;color:#fff;">
            <strong>${item['name']}</strong><br>
            <span style="color:#999;font-size:12px;">${item['brand'] ?? ''} · Talla ${item['size']}</span>
          </td>
          <td style="padding:12px 8px;border-bottom:1px solid #2a2a2a;text-align:center;color:#ccc;">$qty</td>
          <td style="padding:12px 8px;border-bottom:1px solid #2a2a2a;text-align:right;color:#FFD700;font-weight:bold;">€${price.toStringAsFixed(2)}</td>
          <td style="padding:12px 8px;border-bottom:1px solid #2a2a2a;text-align:right;color:#fff;">€${lineTotal.toStringAsFixed(2)}</td>
        </tr>
      ''';
    }).join();

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="margin:0;padding:0;background:#0a0a0a;font-family:'Helvetica Neue',Arial,sans-serif;">
        <div style="max-width:600px;margin:0 auto;background:#121212;">
          <!-- Header -->
          <div style="background:linear-gradient(135deg,#1a1a1a 0%,#2a2a2a 100%);padding:30px;text-align:center;border-bottom:3px solid #FFD700;">
            <h1 style="margin:0;color:#FFD700;font-size:24px;letter-spacing:2px;">KICKSPREMIUM</h1>
            <p style="margin:8px 0 0;color:#ccc;font-size:13px;">FACTURA DE COMPRA</p>
          </div>

          <!-- Order ID badge -->
          <div style="text-align:center;padding:20px 0 10px;">
            <span style="background:#FFD700;color:#000;padding:6px 18px;border-radius:20px;font-size:13px;font-weight:bold;">
              Pedido #$orderId
            </span>
          </div>

          <div style="padding:20px 24px;">
            <p style="color:#ccc;font-size:14px;">¡Tu pedido ha sido confirmado con éxito! A continuación, el detalle de tu compra:</p>

            <!-- Items table -->
            <table style="width:100%;border-collapse:collapse;margin:16px 0;">
              <thead>
                <tr style="background:#1e1e1e;">
                  <th style="padding:10px 8px;text-align:left;color:#999;font-size:11px;text-transform:uppercase;letter-spacing:1px;width:60px;"></th>
                  <th style="padding:10px 8px;text-align:left;color:#999;font-size:11px;text-transform:uppercase;letter-spacing:1px;">Producto</th>
                  <th style="padding:10px 8px;text-align:center;color:#999;font-size:11px;text-transform:uppercase;letter-spacing:1px;">Ud.</th>
                  <th style="padding:10px 8px;text-align:right;color:#999;font-size:11px;text-transform:uppercase;letter-spacing:1px;">Precio</th>
                  <th style="padding:10px 8px;text-align:right;color:#999;font-size:11px;text-transform:uppercase;letter-spacing:1px;">Total</th>
                </tr>
              </thead>
              <tbody>
                $itemsHtml
              </tbody>
            </table>

            <!-- IVA breakdown -->
            <div style="background:#1a1a1a;border-radius:10px;padding:16px;margin-top:16px;">
              <table style="width:100%;border-collapse:collapse;">
                <tr>
                  <td style="padding:6px 0;color:#999;font-size:13px;">Subtotal (sin IVA)</td>
                  <td style="padding:6px 0;text-align:right;color:#ccc;font-size:13px;">€${baseAmount.toStringAsFixed(2)}</td>
                </tr>
                <tr>
                  <td style="padding:6px 0;color:#999;font-size:13px;">IVA (21%)</td>
                  <td style="padding:6px 0;text-align:right;color:#ccc;font-size:13px;">€${ivaAmount.toStringAsFixed(2)}</td>
                </tr>
                <tr>
                  <td style="padding:6px 0;color:#999;font-size:13px;">Envío</td>
                  <td style="padding:6px 0;text-align:right;color:#4CAF50;font-size:13px;">GRATIS</td>
                </tr>
                <tr style="border-top:2px solid #333;">
                  <td style="padding:12px 0 0;color:#fff;font-size:18px;font-weight:bold;">TOTAL</td>
                  <td style="padding:12px 0 0;text-align:right;color:#FFD700;font-size:22px;font-weight:bold;">€${totalAmount.toStringAsFixed(2)}</td>
                </tr>
              </table>
            </div>

            <p style="color:#999;font-size:13px;margin-top:20px;line-height:1.5;">
              Recibirás actualizaciones sobre el estado de tu envío. Si tienes alguna pregunta, no dudes en contactarnos.
            </p>
          </div>

          <!-- Footer -->
          <div style="text-align:center;padding:20px;border-top:1px solid #2a2a2a;color:#666;font-size:11px;">
            <p style="margin:0;">¿Dudas? Escríbenos a <a href="mailto:support@kickspremium.com" style="color:#FFD700;">support@kickspremium.com</a></p>
            <p style="margin:8px 0 0;">© 2026 KicksPremium. Todos los derechos reservados.</p>
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
    final baseAmount = totalAmount / 1.21;
    final ivaAmount = totalAmount - baseAmount;

    String itemsHtml = items.map((item) {
      final price = item['price'] is num
          ? (item['price'] as num).toDouble()
          : double.tryParse(item['price'].toString()) ?? 0.0;
      final qty = item['quantity'] ?? 1;
      return '''
        <tr>
          <td style="padding:8px;border-bottom:1px solid #ddd;">${item['name']}</td>
          <td style="padding:8px;border-bottom:1px solid #ddd;text-align:center;">${item['size']}</td>
          <td style="padding:8px;border-bottom:1px solid #ddd;text-align:center;">$qty</td>
          <td style="padding:8px;border-bottom:1px solid #ddd;text-align:right;">€${price.toStringAsFixed(2)}</td>
        </tr>
      ''';
    }).join();

    return '''
      <!DOCTYPE html>
      <html>
      <head><meta charset="UTF-8"></head>
      <body style="margin:0;padding:0;background:#f5f5f5;font-family:Arial,sans-serif;">
        <div style="max-width:600px;margin:0 auto;background:#fff;">
          <div style="background:#ff6b6b;color:#fff;padding:24px;text-align:center;">
            <h1 style="margin:0;font-size:20px;">🔔 NUEVO PEDIDO RECIBIDO</h1>
          </div>
          <div style="padding:20px;">
            <div style="background:#fff3cd;padding:14px;border-left:4px solid #ffc107;margin-bottom:16px;border-radius:4px;">
              <strong>¡Tienes un nuevo pedido!</strong>
            </div>
            <p><strong>Pedido:</strong> #$orderId</p>
            <p><strong>Email:</strong> $customerEmail</p>

            <table style="width:100%;border-collapse:collapse;margin:16px 0;">
              <thead>
                <tr style="background:#f0f0f0;">
                  <th style="padding:8px;text-align:left;">Producto</th>
                  <th style="padding:8px;text-align:center;">Talla</th>
                  <th style="padding:8px;text-align:center;">Ud.</th>
                  <th style="padding:8px;text-align:right;">Precio</th>
                </tr>
              </thead>
              <tbody>$itemsHtml</tbody>
            </table>

            <div style="background:#f9f9f9;border-radius:8px;padding:14px;margin-top:12px;">
              <table style="width:100%;border-collapse:collapse;">
                <tr>
                  <td style="padding:4px 0;color:#666;font-size:13px;">Base (sin IVA)</td>
                  <td style="padding:4px 0;text-align:right;font-size:13px;">€${baseAmount.toStringAsFixed(2)}</td>
                </tr>
                <tr>
                  <td style="padding:4px 0;color:#666;font-size:13px;">IVA (21%)</td>
                  <td style="padding:4px 0;text-align:right;font-size:13px;">€${ivaAmount.toStringAsFixed(2)}</td>
                </tr>
                <tr style="border-top:2px solid #ddd;">
                  <td style="padding:8px 0 0;font-size:16px;font-weight:bold;">TOTAL</td>
                  <td style="padding:8px 0 0;text-align:right;font-size:18px;font-weight:bold;color:#28a745;">€${totalAmount.toStringAsFixed(2)}</td>
                </tr>
              </table>
            </div>

            <p style="margin-top:16px;color:#666;font-size:13px;">Procesa este pedido lo antes posible.</p>
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

  String _getCancellationInvoiceTemplate(
    String orderId,
    double refundAmount,
    String customerName,
    List<Map<String, dynamic>> items,
    String? reason,
  ) {
    final baseRefund = refundAmount / 1.21;
    final ivaRefund = refundAmount - baseRefund;

    String itemsHtml = items.map((item) {
      final price = item['price'] is num ? (item['price'] as num).toStringAsFixed(2) : item['price'].toString();
      final qty = item['quantity'] ?? 1;
      final total = (item['price'] is num ? (item['price'] as num).toDouble() : 0.0) * (qty is num ? qty.toInt() : 1);
      final imageUrl = item['image'] ?? '';
      final imageTag = imageUrl.toString().isNotEmpty
          ? '<img src="$imageUrl" width="50" height="50" alt="${item['name']}" style="border-radius:6px;object-fit:cover;">'
          : '<div style="width:50px;height:50px;background:#333;border-radius:6px;"></div>';

      return '''
        <tr>
          <td style="padding:10px 8px;border-bottom:1px solid #2a2a2a;">$imageTag</td>
          <td style="padding:10px 8px;border-bottom:1px solid #2a2a2a;color:#fff;">
            <strong>${item['name']}</strong><br>
            <span style="color:#999;font-size:12px;">Talla ${item['size'] ?? '-'}</span>
          </td>
          <td style="padding:10px 8px;border-bottom:1px solid #2a2a2a;text-align:center;color:#ccc;">$qty</td>
          <td style="padding:10px 8px;border-bottom:1px solid #2a2a2a;text-align:right;color:#ccc;">€$price</td>
          <td style="padding:10px 8px;border-bottom:1px solid #2a2a2a;text-align:right;color:#fff;">€${total.toStringAsFixed(2)}</td>
        </tr>
      ''';
    }).join();

    String reasonSection = reason != null && reason.isNotEmpty
        ? '''
          <div style="background:#3a2a00;padding:14px;border-left:4px solid #ffc107;margin:16px 0;border-radius:4px;">
            <p style="margin:0;color:#FFD700;font-size:13px;"><strong>Motivo de cancelación:</strong></p>
            <p style="margin:5px 0 0;color:#ccc;font-size:13px;">$reason</p>
          </div>
        '''
        : '';

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="margin:0;padding:0;background:#0a0a0a;font-family:'Helvetica Neue',Arial,sans-serif;">
        <div style="max-width:600px;margin:0 auto;background:#121212;">
          <!-- Header -->
          <div style="background:linear-gradient(135deg,#1a1a1a 0%,#2a2a2a 100%);padding:30px;text-align:center;border-bottom:3px solid #dc3545;">
            <h1 style="margin:0;color:#dc3545;font-size:22px;letter-spacing:2px;">KICKSPREMIUM</h1>
            <p style="margin:8px 0 0;color:#ccc;font-size:13px;">FACTURA DE CANCELACIÓN</p>
          </div>

          <!-- Order ID -->
          <div style="text-align:center;padding:20px 0 10px;">
            <span style="background:#dc3545;color:#fff;padding:6px 18px;border-radius:20px;font-size:13px;font-weight:bold;">
              Pedido #$orderId
            </span>
          </div>

          <div style="padding:20px 24px;">
            <p style="color:#ccc;font-size:14px;">Hola <strong style="color:#fff;">$customerName</strong>,</p>
            <p style="color:#ccc;font-size:14px;">Tu pedido <strong style="color:#fff;">#$orderId</strong> ha sido cancelado y se ha procesado el reembolso correspondiente.</p>
            
            $reasonSection
            
            <p style="color:#999;font-size:12px;text-transform:uppercase;letter-spacing:1px;margin-bottom:8px;">Artículos reembolsados</p>
            <table style="width:100%;border-collapse:collapse;margin:0 0 16px;">
              <thead>
                <tr style="background:#1e1e1e;">
                  <th style="padding:8px;width:50px;"></th>
                  <th style="padding:8px;text-align:left;color:#999;font-size:11px;text-transform:uppercase;">Producto</th>
                  <th style="padding:8px;text-align:center;color:#999;font-size:11px;text-transform:uppercase;">Ud.</th>
                  <th style="padding:8px;text-align:right;color:#999;font-size:11px;text-transform:uppercase;">Precio</th>
                  <th style="padding:8px;text-align:right;color:#999;font-size:11px;text-transform:uppercase;">Total</th>
                </tr>
              </thead>
              <tbody>
                $itemsHtml
              </tbody>
            </table>

            <!-- IVA breakdown -->
            <div style="background:#1a1a1a;border-radius:10px;padding:16px;margin-bottom:16px;">
              <table style="width:100%;border-collapse:collapse;">
                <tr>
                  <td style="padding:4px 0;color:#999;font-size:13px;">Base (sin IVA)</td>
                  <td style="padding:4px 0;text-align:right;color:#ccc;font-size:13px;">€${baseRefund.toStringAsFixed(2)}</td>
                </tr>
                <tr>
                  <td style="padding:4px 0;color:#999;font-size:13px;">IVA (21%)</td>
                  <td style="padding:4px 0;text-align:right;color:#ccc;font-size:13px;">€${ivaRefund.toStringAsFixed(2)}</td>
                </tr>
              </table>
            </div>
            
            <!-- Refund box -->
            <div style="background:linear-gradient(135deg,#1b3a26 0%,#1e4d2b 100%);padding:20px;border-radius:10px;text-align:center;margin:16px 0;">
              <p style="margin:0 0 5px;font-size:12px;color:#8fc9a0;text-transform:uppercase;letter-spacing:1px;">IMPORTE REEMBOLSADO</p>
              <p style="margin:0;font-size:30px;font-weight:bold;color:#4CAF50;">€${refundAmount.toStringAsFixed(2)}</p>
              <p style="margin:10px 0 0;font-size:12px;color:#8fc9a0;">
                El reembolso se reflejará en tu método de pago original en 5-10 días hábiles.
              </p>
            </div>
            
            <div style="background:#1a2332;padding:14px;border-radius:8px;margin:16px 0;">
              <p style="margin:0;font-size:12px;color:#7fb3d8;">
                <strong>📌 Nota:</strong> Este email sirve como comprobante oficial de tu cancelación y reembolso. 
                Guárdalo para tus registros.
              </p>
            </div>
          </div>

          <!-- Footer -->
          <div style="text-align:center;padding:20px;border-top:1px solid #2a2a2a;color:#666;font-size:11px;">
            <p style="margin:0;">¿Dudas? Escríbenos a <a href="mailto:support@kickspremium.com" style="color:#FFD700;">support@kickspremium.com</a></p>
            <p style="margin:8px 0 0;">© 2026 KicksPremium. Todos los derechos reservados.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }
}
