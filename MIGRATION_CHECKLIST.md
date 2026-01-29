# ✅ CHECKLIST DE MIGRACIÓN - ADMIN PANEL V2

## 📋 PRE-MIGRACIÓN

- [ ] **Backup de BD**
  ```bash
  # Exportar datos actuales
  # Supabase Dashboard > SQL Editor > Backup
  ```

- [ ] **Verificar que el usuario es admin**
  ```sql
  SELECT * FROM user_profiles WHERE is_admin = true;
  -- Debe haber al menos un admin registrado
  ```

- [ ] **Revisar archivos SQL de BD**
  - DATABASE_COMPLETE_BACKUP.sql contiene:
    - Tablas: orders, products, categories, discount_codes, user_profiles
    - RLS Policies para seguridad
    - Triggers para updated_at
    - Funciones de sincronización de stock

## 🔧 PASO 1: ACTUALIZAR CÓDIGO

### Opción A: Migración gradual (SIN remplazar archivo viejo)

- [ ] Los nuevos providers funcionan con el admin_panel_screen.dart antiguo
- [ ] AdminRepository nuevo es backward-compatible
- [ ] Prueba en desarrollo primero
- [ ] Comando:
  ```bash
  flutter pub get
  flutter run
  ```

### Opción B: Reemplazar completamente (RECOMENDADO)

- [ ] Hacer backup del archivo viejo
  ```bash
  cp lib/presentation/screens/admin/admin_panel_screen.dart \
     lib/presentation/screens/admin/admin_panel_screen_v1_backup.dart
  ```

- [ ] Reemplazar con versión v2
  ```bash
  cp lib/presentation/screens/admin/admin_panel_screen_v2.dart \
     lib/presentation/screens/admin/admin_panel_screen.dart
  ```

- [ ] Verificar imports en router.dart
  ```dart
  import 'package:kickspremium_mobile/presentation/screens/admin/admin_panel_screen.dart';
  ```

## 🗄️ PASO 2: VERIFICAR BASE DE DATOS

### Verificar esquema
- [ ] Ejecutar SQL del backup si es necesario:
  ```bash
  # Supabase Dashboard > SQL Editor
  # Copiar y pegar: DATABASE_COMPLETE_BACKUP.sql
  ```

### Verificar tablas existen
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';
-- Debe mostrar: orders, products, categories, user_profiles, discount_codes
```

### Verificar índices
```sql
-- Los índices deben existir para performance
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_products_stock ON products(stock);
```

### Verificar triggers
```sql
-- Triggers para updated_at deben estar activos
SELECT trigger_name FROM information_schema.triggers
WHERE table_schema = 'public';
```

## 🔐 PASO 3: CONFIGURAR STRIPE

### Setup Webhooks
- [ ] Ir a https://dashboard.stripe.com/webhooks
- [ ] Click "Add endpoint"
- [ ] URL: `https://tudominio.com/api/webhooks/stripe`
- [ ] Eventos a escuchar:
  ```
  ✅ payment_intent.succeeded
  ✅ payment_intent.payment_failed
  ✅ charge.refunded
  ✅ charge.dispute.created
  ✅ charge.dispute.closed
  ```
- [ ] Guardar Signing Secret en `.env`
  ```
  STRIPE_WEBHOOK_SECRET=whsec_xxx
  ```

### Crear endpoint en backend
- [ ] Implementar `/api/webhooks/stripe`
- [ ] Usar `StripeAdminService.syncStripePaymentStatus()`
- [ ] Logar en tabla `stripe_webhooks_log`

### Test webhook
```bash
# Usar Stripe CLI
stripe listen --forward-to localhost:3000/api/webhooks/stripe
stripe trigger payment_intent.succeeded
```

## 🧪 PASO 4: TESTING

### En desarrollo
- [ ] `flutter run` en modo debug
- [ ] Navegar a Admin Panel
- [ ] Verificar que carga dashboard
- [ ] Presionar botón refresh
- [ ] Ver datos actualizados

### Test de órdenes
- [ ] Ver listado de órdenes
- [ ] Hacer click en una orden
- [ ] Ver detalles y cambiar estado
- [ ] Verificar que se actualiza en BD
- [ ] Invalidate y recargar

### Test de productos
- [ ] Ver listado de productos
- [ ] Crear nuevo producto
- [ ] Editar producto existente
- [ ] Verificar stock
- [ ] Eliminar producto

### Test de sincronización
- [ ] Hacer pago prueba en Stripe
- [ ] Verificar que orden aparece en admin
- [ ] Ver status actualizado en tiempo real
- [ ] Revisar logs en Supabase

### Test de error handling
- [ ] Desconectar internet
- [ ] Ver que muestra error
- [ ] Presionar reintentar
- [ ] Verificar que reconecta

## 📊 PASO 5: VERIFICACIÓN DE DATOS

### Dashboard debe mostrar:
- [ ] Órdenes de hoy (número correcto)
- [ ] Ingresos de hoy (desde Stripe)
- [ ] Usuarios nuevos
- [ ] Productos activos
- [ ] Stock bajo (< 5)
- [ ] Pendientes de envío
- [ ] Ingresos totales históricos
- [ ] Timestamps de última actualización

### Órdenes deben mostrar:
- [ ] Lista de todas las órdenes
- [ ] Estado sincronizado con Stripe
- [ ] Total del pedido correcto
- [ ] Fecha correcta
- [ ] Cambio de estado funciona

### Productos deben mostrar:
- [ ] Lista de productos
- [ ] Precio correcto
- [ ] Stock sincronizado
- [ ] Alertas de stock bajo en rojo

## 🚀 PASO 6: DEPLOYMENT

### En staging
- [ ] Deploy código a staging
- [ ] Test completo en servidor
- [ ] Verificar webhooks funcionan
- [ ] Hacer transacciones Stripe test

### En producción
- [ ] Verificar que usuarios son admins
- [ ] Deploy código
- [ ] Monitorear logs
- [ ] Verificar webhooks productivos
- [ ] Test con órdenes reales

## 📈 PASO 7: MONITOREO

### Logs a revisar
- [ ] Supabase: Dashboard > Logs
- [ ] Stripe: Dashboard > Logs
- [ ] Console: `flutter run --verbose`

### Errores comunes a buscar
```
❌ "Not authorized" → Usuario no es admin
❌ "RLS policy denied" → Problema con permisos
❌ "Stripe session not found" → ID no coincide
❌ "Connection timeout" → Problema de red
```

### Métricas a monitorear
- [ ] Tiempo de carga del dashboard
- [ ] Tasa de error en queries
- [ ] Latencia de sincronización
- [ ] Uso de memoria de app

## 🔄 PASO 8: ROLLBACK (Si hay problemas)

### Si algo falla en producción:
```bash
# 1. Revertir a versión anterior
git checkout HEAD~1 lib/presentation/screens/admin/admin_panel_screen.dart

# 2. Rebuild
flutter clean && flutter pub get

# 3. Deploy anterior
flutter build apk/ios

# 4. Investigar issue
# 5. Hacer fix
# 6. Redeploy
```

## 📚 DOCUMENTOS DE REFERENCIA

- [x] `ADMIN_PANEL_STRIPE_SYNC_GUIDE.md` - Guía completa
- [x] `ADMIN_IMPROVEMENTS_SUMMARY.md` - Resumen de cambios
- [x] `ADMIN_USAGE_EXAMPLES.dart` - Ejemplos de código
- [x] `DATABASE_COMPLETE_BACKUP.sql` - Schema de BD

## 🎉 POST-MIGRACIÓN

- [ ] Actualizar documentación de equipo
- [ ] Capacitar a equipo sobre nuevas funciones
- [ ] Archivar versión vieja
- [ ] Monitorear en producción por 1 semana
- [ ] Resolver problemas encontrados
- [ ] Celebrar 🎊

## 📞 SOPORTE

### Si encuentras problemas:

1. **Revisar logs:**
   ```
   - Supabase Dashboard > Logs
   - Stripe Dashboard > Logs
   - Console del app: flutter run --verbose
   ```

2. **Verificar BD:**
   ```sql
   SELECT * FROM user_profiles WHERE is_admin = true;
   SELECT COUNT(*) FROM orders;
   SELECT COUNT(*) FROM products;
   ```

3. **Revisar providers:**
   - ¿Se invalidan correctamente?
   - ¿Hay errores en consola?
   - ¿Los datos vienen de BD?

4. **Contactar soporte:**
   - Stripe: support@stripe.com
   - Supabase: support@supabase.io
   - Flutter: stackoverflow.com/questions/tagged/flutter

## ✨ TIPS FINALES

### Buenas prácticas:
- ✅ Siempre hacer backup antes de cambios
- ✅ Test en desarrollo primero
- ✅ Deploy a staging antes de producción
- ✅ Monitorear los primeros días
- ✅ Tener rollback plan

### Optimización:
- ✅ Los providers autoDispose liberan memoria
- ✅ Riverpod cachea automáticamente
- ✅ Las queries tienen índices
- ✅ Webhooks son más eficientes que polling

### Seguridad:
- ✅ RLS policies protegen en BD
- ✅ Solo admins acceden
- ✅ Cambios se loguean
- ✅ Webhooks verificados con HMAC

---

**Estado:** ✅ Listo para migración
**Versión:** 2.0
**Fecha:** 29/01/2026
