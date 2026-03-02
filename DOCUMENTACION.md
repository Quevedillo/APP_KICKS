# KICKSPREMIUM MOBILE — Documentación Técnica

**Versión:** 1.0.0 | **Framework:** Flutter (Dart SDK ^3.10.0) | **Plataformas:** Android, iOS, Windows
**Fecha:** 2 de marzo de 2026

---

## 1. Descripción del Proyecto

KicksPremium es una aplicación móvil de e-commerce especializada en sneakers exclusivos y de edición limitada. Permite a los usuarios explorar un catálogo con filtros avanzados, comprar mediante Stripe (incluso como invitado), gestionar pedidos, solicitar devoluciones y generar facturas PDF. Incluye un panel de administración completo con analytics en tiempo real.

**Funcionalidades clave:** catálogo con filtros (marca, categoría, color, precio), colecciones (Limitadas, Nuevos, Restocks, Ofertas), carrito con control de stock por talla, checkout Stripe, compra como invitado con vinculación automática, códigos de descuento, IVA 21% automático, emails transaccionales, generación de facturas PDF, dashboard admin con gráficas y panel de gestión integral.

---

## 2. Arquitectura y Estructura

Arquitectura en capas (Clean Architecture simplificada) con Riverpod para gestión de estado:

```
lib/
├── main.dart                         → Punto de entrada (inicializa Supabase, Stripe, locale)
├── core/theme/app_theme.dart         → Tema oscuro Material 3 (colores: #0A0A0A, #FF3131, #00D4FF)
├── data/
│   ├── models/                       → Modelos Freezed: Product, Order, CartItem, Category,
│   │                                   UserProfile, DiscountCode
│   ├── repositories/                 → ProductRepo, AuthRepo, OrderRepo, AdminRepo,
│   │                                   DiscountRepo, EmailRepo
│   └── services/                     → StripeService, CloudinaryService, EmailService,
│                                       StripeAdminService
├── logic/providers.dart              → ~60 providers Riverpod (auth, productos, carrito,
│                                       pedidos, búsqueda, admin, Stripe)
├── presentation/
│   ├── router.dart                   → GoRouter con ShellRoute + rutas completas
│   ├── screens/                      → 14 pantallas (home, auth, product, cart, checkout,
│   │                                   orders, profile, sales, admin)
│   └── widgets/                      → 8 widgets: MainScaffold, ProductCard, LiveSearch,
│                                       NewsletterPopup, SizeRecommender, CreditNote...
└── utils/vat_helper.dart             → Cálculos IVA 21% España
```

**Backend (Supabase Edge Functions):** `stripe-proxy` (PaymentIntents/reembolsos), `send-email` (emails transaccionales), `admin-auth` (ban/unban/delete usuarios).

---

## 3. Stack Tecnológico

| Capa | Tecnologías |
|------|-------------|
| **UI** | Flutter 3.10+, Material 3, Google Fonts (Bebas Neue, Oswald, Inter) |
| **Estado** | flutter_riverpod ^3.2.0 (Notifier + FutureProvider + StreamProvider) |
| **Navegación** | go_router ^17.0.1 (ShellRoute con bottom nav + rutas full-screen) |
| **Modelos** | freezed ^3.2.5 + json_serializable ^6.9.0 + build_runner |
| **Backend** | Supabase (PostgreSQL + Auth + Edge Functions + RLS) |
| **Pagos** | Stripe (flutter_stripe ^12.2.0) — claves secretas solo en Edge Functions |
| **Imágenes** | Cloudinary (upload unsigned) + cached_network_image |
| **Extras** | pdf + printing (facturas), fl_chart (gráficas admin), intl (i18n), image_picker |

---

## 4. Modelos de Datos y Base de Datos

### Tablas principales (Supabase/PostgreSQL):

**products** — `id` UUID, `name`, `slug` (unique), `price` INT (céntimos sin IVA), `compare_price`, `cost_price`, `stock`, `category_id` FK, `brand`, `model`, `colorway`, `sku`, `is_limited_edition`, `is_featured`, `is_active`, `sizes_available` JSONB, `images` JSONB, `tags` JSONB, `discount_type` (percentage|fixed), `discount_value`, `release_type` (new|restock), `created_at`.

**orders** — `id` UUID, `stripe_payment_intent_id`, `user_id` FK (nullable para invitados), `total_amount` INT, `subtotal_amount`, `shipping_amount`, `discount_amount`, `discount_code_id`, `status` (pending|paid|processing|shipped|delivered|completed|cancelled|refunded), `return_status`, `cancelled_reason`, `items` JSONB, `shipping_name`, `billing_email`, `shipping_phone`, `shipping_address` JSONB, `created_at`.

**categories** — `id`, `name`, `slug`, `description`, `icon`, `display_order`.

**user_profiles** — `id` FK auth.users, `email`, `full_name`, `is_admin`, `created_at`.

**discount_codes** — `id`, `code` (unique), `discount_type`, `discount_value`, `min_purchase`, `max_uses`, `max_uses_per_user`, `current_uses`, `is_active`, `expires_at`.

**discount_code_uses** — `code_id` FK, `user_id` FK, `order_id`, `discount_amount`.

**RPC Functions:** `reduce_size_stock`, `cancel_order_atomic`, `link_guest_orders`, `create_guest_order`, `increment_discount_code_uses`.

---

## 5. Navegación, Flujos y Lógica de Negocio

### Rutas:
- **Con bottom nav (ShellRoute):** `/` (Home), `/orders`, `/profile`
- **Full-screen:** `/product/:slug`, `/category/:slug`, `/products`, `/sales`, `/sales/:collection`, `/cart`, `/checkout`, `/login?redirect=`, `/register`, `/change-password`, `/admin`

### Flujo de compra:
Catálogo → Detalle (elegir talla) → Carrito (código descuento opcional) → Checkout → Stripe Payment Sheet → Pedido creado + stock reducido + email confirmación. **Invitados:** introducen email; al registrarse luego, los pedidos se vinculan automáticamente vía `guestOrderLinkerProvider`.

### Lógica clave:
- **IVA:** Precios en BD sin IVA (céntimos). `VatHelper` aplica 21% para mostrar al usuario.
- **Descuentos:** Validación de expiración, límite global/por usuario, compra mínima. Tipos: porcentaje o fijo.
- **Stock:** Control por talla (JSONB `sizes_available`). Productos con stock 0 ocultos del catálogo.
- **Cancelaciones:** Disponible en estados `paid`/`processing`. Reembolso automático en Stripe.
- **Devoluciones:** Disponible en `shipped`/`delivered`. El admin aprueba/rechaza desde el panel.

### Panel Admin (ruta `/admin`):
Dashboard (ingresos, gráficas 7 días, top producto, bajo stock, beneficio) + Gestión de pedidos (cambio estado, reembolsos) + CRUD productos (con Cloudinary) + CRUD categorías + Gestión usuarios (admin, ban, delete) + Códigos descuento + Analytics Stripe (pagos, disputas, reembolsos).

---

## 6. Configuración, Seguridad y Despliegue

### Variables de entorno (--dart-define):
```
PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY,
PUBLIC_STRIPE_PUBLIC_KEY, PUBLIC_CLOUDINARY_CLOUD_NAME
```

### Ejecución:
```bash
flutter run --dart-define-from-file=assets/env
# o individualmente:
flutter run --dart-define=PUBLIC_SUPABASE_URL=https://xxx.supabase.co ...
```

### Generación de código:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Seguridad:
- Claves secretas Stripe y SMTP **solo en Edge Functions** (nunca en cliente)
- Supabase RLS activo en todas las tablas
- Validación `isAdmin` en cada provider admin con `autoDispose`
- Cloudinary con upload preset unsigned (sin secretos)
- Variables sensibles inyectadas vía `--dart-define`

---

*KicksPremium Mobile v1.0.0 — Flutter SDK ^3.10.0 — Generado el 2 de marzo de 2026*
