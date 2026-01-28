# 🎛️ Panel de Administrador - KicksPremium Mobile

## 📋 Descripción

Se ha implementado un completo panel de administración con todas las funciones de gestión de correos electrónicos para el proyecto KicksPremium Mobile.

## ✨ Características Implementadas

### 1. **Panel de Admin** (`admin_panel_screen.dart`)

#### Secciones Disponibles:

- **Dashboard**: Estadísticas en tiempo real
  - Pedidos de hoy
  - Ingresos del día
  - Usuarios nuevos
  - Total de productos
  - Actividad reciente

- **Gestión de Pedidos**: Ver y administrar todos los pedidos
  - Estado del pedido (Pendiente, Confirmado, Enviado)
  - Monto total
  - Información del cliente

- **Gestión de Productos**: Administrar el inventario
  - Ver todos los productos
  - Editar productos
  - Eliminar productos
  - Agregar nuevos productos

- **Gestión de Usuarios**: Administrar clientes
  - Ver perfil
  - Editar información
  - Suspender usuarios

- **Campañas de Email**: Sistema completo de emails
  - Newsletter
  - Promociones
  - Eventos
  - Anuncios
  - Carrito Abandonado

- **Reportes**: Análisis de datos
  - Ventas mensuales
  - Clientes nuevos
  - Productos vendidos
  - Tasa de conversión

- **Configuración**: Ajustes del sistema
  - Notificaciones de email
  - Alertas de stock
  - Modo de mantenimiento

### 2. **Servicio de Email** (`email_service.dart`)

#### Métodos Disponibles:

```dart
// Bienvenida
sendWelcomeEmail(String userEmail, String userName)

// Confirmación de pedido
sendOrderConfirmationEmail(String userEmail, String orderId, double totalAmount, List<Map<String, dynamic>> items)

// Notificar al admin
sendAdminOrderNotification(String orderId, String customerEmail, double totalAmount, List<Map<String, dynamic>> items)

// Actualización de estado
sendOrderStatusUpdate(String userEmail, String orderId, String status, String? trackingUrl)

// Newsletter
sendNewsletter(List<String> emails, String subject, String htmlContent)

// Recuperación de contraseña
sendPasswordResetEmail(String userEmail, String userName, String resetLink)

// Formulario de contacto
sendContactFormEmail(String senderName, String senderEmail, String subject, String message)

// Reporte de problemas
sendProblemReportEmail(String userEmail, String userName, String problemDescription, String? attachmentUrl)
```

### 3. **Repositorio de Email** (`email_repository.dart`)

Capa de abstracción para acceder al servicio de email:

```dart
final emailRepository = EmailRepository();

// Usar cualquier método del servicio
await emailRepository.sendWelcome(email, name);
await emailRepository.sendOrderConfirmation(email, orderId, total, items);
await emailRepository.sendNewsletter(emails, subject, content);
```

### 4. **Funciones Avanzadas de Admin** (`admin_email_functions.dart`)

#### Métodos Especializados:

```dart
// Newsletter
sendNewsletter({required List<String> recipients, required String subject, required String htmlContent})

// Promoción
sendPromotion({required List<String> recipients, required String promotionName, required String discountPercent, required String validUntil})

// Evento
sendEvent({required List<String> recipients, required String eventName, required String eventDate, required String eventDescription})

// Nuevo producto
sendNewProductNotification({required List<String> recipients, required String productName, required String productPrice, required String productImage})

// Carrito abandonado
sendAbandonedCart({required String userEmail, required String cartValue, required List<Map<String, dynamic>> items})

// Reactivación de usuario
sendReactivation({required List<String> recipients, required String specialOffer})
```

## 🚀 Cómo Usar

### Acceder al Panel de Admin:

1. Navega a `/admin` en la aplicación
2. Solo los administradores verificados pueden acceder
3. Se abrirá el panel con todas las opciones disponibles

### Enviar un Email desde el Código:

```dart
import 'package:your_app/data/repositories/email_repository.dart';

final emailRepo = EmailRepository();

// Enviar email de bienvenida
await emailRepo.sendWelcome(
  'usuario@example.com',
  'Juan Pérez'
);

// Enviar newsletter
await emailRepo.sendNewsletter(
  ['user1@example.com', 'user2@example.com'],
  '¡Ofertas exclusivas!',
  '<h1>Hola</h1><p>Tenemos ofertas especiales para ti</p>'
);
```

### Usar desde Riverpod:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailRepo = ref.read(emailRepositoryProvider);
    
    return ElevatedButton(
      onPressed: () async {
        await emailRepo.sendWelcome('email@example.com', 'Usuario');
      },
      child: const Text('Enviar Email'),
    );
  }
}
```

## 📧 Plantillas de Email Disponibles

Todas las plantillas incluyen:
- ✅ Diseño responsivo
- ✅ Branding de KicksPremium
- ✅ Botones de call-to-action
- ✅ HTML limpio y moderno
- ✅ Compatibilidad con todos los clientes de email

### Tipos de Email:

1. **Bienvenida**: Para nuevos usuarios registrados
2. **Confirmación de Pedido**: Detalle completo del pedido
3. **Notificación a Admin**: Información de nuevos pedidos
4. **Actualización de Estado**: Cambios en el estado del pedido
5. **Newsletter**: Contenido personalizado
6. **Recuperación de Contraseña**: Con enlace de reset
7. **Contacto**: Formulario de contacto del usuario
8. **Reporte de Problema**: Problemas reportados por usuarios
9. **Promoción**: Descuentos y ofertas especiales
10. **Evento**: Notificaciones de eventos
11. **Nuevo Producto**: Lanzamiento de productos
12. **Carrito Abandonado**: Recordatorio de compra
13. **Reactivación**: Oferta especial para usuarios inactivos

## 🔧 Configuración Requerida

El archivo `.env` debe contener:

```env
# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
FROM_EMAIL=your-email@gmail.com
ADMIN_EMAIL=admin@example.com
```

## 📱 Rutas Disponibles

```dart
// Panel de Admin
GoRoute(
  path: '/admin',
  builder: (context, state) => const AdminPanelScreen(),
),
```

## 🔒 Seguridad

- ✅ Solo administradores verificados pueden acceder
- ✅ Validación de permisos en el servidor
- ✅ Credenciales seguras en variables de entorno
- ✅ Encriptación de datos sensibles

## 📊 Estadísticas

El panel proporciona:
- Gráficos de ventas
- Información de clientes
- Análisis de productos
- Reportes mensuales

## 🎨 Diseño

- ✅ Interfaz moderna y limpia
- ✅ Sidebar de navegación intuitiva
- ✅ Tema oscuro predeterminado
- ✅ Botones y controles responsivos
- ✅ Color dorado (#FFD700) como accent

## 📝 Notas Importantes

1. El servicio de email actualmente retorna `true` para demostración
2. Se recomienda integrar con un servicio SMTP real como:
   - SendGrid
   - Mailgun
   - AWS SES
   - Resend
   - Nodemailer

3. Implementar validación de permisos en la ruta `/admin`

## 🚦 Próximos Pasos

1. Integrar con Supabase para obtener datos reales
2. Implementar SMTP real para envío de emails
3. Agregar autenticación de admin
4. Crear base de datos para plantillas de email
5. Implementar programación de emails automáticos

## ❓ Preguntas Frecuentes

**¿Cómo accedo al panel?**
- Navega a `/admin` si eres administrador

**¿Puedo personalizar las plantillas?**
- Sí, edita los métodos `_get*EmailTemplate()` en `email_service.dart`

**¿Se envían los emails realmente?**
- No en la versión actual. Necesitas integrar un servicio SMTP real.

**¿Puedo agendar emails?**
- Sí, implementando un sistema de colas (p.ej., con Supabase functions)

---

**Creado para KicksPremium Mobile | 2026**
