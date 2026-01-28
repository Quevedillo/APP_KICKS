// EJEMPLOS DE USO - Sistema de Emails y Panel de Admin
// Este archivo contiene ejemplos prácticos de cómo usar todas las funciones

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/repositories/email_repository.dart';
import 'data/repositories/admin_email_functions.dart';
import 'logic/providers.dart';

// ============================================
// EJEMPLO 1: Enviar Email de Bienvenida
// ============================================

Future<void> example1_sendWelcomeEmail() async {
  final emailRepo = EmailRepository();
  
  await emailRepo.sendWelcome(
    'juan@example.com',
    'Juan Pérez',
  );
  
  print('✅ Email de bienvenida enviado');
}

// ============================================
// EJEMPLO 2: Enviar Confirmación de Pedido
// ============================================

Future<void> example2_sendOrderConfirmation() async {
  final emailRepo = EmailRepository();
  
  final items = [
    {
      'name': 'Nike Air Max 90',
      'size': '42',
      'quantity': 1,
      'price': 129.99
    },
    {
      'name': 'Adidas Ultraboost',
      'size': '41',
      'quantity': 2,
      'price': 179.99
    },
  ];
  
  await emailRepo.sendOrderConfirmation(
    'cliente@example.com',
    'ORD-2026-001234',
    489.97,
    items,
  );
  
  print('✅ Confirmación de pedido enviada');
}

// ============================================
// EJEMPLO 3: Notificar al Admin de Nuevo Pedido
// ============================================

Future<void> example3_notifyAdminNewOrder() async {
  final emailRepo = EmailRepository();
  
  final items = [
    {
      'name': 'Nike Air Max 90',
      'size': '42',
      'quantity': 1,
      'price': 129.99
    },
  ];
  
  await emailRepo.notifyAdminNewOrder(
    'ORD-2026-001234',
    'cliente@example.com',
    129.99,
    items,
  );
  
  print('✅ Notificación al admin enviada');
}

// ============================================
// EJEMPLO 4: Actualizar Estado del Pedido
// ============================================

Future<void> example4_sendOrderStatusUpdate() async {
  final emailRepo = EmailRepository();
  
  await emailRepo.sendOrderStatusUpdate(
    'cliente@example.com',
    'ORD-2026-001234',
    'Enviado',
    'https://tracking.example.com/ORD-2026-001234',
  );
  
  print('✅ Actualización de estado enviada');
}

// ============================================
// EJEMPLO 5: Enviar Newsletter a Múltiples Usuarios
// ============================================

Future<void> example5_sendNewsletter() async {
  final emailRepo = EmailRepository();
  
  final recipients = [
    'user1@example.com',
    'user2@example.com',
    'user3@example.com',
  ];
  
  final result = await emailRepo.sendNewsletter(
    recipients,
    '🎉 Nuestras Mejores Ofertas de Febrero',
    '''
      <h1>¡Hola amigos!</h1>
      <p>Tenemos increíbles ofertas para ti esta semana.</p>
      <p>Descuentos de hasta 50% en productos seleccionados.</p>
      <a href="https://kickspremium.com">Ver Ofertas</a>
    ''',
  );
  
  print('✅ Newsletter enviada - Exitosos: ${result['successful']}, Fallidos: ${result['failed']}');
}

// ============================================
// EJEMPLO 6: Recuperación de Contraseña
// ============================================

Future<void> example6_sendPasswordReset() async {
  final emailRepo = EmailRepository();
  
  await emailRepo.sendPasswordReset(
    'usuario@example.com',
    'Carlos López',
    'https://kickspremium.com/reset-password?token=abc123def456',
  );
  
  print('✅ Email de recuperación enviado');
}

// ============================================
// EJEMPLO 7: Email de Contacto
// ============================================

Future<void> example7_sendContactForm() async {
  final emailRepo = EmailRepository();
  
  await emailRepo.sendContactForm(
    'Juan García',
    'juan@example.com',
    'Consulta sobre envíos',
    'Hola, quisiera saber cuánto tiempo tarda el envío a Barcelona',
  );
  
  print('✅ Email de contacto enviado');
}

// ============================================
// EJEMPLO 8: Reporte de Problema
// ============================================

Future<void> example8_sendProblemReport() async {
  final emailRepo = EmailRepository();
  
  await emailRepo.sendProblemReport(
    'usuario@example.com',
    'María Rodríguez',
    'El carrito se congela cuando intento pagar',
    null, // Sin archivo adjunto
  );
  
  print('✅ Reporte de problema enviado');
}

// ============================================
// EJEMPLO 9: Enviar Promoción (Admin)
// ============================================

Future<void> example9_sendPromotion() async {
  final adminFunctions = AdminEmailFunctions();
  
  final recipients = [
    'user1@example.com',
    'user2@example.com',
  ];
  
  final result = await adminFunctions.sendPromotion(
    recipients: recipients,
    promotionName: 'Black Friday',
    discountPercent: '40',
    validUntil: '31 de Enero de 2026',
  );
  
  print('✅ Promoción enviada - Exitosos: ${result['successful']}');
}

// ============================================
// EJEMPLO 10: Evento Especial (Admin)
// ============================================

Future<void> example10_sendEvent() async {
  final adminFunctions = AdminEmailFunctions();
  
  final recipients = [
    'user1@example.com',
    'user2@example.com',
  ];
  
  final result = await adminFunctions.sendEvent(
    recipients: recipients,
    eventName: 'Lanzamiento de Colección Spring 2026',
    eventDate: '15 de Marzo de 2026',
    eventDescription: 'Únete a nosotros para el lanzamiento de nuestra nueva colección de primavera con descuentos especiales.',
  );
  
  print('✅ Invitación a evento enviada - Exitosos: ${result['successful']}');
}

// ============================================
// EJEMPLO 11: Nuevo Producto (Admin)
// ============================================

Future<void> example11_sendNewProductNotification() async {
  final adminFunctions = AdminEmailFunctions();
  
  final recipients = [
    'user1@example.com',
    'user2@example.com',
  ];
  
  final result = await adminFunctions.sendNewProductNotification(
    recipients: recipients,
    productName: 'Nike Air Jordan 1 Retro High',
    productPrice: '\$199.99',
    productImage: 'https://example.com/jordan1.jpg',
  );
  
  print('✅ Notificación de nuevo producto enviada - Exitosos: ${result['successful']}');
}

// ============================================
// EJEMPLO 12: Carrito Abandonado (Admin)
// ============================================

Future<void> example12_sendAbandonedCart() async {
  final adminFunctions = AdminEmailFunctions();
  
  final items = [
    {
      'name': 'Nike Air Max 90',
      'size': '42',
      'quantity': 1,
      'price': '129.99'
    },
  ];
  
  final result = await adminFunctions.sendAbandonedCart(
    userEmail: 'usuario@example.com',
    cartValue: '\$129.99',
    items: items,
  );
  
  print(result
      ? '✅ Email de carrito abandonado enviado'
      : '❌ Error al enviar email');
}

// ============================================
// EJEMPLO 13: Reactivación de Usuario (Admin)
// ============================================

Future<void> example13_sendReactivation() async {
  final adminFunctions = AdminEmailFunctions();
  
  final recipients = [
    'inactive_user1@example.com',
    'inactive_user2@example.com',
  ];
  
  final result = await adminFunctions.sendReactivation(
    recipients: recipients,
    specialOffer: '25% de descuento en tu próxima compra',
  );
  
  print('✅ Campaña de reactivación enviada - Exitosos: ${result['successful']}');
}

// ============================================
// EJEMPLO 14: Usar con Riverpod (Widget)
// ============================================

class EmailExampleWidget extends ConsumerWidget {
  const EmailExampleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el repositorio de email desde Riverpod
    final emailRepo = ref.watch(emailRepositoryProvider);

    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final success = await emailRepo.sendWelcome(
              'nuevo@example.com',
              'Nuevo Usuario',
            );
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Email enviado')),
              );
            }
          },
          child: const Text('Enviar Bienvenida'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await emailRepo.sendPasswordReset(
              'usuario@example.com',
              'Usuario',
              'https://app.com/reset?token=xyz',
            );
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Email de reset enviado')),
              );
            }
          },
          child: const Text('Enviar Reset de Contraseña'),
        ),
      ],
    );
  }
}

// ============================================
// EJEMPLO 15: Flujo Completo de Compra
// ============================================

Future<void> example15_completePurchaseFlow() async {
  final emailRepo = EmailRepository();
  
  // 1. Enviar confirmación al cliente
  await emailRepo.sendOrderConfirmation(
    'cliente@example.com',
    'ORD-2026-005678',
    299.99,
    [
      {'name': 'Producto 1', 'size': '42', 'quantity': 1, 'price': 299.99}
    ],
  );
  
  // 2. Notificar al admin
  await emailRepo.notifyAdminNewOrder(
    'ORD-2026-005678',
    'cliente@example.com',
    299.99,
    [
      {'name': 'Producto 1', 'size': '42', 'quantity': 1, 'price': 299.99}
    ],
  );
  
  // 3. Después de 2 horas, si no se envía, recordar
  // (Implementar con timer o background task)
  
  // 4. Cuando se procese, actualizar estado
  await Future.delayed(const Duration(seconds: 5));
  await emailRepo.sendOrderStatusUpdate(
    'cliente@example.com',
    'ORD-2026-005678',
    'Procesando',
    null,
  );
  
  // 5. Cuando se envíe, notificar con seguimiento
  await emailRepo.sendOrderStatusUpdate(
    'cliente@example.com',
    'ORD-2026-005678',
    'Enviado',
    'https://tracking.example.com/ORD-2026-005678',
  );
  
  print('✅ Flujo de compra completo ejecutado');
}

// ============================================
// EJEMPLO 16: Campañas Masivas (Admin)
// ============================================

Future<void> example16_massiveCampaign() async {
  final adminFunctions = AdminEmailFunctions();
  
  // Simular obtención de lista de usuarios desde BD
  final allUsers = [
    'user1@example.com',
    'user2@example.com',
    'user3@example.com',
    'user4@example.com',
    'user5@example.com',
  ];
  
  // Dividir en lotes para no saturar
  const batchSize = 100;
  
  for (int i = 0; i < allUsers.length; i += batchSize) {
    final end = (i + batchSize > allUsers.length)
        ? allUsers.length
        : i + batchSize;
    final batch = allUsers.sublist(i, end);
    
    await adminFunctions.sendNewsletter(
      recipients: batch,
      subject: 'Newsletter de KicksPremium - Enero 2026',
      htmlContent: '<h1>Nuestras mejores ofertas</h1>',
    );
    
    print('✅ Lote ${(i / batchSize + 1).toInt()} enviado');
    await Future.delayed(const Duration(seconds: 1)); // Respetar rate limits
  }
}

// ============================================
// NOTAS DE IMPLEMENTACIÓN
// ============================================

/*
PASOS PARA USAR ESTOS EJEMPLOS:

1. IMPORTAR:
   import 'examples.dart';

2. EJECUTAR UN EJEMPLO:
   await example1_sendWelcomeEmail();

3. EN UN WIDGET:
   ElevatedButton(
     onPressed: () => example2_sendOrderConfirmation(),
     child: const Text('Enviar Confirmación'),
   )

4. DESDE RIVERPOD:
   final emailRepo = ref.watch(emailRepositoryProvider);
   await emailRepo.sendWelcome(email, name);

IMPORTANTE:
- Los ejemplos usan datos ficticios
- En producción, obtener datos reales de tu BD
- El servicio de email actualmente retorna true (demostración)
- Integrar con SMTP real (SendGrid, Mailgun, etc)
- Validar emails antes de enviar
- Implementar rate limiting
- Guardar historial de emails enviados
*/
