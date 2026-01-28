import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/email_repository.dart';

// Provider para las funciones del admin
final adminEmailFunctionsProvider = Provider<AdminEmailFunctions>((ref) {
  return AdminEmailFunctions();
});

class AdminEmailFunctions {
  final _emailRepository = EmailRepository();

  /// Enviar newsletter a múltiples usuarios
  Future<Map<String, int>> sendNewsletter({
    required List<String> recipients,
    required String subject,
    required String htmlContent,
  }) async {
    return _emailRepository.sendNewsletter(recipients, subject, htmlContent);
  }

  /// Enviar email de promoción
  Future<Map<String, int>> sendPromotion({
    required List<String> recipients,
    required String promotionName,
    required String discountPercent,
    required String validUntil,
  }) async {
    final htmlContent = _buildPromotionEmail(promotionName, discountPercent, validUntil);
    return _emailRepository.sendNewsletter(
      recipients,
      '🎉 ¡Promoción: $promotionName!',
      htmlContent,
    );
  }

  /// Enviar notificación de evento
  Future<Map<String, int>> sendEvent({
    required List<String> recipients,
    required String eventName,
    required String eventDate,
    required String eventDescription,
  }) async {
    final htmlContent = _buildEventEmail(eventName, eventDate, eventDescription);
    return _emailRepository.sendNewsletter(
      recipients,
      '🎊 Evento: $eventName',
      htmlContent,
    );
  }

  /// Enviar notificación de nuevo producto
  Future<Map<String, int>> sendNewProductNotification({
    required List<String> recipients,
    required String productName,
    required String productPrice,
    required String productImage,
  }) async {
    final htmlContent = _buildNewProductEmail(productName, productPrice, productImage);
    return _emailRepository.sendNewsletter(
      recipients,
      '✨ Nuevo Producto: $productName',
      htmlContent,
    );
  }

  /// Enviar email de carrito abandonado
  Future<bool> sendAbandonedCart({
    required String userEmail,
    required String cartValue,
    required List<Map<String, dynamic>> items,
  }) async {
    final htmlContent = _buildAbandonedCartEmail(cartValue, items);
    final result = await _emailRepository.sendNewsletter(
      [userEmail],
      '🛒 ¡No olvides tu carrito!',
      htmlContent,
    );
    return (result['successful'] ?? 0) > 0;
  }

  /// Enviar email de reactivación
  Future<Map<String, int>> sendReactivation({
    required List<String> recipients,
    required String specialOffer,
  }) async {
    final htmlContent = _buildReactivationEmail(specialOffer);
    return _emailRepository.sendNewsletter(
      recipients,
      '👟 ¡Te extrañamos! Regresa y obtén $specialOffer',
      htmlContent,
    );
  }

  // ========== Plantillas HTML ==========

  String _buildPromotionEmail(String promoName, String discount, String validUntil) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; background: #f5f5f5; }
          .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; }
          .header { background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%); color: #000; padding: 30px; text-align: center; border-radius: 10px; }
          .promo-badge { display: inline-block; background: #ff6b6b; color: white; padding: 15px 30px; border-radius: 50px; font-size: 24px; font-weight: bold; margin: 20px 0; }
          .content { padding: 20px; }
          .cta-button { display: inline-block; background: #FFD700; color: #000; padding: 15px 40px; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; border-top: 1px solid #ddd; margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎉 ¡PROMOCIÓN ESPECIAL!</h1>
          </div>
          <div class="content">
            <p>¡Hola! Tenemos una increíble promoción especialmente para ti:</p>
            <div class="promo-badge">$promoName</div>
            <h2 style="color: #ff6b6b; text-align: center;">¡Descuento de $discount%!</h2>
            <p>Esta oferta especial es válida hasta el <strong>$validUntil</strong>.</p>
            <p>No dejes pasar esta oportunidad de obtener tus zapatillas favoritas a un precio increíble.</p>
            <center>
              <a href="https://kickspremium.com" class="cta-button">Compra Ahora</a>
            </center>
            <p><strong>Código:</strong> PROMO$discount</p>
          </div>
          <div class="footer">
            <p>© 2026 KicksPremium. Todos los derechos reservados.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _buildEventEmail(String eventName, String eventDate, String description) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; background: #f5f5f5; }
          .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px; }
          .event-details { background: #f0f0f0; padding: 20px; border-left: 4px solid #667eea; margin: 20px 0; }
          .cta-button { display: inline-block; background: #667eea; color: white; padding: 15px 40px; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; border-top: 1px solid #ddd; margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎊 $eventName</h1>
          </div>
          <div class="event-details">
            <p><strong>📅 Fecha:</strong> $eventDate</p>
            <p><strong>📍 Detalles:</strong></p>
            <p>$description</p>
          </div>
          <p>¡Te invitamos a participar en este evento especial en KicksPremium!</p>
          <center>
            <a href="https://kickspremium.com" class="cta-button">Más Información</a>
          </center>
          <div class="footer">
            <p>© 2026 KicksPremium. Todos los derechos reservados.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _buildNewProductEmail(String productName, String price, String imageUrl) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; background: #f5f5f5; }
          .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; }
          .header { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; padding: 30px; text-align: center; border-radius: 10px; }
          .product-box { text-align: center; padding: 20px; background: #f9f9f9; border-radius: 10px; margin: 20px 0; }
          .product-image { max-width: 100%; height: auto; border-radius: 10px; margin: 20px 0; }
          .price { font-size: 32px; font-weight: bold; color: #f5576c; }
          .cta-button { display: inline-block; background: #f5576c; color: white; padding: 15px 40px; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; border-top: 1px solid #ddd; margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>✨ ¡NUEVO PRODUCTO!</h1>
          </div>
          <div class="product-box">
            <img src="$imageUrl" alt="$productName" class="product-image" style="max-width: 300px;">
            <h2>$productName</h2>
            <p class="price">$price</p>
            <p>Este increíble producto acaba de llegar a nuestro catálogo. ¡No te lo pierdas!</p>
            <a href="https://kickspremium.com" class="cta-button">Ver Producto</a>
          </div>
          <div class="footer">
            <p>© 2026 KicksPremium. Todos los derechos reservados.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _buildAbandonedCartEmail(String cartValue, List<Map<String, dynamic>> items) {
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
          body { font-family: Arial, sans-serif; background: #f5f5f5; }
          .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; }
          .header { background: #ff9800; color: white; padding: 30px; text-align: center; border-radius: 10px; }
          table { width: 100%; border-collapse: collapse; margin: 20px 0; }
          th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
          th { background: #f0f0f0; }
          .total { font-size: 20px; font-weight: bold; color: #ff9800; text-align: right; padding: 20px 0; }
          .cta-button { display: inline-block; background: #ff9800; color: white; padding: 15px 40px; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; border-top: 1px solid #ddd; margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🛒 ¡No Olvides tu Carrito!</h1>
          </div>
          <p>Hola, parece que dejaste algunos artículos en tu carrito. ¡No dejes pasar esta oportunidad!</p>
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
          <div class="total">Total: $cartValue</div>
          <p>Completa tu compra ahora y recibe tu orden lo antes posible.</p>
          <center>
            <a href="https://kickspremium.com/cart" class="cta-button">Ir al Carrito</a>
          </center>
          <div class="footer">
            <p>© 2026 KicksPremium. Todos los derechos reservados.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _buildReactivationEmail(String offer) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; background: #f5f5f5; }
          .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px; }
          .offer-badge { background: #fff44f; color: #000; padding: 20px; border-radius: 10px; text-align: center; margin: 20px 0; font-size: 18px; font-weight: bold; }
          .cta-button { display: inline-block; background: #667eea; color: white; padding: 15px 40px; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; border-top: 1px solid #ddd; margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>👟 ¡Te Extrañamos!</h1>
          </div>
          <p>Hola, nos hemos dado cuenta de que no has visitado KicksPremium en un tiempo. ¡Tenemos una sorpresa especial para ti!</p>
          <div class="offer-badge">$offer</div>
          <p>Usa este código especial en tu próxima compra y disfruta de un descuento exclusivo.</p>
          <center>
            <a href="https://kickspremium.com" class="cta-button">Explorar Catálogo</a>
          </center>
          <p>¡Esperamos verte pronto!</p>
          <div class="footer">
            <p>© 2026 KicksPremium. Todos los derechos reservados.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }
}
